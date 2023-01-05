<?php
class Database {
    private static $dsn = 'mysql:host=192.168.11.76;dbname=my_guitar_shop1';
    private static $username = 'vertical';
    private static $password = 'vertical';
    private static $db;

    private function __construct() {}

    public static function getDB () {
        if (!isset(self::$db)) {
            try {
                self::$db = new PDO(self::$dsn,
                                     self::$username,
                                     self::$password);
            } catch (PDOException $e) {
                $error_message = $e->getMessage();
                include('../errors/database_error.php');
                exit();
            }
        }
        return self::$db;
    }
}
?>