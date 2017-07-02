# Perl 6 Read/Write Tests

[![Build Status](https://travis-ci.org/tbrowder/perl6-read-write-tests.svg?branch=master)](https://travis-ci.org/tbrowder/perl6-read-write-tests)

Perl 6 is currently slow compared to Perl 5 reading ASCII text
files line by line (although the time differences are not so large
when UTF-8 files are read).  Such line processing is a staple of data
processing in use cases such as analyzing output of many kinds of
programs.  An example is the category of programs known as raytracing,
one of which, used heavily by analysts and scientists, is
[BRL-CAD](http://brlcad.org).

This test suite was developed to monitor the progress of Perl 6 versus
Perl 5 in closing the gap of processing an ASCII or UTF-8 file of many lines.
The test files are of varying numbers of lines, each line consisting
of 100 bytes, including the ending newline.

The tests currently compare Perl 6 versus Perl 5 under the following conditions:

   reading UTF-8 files (Perl 5 using the '<:encoding(UTF-8)' form of open)
   reading ASCII files (native read with both Perl versions)
   reading ASCII files (Perl 6 using the ':enc<ascii>' form of open)

## Running the tests

1. Edit file `run-rw-tests.p6` to set the value of array `@S` to the
   number and size of tests to run.  Note that a bare number will be
   interpreted as Megabytes and a number with an 'M' or 'G' appended
   will be interpreted accordingly. The settings that generate most
   test logs shown on the github site are:

     @S = <1m 1g 5g 10g>; # 10K, 10M, 50M, 100M lines, respectively

     $ntrials = 3;

2. Edit file `run-rw-tests.p6` to set the variable `$ntrials` for
   the number of trials desired for each size file

3. Exexute file `run-rw-tests.p6`.  A log will be generated and placed
   in the `logs` subdirectories (which will be created if they don't
   exist).

## Results of recent file read tests

### Before latest IO improvements

Date: 2017-05-17
File type: ASCII
Rakudo version: 2017.04.3-275-g84502dc
Perl 5 version: 

| File Sz (lines) | Trials | Perl 5 T  | Perl 6 T  | P6T / P5T |
| ---:            | :---:  | ---:       | ---:       | :---: |
|          10,000 |    3   |     0.03 s |     0.86 s |  28.7 |
|      10,000,000 |    3   |     2.73 s |    51.50 s |  18.9 |
|      50,000,000 |    3   |    27.41 s |   410.00 s |  15.0 |
|     100,000,000 |    3   |    66.39 s |   860.56 s |  13.0 |

### After latest IO improvements

Date: 2017-06-29
File type: ASCII
Rakudo version: 2017.06-45-g86e7b2b 
Perl 5 version: 

| File Sz (lines) | Trials | Perl 5 T  | Perl 6 T  | P6T / P5T | Improvement
| ---:            | :---:  | ---:       | ---:       | :---: | :--: |
|          10,000 |    3   |     0.03 s |     0.60 s |  20.0 | 30.3% |
|      10,000,000 |    3   |     2.67 s |    32.27 s |  12.1 | 36.0% |
|      50,000,000 |    3   |    24.37 s |   276.41 s |  11.3 | 24.7% |
|     100,000,000 |    3   |    55.40 s |   582.37 s |  10.5 | 19.2%|

Notes:

1. See the complete results in log files in the **logs** subdirectories.

2. **T** - Time: user time from the GNU `time` program.

3. **Improvement** - (prev P6T/P5T less curr P6T/P5T)/(prev P6T/P5T)

4. When the number of trials is > 1, the RT data are averages over that number.

5. This suite is developed on a Debian system with no consideration to
   it running successfully on any other OS.  Pull requests are
   welcome.
