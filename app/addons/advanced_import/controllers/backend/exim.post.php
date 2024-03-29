<?php

/***************************************************************************
 *                                                                          *
 *   (c) 2004 Vladimir V. Kalynyak, Alexey V. Vinokurov, Ilya M. Shalnev    *
 *                                                                          *
 * This  is  commercial  software,  only  users  who have purchased a valid *
 * license  and  accept  to the terms of the  License Agreement can install *
 * and use this program.                                                    *
 *                                                                          *
 ****************************************************************************
 * PLEASE READ THE FULL TEXT  OF THE SOFTWARE  LICENSE   AGREEMENT  IN  THE *
 * "copyright.txt" FILE PROVIDED WITH THIS DISTRIBUTION PACKAGE.            *
 ****************************************************************************/

use Tygh\Registry;

defined('BOOTSTRAP') or die('Access denied');

$products_deprecated_href = Registry::get('navigation.dynamic.sections.products.href');
if ($products_deprecated_href && ($mode === 'import')) {
    Registry::set('navigation.dynamic.sections.products.href', 'import_presets.manage&object_type=products');
    Registry::set('navigation.dynamic.sections.products_deprecated', [
        'href' => $products_deprecated_href,
        'title' => __('products_deprecated'),
    ]);

    if ($_REQUEST['section'] === 'products') {
        Registry::set('navigation.dynamic.active_section', 'products_deprecated');
    }
}
