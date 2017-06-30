use v6;
use Test;
use lib <lib ../lib>;
use Proc::More :time-command;
use RW-TEST;

plan 1;

# test file sizes:
my $LFIL = './data/large-1-Mb-file.txt';

# commands for the various tests
my $P5R = './bin/read-file-test-utf8.pl';
my $P5W = './bin/create-large-file.pl';
my $P6R = './bin/read-file-test-utf8.p6';

if !$LFIL.IO.f {
    my $proc = shell "$P5W $LFIL";
}

say "reading file '$LFIL' with Perl 5...";
my $p5usec = time-command("$P5R $LFIL");
say "Perl 5 read time $p5usec";

say "reading file '$LFIL' with Perl 6...";
my $p6usec = time-command("$P6R $LFIL");
say "Perl 6 read time $p6usec";

my $p6tp5t = sprintf "%.1f", $p6usec/$p5usec;
say "p6/p5 ratio: $p6tp5t"; # the perl6/perl5 user time ratio

# THE TEST
ok $p6tp5t < 50;
