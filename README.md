# perl6-read-write-tests ##

Perl 6 is **very** slow compared to Perl 5 reading text files line by line.  
SUch line processing is a staple of data processing in use cases such as
analyzing output of many kinds of raytracing programs such as [BRL-CAD](http://brlcad.org).

This test suite was developed to monitor the progress of Perl 6 versus Perl 5 in closing
the gap of processing an ASCII file of many lines.  The test files are of varying
numbers of lines, each line consisting of 100 characters, including the ending newline.

Results of recent tests:

| Date | Rakudo Version | File Size | Perl 5    | Perl 6    | P6/P5 |
|      | Version        |  (Gb)     | Read Time | Read Time |       |
|------|----------------|-----------|-----------|-----------|-------|

