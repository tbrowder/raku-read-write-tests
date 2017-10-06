#!/usr/bin/env perl6

my $debug = 0;

if !@*ARGS.elems {
  say qq:to/END/;
  Usage: $*PROGRAM.basename <input file>
  END
  exit;
}

my $ifil = shift @*ARGS;

die "FATAL: file '$ifil' not found.\n"
    if !$ifil.IO.f;

my $fsiz = $ifil.IO.s;

say "  File '$ifil' size: $fsiz bytes" if $debug;


my $nlines = 0;
my $nchars = 0;
my $fh = open $ifil, :enc<latin-1>; # recognized alias for iso-8859-1
for $fh.lines -> $line {
    ++$nlines;
    $nchars += $line.chars;
}

if $debug {
    # adjust for newlines being removed
    $nchars += $nlines;
    say "  Normal end.";
    say "  For input file '$ifil':";
    say "    Number lines: $nlines";
    say "    Number chars: $nchars";
}
