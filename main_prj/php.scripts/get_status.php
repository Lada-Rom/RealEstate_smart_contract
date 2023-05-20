<?php
header('Access-Control-Allow-Origin: *');
session_start();

echo $_SESSION['contract_status'];

// echo isset($_SESSION['contract_status'])
//     ? $_SESSION['contract_status'] : "false";
//header('location:contract_status.php');
?>