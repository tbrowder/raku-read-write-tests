#!/usr/bin/env perl6

use lib '.';

use RW-TEST;

# test file sizes:
#my @GB = <0 1 2 3 4 5 6 7 8 9 10>;
#my @GB = <0 1>;
my @GB = <0>; # a small file for testing this file

my $run-perl6 = True;
#my $run-perl6 = False; # for speedy testing of this file

# get host info
my $proc = shell "hostname -s", :out;
my $HOST = $proc.out.slurp-rest;
$HOST.=chomp;
$proc = shell "uname -a", :out;
my $HOSTINFO = $proc.out.slurp-rest;
$HOSTINFO.=chomp;

# use the system 'time' function to collect process time
my $TFIL = '.systime'; # will be overwritten upon each 'time' call
my $TCMD = "time -p -o $TFIL";
# get perl versions

# perl 5 =====
# one-liner to get perl 5 version:
# $ perl -e  'printf "%vd\n", $^V'
# 5.14.2
$proc = shell "perl -e 'printf \"\%vd\", \$^V'", :out;
my $p5v  = $proc.out.slurp-rest;
#die "DEBUG: Perl 5 version: $p5v";

# perl 6 =====
$proc = shell "perl6 -v", :out;
my $p6v  = $proc.out.slurp-rest;
#die "DEBUG: Perl 6 version: $p6v";

# put all output in a log file
my $stamp = my-date-time-stamp;
my $ofil = 'run-rw-tests-' ~ $stamp ~ '.log';
my $fp = open($ofil, :w);

my $sdate = my-date-time;
my $start = now;
$fp.say("====================================");
$fp.say("# Start testing at: $sdate");
$fp.say("# Test host: $HOST");
$fp.say("# Host info: $HOSTINFO");
$fp.say("# Perl 5 version: $p5v");
my @s = $p6v.lines;
my $s = @s.join(' ');
@s = $s.words;
## 'This is Rakudo version 2015.12 built on MoarVM version 2015.12 implementing Perl 6.c.'
my ($rv, $mv, $pv) = (@s[4], @s[9], @s[*-1]);
$pv ~~ s/\.$//;
#say "# Perl 6 version: $p6v";
#say "# Perl 6 version: $s";
$fp.say("# Perl 6 version: $pv");
$fp.say("# Rakudo version: $rv");
$fp.say("# MoarVM version: $mv");
$fp.say("====================================");

# commands for the various tests
my $P5R = './read-file-test.pl';
my $P5W = './create-large-file.pl';
my $P6R = './read-file-test.pl6';
my $P6W = './create-large-file.pl6';

my $ntests = 0;
for @GB -> $G {
  my $sdate = my-date-time;
  $fp.say("#***** Working with $G Gb...");
  $fp.say("# Starting at: $sdate");
  my $LFIL = 'large-' ~ $G ~ '-gb-file.txt';

  if !$LFIL.IO.f {
    # choose which Perl to create the missing files
    #my $wver = 5;
    my $wver = 6;
    my $wexe = $wver == 5 ?? $P5W !! $P6W;
    $fp.say("  #---------------------------------");
    $fp.say("  # Creating file '$LFIL' with Perl $wver...");
    $fp.say("  #---------------------------------");
    my $proc = shell "$TCMD $wexe $G", :out;
    my $s    = $proc.out.slurp-rest;
    $s.=chomp;
    #my @s = $s.words;
    for $s.lines -> $line {
      $fp.say("  $line");
    }
  }

  my ($proc, $s, $p5time, $p6time, $p5usec, $p6usec);
  {
    $fp.say("  #---------------------------------");
    $fp.say("  # Start read process...");
    $fp.say("  #---------------------------------");
    my $pstart = now;
    $fp.say("  Reading file '$LFIL' with Perl 5...");
    $proc = shell "$TCMD $P5R $LFIL", :out;
    $s    = $proc.out.slurp-rest;
    $s.=chomp;
    $fp.say($s);
    ++$ntests;

    # show some time stats
    my $pend = now;
    my $pet = $pend - $pstart;
    $p5time = $pet;
    my $pets = sprintf "%.2f", $pet;
    my $ps = " ($pets s)";
    my $pdt = delta-time($pet);
    $pdt.=Str;

    # get system time (real, user, sys)
    my ($rts, $rt, $uts, $ut, $sts, $st) = read-sys-time($TFIL);
    $p5usec = $uts;

    $fp.say("  #---------------------------------");
    $fp.say("  # End read process - delta time: $pdt$ps");
    $fp.say("  #   Real time:   $rt");
    $fp.say("  #   User time:   $ut");
    $fp.say("  #   System time: $st");
    $fp.say("  #---------------------------------");
    $fp.flush;
  }

  if $run-perl6 {
    $fp.say("  #---------------------------------");
    $fp.say("  # Start read process...");
    $fp.say("  #---------------------------------");
    my $pstart = now;
    $fp.say("  Reading file '$LFIL' with Perl 6...");
    $proc = shell "$TCMD $P6R $LFIL", :out;
    $s    = $proc.out.slurp-rest;
    $s.=chomp;
    $fp.say($s);
    ++$ntests;

    # show some time stats
    my $pend = now;
    my $pet = $pend - $pstart;
    $p6time = $pet;
    my $pets = sprintf "%.2f", $pet;
    my $ps = " ($pets s)";
    my $pdt = delta-time($pet);
    $pdt.=Str;

    # get system time (real, user, sys)
    my ($rts, $rt, $uts, $ut, $sts, $st) = read-sys-time($TFIL);
    $p6usec = $uts;

    $fp.say("  #---------------------------------");
    $fp.say("  # End read process - delta time: $pdt$ps");
    $fp.say("  #   Real time:   $rt");
    $fp.say("  #   User time:   $ut");
    $fp.say("  #   System time: $st");
    $fp.say("  #---------------------------------");
    $fp.flush;
  }
  #my $p6tp5t = sprintf "%.1f", $p6time/$p5time;
  my $p6tp5t = sprintf "%.1f", $p6usec/$p5usec;
  $fp.say("  #---------------------------------");
  $fp.say("  # Perl 6 time / Perl 5 time: $p6tp5t");
  $fp.say("  #---------------------------------");

  # check that char and line counts are correct
  $fp.say("  Reading file '$LFIL' with system wc...");
  $proc = shell "wc $LFIL", :out;
  my $wc = $proc.out.slurp-rest;
  $wc.=chomp;
  $fp.say("  $wc");
  $fp.say("#***** End working with $G Gb");
  $fp.flush;
}
$fp.say("====================================");
$fp.say("End testing.");
$fp.say("====================================");

my $end = now;
my $et = $end - $start;
my $edate = my-date-time;
$s = $ntests > 1 ?? 's' !! '';

$fp.say("====================================");
$fp.say("$ntests test$s completed.");
$fp.say("WARNING:  No Perl 6 tests were run.") if !$run-perl6;
$fp.say("End time: $edate");
$fp.say("Total elapsed time: $et sec");
my $dt = delta-time($et);
$dt.=Str;
$fp.say("Delta time: $dt");
$fp.say("====================================");

say "Normal end.";
say "$ntests test$s completed.";
say "WARNING:  No Perl 6 tests were run." if !$run-perl6;
say "End time: $edate";
say "Total elapsed time: $et sec";
say "See log file '$ofil'.";
