unit module LIBCIO;

# attempt to use Libc's read/write functions.

use NativeCall;

#sub getline() returns ssize_t is native(Str) is export { * };
sub getline() returns size_t is native(Str) is export { * };

