<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>PHP test</title>
    </head>
    <body>

        <h1>PHP test</h1>
<?php
echo '<h2 style="color: green;">PHP is working</h2>';

// user
$userid = posix_geteuid();
$user = posix_getpwuid($userid);
echo 'user: '.$user['name'].'<br>';

// group
$groupid   = posix_getegid();
$group = posix_getgrgid($groupid);
echo 'group: '.$group['name'].'<br>';

// home
echo 'home: '.getcwd().'<br>';

// write access
file_put_contents('write-test.txt', 'OK');

if (!file_exists('write-test.txt')) {
    echo '<h2 style="color: red;">ERROR: you do not have write access</h2>';
} else {
    unlink('io.test');
}
?>
    </body>
</html>

