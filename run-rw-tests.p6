#!/usr/bin/env perl6

use lib 'lib';
use Getopt::Std;
use Text::More :commify;
use Linux::Proc::Time :time-command;

use RW-TEST;

# test file sizes:
my @S;
#@S = <1m 1g 5g 10g>;
#@S = <1m>;
#@S = <1g>;
#@S = <1m 2 3 4 5>;
#@S = <1m 100>;
@S = <1m 2 3 4 5>;

my $ntrials = 1; # number of times to run each file test and average it

my $run-perl6 = True;
#my $run-perl6 = False; # for speedy testing of this file

# create two dirs if they don't exist
mkdir 'data' if not 'data'.IO ~~ :d;
mkdir 'logs-long' if not 'logs-long'.IO ~~ :d;
mkdir 'logs-short' if not 'logs-short'.IO ~~ :d;

# get host info
my $proc = shell "hostname -s", :out;
my $HOST = $proc.out.slurp-rest;
$HOST .= chomp;
$proc = shell "uname -a", :out;
my $HOSTINFO = $proc.out.slurp-rest;
$HOSTINFO .= chomp;

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

# put all output in two log files
my $stamp = my-date-time-stamp(:short(True));

my $ofil-long  = './logs-long/run-rw-tests-long--' ~ $stamp ~ '.log';
my $ofil-short = './logs-short/run-rw-tests-short-' ~ $stamp ~ '.log';
my $fp  = open $ofil-long, :w;
my $fp2 = open $ofil-short, :w;

my $sdate = my-date-time;
my $start = now;

$fp.say: qq:to/END-A/;
====================================
# Start testing at: $sdate
# Test host: $HOST
# Host info: $HOSTINFO
# Perl 5 version: $p5v
END-A

my @s = $p6v.lines;
my $s = @s.join(' ');
@s = $s.words;
## 'This is Rakudo version 2015.12 built on MoarVM version 2015.12 implementing Perl 6.c.'
my ($rv, $mv, $pv) = (@s[4], @s[9], @s[*-1]);
$pv ~~ s/\.$//;
$fp.say: qq:to/END-B/;
# Perl 6 version: $pv
# Rakudo version: $rv
# MoarVM version: $mv
====================================
END-B

# commands for the various tests
my $P5R = './bin/read-file-test.pl';
my $P5W = './bin/create-large-file.pl';
my $P6R = './bin/read-file-test.p6';
my $P6W = './bin/create-large-file.p6';

my $ntests = 0;
for @S -> $S is copy {
    # get size in Mb or Gb
    my ($sz, $szmod, $nlines) = get-desired-file-sizes($S);

    # used for file names
    my $size-f = $sz ~ '-' ~ $szmod ~ 'b';
    my $size-s = $sz ~ ' ' ~ $szmod ~ 'b';

    my $sdate = my-date-time;
    $fp.say: qq:to/END-C/;
    #***** Working with $size-s...
    # Starting at: $sdate
    END-C

    my $LFIL = './data/large-' ~ $size-f ~ '-file.txt';

    if !$LFIL.IO.f {
	# choose which Perl to create the missing files
	my $wver = 5;
	#my $wver = 6;
	my $wexe = $wver == 5 ?? $P5W !! $P6W;

	$fp.say: qq:to/END-D/;
	#---------------------------------
	# Creating file '$LFIL' with Perl $wver...
	#---------------------------------
	END-D

	my $uts = time-command("$wexe $sz $szmod ./data", :uts(True));
    }

    my ($proc, $s, $p5usec, $p6usec);
    {
	my $p5usec-total = 0;
	for 1..$ntrials -> $nt {
	    $fp.say("  #---------------------------------");
	    $fp.say("  # Start read process, trial $nt of $ntrials...");
	    $fp.say("  #---------------------------------");
	    $fp.say("  Reading file '$LFIL' with Perl 5...");

	    ++$ntests;

	    # get system time (real, user, sys)
	    my ($rts, $rt, $uts, $ut, $sts, $st) = time-command("$P5R $LFIL");
	    $p5usec = sprintf "%.2f", $uts;

	    $p5usec-total += $p5usec;

	    $fp.say("  #---------------------------------");
	    $fp.say("  # End read process:");
	    $fp.say("  #   Real time:   $rt");
	    $fp.say("  #   User time:   $ut ($p5usec s)");
	    $fp.say("  #   System time: $st");
	    $fp.say("  #---------------------------------");
	    $fp.flush;
	}
	$p5usec = $p5usec-total / $ntrials;
	$p5usec = sprintf "%.2f", $p5usec;
    }

    if $run-perl6 {
	my $p6usec-total = 0;
	for 1..$ntrials -> $nt {
	    $fp.say("  #---------------------------------");
	    $fp.say("  # Start read process, trial $nt of $ntrials...");
	    $fp.say("  #---------------------------------");
	    $fp.say("  Reading file '$LFIL' with Perl 6...");

	    ++$ntests;

	    # get system time (real, user, sys)
	    my ($rts, $rt, $uts, $ut, $sts, $st) = time-command("$P6R $LFIL");
	    $p6usec = sprintf "%.2f", $uts;

	    $p6usec-total += $p6usec;

	    $fp.say("  #---------------------------------");
	    $fp.say("  # End read process:");
	    $fp.say("  #   Real time:   $rt");
	    $fp.say("  #   User time:   $ut ($p6usec s)");
	    $fp.say("  #   System time: $st");
	    $fp.say("  #---------------------------------");
	    $fp.flush;
	}
	$p6usec = $p6usec-total / $ntrials;
	$p6usec = sprintf "%.2f", $p6usec;
    }

    my $p6tp5t = sprintf "%.1f", $p6usec/$p5usec;
    $fp.say("  #---------------------------------");
    $fp.say("  # Perl 6 time / Perl 5 time: $p6tp5t");
    $fp.say("  #---------------------------------");

    # check that char and line counts are correct
    $fp.say("  Reading file '$LFIL' with system wc...");
    $proc = shell "wc $LFIL", :out;
    my $wc = $proc.out.slurp-rest;
    $wc .= chomp;
    $fp.say("  $wc");
    $fp.say("#***** End working with $size-s");
    $fp.flush;

    # add a one-liner to the short log
    #| 2016-10-18 | 2016.10-16-geb6907e | 10_000_000_000 | nnn | nnnnn.nn s | nnnnn.nn s | nnn.n |
    my $dts = my-date-time-stamp(:shorter(True));
    $nlines = commify($nlines);
    $fp2.say(sprintf(
	     "| %-10s | %-19s | %17.17s |  %3d   | %8.2f s | %8.2f s | %5.1f |",
	     $dts, $rv, $nlines, $ntrials, $p5usec, $p6usec, $p6tp5t));

}

$fp.say("====================================");
$fp.say("End testing.");
$fp.say("====================================");

my $end   = now;
my $et    = $end - $start;
my $edate = my-date-time;
$s = $ntests > 1 ?? 's' !! '';

my $stret = sprintf "%.2f", $et;

$fp.say("====================================");
$fp.say("$ntests test$s completed.");
$fp.say("WARNING:  No Perl 6 tests were run.") if !$run-perl6;
$fp.say("End time: $edate");
$fp.say("Total elapsed time: $stret sec");
$fp.say("====================================");

say "Normal end.";
say "$ntests test$s completed.";
say "WARNING:  No Perl 6 tests were run." if !$run-perl6;
say "End time: $edate";
say "Total elapsed time: $stret sec";
say qq:to/END-F/;
"See log files:
    '$ofil-long'
    '$ofil-short'

END-F
