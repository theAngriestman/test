<?php

use Tygh\Registry;

if (Registry::get('addons.my_changes.ab_dev') == 'Y') {
    $schema['top']['ab']['items']['ab.full_cc'] = array(
        'href' => 'ab.full_cc?redirect_url=%CURRENT_URL',
        'position' => 10,
    );

    $schema['top']['ab']['items']['ab.dev_mode.compile_check.true'] = array(
        'href' => 'ab.dev_mode.true',
        'attrs' => array(
            'class_href' => 'cm-ajax',
        ),
        'position' => 11,
    );

    $schema['top']['ab']['items']['ab.full_divider'] = array(
        'type' => 'divider',
        'position' => 20,
    );

    $schema['top']['ab']['items']['ab.update_po'] = array(
        'href' => 'ab.update_po',
        'type' => 'title',
        'position' => 30,
    );

    foreach (Registry::get('addons') as $a => $d) {
        if ($d['status'] == 'A' && preg_match('/^(ab__|abt__)/', $a)) {
            $schema['top']['ab']['items']['ab.update_po']['subitems'][$a] = array(
                    'href' => "ab.update_po.{$a}?redirect_url=%CURRENT_URL",
                    'position' => 10,
            );
        }
    }

    $schema['top']['ab']['items']['ab.log_divider'] = array(
        'type' => 'divider',
        'position' => 40,
    );

    $schema['top']['ab']['items']['ab.log'] = array(
        'href' => fn_url('', 'C') . 'log.txt?t=' . time(),
        'attrs' => array(
            'href' => array (
                'target' => '_blank',
            )
        ),
        'position' => 50,
    );


}

return $schema;
