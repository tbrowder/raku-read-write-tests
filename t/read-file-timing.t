use v6;
use Test;
use RW-TEST;

plan 1;

# test file sizes:
my $S = 1;
my $LFIL = './data/large-' ~ $S ~ '-Mb-file.txt';

# use the system 'time' function to collect process time
my $TFIL = './.systime'; # will be overwritten upon each 'time' call
my $TCMD = "time -p -o $TFIL";

# commands for the various tests
my $P5R = './bin/read-file-test.pl';
my $P5W = './bin/create-large-file.pl';
my $P6R = './bin/read-file-test.p6';
my $P6W = './bin/create-large-file.p6';

my ($proc, $s);
if !$LFIL.IO.f {
  # choose which Perl to create the missing files
  my $wver = 5;
  my $wexe = $wver == 5 ?? $P5W !! $P6W;
  $proc = shell "$TCMD $wexe $S", :out;
  $s  = $proc.out.slurp-rest;
  $s .= chomp;
  say "creating file '$LFIL'";
}

my ($p5time, $p6time, $p5usec, $p6usec);

say "reading file '$LFIL' with Perl 5...";
{
  $proc = shell "$TCMD $P5R $LFIL", :out;
  $s  = $proc.out.slurp-rest;
  $s .= chomp;

  # get system time (real, user, sys)
  my ($rts, $rt, $uts, $ut, $sts, $st) = read-sys-time($TFIL);
  $p5usec = $uts;
  say "p5usec: $p5usec";
}

say "reading file '$LFIL' with Perl 6...";
{
  $proc = shell "$TCMD $P6R $LFIL", :out;
  $s  = $proc.out.slurp-rest;
  $s .= chomp;

  # get system time (real, user, sys)
  my ($rts, $rt, $uts, $ut, $sts, $st) = read-sys-time($TFIL);
  $p6usec = $uts;
  say "p6usec: $p6usec";
}

my $p6tp5t = sprintf "%.1f", $p6usec/$p5usec;
say "p6/p5 ratio: $p6tp5t";
# is the perl6/perl5 user ratio
# THE TEST
ok $p6tp5t < 50;
