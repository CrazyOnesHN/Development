<?php
    $dsn = 'mysql:host=192.168.0.86;dbname=my_guitar_shop1';
    $username = 'vertical';
    $password = 'vertical';

    try {
        $db = new PDO($dsn, $username, $password);        
    } catch (PDOException $e) {
        $error_message = $e->getMessage();
        include('database_error.php');
        exit();
    }
?>
