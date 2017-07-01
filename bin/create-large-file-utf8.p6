#!/usr/bin/env perl6

# note: a run on juvat2 (2016-01-31) with 10 Gb was ~36 minutes

=begin comment
# 100 char string (counting the ending newline)
my $str = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678\n";
=end comment

# 100-byte utf8 string (counting the ending newline)
my $str0 = "\x[2000,2001,2002,2003,2004,2005,2006,2007,2008,2009]"; # 30 bytes
my $str1 = "\x[2000,2001,2002,2003,2004,2005,2006,2007,2008,2009]"; # 30 bytes
my $str2 = "\x[2000,2001,2002,2003,2004,2005,2006,2007,2008,2009]"; # 30 bytes
my $str3 = "123456789\n";                                           # 10 bytes
my $str = $str0 ~ $str1 ~ $str2 ~ $str3;

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

my $odir = shift @*ARGS;
$odir = '.' if not $odir.defined;

my $typ = 'utf8';
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
my $slen   = $str.encode.bytes;
die "FATAL: Line length != 100 bytes (it equals $slen instead)" if $slen != 100;
my $nlines = $siz * $mul div $slen;

say "Requested file size: $siz $txt";
say "String size:  $slen";
say "Number lines: $nlines";

my $fp = open($ofil, :w);

for 1 .. $nlines {
  $fp.print($str);
}

say "see output file '$ofil'";
