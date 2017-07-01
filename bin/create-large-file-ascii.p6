#!/usr/bin/env perl6

# note: a run on juvat2 (2016-01-31) with 10 Gb was ~36 minutes

# 100 char string (counting the ending newline)
my $str = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678\n";
my $Gb  = 1_000_000_000;
my $Mb  = 1_000_000;
my $use-gb = False;

my $prog = $*PROGRAM.basename;
if @*ARGS.elems < 2 {
    say qq:to/END/;
    Usage: $prog <file size (int > 0)> <modifier: 'G' or 'M'> [output dir]

END
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
die "FATAL:  Size modifier (G or M) not entered" if not $arg2.defined;
if $arg2 ~~ m:i/^g$/ {
    $use-gb = True;
}
elsif $arg2 ~~ m:i/^m$/ {
    $use-gb = False;
}
else {
    die "FATAL:  Unknown size modifier '$arg2'";
}

my $odir = shift @ARGV;
$odir = '.' if not $odir.defined;

my $typ = 'ascii';
my ($mul, $txt);
if $use-gb {
  $txt = 'Gb';
  $mul = $Gb;
}
else {
  $txt = 'Mb';
  $mul = $Mb;
}
my $ofil = "{$odir}/large-{$siz}-{$txt}-{$typ}-file.txt";

# how many (lines) iterations needed?
my $slen   = $str.chars;
my $nlines = $siz * $mul div $slen;

say "Requested file size: $siz $txt";
say "String size:  $slen";
say "Number lines: $nlines";

my $fp = open($ofil, :w);

for 1 .. $nlines {
  $fp.print($str);
}

say "see output file '$ofil'";
