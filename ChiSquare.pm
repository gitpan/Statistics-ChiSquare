package Statistics::ChiSquare;

use strict;

# ChiSquare.pm
#
# Jon Orwant, orwant@media.mit.edu
#
# 31 Oct 95
#
# Copyright 1995 Jon Orwant.  
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
# 
# Version 0.100.  Module list status is "Rdpf".


require 5.000;

require Exporter;
@Statistics::ChiSquare::ISA = qw( Exporter );

use Carp;

=head1 NAME

C<Statistics::ChiSquare> - How random is your data?

=head1 SYNOPSIS



  use Statistics::ChiSquare;

  

  print chisquare(@actual_occurrences);
  print chisquare_nonuniform([actual_occurrences], [expected_occurrences]);

The Statistics::ChiSquare module is available at a CPAN site near you.

=head1 DESCRIPTION

Suppose you flip a coin 100 times, and it turns up heads 70 times.
I<Is the coin fair?>

Suppose you roll a die 100 times, and it shows 30 sixes.  
I<Is the die loaded?>

In statistics, the B<chi-square> test calculates "how random" a series
of numbers is.  But it doesn't simply say "random" or "not random".
Instead, it gives you a I<confidence interval>, which sets upper and
lower bounds on the likelihood that the variation in your data is due
to chance.  See the examples below.

If you've ever studied elementary genetics, you've probably heard
about Gregor Mendel.  He was a wacky Austrian botanist who discovered
(in 1865) that traits could be inherited in a predictable fashion.  He
performed lots of experiments with cross-fertilizing peas: green peas, yellow
peas, smooth peas, wrinkled peas.  A veritable Brave New World of legumes.

How many fertilizations are needed to be sure that the variations in
the results aren't due to chance?  Well, you can never be entirely
sure.  But the chi-square test tells you I<how sure you should be>.

(As it turns out, Mendel faked his data.  A statistician by the name
of R. A. Fisher used the chi-square test again, in a slightly more
sophisticated way, to show that Mendel was either very very lucky or a
little dishonest.)

There are two functions in this module: chisquare() and
chisquare_nonuniform().  chisquare() expects an array of occurrences:
if you flip a coin seven times, yielding three heads and four tails,
that array is (3, 4).  chisquare_nonuniform() is a bit trickier---more about it later.

Instead of returning the bounds on the confidence interval in a tidy
little two-element array, these functions return an English string.
This was a deliberate design choice---many people misinterpret
chi-square results; the text helps clarify the meaning.  Both
chisquare() and chisquare_nonuniform() return UNDEF if the arguments
aren't "proper".

Upon success, the string returned by chisquare() will always match one
of these patterns:

  There's a >\d+% chance, and a <\d+% chance, that this data is random.

or 

  There's a <\d+% chance that this data is random.

unless there's an error.  Here's one error you should know about:

  (I can't handle \d+ choices without a better table.)

That deserves an explanation.  The "modern" chi-square test uses a
table of values (based on Pearson's approximation) to avoid expensive
calculations.  Thanks to the table, the chisquare() calculation is
quite fast, but there are some collections of data it can't handle,
including any collection with more than 21 slots.  So you can't
calculate the randomness of a 30-sided die.

chisquare_nonuniform() expects I<two> arguments: a reference to an array of actual occurrences followed by a reference to an array of expected occurrences.

chisquare_nonuniform() is used when you expect a nonuniform
distribution of your data; for instance, if you expect twice as many
heads as tails and want to see if your coin lives up to that
hypothesis.  With such a coin, you'd expect 40 heads (and 20 tails) in
60 flips; if you actually observed 42 heads (and 18 tails), you'd call

  chisquare_nonuniform([42, 18], [40, 20])

The strings returned by chisquare_nonuniform() look like this:

  There's a >\d+% chance, and a <\d+% chance, 
       that this data is distributed as you expect.

=head1 EXAMPLES

Imagine a coin flipped 1000 times.  The most likely outcome is 
500 heads and 500 tails:

  @coin = (500, 500);
  print chisquare(@coin);

which prints 

  There's a >99% chance, and a <100% chance, 
       that this data is evenly distributed.


Imagine a die rolled 60 times that shows sixes just a wee bit too often.

  @die1  = (9, 8, 10, 9, 9, 15);
  print chisquare(@die1);

which prints 

  There's a >50% chance, and a <70% chance, 
       that this data is evenly distributed.

Imagine a die rolled 600 times that shows sixes B<way> too often.

  @die2  = (80, 70, 90, 80, 80, 200);
  print chisquare(@die2);

which prints 

  There's a <1% chance that this data is evenly distributed.


How random is rand()?

  srand(time ^ $$);
  @rands = ();
  for ($i = 0; $i < 60000; $i++) {
      $slot = int(rand(6));
      $rands[$slot]++;
  }
  print "@rands\n";
  print chisquare(@rands);


which prints (on my machine):

  
  9987 10111 10036 9975 9984 9907
  There's a >70% chance, and a <90% chance, 
       that this data is evenly distributed.

(So much for pseudorandom number generation.)

All the above examples assume that you're testing a uniform
distribution---testing whether the coin is fair (i.e. a 1:1
distribution), or whether the die is fair (i.e. a 1:1:1:1:1:1
distribution).  That's why chisquare() could be used instead of
chisquare_nonuniform().

Suppose a mother with blood type AB, and a father with blood type Ai
(that is, blood type A, but heterozygous) have one hundred children.
You'd expect 50 kids to have blood type A, 25 to have blood type AB,
and 25 to have blood type B.  Plain old chisquare() isn't good enough
when you expect a nonuniform distribution like 2:1:1.

Let's say that couple has 40 kids with blood type A, 30 with blood type
AB, and 30 with blood type B.  Here's how you'd settle any nagging
questions of paternity:

    @data = (40, 30, 30);
    @dist = (50, 25, 25);
    print chisquare_nonuniform(\@data, \@dist);

which prints 

  There's a >10% chance, and a <30% chance, 
       that this data is distributed as you expect.

=head1 AUTHOR

Jon Orwant

MIT Media Lab

B<orwant@media.mit.edu>

=cut

@Statistics::ChiSquare::EXPORT = qw( chisquare chisquare_nonuniform );

my @chilevels = (100, 99, 95, 90, 70, 50, 30, 10, 5, 1);

my %chitable;

$chitable{1} = [0, 0.00016, 0.0039, 0.016, 0.15, 0.46, 1.07, 2.71, 3.84, 6.64];
$chitable{2} = [0, 0.020,   0.10,   0.21,  0.71, 1.39, 2.41, 4.60, 5.99, 9.21];
$chitable{3} = [0, 0.12,   0.35,   0.58,  1.42, 2.37, 3.67, 6.25, 7.82, 11.34];
$chitable{4} = [0, 0.30,   0.71,   1.06,  2.20, 3.36, 4.88, 7.78, 9.49, 13.28];
$chitable{5} = [0, 0.55,  1.14,   1.61,  3.00, 4.35, 6.06, 9.24, 11.07, 15.09];
$chitable{6} = [0, 0.87, 1.64,   2.20,  3.83, 5.35, 7.23, 10.65, 12.59, 16.81];
$chitable{7} = [0, 1.24, 2.17,   2.83,  4.67, 6.35, 8.38, 12.02, 14.07, 18.48];
$chitable{8} = [0, 1.65, 2.73,   3.49,  5.53, 7.34, 9.52, 13.36, 15.51, 20.09];
$chitable{9} = [0, 2.09, 3.33,   4.17, 6.39, 8.34, 10.66, 14.68, 16.92, 21.67];
$chitable{10} = [0, 2.56, 3.94,  4.86, 7.27, 9.34, 11.78, 15.99, 18.31, 23.21];
$chitable{11} = [0, 3.05, 4.58, 5.58, 8.15, 10.34, 12.90, 17.28, 19.68, 24.73];
$chitable{12} = [0, 3.57, 5.23, 6.30, 9.03, 11.34, 14.01, 18.55, 21.03, 26.22];
$chitable{13} = [0, 4.11, 5.89, 7.04, 9.93, 12.34, 15.12, 19.81, 22.36, 27.69];
$chitable{14} = [0, 4.66, 6.57, 7.79, 10.82, 13.34. 16.22, 21.06, 23.69,29.14];
$chitable{15} = [0, 5.23, 7.26, 8.55, 11.72, 14.34, 17.32, 22.31, 25.00,30.58];
$chitable{16} = [0, 5.81, 7.96, 9.31, 12.62, 15.34, 18.42, 23.54, 26.30,32.00];
$chitable{17} = [0, 6.41, 8.67, 10.09, 13.53, 16.34, 19.51, 24.77,27.59,33.41];
$chitable{18} = [0, 7.00, 9.39, 10.87, 14.44, 17.34, 20.60, 25.99,28.87,34.81];
$chitable{19} = [0, 7.63, 10.12, 11.65, 15.35, 18.34, 21.69,27.20,30.14,36.19];
$chitable{20} = [0, 8.26, 10.85, 12.44, 16.27, 19.34, 22.78,28.41,31.41,37.57];

# chisquare() assumes the expected probability distribution is uniform
# It expects a single array of data; the nth element should hold the number
# of times that selection n was observed.

sub chisquare {
    my @data = @_;
    my $degrees_of_freedom = scalar(@data) - 1;
    my ($chisquare, $num_samples, $expected, $i, $carp) = (0, 0, 0, 0, "");
    exists($chitable{$degrees_of_freedom}) or 
	$carp = "(I can't handle " . scalar(@data) . " choices without a better table.)", 
	carp($carp),
	return undef;
    foreach (@data) { $num_samples += $_ }
    $expected = $num_samples / scalar(@data);
    $expected or carp("(Error: the number of samples sums to 0.)"), return undef;
    foreach (@data) {
	$chisquare += (($_ - $expected) ** 2) / $expected;
    }
    $i = 0;
    foreach (@{$chitable{$degrees_of_freedom}}) {
	if ($chisquare < $_) {
	    return "There's a >$chilevels[$i]% chance, and a <$chilevels[$i-1]% chance, that this data is evenly distributed.";
	}
	$i++;
    }
    return "There's a <$chilevels[$#chilevels]% chance that this data is evenly distributed.";
}

# chisquare_nonuniform() is similar to chisquare(), but handles data
# that you expect to be unequally distributed.  It expects two arguments:
# the first is a reference to the array of data; the second is a reference
# to an array of distributions (which should sum to 1.0).

sub chisquare_nonuniform {
    my ($dataref, $distref) = @_;
    my (@data) = @$dataref;
    my (@dist) = @$distref;
    my ($degrees_of_freedom) = scalar(@data) - 1;
    my ($chisquare, $i, $observed, $expected) = (0, 0, 0, 0);
    exists($chitable{$degrees_of_freedom}) or
	carp("(Can't handle ",scalar(@data)," choices without a better table.)"),
	return undef;
    scalar(@data) && scalar(@data) == scalar(@dist) or 
	carp("(Error: there should be as many data elements as distribution elements.)"), return undef;
    for ($i = 0; $i < @data; $i++) {
	$observed += $data[$i];
	$expected += $dist[$i];
    }
    $observed == $expected or carp("(Error: $observed observed and $expected expected.  Those should be equal.)"), return undef;
    for ($i = 0; $i < @data; $i++) {
	$chisquare += (($data[$i] - $dist[$i]) ** 2) / $dist[$i];
    }
    $i = 0;
    foreach (@{$chitable{$degrees_of_freedom}}) {
	if ($chisquare < $_) {
	    return "There's a >$chilevels[$i]% chance, and a <$chilevels[$i-1]% chance, that this data is distributed as you expect.";
	}
	$i++;
    }
    return "There's a <$chilevels[$#chilevels]% chance that this data is distributed as you expect.";
}    

1;




