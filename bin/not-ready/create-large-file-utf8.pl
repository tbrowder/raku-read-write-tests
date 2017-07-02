#!/usr/bin/env perl

# notes:
#   a run on juvat2 (2016-01-31) with 10 Gb was ~2 minutes
#   a run on bigtom (2016-01-31) with 10 Gb was 1m37s

use v5.14; # 'say'

use File::Basename;

die FATAL: make this create a utf8 string like the Perl 6 version";

# 100 char string (counting the ending newline)
my $str = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678\n";
my $Gb  = 1_000_000_000;
my $Mb  = 1_000_000;
my $use_gb = 0;

my $prog = basename($0);
if (!@ARGV) {
  say "Usage: $prog <file size (int > 0)> <modifier: 'G' or 'M'> [output dir]\n";
  exit;
}

# desired size in Mb or Gb
my $siz = shift @ARGV;

die "FATAL: '$siz' is not an integer.\n"
  if $siz =~ /[^\d]+/;
die "FATAL: '$siz' is not positive.\n"
  if $siz < 1;

my $arg2 = shift @ARGV;
die "FATAL:  Size modifier (G or M) not entered" if !defined $arg2;
if ($arg2 =~ /^g$/i) {
    $use_gb = 1;
}
elsif ($arg2 =~ /^m$/i) {
    $use_gb = 0;
}
else {
    die "FATAL: Unknown size modifier '$arg2'";
}

my $odir = shift @ARGV;
$odir = '.' if !defined $odir;

my $typ = 'utf8';
my ($mul, $txt);
if ($use_gb) {
  $txt = 'Gb';
  $mul = $Gb;
}
else {
  $txt = 'Mb';
  $mul = $Mb;
}
my $ofil = "${odir}/large-${siz}-${txt}-${typ}-file.txt";

# how many lines (iterations) needed?
my $slen   = length $str;
my $nlines = $siz * $mul / $slen;

say "Requested file size: $siz $txt";
say "String size:  $slen";
say "Number lines: $nlines";

open my $fp, '>', $ofil
    or die "file '$ofil': $!";

for (1 .. $nlines) {
  print $fp $str;
}

say "see output file '$ofil'";
