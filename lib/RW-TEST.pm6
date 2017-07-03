unit module RW-TEST;

# for local test funcs
#my $debug = True;
my $debug = False;

sub get-desired-file-sizes(Str:D $s, UInt $bytes-per-line = 100 --> List) is export {
    # input is the desired file size in megabytes or gigabytes, e.g., '100m'

    my ($size, $size-modifier, $nlines );

    if $s ~~ /^ (\d+) (<[:i mg]>) $/ {
	$size          = +$0;
	$size-modifier = uc ~$1;
    }
    elsif $s ~~ /^ (\d+) $/ {
	$size          = +$0;
	$size-modifier = 'M';
    }
    else {
	die "FATAL: Unknown desired file size '$s'.";
    }

    #say "DEBUG: sz = '$sz'; sm = '$sm'";
    # need nlines
    if $size-modifier eq 'M' {
	$nlines = $size * 1_000_000 div $bytes-per-line;
    }
    elsif $size-modifier eq 'G' {
	$nlines = $size * 1_000_000_000 div $bytes-per-line;
    }
    else {
	die "FATAL: Unknown desired file size modifier '$size-modifier'.";
    }

    return $size, $size-modifier, $nlines;

} # get-desired-file-sizes

sub my-date-time() is export {
    my $date = DateTime.now(formatter => {
	    sprintf "%04d-%02d-%02d  %02d:%02d:%05.2f",
	    .year, .month, .day, .hour, .minute, .second});

    return $date;

} # my-date-time

sub my-date-time-stamp(:$short, :$shorter) is export {
    my $date;
    if $short {
	$date = DateTime.now(formatter => {
	# bzr-friendly format (no ':' used)
	sprintf "%04d%02d%02dT%02dh%02dm%02ds",
	.year, .month, .day, .hour, .minute, .second});
    }
    elsif $shorter {
	$date = DateTime.now(formatter => {
	# bzr-friendly format (no ':' used)
	sprintf "%04d-%02d-%02d",
	.year, .month, .day});
    }
    else {
	$date = DateTime.now(formatter => {
				    # bzr-friendly format (no ':' used)
				    sprintf "%04d-%02d-%02dT%02dh%02dm%05.2fs",
				    .year, .month, .day, .hour, .minute, .second});
    }
    return $date;

} # my-date-time-stamp

sub read-file(
              Str :$size-modifier! where {/:i M|G/},
              UInt:D :$size! where {$size > 0},
              UInt:D :$perl-num! where {/5|6/},
              Str:D :$file-encoding! where {/:i ascii|utf8/},
              Str:D :$exec-encoding! where {/:i ascii|utf8|default/},
             ) {
    # form the input file name
    #   large-{$size}-{$size-modifier}-{$file-encoding}-file.txt
    # form the file reader name
    #   read-file-test-{$exec-encoding}.p[l|6]

    # some restrictions:
    #   Perl 5:
}

sub get-host-info(--> List) is export {
    my ($HOST, $HOSTINFO);

    =begin comment
    my $cmd = "hostname -s";
    my $proc = run $cmd.words, :out;
    my $HOST = $proc.out.slurp(:close);
    $HOST .= chomp;
    $cmd = "uname -a";
    $proc = run $cmd.words, :out;
    my $HOSTINFO = $proc.out.slurp-rest;
    $HOSTINFO .= chomp;
    =end comment

    return $HOST, $HOSTINFO;
}

sub get-perl-versions(--> List) is export {
    my ($p5v, $p6v, $rv, $mv);

    =begin comment
    # perl 5 =====
    # one-liner to get perl 5 version:
    # $ perl -e  'printf "%vd\n", $^V'
    # 5.14.2
    $proc = shell "perl -e 'printf \"\%vd\", \$^V'", :out;
    my $p5v  = $proc.out.slurp-rest;
    #die "DEBUG: Perl 5 version: $p5v";
    # perl 6 =====
    $proc = shell "perl6 -v", :out;
    my $p6v  = $proc.out.slurp-rest;
    #die "DEBUG: Perl 6 version: $p6v";
    my @s = $p6v.lines;
    my $s = @s.join(' ');
    @s = $s.words;
    ## 'This is Rakudo version 2015.12 built on MoarVM version 2015.12 implementing Perl 6.c.'
    my ($rv, $mv, $p6v) = (@s[4], @s[9], @s[*-1]);
    $p6v ~~ s/\.$//;
    =end comment

    return $p5v, $p6v, $rv, $mv;
}
