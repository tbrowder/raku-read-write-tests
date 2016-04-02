#!/usr/bin/env perl

# notes: 
#   a run on juvat2 (2016-01-31) with 10 Gb was ~2 minutes
#   a run on bigtom (2016-01-31) with 10 Gb was 1m37s

use v5.14; # 'say'

use autodie;
use File::Basename;

# 100 char string (counting the ending newline)
my $str = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678\n";
my $Gb  = 1_000_000_000;
my $Mb  = 1_000_000;
my $use_gb = 0;

my $prog = basename($0);
if (!@ARGV) {
  say "Usage: $prog <file size in Mb (an integer > 0)> [g]\n";
  say "  Add a 'g' or 'G' as a second arg for gigabytes.";
  exit;
}

# desired size in Mb or Gb
my $siz = shift @ARGV;

die "FATAL: '$siz' is not an integer.\n"
  if $siz =~ /[^\d]+/;
die "FATAL: '$siz' is not positive.\n"
  if $siz < 1;

my $arg2 = shift @ARGV;
$use_gb = 1 if (defined $arg2 && $arg2 =~ /^g/i);

my ($mul, $txt);
if ($use_gb) {
  $txt = 'Gb';
  $mul = $Gb;
}
else {
  $txt = 'Mb';
  $mul = $Mb;
}
my $ofil = "large-${siz}-${txt}-file.txt";

# how many lines (iterations) needed?
my $slen   = length $str;
my $nlines = $siz * $mul / $slen;

say "Requested file size: $siz $txt";
say "String size:  $slen";
say "Number lines: $nlines";

open my $fp, '>', $ofil;

for (1 .. $nlines) {
  print $fp $str;
}

say "see output file '$ofil'";
