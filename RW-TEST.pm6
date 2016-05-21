unit module RW-TEST;

# for local test funcs

sub my-date-time is export {
    my $date = DateTime.now(formatter => {
	    sprintf "%04d-%02d-%02d  %02d:%02d:%05.2f",
	    .year, .month, .day, .hour, .minute, .second});
    return $date;
} # my-date-time

sub my-date-time-stamp is export {
    my $date = DateTime.now(formatter => {
	    # bzr-friendly format (no ':' used)
	    sprintf "%04d-%02d-%02dT%02dh%02dm%05.2fs",
	    .year, .month, .day, .hour, .minute, .second});
    return $date;
} # my-date-time-stamp

sub delta-time($Time) is export {
    my Num $time = $Time.Num;

    my Int $sec-per-min = 60;
    my Int $min-per-hr  = 60;
    my Int $sec-per-hr  = $sec-per-min * $min-per-hr;

    my Int $hr = ($time/$sec-per-hr).Int;
    my Num $sec = $time - ($sec-per-hr * $hr);
    my Int $min = ($sec/$sec-per-min).Int;
    $sec    = $sec - ($sec-per-min * $min);
    return sprintf "%dh%02dm%05.2fs", $hr, $min, $sec;
} # delta-time

sub read-sys-time($time-file) is export {
    my ($rts, $uts, $sts);
    for $time-file.IO.lines -> $line {
       my $typ = $line.words[0];
       my $sec = $line.words[1];
       given $typ {
           when $_ ~~ /real/ {
               $rts = $sec;
           }
           when $_ ~~ /user/ {
               $uts = $sec;
           }
           when $_ ~~ /sys/ {
               $sts = $sec;
           }
       }
    }

    # convert each to hms
    my $rt = delta-time($rts);
    my $ut = delta-time($uts);
    my $st = delta-time($sts);

    # back to the caller
    return $rts, $rt,
           $uts, $ut,
           $sts, $st;
} # read-sys-time
