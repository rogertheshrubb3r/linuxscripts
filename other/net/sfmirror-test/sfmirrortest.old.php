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
$outfile  ="sfmirrors.txt";

$NUMTESTS=50;
$FILETOGET="/xampp/lampp-rh9fix-0.9.9a.tar.gz";

$fh=fopen($hostsfile, "r");
while (!feof($fh)) {
  $line = trim(fgets($fh, 4096));
  if ($line != "" && substr($line, 0, 1) != "#") $h[]=trim($line);
}

function microtime_float()
{
   list($usec, $sec) = explode(" ", microtime());
   return ((float)$usec + (float)$sec);

}

function timeconn($server, $port=80, $timeout=10) {
// returns array: ['time']=elapsed time (or -1 if error); ['code']=HTTP result code
global $j, $FILETOGET;

    $time_start = microtime_float();
    $fp = fsockopen($server, $port, $errno, $errstr, $timeout);
    if (!$fp) {
//       echo "ERROR:<br> $errstr ($errno)<br />\n";
       $result['time']=-1;
       $result['code']="ERR";
       return $result; break; // ??
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
    $fw=fopen($server."/outfile".$j, "r");
    $result['code']=substr(fgets($fw, 256), 9, 3);
//    echo "[ ".$result['code']." ]\n";
    fclose($fw);
    $result['time']=$time;    
    return $result;
//    return $time;
}

for ($i=0; $i<sizeof($h); $i++) {
    $maxt=0; $mint=0; $lastt=0;$tt=0;
    printf ("%s: \n", $h[$i]);        

    mkdir ($h[$i]);
    for ($j=0; $j<$NUMTESTS; $j++) {
        
        $lastres=timeconn($h[$i]);
        $t=$lastres['time'];
        if ($t>$maxt) $maxt=$t;
        if ($t<$mint || $mint==0) $mint=$t;
        $tt+=$t;
        $line=sprintf("%8.2f %s\n", $lastres['time'], $lastres['code']);
        echo $line; fwrite($oh, $line);
    }

    $avgt=$tt/$NUMTESTS;
    $mint=$mint*1000; $maxt=$maxt*1000; $avgt=$avgt*1000; $tt=$tt*1000;

    switch ($lastres['code']) {
    case 200:
        $err=""; break;
    case 302:
        $err=$lastres['code']." *"; break;
    case 404:
        $err=$lastres['code']." ****"; break;
    case "ERR":
        $err=$lastres['code']." *****"; break;
    default:
        $err=$lastres['code']." ?"; break;
    }

    

    $line=sprintf ("%-25s: %8.2f/%8.2f/%8.2f (%9.2f) %s\n", $h[$i], $mint, $tt/$NUMTESTS, $maxt, $tt, $err);
    echo $line; fwrite($oh, $line);

    $th['err']=$err;
    $th['time']=$avgt;
    $th['totalime']=$tt;
    $th['host']=$h[$i];

   $r[]=$th;
//    printf ("%.4f s\n", );
}

sort($r);
echo "\n";
$oh=fopen ($outfile, "w+");
foreach ($r as $key => $val) {
   $line=sprintf ("%-10s %8.2f %9.2f %s\n", $val['err'], $val['time'], $val['totalime'], $val['host']); // " . $val['host'] . "] = " . $val['time'] . "\n";  
   echo $line; fwrite($oh, $line);         
}
fclose ($oh);
?>
