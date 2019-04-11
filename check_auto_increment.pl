#!/usr/bin/env perl
#use strict;
#use warnings;
# Richard L. Byrd, written sometime in the 90s and improved bit by bit over the next 20 years
#
# 2016-01-27: While originally written to take a configfile input on the CLI (--configfile=xxxxx.cfg) I've hacked
# that out of this version.  The only CLI parameteres required are host, username, password.  Hardcoded warning to
# 70% and critical to 85%.  Expects dbhost, dbuser, dbpass on the command line in that order.  See below for details.

use utf8;
use DBI;

use Getopt::Long;

binmode STDOUT, ':encoding(UTF-8)';

our $VERSION = 3;

GetOptions(
    'verbosity=i'  => \(my $verbosity),
    'critical=f'   => \(my $critical),
    'warning=f'    => \(my $warning),
    'dbhost=s'     => \(my $dbhost),
    'dbuser=s'     => \(my $dbuser),
    'dbpass=s'     => \(my $dbpass),
    'configfile=s' => \(my $configfile), );

my %config;

if ($configfile) {
    open my $IN, '<:encoding(UTF-8)', $configfile
        or die "Cannot open '$configfile' for reading: $!";
    while (<$IN>) {
        chomp;
        next unless /\S/;
        next if /^\s*#/;
        if (/^\s*(\w+)\s*=\s*(\S(?:.*\S)?)\s*\z/) {
            $config{$1} = $2;
        }
        else {
            die qq[Cannot parse line "$_" in config file "$configfile" (should be: key=value)\n];
        }
    }
}




$verbosity = $config{verbosity}; #  0;
$warning   = $config{warning}  ; #  0.7;
$critical  = $config{critical} ; #  0.85;
$dbhost    = $ARGV[0]   ; 
$dbuser    = $ARGV[1]   ; 
$dbpass    = $ARGV[2]   ;

$warning=0.7;
$critical=0.85;


my %max = (
    unsigned_bigint    => 18446744073709551615,
    unsigned_int       => 4294967295,
    unsigned_integer   => 4294967295,
    unsigned_smallint  => 65535,
    unsigned_tinyint   => 255,
    unsigned_mediumint => 16777215,
    signed_bigint      => 9223372036854775807,
    signed_int         => 2147483647,
    signed_integer     => 2147483647,
    signed_smallint    => 32767,
    signed_tinyint     => 127,
    signed_mediumint   => 8388607,
);

my $dbh = DBI->connect("dbi:mysql:datatbase=mysql;host=$dbhost", $dbuser, $dbpass, {RaiseError => 1});

my $ai = $dbh->prepare(<<SQL);
SELECT c.table_catalog, c.table_schema, c.table_name, c.column_name, c.data_type, t.auto_increment, c.column_type
    FROM information_schema.columns AS c
    JOIN information_schema.tables  AS t
         ON c.table_schema  = t.table_schema
        AND c.table_name    = t.table_name
    WHERE c.extra LIKE '%auto_increment%'
    ORDER BY c.table_catalog, c.table_schema, c.table_name, c.column_name 
SQL

$ai->execute;

my $has_warnings = 0;
my $has_critical = 0;


my $db = '';

my $max_record;
while (my ($catalog, $database, $table, $column, $type, $auto_increment, $column_type) = $ai->fetchrow_array) {
    next unless defined $auto_increment;
    my $type_with_signed = ( $column_type =~ /unsigned/ ) ? "unsigned_$type" : "signed_$type";
    my $max = $max{$type_with_signed};
    unless ($max) {
        if ($verbosity >= 1) {
            print "Don't know maximal value for data type $type_with_signed";
        }
        next;
    }
    my $fill = $auto_increment / $max;
#    print "RLB: $fill - $critical\n";
    if ($verbosity >= 2) {
        print join "\t", $catalog, $database, $table, $column, $type_with_signed,
        $auto_increment, $fill;
    }
    if ($fill >= $critical) {
        $has_critical++;
        printf "CRITICAL: %s.%s.%s at %.3f (%d/%d)\n", $database, $table, $column, $fill, $auto_increment, $max;
    }
    elsif ($fill >= $warning) {
        $has_warnings++;
        printf "WARNING: %s.%s.%s at %.3f (%d/%d)\n", $database, $table, $column, $fill, $auto_increment, $max;
    }
    if (!$max_record || $max_record->{fill} <= $fill) {
        $max_record = {
            database => $database,
            table        => $table,
            column       => $column,
            value        => $auto_increment,
            max  => $max,
            fill         => $fill,
        };
    }
}
$ai->finish;

if (!$has_warnings && !$has_critical && $max_record) {
    printf "OK (maximal value: : %s.%s.%s at %.3f (%d/%d))\n",  @{$max_record}{qw/database table column fill value max/}; }

if ($has_critical) {
    exit 2;
}
elsif ($has_warnings) {
    exit 1;
}
else {
    exit 0;
}

