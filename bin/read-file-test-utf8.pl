#!/usr/bin/env perl

use v5.14; # 'say'
# need to read with utf8 same as Perl 6
use open IO => ':endoding(UTF-8)';

my $debug = 0;

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

say "  File '$ifil' size: $fsiz bytes" if $debug;

open my $fp, '<', $ifil
    or die "file: '$ifil': $!";

my $nlines = 0;
my $nchars = 0;
while (defined(my $line = <$fp>)) {
  chomp $line;
  ++$nlines;
  $nchars += length $line;
}

if ($debug) {
    # adjust for newlines being removed
    $nchars += $nlines;
    say "  Normal end.";
    say "  For input file '$ifil':";
    say "    Number lines: $nlines";
    say "    Number chars: $nchars";
}
