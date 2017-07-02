#!/usr/bin/env perl6

my $debug = False;

if !@*ARGS.elems {
  say qq:to/END/;
  Usage: $*PROGRAM.basename <input file> [lines | split | slurp | getline]

  Options:
    lines   - uses 'IO.lines' (default)
    split   - uses 'IO.split(\"\\nl\")'
    slurp   - uses 'IO.slurp'
    getline - uses GNU libc 'getline'

  Note you only need to specify the first two chars of an option.
  END
  exit;
}

my $ifil = shift @*ARGS;

die "FATAL: file '$ifil' not found.\n"
    if !$ifil.IO.f;

my $fsiz = $ifil.IO.s;

my $method = shift @*ARGS;
$method = 'lines' if !$method.defined;
if $method ~~ /^li/ {
  $method = 'IO.lines';
}
elsif $method ~~ /^sp/ {
  $method = 'IO.split';
}
elsif $method ~~ /^sl/ {
  $method = 'IO.slurp';
}
elsif $method ~~ /^ge/ {
  $method = 'GNU libc getline';
}

if $debug {
    say "  Method: $method";
    say "  File '$ifil' size: $fsiz bytes";
}

my $nlines = 0;
my $nchars = 0;

# use lines method

#my $fp = open $ifil, :r :enc('ascii');
my $fp = open $ifil, :r;
for $fp.lines -> $line {
    ++$nlines;
    $nchars += $line.chars;
    #say "line: '$line'";
}
# adjust for newlines being removed
$nchars += $nlines;

=begin comment
if $method ~~ /lines/ {

  #my $fp = open $ifil, :r :enc('ascii');
  my $fp = open $ifil, :r;
  for $fp.lines -> $line {
    ++$nlines;
    $nchars += $line.chars;
    #say "line: '$line'";
  }
  # adjust for newlines being removed
  $nchars += $nlines;
}
elsif $method ~~ /slurp/ {
  # suggested by Timo
  my @str = split "\n", $ifil.IO.open.slurp-rest;
  for @str -> $line {
    ++$nlines;
    $nchars += $line.chars;
    #say "line: '$line'";
  }
  # adjust for newlines being removed
  $nchars += $nlines;
}
elsif $method ~~ /split/ {
  # suggested by Liz
  for $ifil.IO.open.split("\n") -> $line {
    ++$nlines;
    $nchars += $line.chars;
    #say "line: '$line'";
  }
  # adjust for newlines being removed
  $nchars += $nlines;
}
elsif $method ~~ /getline/ {
  # try NativeCall
  use lib '.';
  # specify the functions to be used
  use LIBCIO :fopen, :fclose, :getline, :malloc;

  # start testing
  # need a special buffer for the input string
  #use NativeCall;
  my $bufsiz = 200;
  #my $buf = malloc($bufsiz);
  # my $buf = CArray[uint8].new($s.encode.list);

  # get a file pointer
  my $mode = "r";
  my $fp = fopen($ifil, $mode);
  #while getline($buf, $bufsiz, $fp) != -1 {
  #  say $buf;
  #}

  # close the file
  fclose($fp);

  die "FATAL:  Option '$method' not yet available";
  for $ifil.IO.open.split("\n") -> $line {
    ++$nlines;
    $nchars += $line.chars;
    #say "line: '$line'";
  }
  # adjust for newlines being removed
  $nchars += $nlines;
}
=end comment

=begin pod
say "  Normal end.";
say "  For input file '$ifil':";
say "    Number lines: $nlines";
say "    Number chars: $nchars";
=end pod
