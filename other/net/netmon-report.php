#!/usr/bin/php

<?

//$DBG=1;

//$logfile="netmon.log";
$logfile="/var/log/netmon.log";
//$statfile="/var/run/netmon/netmon.stat";

function datediff($date1, $date2, $fmt="") {
// uses unix timestamps
//    echo "date1: $date1, date2: $date2\n";
   if ($date2 > $date1) return FALSE;
   $seconds  = $date1 - $date2;
   $days       = floor($seconds / (60*60*24) ); $seconds -= $days * 60*60*24;
   $hours      = floor($seconds / (60*60) );    $seconds -= $hours * 60*60;
   $minutes   = floor($seconds / 60);           $seconds -= $minutes * 60;
   // Return an associative array of results
//   return array( "d" => $days, "h" => $hours, "m" => $minutes, "s" => $seconds);
   $d=sprintf("%02d", $days);
   $h=sprintf("%02d", $hours);
   $m=sprintf("%02d", $minutes);
   $s=sprintf("%02d", $seconds);
   return array( "d" => $d, "h" => $h, "m" => $m, "s" => $s);
}

$fh= fopen($logfile, "r"); // open file
$ln=0;

while (!feof($fh)) {
  $line = trim(fgets($fh, 4096));
  $ln++;
  // look for start
  $el=explode(" ", $line);

  if ($DBG) echo "$line\n";

  $action=trim($el[6]." ".$el[7]." ".$el[8]);
  if ($DBG) echo "line: $ln; action: $action\n";

  if ($action != "") {
    $txtdate=$el[0]." ".$el[4];
    if (trim($el[6])=="netmon") { 
	if ($action=="netmon was started") $startmarker=1;
	if ($action=="netmon was stopped") $endmarker=1;
    } else {
      $host=$el[6]; $state=$el[8]; $verb=$el[7];
//      $date=strftime('%d.%m.%Y %H:%M:%S', strtotime('2006-01-22 11:32:34'));
      $cnt[$host]++; $c=$cnt[$host];
      $ts['time']=strtotime($txtdate);
      $ts['state']=$state;
      $ts['verb']=$verb;
      $states[$host][$c]=$ts;

      if ($DBG) echo "-- added state: $host: $state [event $c]\n";
      if ($c>1) { // calc. interval
            $dd=datediff($states[$host][$c]['time'], $states[$host][$c-1]['time']);
            if ($DBG) echo "-- interval: ".$dd['h'].":".$dd['m'].":".$dd['s']."\n";
      }

    }
  }
}

//date
// add final state to array

foreach ($states as $k => $v) {
    $events=sizeof($v); // no. of log entries for each host
    $ts['time']=filemtime($logfile);
    $ts['state']=$v[$events]['state']; // state at end is assumed to be last logged state
    $ts['verb']="is";
    $states[$k][$events+1]=$ts;
}

// print stats
foreach ($states as $k => $v) {
    $events=sizeof($v); // no. of log entries for each host
    echo "== downtimes for $k: [$events events]\n";
    if ($events>1) for ($i=2; $i<=$events; $i++) {
        if ( $v[$i-1]['state']=="DOWN" ) {
          $dd=datediff($v[$i]['time'], $v[$i-1]['time']);
//          $outstr="[".$v[$i-1]['state']."] ".( ($v[$i-1]['verb']=="is" || $v[$i]['verb']=="is") ? "~": " ")
	  $prestr=" ";
	  if ($v[$i-1]['verb']=="is") { 
	    $prestr="e";
	    if ($v[$i]['verb']=="is") $prestr="~";
	  } else if ($v[$i]['verb']=="is") $prestr="b";
          $outstr=$prestr
          .$dd['d']."d ".$dd['h']."h ".$dd['m']."m ".$dd['s']."s | "
          .( $v[$i-1]['verb']=="is" ? "?": " ").date("D j M Y H:i:s", $v[$i-1]['time'])." - "
          .( $v[$i]['verb']=="is" ? "?": " ").date("D j M Y H:i:s", $v[$i]['time'])."\n";
          $outstr=str_replace("00d 00h 00m", "           ", $outstr);
          $outstr=str_replace("00d 00h", "       ", $outstr);
          $outstr=str_replace("00d", "   ", $outstr);
          echo $outstr;
        }
    }
}
if ($DBG) var_dump ($states);

?>
