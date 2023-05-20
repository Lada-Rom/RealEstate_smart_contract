<?php
header('Access-Control-Allow-Origin: *');
session_start();

$post_rest = (string)$_POST['status'];
$_SESSION['contract_status'] = $post_rest;
echo $_SESSION['contract_status'];

?>