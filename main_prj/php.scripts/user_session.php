<?php
header('Access-Control-Allow-Origin: *');
session_start();

$login = (string)$_POST['LOGIN'];
$pswd = (string)$_POST['PASSWORD'];

$_SESSION['ulogin'] = $login;
$_SESSION['upswd'] = $pswd;

$filename = './accounts.json';
$handle = fopen($filename, "r");      
$content = json_decode(file_get_contents($filename), true);
foreach($content as &$item) { //foreach element in $arr
    if($item['is_busy'] !== true) {
        $item['belong'] = $login . $pswd;
        $item['is_busy'] = true;
        break;
    }
}
file_put_contents($filename, json_encode($content));

fclose($handle);
?>