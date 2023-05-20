<?php
header('Access-Control-Allow-Origin: *');
$filename ='./f.txt';
$data = file_get_contents($filename);
echo $data;
?>
