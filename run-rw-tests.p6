#!/usr/bin/env perl6

use Text::More :commify;

# the following module is not in the ecosystem yet but is available
# at: github.com/tbrowder/Proc-More-Perl6.git:
use Proc::More :time-command, :seconds-to-hms;

use lib <./lib>;
use RW-TEST;

# test file sizes:
my @S;
@S = <1m 1g 5g 10g>; # for publishing, yields (in numbers of lines): 10K, 10M, 50M, 100M
@S = <1m 2m>;        # for development testing, yields (in numbers of lines): 10K, 20K

my $ntrials = 3; # number of times to run each file test and average it
$ntrials = 1;

die "FATAL:  Empty \@S array.\n" if !@S;
die "FATAL:  \$ntrials must be > 0.\n" if $ntrials < 1;

my $rakrel = "2017.04";
if !@*ARGS {
    say qq:to/HERE/;
    Usage: $*PROGRAM.basename curr | prev

      The 'curr' option uses the installed Perl 6 and the 'prev'
      option uses the older Perl in release '$rakrel'.

      Currently the \@S array contains: '{@S.gist}'
      and \$ntrials is set to '{$ntrials}'.
      Edit this file and modify those values to test
      reading files of desired size and number of trials.
    HERE
    exit;
}

my $run-perl6 = True;
$run-perl6 = False; # for speedy testing of this file

my $ver = '';
for @*ARGS -> $arg {
    when /^ :i c / { $ver = 'curr'; }
    when /^ :i p / { $ver = 'prev'; }
    default { die "FATAL:  Unknown arg '$arg'.\n"; } 
}

die "FATAL:  No option entered.\n" if !$ver;

# run the test progs ===========================
my @title;
my @title2;
my @p5-ascii-time;
my @p5-utf8-time;
my @p6-ascii-time;
my @p6-utf8-time;
my @p6-default-time;
for @S.kv -> $i, $str-size {
    my ($size, $size-modifier, $nlines) = get-file-sizes($str-size);
    @title[$i]  = "File size:    $size $size-modifier";
    @title2[$i] = "Number lines: $nlines";

    # file names include their dir: ./data
    my ($ifil-ascii, $ifil-utf8) = get-input-files($size, $size-modifier);
    if !$ifil-ascii.IO.f {
        my $cmd = "bin/create-ascii-file.pl $ifil-ascii";
    }
    if !$ifil-utf8.IO.f {
        my $cmd = "bin/create-utf8-file.p6 $ifil-utf8";
    }

    =begin comment
    # the tests
    # file names include their dir: ./data
    @p5-ascii-time[$i]   = run-read-test();
    @p5-utf8-time[$i]    = run-read-test();
    @p6-ascii-time[$i]   = run-read-test();
    @p6-utf8-time[$i]    = run-read-test();
    @p6-default-time[$i] = run-read-test();
    =end comment

}

# now log results ===========================

=begin comment
# create two dirs if they don't exist
mkdir 'data' if not 'data'.IO.d;
mkdir 'logs-long' if not 'logs-long'.IO.d;
mkdir 'logs-short' if not 'logs-short'.IO.d;

# get host info
my ($HOST, $HOSTINFO) = get-host-info();

# get perl versions
my ($p5v, $p6v, $rv, $nv, $mv) = get-perl-versions();

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
# Perl 6 version: $p6v
# Rakudo version: $rv
# MoarVM version: $mv
====================================
END-A

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

	my $uts = time-command "$wexe $sz $szmod ./data", :uts(True); # original Linux::Proc::Time [now it's the default]
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
	    my ($rts, $rt, $uts, $ut, $sts, $st) = time-command "$P5R $LFIL", :list(True); # good format old and new
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
	    my ($rts, $rt, $uts, $ut, $sts, $st) = time-command "$P6R $LFIL", :list(True); # good format old and new
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
my $shms = seconds-to-hms $stret, :fmt<h>;

$fp.say("====================================");
$fp.say("$ntests test$s completed.");
$fp.say("WARNING:  No Perl 6 tests were run.") if !$run-perl6;
$fp.say("End time: $edate");
$fp.say("Total elapsed time: $stret sec ($shms)");
$fp.say("====================================");

say "Normal end.";
say "$ntests test$s completed.";
say "WARNING:  No Perl 6 tests were run." if !$run-perl6;
say "End time: $edate";
say "Total elapsed time: $stret sec ($shms)";
say qq:to/END-F/;
"See log files:
    '$ofil-long'
    '$ofil-short'

END-F
=end comment
