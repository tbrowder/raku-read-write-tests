#!/bin/sh

PERL6=perl6
TESTS=t/*.t
LIBPATH=.
for t in $TESTS
do
    PERL6LIB=$LIBPATH prove -v --exec=$PERL6 $t
done
