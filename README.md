# Perl 6 Read/Write Tests

[![Build Status](https://travis-ci.org/tbrowder/perl6-read-write-tests.svg?branch=master)]
  (https://travis-ci.org/tbrowder/perl6-read-write-tests)

Perl 6 is **very** slow compared to Perl 5 reading text files line by
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
   will be interpreted accordingly.

2. Edit file `run-rw-tests.p6` to set the variable `$ntrials` for
   number of trials desired for each size file

3. Exexute file `run-rw-tests.p6`.  A log will be generated and placed
   in the `logs` subdirectories (which will be created if they don't
   exist).

## Results of recent file read tests

| Date       | Rakudo Version      | File Size (lines) | Trials | Perl 5 RT  | Perl 6 RT  | P6 RT / P5 RT |
| ---        | ---                 | ---:              | ---:   | ---:       | ---:       | ---:  |
| 2016-10-23 | 2016.10-16-geb6907e |            10,000 |    1   |     0.02 s |     0.61 s |  30.5 |
| 2016-10-23 | 2016.10-16-geb6907e |            20,000 |    1   |     0.03 s |     0.75 s |  25.0 |
| 2016-10-23 | 2016.10-16-geb6907e |            30,000 |    1   |     0.03 s |     0.82 s |  27.3 |
| 2016-10-23 | 2016.10-16-geb6907e |            40,000 |    1   |     0.04 s |     0.96 s |  24.0 |
| 2016-10-23 | 2016.10-16-geb6907e |            50,000 |    1   |     0.05 s |     1.07 s |  21.4 |

Notes:

1. See the complete results in log files in the **logs** subdirectories.
2. **RT** - run time
3. When the number of trials is > 1, the RT data are averages over that number.
