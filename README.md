# Perl 6 Read/Write Tests

Perl 6 is **very** slow compared to Perl 5 reading text files line by line.
Such line processing is a staple of data processing in use cases such as
analyzing output of many kinds of programs.  An example is the category of
programs known as raytracing, one of which, used heavily
by analysts and scientists, is [BRL-CAD](http://brlcad.org).

This test suite was developed to monitor the progress of Perl 6 versus Perl 5 in closing
the gap of processing an ASCII file of many lines.  The test files are of varying
numbers of lines, each line consisting of 100 characters, including the ending newline.

## Results of recent file read tests

| Date       | Rakudo Version      | File Size (lines) | Perl 5 RT | Perl 6 RT | P6/P5 |
| ---        | ---                 | ---:              | ---:      | ---:      | ---:  |
| 2016-10-18 | 2016.10-16-geb6907e |      1_000_000    |    1.39 s |  12.61 s  | 25.2  |
| 2016-10-18 | 2016.10-16-geb6907e |  6_000_000_000    |   75.47 s | 737.63 s  | 18.2  |

Notes:

1. See the complete results in log files in the **logs** subdirectory.
2. **RT** - run time
