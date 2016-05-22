#!/usr/bin/env perl6

# test file sizes:
#my @GB = <0 1 2 3 4 5 6 7 8 9 10>;
my $G = 1;
my $run-perl6 = True;


if !@*ARGS.elems {
  say qq:to/END/;
  Usage: $prog <mode> [debug]

  Modes:
    full  - outputs detailed run data
    short - outputs run data in a short format for easy
              run-to-run comparisons
    test  - outputs just the perl6/perl5 user time ratio
              (the default mode for an unrecognized mode)

  The 'short' and 'full' modes output data to a log file,
    while the 'test' mode outputs results to STDOUT.

  Note you only need to specify the first two chars of a mode.
  END
  exit;
}

my $mode;
for @*ARGS -> $arg {
  given $arg {
    when $_ ~~ /^fu/ { $mode = 'full'  }
    when $_ ~~ /^sh/ { $mode = 'short' }
    when $_ ~~ /^te/ { $mode = 'test'  }
    when $_ ~~ /^de/ { $debug = True   }
  }
}
$mode = 'test' if !$mode;

say "DEBUG: mode is '$mode'...." if $debug;

# use the system 'time' function to collect process time
my $TFIL = '.systime'; # will be overwritten upon each 'time' call
my $TCMD = "time -p -o $TFIL";

# commands for the various tests
my $P5R = './read-file-test.pl';
my $P5W = './create-large-file.pl';
my $P6R = './read-file-test.pl6';
my $P6W = './create-large-file.pl6';

my $LFIL = 'large-' ~ $G ~ '-gb-file.txt';

if !$LFIL.IO.f {
  # choose which Perl to create the missing files
  my $wver = 5;
  #my $wver = 6;
  my $wexe = $wver == 5 ?? $P5W !! $P6W;
  my $proc = shell "$TCMD $wexe $G", :out;
  $s    = $proc.out.slurp-rest;
  $s.=chomp;
  #my @s = $s.words;
}

my ($p5time, $p6time, $p5usec, $p6usec);
{
  if $mode eq 'full' {
    $fp.say("  #---------------------------------");
    $fp.say("  # Start read process...");
    $fp.say("  #---------------------------------");
  }
  my $pstart = now;
  if $mode eq 'full' {
    $fp.say("  Reading file '$LFIL' with Perl 5...");
  }
  $proc = shell "$TCMD $P5R $LFIL", :out;
  $s    = $proc.out.slurp-rest;
  $s.=chomp;

  # get system time (real, user, sys)
  my ($rts, $rt, $uts, $ut, $sts, $st) = read-sys-time($TFIL);
  $p5usec = $uts;

}

  my $pstart = now;
  if $mode eq 'full' {
    $fp.say("  Reading file '$LFIL' with Perl 6...");
  }
  $proc = shell "$TCMD $P6R $LFIL", :out;
  $s    = $proc.out.slurp-rest;
  $s.=chomp;
  if $mode eq 'full' {
    $fp.say($s);
  }

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

  if $mode eq 'full' {
    $fp.say("  #---------------------------------");
    $fp.say("  # End read process - delta time: $pdt$ps");
    $fp.say("  #   Real time:   $rt");
    $fp.say("  #   User time:   $ut");
    $fp.say("  #   System time: $st");
    $fp.say("  #---------------------------------");
    $fp.flush;
  }
}
#my $p6tp5t = sprintf "%.1f", $p6time/$p5time;
my $p6tp5t = sprintf "%.1f", $p6usec/$p5usec;
if $mode eq 'full' {
  $fp.say("  #---------------------------------");
  $fp.say("  # Perl 6 time / Perl 5 time: $p6tp5t");
  $fp.say("  #---------------------------------");

  # check that char and line counts are correct
  $fp.say("  Reading file '$LFIL' with system wc...");
}
$proc = shell "wc $LFIL", :out;
my $wc = $proc.out.slurp-rest;
$wc.=chomp;
if $mode eq 'full' {
  $fp.say("  $wc");
  $fp.say("#***** End working with $G Gb");
  $fp.flush;
}

if $mode eq 'full' {
  $fp.say("====================================");
  $fp.say("End testing.");
  $fp.say("====================================");
}

my $end = now;
my $et = $end - $start;
my $edate = my-date-time;

if $mode eq 'full' {
  $fp.say("====================================");
  $fp.say("test completed.");
  $fp.say("WARNING:  No Perl 6 tests were run.") if !$run-perl6;
  $fp.say("End time: $edate");
  $fp.say("Total elapsed time: $et sec");
}


if $mode eq 'full' {
  my $dt = delta-time($et);
  $dt.=Str;
  $fp.say("Delta time: $dt");
  $fp.say("====================================");

  say "Normal end.";
  say "test completed.";
  say "WARNING:  No Perl 6 tests were run." if !$run-perl6;
  say "End time: $edate";
  say "Total elapsed time: $et sec";
  say "See log file '$ofil'.";
}

# delete the $TFIL unless we're debugging
unlink $TFIL if !$TFIL.IO.f && !$debug;

# if we are in the 'test' mode all we care about
# is the perl6/perl5 user ratio
if $mode eq 'test' {
  print $p6tp5t;
  exit;
}

# if we are in the 'short' mode put some info to the log file
if $mode eq 'short' {
  $fp.say("rakudo version $rv perl6/perl5 ratio $p6tp5t");
  say "See log file '$ofil'.";
  exit;
}
