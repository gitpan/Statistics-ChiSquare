# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 2 };
use Statistics::ChiSquare;
@coin = (500, 500);
ok(1); # If we made it this far, we're ok.

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

ok(Statistics::ChiSquare::chisquare(@coin),
   "There's a >99% chance, and a <100% chance, that this data is random.");

