use v6;
use Test;
use lib <lib ../lib>;
use Proc::More :time-command, :run-command;
use RW-TEST;

plan 2;

# test file sizes:
my $LFILA = './data/large-10-Mb-ascii-file.txt';
my $LFIL8 = './data/large-10-Mb-utf8-file.txt';

# commands for the various tests
my $P5R8 = './bin/read-file-test-utf8.pl';
my $P5RA = './bin/read-file-test-ascii.pl';

my $P6R8 = './bin/read-file-test-utf8.p6';
my $P6RA = './bin/read-file-test-ascii.p6';

if !$LFILA.IO.f {
    mkdir 'data';
    my $W = '../bin/create-large-ascii-file.pl';
    my $cmd = "$W 10 M";
    run-command $cmd, :dir<data>; 
}
if !$LFIL8.IO.f {
    mkdir 'data';
    my $W = '../bin/create-large-utf8-file.p6';
    my $cmd = "$W 10 M";
    run-command $cmd, :dir<data>; 
}

say "reading file '$LFILA' with Perl 5 ascii...";
my $p5useca = time-command("$P5RA $LFILA");
say "Perl 5 ascii read time $p5useca";

say "reading file '$LFIL8' with Perl 5 utf8...";
my $p5usec8 = time-command("$P5R8 $LFIL8");
say "Perl 5 utf8 read time $p5usec8";

say "reading file '$LFILA' with Perl 6 ascii...";
my $p6useca = time-command("$P6RA $LFILA");
say "Perl 6 ascii read time $p6useca";

say "reading file '$LFIL8' with Perl 6 utf8...";
my $p6usec8 = time-command("$P6R8 $LFIL8");
say "Perl 6 utf8 read time $p6usec8";

my $p6tp5ta = sprintf "%.1f", $p6useca/$p5useca;
say "p6/p5 ascii ratio: $p6tp5ta"; # the perl6/perl5 user time ratio

my $p6tp5t8 = sprintf "%.1f", $p6usec8/$p5usec8;
say "p6/p5 utf8 ratio: $p6tp5t8"; # the perl6/perl5 user time ratio

# THE TESTS
ok $p6tp5ta < 50;
ok $p6tp5t8 < 50;
