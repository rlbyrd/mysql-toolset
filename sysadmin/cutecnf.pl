#!/usr/bin/perl
#
# cutecnf - RL Byrd, 12 June 1997
# Yes, I am OCD.  
# This little script, when pointed at a my.cnf file (or any configuration file with #-based commenting
# and key/value pairs separated by the equal sign) will reformat the file, lining the equals signs up
# on column 35 by default, removing extra blank lines, etc.  Requires at least one parameter, the filename,
# and will accept a second parameter if one wishes to change the default alignment column.
#


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}



# Expect a filename on the command line and an optional column number
$fname=$ARGV[0];
$colnum=$ARGV[1];

if ("$fname" eq "" ) {
  print "\nUSAGE: cutcnf <filename> [columnNumber]\n     filename is required; columnNumber is optional and defaults to 35 if omitted.\n\n";
  exit 0;
}

if ("$colnum" eq "") {
  $colnum=35;
}

$cnt=0;

open DATA, "$fname";

while (<DATA>) {

        $cnt++;
        $liner=$_;
        if ("$liner" =~ /^#/) {
                if ("$cnt" == 1) { print "$liner\n"; } else { print "\n$liner" };
        } elsif ("$liner" =~ /^\[/) {
                if ("$cnt" == 1) { print "$liner"; } else { print "\n$liner" };
        } elsif (trim($liner) eq "" ) {
          #do nothing
          
        } else {
                ($a,$b)=split("=",$liner);
                $key=trim($a);
                $value=trim($b);
                $keylen=length $key;
                $numspaces=($colnum - $keylen);
                print "$key";
                print " " x $numspaces;
                print "= ";
                print "$value\n";
                
                
        }
}

close DATA;




