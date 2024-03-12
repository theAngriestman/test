<?php

use Tygh\Registry;

if (!defined('BOOTSTRAP')) {
    die('Access denied');
}

fn_register_hooks(
    'dispatch_assign_template'
    ,'install_addon_post'
);
