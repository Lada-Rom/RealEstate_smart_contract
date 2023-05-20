<?php
header('Access-Control-Allow-Origin: *');
session_start();

$post_data = $_POST['GanacheAccounts'];
$filename ='./accounts.json';
$handle = fopen($filename, "w"); 

if (empty($post_data)) {   
    fwrite($handle, 'Hmm, I did NOT get any data from AJAX');  
}
if (!empty($post_data)) {
    $temp_array = array();
    foreach($post_data as $item) { //foreach element in $arr
        $temp_array[] = array("address" => $item, "is_busy" => false, "belong" => null); //etc
    }
    $temp_array[0]['is_busy'] = true;
    // https://stackoverflow.com/questions/8858848/php-read-and-write-json-from-file
    file_put_contents($filename, json_encode($temp_array));
    // echo $temp_array[0];
    // echo $temp_array[1];
    // Write an array
    //fwrite($handle, print_r($post_data, TRUE));
    // BASIC writing
    //fwrite($handle, $post_data);
}
fclose($handle);
?>