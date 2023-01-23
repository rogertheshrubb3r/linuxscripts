<?php
error_reporting(E_ERROR);
/*
$h[]="www.oopyarhitectura.ro";
$h[]="www.home.ro";
$h[]="www.yahoo.com";
$h[]="www.google.com";
$h[]="www.microsoft.com";
*/

//$h[]="mesh.dl.sf.net";

$hostsfile="sfmirrors.ini";

$outfile="results.txt";

$fh=fopen($hostsfile, "r");
while (!feof($fh)) {
  $line = trim(fgets($fh, 4096));
  if ($line != "" && substr($line, 0, 1) != "#") $h[]=trim($line);
}

$NUMTESTS=3;
$FILETOGET="/xampp/lampp-rh9fix-0.9.9a.tar.gz";

function microtime_float()
{
   list($usec, $sec) = explode(" ", microtime());
   return ((float)$usec + (float)$sec);

}

function timeconn($server, $port=80, $timeout=10) {
global $j, $FILETOGET;

    $time_start = microtime_float();
    $fp = fsockopen($server, $port, $errno, $errstr, $timeout);
    if (!$fp) {
//       echo "ERROR:<br> $errstr ($errno)<br />\n";
       return 0; break; // ??
    } else {

//       $out = "GET / HTTP/1.1\r\n";
       $out = "GET ".$FILETOGET." HTTP/1.1\r\n";
       $out .= "Host: ".$server."\r\n";
       $out .= "Connection: Close\r\n\r\n";
//       $out="HELLO WORLD";
//        echo $out;
       fwrite($fp, $out);
///*
       $fw=fopen($server."/outfile".$j, "w+");
       while (!feof($fp)) {
           //echo 
           fwrite($fw, fgets($fp, 128));
       }
       fclose($fw);
//*/
       fclose($fp);
    }
    $time_end = microtime_float();
    $time = $time_end - $time_start;
    return $time;
}

for ($i=0; $i<sizeof($h); $i++) {
    $maxt=0; $mint=0; $lastt=0;$tt=0;
    printf ("testing %-25s: ", $h[$i]);        

    mkdir ($h[$i]);
    for ($j=0; $j<$NUMTESTS; $j++) {
        $t=timeconn($h[$i]);
        if ($t>$maxt) $maxt=$t;
        if ($t<$mint || $mint==0) $mint=$t;
        $tt+=$t;
    }

    $avgt=$tt/$NUMTESTS;
    $mint=$mint*1000; $maxt=$maxt*1000; $avgt=$avgt*1000; $tt=$tt*1000;

    $line=sprintf ("%9.2f/%9.2f/%9.2f; (%9.2f)\n", $mint, $tt/$NUMTESTS, $maxt, $tt);
    echo $line;
    fwrite($oh, $line);
    $th['time']=$avgt;
    $th['host']=$h[$i];


   $r[]=$th;
//    printf ("%.4f s\n", );
}

sort($r);
echo "\n";
$oh=fopen ($outfile, "w+");
foreach ($r as $key => $val) {
   $line=sprintf ("%9.2f %s\n", $val['time'], $val['host']); // " . $val['host'] . "] = " . $val['time'] . "\n";  
    echo $line;
   fwrite($oh, $line);         
}
fclose ($oh);
?>
