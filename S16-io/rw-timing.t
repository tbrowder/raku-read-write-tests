#!/usr/bin/env perl6

# test file sizes:
#my @GB = <0 1 2 3 4 5 6 7 8 9 10>;
my $G = 1;
my $LFIL = 'large-' ~ $G ~ '-gb-file.txt';
my $mode = 'test';

# use the system 'time' function to collect process time
my $TFIL = '.systime'; # will be overwritten upon each 'time' call
my $TCMD = "time -p -o $TFIL";

# commands for the various tests
my $P5R = './read-file-test.pl';
my $P5W = './create-large-file.pl';
my $P6R = './read-file-test.pl6';
my $P6W = './create-large-file.pl6';

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

my $end = now;
my $et = $end - $start;
my $edate = my-date-time;

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

# delete the $TFIL
unlink $TFIL if $TFIL.IO.f;

# if we are in the 'test' mode all we care about
# is the perl6/perl5 user ratio
print $p6tp5t;
