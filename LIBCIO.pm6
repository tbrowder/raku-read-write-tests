unit module LIBCIO;

# attempt to use Libc's read/write functions.

use NativeCall;


#=====================================================
# From: GNU libc, the standard function 'fopen':
# 
# Function: FILE * fopen (const char *filename, const char *opentype)
# 
# The fopen function opens a stream for I/O to the file filename, and
# returns a pointer to the stream.
# 
# The opentype argument is a string that controls how the file is opened
# and specifies attributes of the resulting stream. It must begin with
# one of the following sequences of characters:
# 
#   r - Open an existing file for reading only.
# 
#   w - Open the file for writing only. If the file already exists, it
#       is truncated to zero length. Otherwise a new file is created.
# 
#   m - The file is opened and accessed using mmap. This is only
#       supported with files opened for reading.
# ...
#
#-----------------------------------------------------
sub fopen(Str, Str) returns Pointer is native('fopen') is export { * }
#-----------------------------------------------------
#=====================================================

#=====================================================
# From: GNU libc, the standard function 'fclose':
# 
# Function: int fclose (FILE *stream)
# 
# This function causes stream to be closed and the connection to the
# corresponding file to be broken. Any buffered output is written and
# any buffered input is discarded. The fclose function returns a value
# of 0 if the file was closed successfully, and EOF if an error was
# detected.
# 
# It is important to check for errors when you call fclose to close an
# output stream, because real, everyday errors can be detected at this
# time. For example, when fclose writes the remaining buffered output,
# it might get an error because the disk is full. Even if you know the
# buffer is empty, errors can still occur when closing a file if you are
# using NFS.
#
#-----------------------------------------------------
sub fclose(Pointer) returns int32 is native('fclose') is export { * }
#-----------------------------------------------------
#=====================================================


#=====================================================
# From: GNU libc, the non-standard function 'getline':
# 
# Function: ssize_t getline (char **lineptr, size_t *n, FILE *stream)
# 
# This function reads an entire line from stream, storing the text
# (including the newline and a terminating null character) in a buffer
# and storing the buffer address in *lineptr.
# 
# Before calling getline, you should place in *lineptr the address of a
# buffer *n bytes long, allocated with malloc. If this buffer is long
# enough to hold the line, getline stores the line in this
# buffer. Otherwise, getline makes the buffer bigger using realloc,
# storing the new buffer address back in *lineptr and the increased size
# back in *n. See Unconstrained Allocation.
# 
# If you set *lineptr to a null pointer, and *n to zero, before the
# call, then getline allocates the initial buffer for you by calling
# malloc. This buffer remains allocated even if getline encounters
# errors and is unable to read any bytes.
# 
# In either case, when getline returns, *lineptr is a char * which
# points to the text of the line.
# 
# When getline is successful, it returns the number of characters read
# (including the newline, but not including the terminating null). This
# value enables you to distinguish null characters that are part of the
# line from the null character inserted as a terminator.
# 
# This function is a GNU extension, but it is the recommended way to
# read lines from a stream. The alternative standard functions are
# unreliable.
# 
# If an error occurs or end of file is reached without any bytes read,
# getline returns -1.


#sub getline() returns ssize_t is native(Str) is export { * };
#sub getline() returns size_t is native(Str) is export { * };
#=====================================================


#=====================================================
# From: GNU libc, the standard function 'malloc':
# 
# Function: void * malloc (size_t size)
# 
# This function returns a pointer to a newly allocated block size bytes
# long, or a null pointer if the block could not be allocated.
# 
#=====================================================

#=====================================================
# From: GNU libc, the standard function 'free':
# 
# Function: void free (void *ptr)
# 
# The free function deallocates the block of memory pointed at by ptr.
# 
#=====================================================
