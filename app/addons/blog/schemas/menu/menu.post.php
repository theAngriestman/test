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

$schema['central']['website']['items']['blog'] = [
    'attrs' => [
        'class'=>'is-addon'
    ],
    'href' => 'pages.manage?get_tree=multi_level&page_type=' . PAGE_TYPE_BLOG,
    'alt' => 'pages.manage?page_type=' . PAGE_TYPE_BLOG . ',pages.update?come_from=' . PAGE_TYPE_BLOG . ',pages.add?come_from=' . PAGE_TYPE_BLOG,
    'position' => 150
];


return $schema;
