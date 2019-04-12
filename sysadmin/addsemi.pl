#!/usr/bin/perl --
#
# addsemi.pl - rlbyrd, 5 April 1999
#
# Does what it says.  Point it add a file and this will add a semicolon at the end of
# lines within.  Particularly suited for handling the output of showgrants.sh to create
# an executable SQL script to duplicate all grants from one instance to another.

open DATA, "$ARGV[0]";

while (<DATA>) {

        $liner=$_;
        if ("$liner" =~ /^#/) {
                print $liner;
        } else {
                chomp($liner);
                print "$liner" . ";\n";
        }
}

close DATA;           
