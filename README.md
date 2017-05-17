# Perl 6 Read/Write Tests

[![Build Status](https://travis-ci.org/tbrowder/perl6-read-write-tests.svg?branch=master)]
  (https://travis-ci.org/tbrowder/perl6-read-write-tests)

Perl 6 is currently **very** slow compared to Perl 5 reading text files line by
line.  Such line processing is a staple of data processing in use
cases such as analyzing output of many kinds of programs.  An example
is the category of programs known as raytracing, one of which, used
heavily by analysts and scientists, is [BRL-CAD](http://brlcad.org).

This test suite was developed to monitor the progress of Perl 6 versus
Perl 5 in closing the gap of processing an ASCII file of many lines.
The test files are of varying numbers of lines, each line consisting
of 100 characters, including the ending newline.

## Running the tests

1. Edit file `run-rw-tests.p6` to set the value of array `@S` to the
   number and size of tests to run.  Note that a bare number will be
   interpreted as Megabytes and a number with an 'M' or 'G' appended
   will be interpreted accordingly. The settings that generate the
   test logs shown on the github site are:

     @S = <1m 1g 5g 10g>; # 10K, 10M, 50M, 100M lines, respectively
     $ntrials = 3;

2. Edit file `run-rw-tests.p6` to set the variable `$ntrials` for
   the number of trials desired for each size file

3. Exexute file `run-rw-tests.p6`.  A log will be generated and placed
   in the `logs` subdirectories (which will be created if they don't
   exist).

## Results of recent file read tests

| Date       | Rakudo Version      | File Size (lines) | Trials | Perl 5 RT  | Perl 6 RT  | P6 RT / P5 RT |
| ---        | ---                 | ---:              | :---:  | ---:       | ---:       | :---: |
| 2016-10-23 | 2016.10-16-geb6907e |            10,000 |    1   |     0.02 s |     0.73 s |  36.5 |
| 2016-10-23 | 2016.10-16-geb6907e |        10,000,000 |    1   |     2.74 s |    72.31 s |  26.4 |
| 2016-10-23 | 2016.10-16-geb6907e |        50,000,000 |    1   |    23.65 s |   582.67 s |  24.6 |
| 2016-10-23 | 2016.10-16-geb6907e |       100,000,000 |    1   |    58.92 s |  1189.56 s |  20.2 |

Notes:

1. See the complete results in log files in the **logs** subdirectories.

2. **RT** - Run Time: user time from the GNU `time` program.

3. When the number of trials is > 1, the RT data are averages over that number.

4. This suite is developed on a Debian system with no consideration to
   it running successfully on any other OS.  Pull requests are
   welcome.
