<?php
error_reporting(E_ERROR);
/*
$h[]="www.home.ro";
*/

$NUMTESTS=10;
//$FILETOGET="/xampp/lampp-rh9fix-0.9.9a.tar.gz"; // <~2k
$FILETOGET = "/sevenzip/7za427.zip"; // ~300k
//$FILETOGET = "/sevenzip/7z425_src_extra.tar.bz2"; // ~100k

$hostsfile = "sfmirrors.ini";
$outfile   = "sfmirrors.txt";

$TMPDIR    = "/tmp";

$VERBOSE   = "yes";
$DBG     = "no";

// add testing order: TODO
// random=test each host random in each test;
// repeat=test each host once, then repeat as necessary
// dumb=test each host N times, then go to next host
//$order="random";
$order="repeat"; 

function microtime_float()
{
   list($usec, $sec) = explode(" ", microtime());
   return ((float)$usec + (float)$sec);

}
// ------------------------------- FUNCTIONS ------------------------------- //
// ------------------------------------------------------------------------- //
function timeconn($server, $port=80, $timeout=10) {
/*
returns an array: 
    result['time']        = elapsed time 
    result['code']        = HTTP result code (or "ERR" if network error)
    result['extcode']     = extended HTTP/network result code (e.g. "HTTP/1.1 404 Not Found", HTTP/1.1 200 OK" etc.)
    result['transferred'] = #bytes transferred
*/
    global $j, $FILETOGET;
//$outf=$server."/outfile".$j.".tmp";
    $outf=$TMPDIR."/".$server.".testfile-".sprintf("%03d", $j).".tmp";
    $time_start = microtime_float(); // start timing
    $fp = pfsockopen($server, $port, $errno, $errstr, $timeout);
    if (!$fp) {
//       echo "ERROR:<br> $errstr ($errno)<br />\n";
       $result['time']=0;
       $result['code']="ERR";
       $result['extcode']="ERROR - [".$errno."]: ".substr($errstr, 0, strlen($errstr)-2);
       $result['transferred']=0;
       return $result; break;
    } else {

//       $out = "GET / HTTP/1.1\r\n";
       $out = "GET ".$FILETOGET." HTTP/1.1\r\n";
       $out .= "Host: ".$server."\r\n";
       $out .= "Connection: Close\r\n\r\n";
//       $out="HELLO WORLD";
//        echo $out;
       fwrite($fp, $out);
///*
       $fw=fopen($outf, "w+");
       while (!feof($fp)) {
           //echo 
           fwrite($fw, fgets($fp, 128));
       }
       fclose($fw);
//*/
       fclose($fp);
    }
    $time_end = microtime_float(); // end timing

    $time = $time_end - $time_start;

    $fw=fopen($outf, "r");
    $result['extcode']=fgets($fw, 256);
    fclose($fw);
    $result['transferred']=filesize($outf);
    if ($DBG != "yes") unlink($outf);
    $result['extcode']=substr($result['extcode'], 0, strlen($result['extcode'])-2);
    $result['code']=substr($result['extcode'], 9, 3);
//    echo "[ ".$result['code']." ]\n";
    $result['time']=$time;
//    echo "$time\n";
    return $result;
//    return $time;
}

// --------------------------------- MAIN ---------------------------------- //
// ------------------------------------------------------------------------- //

// read config file
$fh=fopen($hostsfile, "r");
while (!feof($fh)) {
  $line = trim(fgets($fh, 4096));
  if ($line != "" && substr($line, 0, 1) != "#") $h[]=trim($line);
}

//$hr=array();
//$hr=$h;
// initialize values
for ($i=0; $i<sizeof($h); $i++) {
    $hr[$i]['errstr']=""; // last error
    $hr[$i]['avgt']=0; // avg. time
    $hr[$i]['tt']=0; // total time
    $hr[$i]['maxt']=0; // max. time
    $hr[$i]['mint']=0; // min. time
    $hr[$i]['ttr']=0; // total bytes transferred
    $hr[$i]['avgtr']=0; // avg. transferred
    $hr[$i]['s']=0; // total successful connections (HTTP 200 OK)
    $hr[$i]['e']=0; // total connection errors
    $hr[$i]['w']=0; // total non-critical errors (warnings, i.e. 302 found)
    $hr[$i]['lerr']=""; // last error
}

$oh=fopen ($outfile, "w+");

$line="using file: $FILETOGET\n";
echo $line; fwrite($oh, $line);

for ($j=0; $j<$NUMTESTS; $j++) {
    for ($i=0; $i<sizeof($h); $i++) {
//        printf ("%s: \n", $h[$i]);
//        mkdir ($h[$i]);
        $lr=timeconn($h[$i]);
        $t=$lr['time'];
        if ( $t > $hr[$i]['maxt'] ) $hr[$i]['maxt'] = $t;
        if ( $t < $hr[$i]['mint'] || $hr[$i]['mint']==0 ) $hr[$i]['mint'] = $t;
        $hr[$i]['tt'] += $t;
//        echo "t: $t; tt:".$hr[$i]['tt']."\n";
        $tr=$lr['transferred'];
        $hr[$i]['ttr']+=$tr;

        $c="[".$lr['code']." (";
        $ec=$lr['extcode'].")]";
        if ($lr['code']==200) { $c=""; $ec=""; };

        if ($VERBOSE=="yes") { // print debug output
            $line=sprintf("[%2d] %-25s  %7.3fs %db %s%s\n", $j, $h[$i], $t, $tr, $c, $ec);
            echo $line; fwrite($oh, $line);
        }
        
        switch ($lr['code']) {
          case 200:     $hr[$i]['s']++; $hr[$i]['lerr']=$lr['code']; break; // ok
          case 302:     $hr[$i]['w']++; $hr[$i]['lerr']=$lr['code']; break; // moved
          case 404:     $hr[$i]['lerr']=$lr['code']; break; // not found
          case 502:     $hr[$i]['lerr']=$lr['code']; break; // Proxy Error, Bad Gateway...

          case "ERR":   
            $hr[$i]['e']++; $hr[$i]['lerr']=$lr['code']; break;

          default:      $hr[$i]['lerr']=$lr['code']." ?"; break;
        }
//        if ($DBG != "yes") rmdir($h[$i]);
    }

//    printf ("%.4f s\n", );
}
$line="--\n";
echo $line; fwrite($oh, $line);
for ($i=0; $i<sizeof($h); $i++) {
// output results
    $hr[$i]['h']=$h[$i];

// calculate averages
//    $hr[$i]['tt']   *= 1000;
    $hr[$i]['avgt']=$hr[$i]['tt']/$NUMTESTS;
//    $hr[$i]['mint'] *= 1000;
//    $hr[$i]['maxt'] *= 1000;
    $hr[$i]['avgtr'] = $hr[$i]['ttr']/$NUMTESTS;

    $cestars=ceil (($hr[$i]['e']*10/$NUMTESTS/2)); // critical (network) error stars
    $hr[$i]['errstr']=str_repeat("-", $cestars);

    if ($cestars<5) {
        // error stars -- (tests minus successful minus warnings)
        $estars=ceil((($NUMTESTS-$hr[$i]['s']-$hr[$i]['w'])*10/$NUMTESTS/2));
        $hr[$i]['errstr']=str_repeat("*", $estars) . $hr[$i]['errstr'];
        // warning stars
        $wstars=ceil (($hr[$i]['w']*10/$NUMTESTS/2));
        $hr[$i]['errstr']=str_repeat("!", $wstars) . $hr[$i]['errstr'];
    }
    $hr[$i]['errstr']=sprintf("%5s", substr($hr[$i]['errstr'], strlen($hr[$i]['errstr'])-5, 5));

//    for ($j=0; $j<; $j++) {
//    $wstars=ceil((($NUMTESTS-$hr[$i]['s']-$hr[$i]['w'])*10/$NUMTESTS/2)); // warning stars
//    $hr[$i]['errstr']=str_repeat("!", $wstars );


//    }
//    $avgt=$tt/$NUMTESTS;
//    $mint=$mint*1000; $maxt=$maxt*1000; $avgt=$avgt*1000; $tt=$tt*1000;
   
//$hr[$i]['tt']

    $avgt=$hr[$i]['avgt'];
    $mint=$hr[$i]['mint'];
    $maxt=$hr[$i]['maxt'];

    $tt=$hr[$i]['tt'];
    $avgtr=$hr[$i]['avgtr'];
    $s=$hr[$i]['s'];
    $e=$hr[$i]['e'];

    $errstr=$hr[$i]['errstr'];

    $line=sprintf ("%-25s: %7.3f/%7.3f/%7.3f (%8.3f) (%5db) [%2d/%2d (%2d)] %s\n", $h[$i], $mint, $avgt, $maxt, $tt, $avgtr, $s, $NUMTESTS, $e, $errstr);
    echo $line; fwrite($oh, $line);

}

$line="-- Final results --\n";
echo $line; fwrite($oh, $line);

sort($hr);
foreach ($hr as $key => $v) {
   $line=sprintf ("%-5s %7.3f %8.3f %2d/%2d/%2d [%2d] %s\n", $v['errstr'], $v['avgt'], $v['tt'], $v['e'], $v['w'], $v['s'], $NUMTESTS, $v['h']); // " . $v['host'] . "] = " . $val['time'] . "\n";  
   echo $line; fwrite($oh, $line);         
}

   $line="\nUsed test file: ".$FILETOGET."\n\n";
   echo $line; fwrite($oh, $line);         
   $line  = "Legend:\n";
   $line .= " ! = protocol warning (e.g. 302 Moved)\n";
   $line .= " * = protocol error   (e.g. 404 Not Found)\n";
   $line .= " - = network error    (e.g. timeout, host not found)\n";
   echo $line; fwrite($oh, $line);
//   $line="\n";
//   echo $line; fwrite($oh, $line);         


fclose ($oh);
//var_dump ($hr);
?>
