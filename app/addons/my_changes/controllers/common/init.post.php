<?php

use Tygh\Registry;

$error_log_file = Registry::get('config.dir.root') . '/error.log.txt';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if ($mode == 'clear_error_log') {
        file_put_contents($error_log_file, '');
        fn_set_notification('N', __('notice'), 'Error.log is empty!');
        exit;
    }
    return;
}

$time = fn_get_storage_data('error_time');

if ((empty($time) || $time + 2 < TIME) && file_exists($error_log_file) && strlen(file_get_contents($error_log_file)) > 5) {
    $notify = Tygh::$app['view']
        ->assign('log', file_get_contents($error_log_file))
        ->fetch('backend:addons/my_changes/views/error.log.notifications.tpl');

    fn_set_notification('I', __('error'), $notify);
    fn_set_storage_data('error_time', TIME);
}
