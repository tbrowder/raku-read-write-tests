#!/usr/bin/env perl6

my $ifil = 'small-file.txt';

use NativeCall;

# Function: ssize_t getline (char **lineptr, size_t *n, FILE *stream)
sub getline(CArray[uint32] is rw, uint32 is rw, Pointer) returns int32 is native(Str) { * }
# Function: void * malloc (size_t size)
sub malloc(uint32) returns Pointer is native(Str) { * }
# Function: void free (void *ptr)
sub free(Pointer) is native(Str) { * }
# Function: int fclose (FILE *stream)
sub fclose(Pointer) returns int32 is native(Str) { * }
# Function: FILE * fopen (const char *filename, const char *opentype)
sub fopen(Str, Str) returns Pointer is native(Str) { * }

# need a special buffer for the input string

my $buf = CArray[uint32].new;
my $bufsiz = 200;
$buf[$bufsiz - 1] = 200; # extend the array to 200 items

# get a file pointer
my $mode = 'r';
my $fp = fopen($ifil, $mode);
while getline($buf, $bufsiz, $fp) != -1 {
  say $buf;
}

# close the file
fclose($fp);
