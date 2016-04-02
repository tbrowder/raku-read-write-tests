#!/usr/bin/env perl

# notes: 
#   a run on juvat2 (2016-01-31) with 10 Gb input file was 2m10s
#   a run on bigtom (2016-01-31) with 10 Gb input file was 1m29s
#   the time for 'wc' on juvat2 was 1m57s
#   the time for 'wc' on bigtom was 1m30s

use v5.14; # 'say'

use autodie;

if (!@ARGV) {
  print <<"HERE";
Usage: $0 <input file>
HERE

  exit;
}

my $ifil = shift @ARGV;

die "FATAL: file '$ifil' not found.\n"
    if !-f $ifil;

my $fsiz = -s $ifil;

say "  File '$ifil' size: $fsiz bytes";

open my $fp, '<', $ifil;

my $nlines = 0;
my $nchars = 0;
while (defined(my $line = <$fp>)) {
  chomp $line;
  ++$nlines;
  $nchars += length $line;
}

# adjust for newlines being removed
$nchars += $nlines;

say "  Normal end.";
say "  For input file '$ifil':";
say "    Number lines: $nlines";
say "    Number chars: $nchars";
