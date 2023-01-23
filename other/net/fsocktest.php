<?php
/*
$h[]="www.oopyarhitectura.ro";
$h[]="www.home.ro";
$h[]="www.yahoo.com";
$h[]="www.google.com";
$h[]="www.microsoft.com";
*/

$h[]="mesh.dl.sf.net";

$fh=fopen("hostlist.txt", "r");
while (!feof($fh)) {
  $line = trim(fgets($fh, 4096));
  if ($line != "") $h[]=$line;
}

$NUMTESTS=5;

function microtime_float()
{
   list($usec, $sec) = explode(" ", microtime());
   return ((float)$usec + (float)$sec);

}

function timeconn($server, $port=80, $timeout=10) {
    $time_start = microtime_float();
    $fp = fsockopen($server, $port, $errno, $errstr, $timeout);
    if (!$fp) {
       echo "ERROR:<br> $errstr ($errno)<br />\n";
       return -1; break; // ??
    } else {
/*
       $out = "GET / HTTP/1.1\r\n";
       $out .= "Host: www.example.com\r\n";
       $out .= "Connection: Close\r\n\r\n";
*/

       $out="HELLO WORLD";
       fwrite($fp, $out);
/*
       while (!feof($fp)) {
           echo fgets($fp, 128);
       }
*/
       fclose($fp);
    }
    $time_end = microtime_float();
    $time = $time_end - $time_start;
    return $time;
}

for ($i=0; $i<sizeof($h); $i++) {
    $maxt=0; $mint=0; $lastt=0;$tt=0;
    printf ("testing %-25s: ", $h[$i]);        
    for ($j=0; $j<$NUMTESTS; $j++) {
        $t=timeconn($h[$i]);
        if ($t>$maxt) $maxt=$t;
        if ($t<$mint || $mint==0) $mint=$t;
        $tt+=$t;
    }
    $avgt=$tt/$NUMTESTS;
    $mint=$mint*1000; $maxt=$maxt*1000; $avgt=$avgt*1000; $tt=$tt*1000;

    printf ("%9.2f/%9.2f/%9.2f; (%9.2f)\n", $mint, $tt/$NUMTESTS, $maxt, $tt);
//    printf ("%.4f s\n", );
}
?>
