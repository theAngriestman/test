<?php

function xhprof_start($ignored_functions = []) {
    if (defined('XHPROF_DEBUG')) {
        return;
    }

    define('XHPROF_DEBUG', 1);
    require_once('xhprof_lib/utils/xhprof_lib.php');
    require_once('xhprof_lib/utils/xhprof_runs.php');
    xhprof_enable(XHPROF_FLAGS_CPU + XHPROF_FLAGS_MEMORY, ['ignored_functions' => $ignored_functions]);
}

function xhprof_stop($print_link = 1, $run_id = null) {
    if (!defined('XHPROF_DEBUG')) {
        return false;
    }

    $xhprof_data = xhprof_disable();
    $xhprof_runs = new XHProfRuns_Default();
    $run_id = $xhprof_runs->save_run($xhprof_data, $_SERVER['USER'], $run_id ?: md5(DIR_ROOT));

    $profiler_url = sprintf( 'xhprof_html/index.php?run=%s&amp;source=%s', $run_id, $_SERVER['USER']);
    if ($print_link) {
        echo '<a href="'. $profiler_url .'" target="_blank">Profiler output</a>';
    } else {
        return $print_link;
    }

    return true;
}