#!/usr/bin/env perl6

# note: a run on juvat2 (2016-01-31) with 10 Gb was ~36 minutes

# 100 char string (counting the ending newline)
my $str = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678\n";
my $Gb  = 1_000_000_000;
my $Mb  = 1_000_000;
my $use_gb = 0;

my $prog = $*PROGRAM.basename;
if !@*ARGS.elems {
  say "Usage: $prog <file size in Gb (an integer > 0)> [g]]\n";
  say "  Add a 'g' or 'G' as a second arg for gigabytes.";
  exit;
}

# desired size in Mb or Gb
my $siz = shift @*ARGS;
$siz .= Int;
#say $siz.WHAT;

die "FATAL: '$siz' is not an integer.\n"
  if $siz.WHAT !~~ Int;
die "FATAL: '$siz' is not positive.\n"
  if $siz < 1;

my $arg2 = shift @*ARGS;
$use_gb = 1 if $arg2 && $arg2 ~~ m:i/^g/;

my ($mul, $txt);
if $use_gb {
  $txt = 'Gb';
  $mul = $Gb;
}
else {
  $txt = 'Mb';
  $mul = $Mb;
}
my $ofil = "large-{$siz}-{$txt}-file.txt";

# how many (lines) iterations needed?
my $slen   = $str.chars;
my $nlines = $siz * $mul / $slen;

say "Requested file size: $siz $txt";
say "String size:  $slen";
say "Number lines: $nlines";

my $fp = open($ofil, :w);

for 1 .. $nlines {
  $fp.print($str);
}

say "see output file '$ofil'";
