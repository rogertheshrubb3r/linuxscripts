#!/usr/bin/php
<?

error_reporting(E_ALL);
#$user="radu";
$limit=25;

$cond="";
$user="";

if (isset($argv[1])) $user=$argv[1];
if (isset($argv[2])) $limit=$argv[2];


$cn=mysql_connect("localhost", "mail", "l00py.mail") or die (mysql_error());
mysql_select_db("mail", $cn);

if ($user != "") $cond="WHERE user='$user'";
$ord="time DESC";
$sql="SELECT msg, user, host, time FROM log $cond ORDER BY $ord LIMIT $limit";

$RS=mysql_query($sql, $cn);
while($row=mysql_fetch_assoc($RS)) {
    $r[]=sprintf("%-20s %-20s %15s %s\n", $row['time'], $row['user'], $row['msg'], $row['host']);
}

if (!empty($r)) {
    $r=array_reverse($r);
    foreach ($r as $k => $v) echo "$v";
}

mysql_close($cn);
?>
