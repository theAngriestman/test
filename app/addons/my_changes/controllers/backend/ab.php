<?php

use Tygh\Registry;
use Tygh\Addons\SchemesManager;
use Tygh\Development;

if (!defined('BOOTSTRAP')) {
    die('Access denied');
}

if ($mode == 'install_addon') {
    $addon = $action;

    $result = 'n/a';

    $company_id = fn_allowed_for('MULTIVENDOR') ? 0 : 1;
    Registry::set('runtime.company_id', $company_id);
    Registry::set('addons_initiated', true);

    if (fn_install_addon($addon)) {
        define('DISABLE_HOOK_CACHE', true);
        fn_load_addon($addon);
        $result = fn_ab_autoinstall($addon);
    }

    echo $result;

    exit;
}

if ($mode == 'update_po') {
    $addon = $action;

    if (!empty($addon)
        && in_array(substr($addon, 0, 4), ['ab__', 'abt_'])
        && !empty(Registry::get('addons.' . $addon))
    ) {
        $data = @json_decode(shell_exec('curl --request GET --url https://test.abt.team/po.php?a=' . $addon));

        if (!empty($data)) {
            $t = [];

            foreach ($data as $l => $v) {
                if (!empty($v) && strlen($v) > 200) {
                    fn_put_contents(Registry::get('config.dir.lang_packs') . "$l/addons/$addon.po", $v);
                    fn_update_addon_language_variables(SchemesManager::getScheme($addon));

                    $t[$l] = "<b>{$addon}</b>: $l" . ', ' . substr_count($v, 'msgctxt') . ' items';
                }
            }

            if (empty($_REQUEST['redirect_url'])) {
                fn_print_r($t);
            } else {
                fn_set_notification('N', __('notice'), '<pre>' . implode(PHP_EOL, $t) . '</pre>');

                return [CONTROLLER_STATUS_REDIRECT];
            }
        }

        exit;
    }

    fn_print_die('Invalid addon name or addon not installed yet!');
}

if ($mode == 'full_cc') {
    fn_clear_cache('all');
    fn_clear_cache('static');
    fn_rm(Registry::get('config.dir.var') . 'cache/');

    fn_set_notification('N', 'AB: ' . __('notice'), __('cache_cleared'));

    if (empty($_REQUEST['redirect_url'])) {
        $_REQUEST['redirect_url'] = 'index.index';
    }

    return [CONTROLLER_STATUS_REDIRECT];
}

if ($mode == 'dev_mode') {
    if ($action == 'true') {
        Development::enable('compile_check');
        fn_set_notification('W', __('warning'), __('warning_store_optimization_dev', ['[link]' => fn_url('themes.manage')]));
    } else {
        Development::disable('compile_check');
        fn_set_notification('W', __('warning'), __('warning_store_optimization_dev_disabled', ['[link]' => fn_url('themes.manage?ctpl')]));
    }

    exit();
}
