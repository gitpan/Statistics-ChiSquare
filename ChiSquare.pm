package Statistics::ChiSquare;

# ChiSquare.pm
#
# Jon Orwant, orwant@media.mit.edu
#
# 31 Oct 95, revised Mon Oct 18 12:16:47 1999, and again November 2001
# to fix an off-by-one error
#
# Copyright 1995, 1999, 2001 Jon Orwant.  All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
# 
# Version 0.3.  Module list status is "Rdpf"

use strict;
use vars qw($VERSION @ISA @EXPORT);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(chisquare);

$VERSION = '0.3';

my @chilevels = (100, 99, 95, 90, 70, 50, 30, 10, 5, 1);
my %chitable = ();

# assume the expected probability distribution is uniform
sub chisquare {
    my @data = @_;
    @data = @{$data[0]} if @data == 1 and ref($data[0]);
    my $degrees_of_freedom = scalar(@data) - 1;
    my ($chisquare, $num_samples, $expected, $i) = (0, 0, 0, 0);
    if (! exists($chitable{$degrees_of_freedom})) {
	return "I can't handle ", scalar(@data), 
	" choices without a better table.";
    }
    foreach (@data) { $num_samples += $_ }
    $expected = $num_samples / scalar(@data);
    return "There's no data!" unless $expected;
    foreach (@data) {
	$chisquare += (($_ - $expected) ** 2) / $expected;
    }
    foreach (@{$chitable{$degrees_of_freedom}}) {
	if ($chisquare < $_) {
	    return "There's a >$chilevels[$i+1]% chance, and a <$chilevels[$i]% chance, that this data is random.";
	}
	$i++;
    }
    return "There's a <$chilevels[$#chilevels]% chance that this data is random.";
}

$chitable{1} = [0.00016, 0.0039, 0.016, 0.15, 0.46, 1.07, 2.71, 3.84, 6.64];
$chitable{2} = [0.020,   0.10,   0.21,  0.71, 1.39, 2.41, 4.60, 5.99, 9.21];
$chitable{3} = [0.12,    0.35,   0.58,  1.42, 2.37, 3.67, 6.25, 7.82, 11.34];
$chitable{4} = [0.30,    0.71,   1.06,  2.20, 3.36, 4.88, 7.78, 9.49, 13.28];
$chitable{5} = [0.55,    1.14,   1.61,  3.00, 4.35, 6.06, 9.24, 11.07, 15.09];
$chitable{6} = [0.87,    1.64,   2.20,  3.83, 5.35, 7.23, 10.65, 12.59, 16.81];
$chitable{7} = [1.24,    2.17,   2.83,  4.67, 6.35, 8.38, 12.02, 14.07, 18.48];
$chitable{8} = [1.65,    2.73,   3.49,  5.53, 7.34, 9.52, 13.36, 15.51, 20.09];
$chitable{9} = [2.09,    3.33,   4.17, 6.39, 8.34, 10.66, 14.68, 16.92, 21.67];
$chitable{10} = [2.56,   3.94,   4.86, 7.27, 9.34, 11.78, 15.99, 18.31, 23.21];
$chitable{11} = [3.05,   4.58,  5.58, 8.15, 10.34, 12.90, 17.28, 19.68, 24.73];
$chitable{12} = [3.57,   5.23, 6.30, 9.03, 11.34, 14.01, 18.55, 21.03, 26.22];
$chitable{13} = [4.11,   5.89, 7.04, 9.93, 12.34, 15.12, 19.81, 22.36, 27.69];
$chitable{14} = [4.66,   6.57, 7.79, 10.82, 13.34, 16.22, 21.06, 23.69, 29.14];
$chitable{15} = [5.23,   7.26, 8.55, 11.72, 14.34, 17.32, 22.31, 25.00, 30.58];
$chitable{16} = [5.81,   7.96, 9.31, 12.62, 15.34, 18.42, 23.54, 26.30, 32.00];
$chitable{17} = [6.41,  8.67, 10.09, 13.53, 16.34, 19.51, 24.77, 27.59, 33.41];
$chitable{18} = [7.00,  9.39, 10.87, 14.44, 17.34, 20.60, 25.99, 28.87, 34.81];
$chitable{19} = [7.63, 10.12, 11.65, 15.35, 18.34, 21.69, 27.20, 30.14, 36.19];
$chitable{20} = [8.26, 10.85, 12.44, 16.27, 19.34, 22.78, 28.41, 31.41, 37.57];

1;
__END__

=head1 NAME

C<Statistics::ChiSquare> - How random is your data?

=head1 SYNOPSIS

    use Statistics::Chisquare;

    print chisquare(@array_of_numbers);

Statistics::ChiSquare is available at a CPAN site near you.

=head1 DESCRIPTION

Suppose you flip a coin 100 times, and it turns up heads 70 times.
I<Is the coin fair?>

Suppose you roll a die 100 times, and it shows 30 sixes.  
I<Is the die loaded?>

In statistics, the B<chi-square> test calculates "how random" a series
of numbers is.  But it doesn't simply say "yes" or "no".  Instead, it
gives you a I<confidence interval>, which sets upper and lower bounds
on the likelihood that the variation in your data is due to chance.
See the examples below. 

If you've ever studied elementary genetics, you've probably heard
about Georg Mendel.  He was a wacky Austrian botanist who discovered
(in 1865) that traits could be inherited in a predictable fashion.  He
did lots of experiments with cross breeding peas: green peas, yellow
peas, smooth peas, wrinkled peas.  A veritable Brave New World of legumes.

But Mendel faked his data.  A statistician by the name of R. A. Fisher used
the chi-square test to prove it.

There's just one function in this module: chisquare().  Instead of
returning the bounds on the confidence interval in a tidy little
two-element array, it returns an English string.  This was a deliberate
design choice---many people misinterpret chi-square results, and the
string helps clarify the meaning. 

The string returned by chisquare() will always match one of these patterns:

  "There's a >\d+% chance, and a <\d+% chance, that this data is random."

or 

  "There's a <\d+% chance that this data is random."

or 

  "I can't handle \d+ choices without a better table."


That last one deserves a bit more explanation.  The "modern"
chi-square test uses a table of values (based on Pearson's
approximation) to avoid expensive calculations.  Thanks to the table,
the chisquare() calculation is very fast, but there are some
collections of data it can't handle, including any collection with more
than 21 slots.  So you can't calculate the randomness of a 30-sided
die.  

=head1 EXAMPLES

Imagine a coin flipped 1000 times.  The most likely outcome is 
500 heads and 500 tails:

  @coin = (500, 500);
  print chisquare(@coin);

prints "There's a >90% chance, and a <100% chance, that this data is random.


Imagine a die rolled 60 times that shows sixes just a wee bit too often.

  @die1  = (8, 7, 9, 8, 8, 20);
  print chisquare(@die1);

prints "There's a >1% chance, and a <5% chance, that this data is random.

Imagine a die rolled 600 times that shows sixes B<way> too often.

  @die2  = (80, 70, 90, 80, 80, 200);
  print chisquare(@die2);

prints "There's a <1% chance that this data is random."


How random is rand()?

  srand(time ^ $$);
  @rands = ();
  for ($i = 0; $i < 60000; $i++) {
      $slot = int(rand(6));
      $rands[$slot]++;
  }
  print "@rands\n";
  print chisquare(@rands);

    
prints (on my machine)


  10156 10041 9991 9868 10034 9910
  There's a >10% chance, and a <50% chance, that this data is random.

So much for pseudorandom number generation.

=head1 AUTHOR

Jon Orwant

Readable Publications, Inc.

orwant@oreilly.com

=cut
