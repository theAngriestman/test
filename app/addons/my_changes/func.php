<?php

use Tygh\Addons\Ab_addonsManager\Autoinstaller\Autoinstaller;
use Tygh\Registry;

function fn_ab_autoinstall($addon)
{
    $result = (new Autoinstaller())->process($addon);

    return $result ? 'ok' : 'error';
}

function fn_ab_autoinstall_old($addon)
{
    $schema = fn_get_schema('autoinstall', $addon);

    $error = false;

    $results = [];

    if (!empty($schema['steps'])) {
        foreach ($schema['steps'] as $step => $functions) {
            fn_get_schema('autoinstall', "$step.functions");

            foreach ($functions as $function) {
                if (!is_array($function)) {
                    $func_name = $function;
                    $args = [];
                } else {
                    $func_name = array_shift($function);
                    $args = $function;
                }

                if (!empty($args)) {
                    foreach ($args as &$arg) {
                        if (is_string($arg) && substr($arg, 0, 1) == '@' && isset($schema['config'][substr($arg, 1)])) {
                            $arg = $schema['config'][substr($arg, 1)];
                        }
                    }
                }

                if (function_exists($func_name)) {
                    $r = '';

                    try {
                        $r = call_user_func_array($func_name, $args);
                    } catch (Tygh\Exceptions\AException $e) {
                        // throw new DeveloperException('Empty product_id or in_work');
                        $error = true;
                        $r = $e->getMessage();
                    }

                    if (!empty($r) && is_string($r)) {
                        $results[] = $r;
                    }
                }
            }
        }
    }

    if (!empty($results)) {
        $log = [
            "[{$addon}]",
        ];

        foreach ($results as $k => $v) {
            $log[] = $k . ' = "' . addslashes($v) . '"';
        }

        file_put_contents(Registry::get('config.dir.root') . '/autoinstall.log', implode(PHP_EOL, $log) . PHP_EOL . PHP_EOL, FILE_APPEND);
    }

    return $error ? 'error' : 'ok';
}

function is_ab_theme()
{
    return in_array(Registry::get('settings.theme_name'), ['abt__unitheme', 'abt__youpitheme', 'abt__unitheme2']);
}

function replace_in_files($replaces)
{
    $result = [];

    if (!empty($replaces) && is_array($replaces)) {
        foreach ($replaces as $file => $items) {
            foreach ($items as $item) {
                if (!empty($item['from'])) {
                    $result[$file][] = file_put_contents($file, str_replace($item['from'], $item['to'], file_get_contents($file)));
                }
            }
        }
    }

    return $result;
}

if (!function_exists('fn_ab__am_get_addon_menu')) {
    function fn_ab__am_compare_url($active_hrefs, $current_url)
    {
        // $CURRENT_URL => ARRAY
        if (strpos($current_url, 'dispatch=') !== false) {
            list(, $current_url) = explode('dispatch=', $current_url);
        }
        $current_url_array = (array) explode('&', str_replace('?', '&', $current_url));

        foreach ((array) explode(',', $active_hrefs) as $active_href) {
            $active_href_array = (array) explode('&', str_replace('?', '&', $active_href));

            $intersect = array_intersect($active_href_array, $current_url_array);

            if (count($active_href_array) == count($intersect)) {
                return true;
            }
        }

        return false;
    }

    function fn_ab__am_get_addon_menu($addon = '', $current_href = '')
    {
        $addon_menu = [];

        if (!empty($addon)) {
            $menu = /*f*/fn_get_schema(/*/f*//*t*/'menu'/*/t*/, /*t*/'menu'/*/t*/);

            if (!empty($menu[/*t*/'central'/*/t*/][/*t*/'ab__addons'/*/t*/][/*t*/'items'/*/t*/][$addon][/*t*/'subitems'/*/t*/])) {
                $addon_menu = $menu[/*t*/'central'/*/t*/][/*t*/'ab__addons'/*/t*/][/*t*/'items'/*/t*/][$addon][/*t*/'subitems'/*/t*/];
                uasort($addon_menu, function ($a, $b) {
                    return ($a[/*t*/'position'/*/t*/] < $b[/*t*/'position'/*/t*/]) ? -1 : 1;
                });

                // Определим текущий URL с разбивкой по параметрам
                $current_url = !empty($current_href) ? $current_href : Registry::get('config.current_url');

                if (!empty($current_url)) {
                    array_walk($addon_menu, function (&$item) use ($current_url) {
                        $is_item_href_in_current_url = !empty($item['href']) ? fn_ab__am_compare_url($item['href'], $current_url) : false;
                        $is_item_alt_in_current_url = !empty($item['alt']) ? fn_ab__am_compare_url($item['alt'], $current_url) : false;

                        if ($is_item_href_in_current_url || $is_item_alt_in_current_url) {
                            $item[/*t*/'active'/*/t*/] = /*t*/'Y'/*/t*/;
                        }

                        if (!empty($item[/*t*/'attrs'/*/t*/][/*t*/'href'/*/t*/])) {
                            $item[/*t*/'attrs'/*/t*/] = $item[/*t*/'attrs'/*/t*/][/*t*/'href'/*/t*/];
                        }
                    });
                }
            }
        }

        return $addon_menu;
    }
}

function fn_my_changes_install_addon_post($addon, $show_notification, $install_demo, $allow_unmanaged)
{
    $addon_scheme = simplexml_load_file(Registry::get('config.dir.addons') . $addon . '/addon.xml');

    $string = date('Y-m-d H:i:s') . ": Installed {$addon}, {$addon_scheme->version}";
    if (isset($addon_scheme->hash)) {
        $string .= ", {$addon_scheme->hash}";
    }
    file_put_contents('log.txt', PHP_EOL . $string, FILE_APPEND);
}

function fn_my_changes_dispatch_assign_template()
{
    if (AREA == 'C') {
        $device = fn_ab__am_get_device_type();
        Registry::set('settings.ab__device', $device);
        Registry::set('settings.abt__device', $device);
        fn_set_cookie('ab__device', $device, 3600);
    }
}

if (!function_exists('fn_ab__am_get_device_type') && AREA == 'C') {
    function fn_ab__am_get_device_type()
    {
        static $device_type = '';

        if (!empty($device_type)) {
            return $device_type;
        }

        if (defined('CONSOLE') || !isset($_SERVER['HTTP_USER_AGENT']) || !isset($_SERVER['HTTP_ACCEPT'])) {
            $device_type = 'desktop';

            return $device_type;
        }

        if (empty($device_type)) {
            $tablet_browser = 0;
            $mobile_browser = 0;

            if (!empty($_SERVER['HTTP_USER_AGENT'])) {
                $http_user_agent = strtolower($_SERVER['HTTP_USER_AGENT']);

                $mobile_agents = ['w3c ', 'acs-', 'alav', 'alca', 'amoi', 'audi',
                    'avan', 'benq', 'bird', 'blac', 'blaz', 'brew', 'cell', 'cldc', 'cmd-',
                    'dang', 'doco', 'eric', 'hipt', 'inno', 'ipaq', 'java', 'jigs', 'kddi',
                    'keji', 'leno', 'lg-c', 'lg-d', 'lg-g', 'lge-', 'maui', 'maxo', 'midp',
                    'mits', 'mmef', 'mobi', 'mot-', 'moto', 'mwbp', 'nec-', 'newt', 'noki',
                    'palm', 'pana', 'pant', 'phil', 'play', 'port', 'prox', 'qwap', 'sage',
                    'sams', 'sany', 'sch-', 'sec-', 'send', 'seri', 'sgh-', 'shar', 'sie-',
                    'siem', 'smal', 'smar', 'sony', 'sph-', 'symb', 't-mo', 'teli', 'tim-',
                    'tosh', 'tsm-', 'upg1', 'upsi', 'vk-v', 'voda', 'wap-', 'wapa', 'wapi',
                    'wapp', 'wapr', 'webc', 'winw', 'winw', 'xda ', 'xda-', ];

                if (preg_match('/(tablet|ipad|playbook)|(android(?!.*(mobi|opera mini)))/', $http_user_agent)) {
                    $tablet_browser++;
                }

                if (preg_match('/(up.browser|up.link|mmp|symbian|smartphone|midp|wap|phone|android|iemobile)/', $http_user_agent)) {
                    $mobile_browser++;
                }

                if (in_array(substr($http_user_agent, 0, 4), $mobile_agents)) {
                    $mobile_browser++;
                }

                if (strpos($http_user_agent, 'opera mini') > 0) {
                    $mobile_browser++;

                    //Check for tablets on opera mini alternative headers
                    $stock_ua = isset($_SERVER['HTTP_X_OPERAMINI_PHONE_UA']) ? $_SERVER['HTTP_X_OPERAMINI_PHONE_UA'] : (isset($_SERVER['HTTP_DEVICE_STOCK_UA']) ? $_SERVER['HTTP_DEVICE_STOCK_UA'] : '');

                    if (preg_match('/(tablet|ipad|playbook)|(android(?!.*mobile))/', strtolower($stock_ua))) {
                        $tablet_browser++;
                    }
                }
            }

            if (!empty($_SERVER['HTTP_ACCEPT'])) {
                if (strpos(strtolower($_SERVER['HTTP_ACCEPT']), 'application/vnd.wap.xhtml+xml') > 0
                    || isset($_SERVER['HTTP_X_WAP_PROFILE'])
                    || isset($_SERVER['HTTP_PROFILE'])) {
                    $mobile_browser++;
                }
            }

            $device_type = ($tablet_browser ? 'tablet' : ($mobile_browser ? 'mobile' : 'desktop'));
        }

        return $device_type;
    }
}