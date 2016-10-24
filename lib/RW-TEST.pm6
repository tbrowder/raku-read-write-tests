unit module RW-TEST;

# for local test funcs
#my $debug = True;
my $debug = False;

sub get-desired-file-sizes(Str:D $s, UInt $chars-per-line = 100) returns List is export {
    # input is the desired file size in megabytes or gigabytes
    # file is
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
	$nlines = $size * 1_000_000 div $chars-per-line;
    }
    elsif $size-modifier eq 'G' {
	$nlines = $size * 1_000_000_000 div $chars-per-line;
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

sub delta-time-hms($Time) returns Str is export {
    #say "DEBUG exit: Time: $Time";
    #exit;

    my Num $time = $Time.Num;

    my Int $sec-per-min = 60;
    my Int $min-per-hr  = 60;
    my Int $sec-per-hr  = $sec-per-min * $min-per-hr;

    my Int $hr  = ($time/$sec-per-hr).Int;
    my Num $sec = $time - ($sec-per-hr * $hr);
    my Int $min = ($sec/$sec-per-min).Int;

    $sec = $sec - ($sec-per-min * $min);

    return sprintf "%dh%02dm%05.2fs", $hr, $min, $sec;
} # delta-time-hms

sub read-sys-time($time-file, :$uts) is export {
    say "DEBUG: time-file '$time-file'" if $debug;
    my ($Rts, $Uts, $Sts);
    for $time-file.IO.lines -> $line {
	say "DEBUG: line: $line" if $debug;

	my $typ = $line.words[0];
	my $sec = $line.words[1];
	given $typ {
            when $_ ~~ /real/ {
		$Rts = sprintf "%.3f", $sec;
		say "DEBUG: rts: $Rts" if $debug;
            }
            when $_ ~~ /user/ {
		$Uts = sprintf "%.3f", $sec;
		say "DEBUG: uts: $Uts" if $debug;
            }
            when $_ ~~ /sys/ {
		$Sts = sprintf "%.3f", $sec;
		say "DEBUG: sts: $Sts" if $debug;
            }
	}
    }

    # convert each to hms
    my $rt = delta-time-hms($Rts);
    my $ut = delta-time-hms($Uts);
    my $st = delta-time-hms($Sts);

    # back to the caller
    return $Uts if $uts;
    return $Rts, $rt,
           $Uts, $ut,
           $Sts, $st;
} # read-sys-time

sub time-command(Str:D $cmd, :$uts) is export {
    # runs the input cmd using the system 'time' function and returns
    # the process times shown below

    use File::Temp;
    # get a temp file (File::Find)
    my ($filename, $filehandle);
    if !$debug {
	($filename, $filehandle) = tempfile;
    }
    else {
	($filename, $filehandle) = tempfile(:tempdir('./tmp'), :!unlink);
    }
    my $TCMD = "time -p -o $filename";
    my $proc = shell "$TCMD $cmd"; #, :out;

    if $uts {
        return read-sys-time(:uts(True), $filename);
    }
    else {
        return read-sys-time($filename);
    }

} # time-command

sub commify($num) is export {
    # translated from Perl Cookbook, 2e, Recipe 2.16
    say "DEBUG: input '$num'" if $debug;
    my $text = $num.flip;
    say "DEBUG: input flipped '$text'" if $debug;
    #$text =~ s:g/(\d\d\d)(?=\d)(?!\d*\.)/$0,/; # how to do in Perl 6?

    $text ~~ s:g/ (\d\d\d) <?before \d> <!before \d*\.> /$0,/;

    # don't forget to flip back to the original
    $text .= flip;
    say "DEBUG: commified output '$text'" if $debug;

    return $text;

} # commify
