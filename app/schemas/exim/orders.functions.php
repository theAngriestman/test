<?php

use Tygh\Tygh;

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

//
// Get order data information
// Parameters:
// @order_id - order ID
// @type - type of information
function fn_exim_orders_get_data($order_id, $type)
{

    $data = db_get_field("SELECT data FROM ?:order_data WHERE order_id = ?i AND type = ?s", $order_id, $type);
    if (!empty($data)) {

        // Payment information
        if ($type == 'P') {
            $data = @unserialize(fn_decrypt_text($data));
        // Coupons, Taxes and Shipping information
        } elseif (strpos('CTL', $type) !== false) {
            $data = @unserialize($data);
        }

        return fn_exim_json_encode($data);
    }
}

/**
 * @param string[] $conditions Conditions
 *
 * @return void
 */
function fn_exim_orders_set_storefront_condition(array &$conditions)
{
    $storefront_id = Tygh::$app['session']['auth']['storefront_id'];

    if (!$storefront_id) {
        return;
    }

    $conditions[] = db_quote('orders.storefront_id = ?i', $storefront_id);
}
//
// Get order data information
// Parameters:
// @order_id - order ID
// @data - data to set
// @type - type of information

function fn_exim_orders_set_data($order_id, $data, $type)
{

    $set_delimiter = ';';
    $pair_delimiter = ':';
    $left = '[';
    $right = ']';

    $data = json_decode($data, true);

    if (is_array($data)) {
        $data = serialize($data);
        if ($type == 'P') {
            $data = fn_encrypt_text($data);
        }
        $insert = array(
            'order_id' => $order_id,
            'type' => $type,
            'data' => $data
        );

        db_query("REPLACE INTO ?:order_data ?e", $insert);
    }

    return true;
}

function fn_exim_orders_get_extra_fields($order_id, $lang_code = CART_LANGUAGE)
{

    $fields = array();
    $_user = db_get_array("SELECT d.description, f.value, a.section FROM ?:profile_fields_data as f LEFT JOIN ?:profile_field_descriptions as d ON d.object_id = f.field_id AND d.object_type = 'F' AND d.lang_code = ?s LEFT JOIN ?:profile_fields as a ON a.field_id = f.field_id WHERE f.object_id = ?i  AND f.object_type = 'O'", $lang_code, $order_id);

    if (!empty($_user)) {
        foreach ($_user as $field) {
            if ($field['section'] == 'B') {
                $type = 'billing';
            } elseif ($field['section'] == 'S') {
                $type = 'shipping';
            } else {
                $type = 'user';
            }

            $fields[$type][$field['description']] = $field['value'];
        }
    }

    if (!empty($fields)) {
        return fn_exim_json_encode($fields);
    }

    return '';
}

function fn_exim_orders_set_extra_fields($data, $order_id, $lang_code = CART_LANGUAGE)
{
    $data = json_decode($data, true);

    if (!empty($data) && is_array($data)) {
        foreach ($data as $type => $_data) {
            foreach ($_data as $field => $value) {
                // Check if field is exist
                if ($type == 'billing' || $type == 'shipping') {
                    $section = strtoupper($type[0]);
                    $field_id = db_get_field("SELECT object_id FROM ?:profile_field_descriptions LEFT JOIN ?:profile_fields ON ?:profile_fields.field_id = ?:profile_field_descriptions.object_id WHERE description = ?s AND lang_code = ?s AND ?:profile_fields.section = ?s AND object_type = 'F' LIMIT 1", $field, $lang_code, $section);
                } else {
                    $field_id = db_get_field("SELECT object_id FROM ?:profile_field_descriptions WHERE description = ?s AND object_type = 'F' AND lang_code = ?s LIMIT 1", $field, $lang_code);
                }

                if (!empty($field_id)) {
                    $update = array(
                        'object_id' => $order_id,
                        'object_type' => 'O',
                        'field_id' => $field_id,
                        'value' => $value
                    );

                    db_query('REPLACE INTO ?:profile_fields_data ?e', $update);
                }
            }
        }

        return true;
    }

    return false;
}

function fn_exim_orders_get_docs($order_id, $type)
{
    $data = db_get_field("SELECT doc_id FROM ?:order_docs WHERE order_id = ?i AND type = ?s", $order_id, $type);
    if (!empty($data)) {
        return $data;
    }
}

function fn_exim_orders_set_docs($order_id, $data, $type)
{
    if (!empty($data)) {

        // let's remove doc_id if such document exists. Doc id for this order will be auto incremented.
        $is_exists = db_get_field("SELECT doc_id FROM ?:order_docs WHERE doc_id = ?i AND order_id != ?i", $data, $order_id, $type);
        if ($is_exists) {
            $data = 0;
        }

        $insert = array(
            'order_id' => $order_id,
            'type' => $type,
            'doc_id' => $data
        );

        // user can change the doc_id. We should delete previous records.
        db_query("DELETE FROM ?:order_docs WHERE `order_id` = ?i AND `type` = ?s", $order_id, $type);
        db_query("REPLACE INTO ?:order_docs ?e", $insert);
    }

    return true;
}

/**
 * @param array<string, array<string, string|int|null>> $data           Order data
 * @param bool                                          $skip_record    Skip record
 * @param array<string, int>                            $processed_data Processed data
 *
 * @return void
 */
function fn_import_check_storefront_id(array &$data, &$skip_record, array &$processed_data)
{
    $storefront_id = (int) Tygh::$app['session']['auth']['storefront_id'];

    foreach ($data as $lang_code => $order_data) {

        if (empty($order_data['storefront_id'])) {

            /** @var \Tygh\Storefront\Repository $repository */
            $repository = Tygh::$app['storefront.repository'];

            $default_storefront = $repository->findDefault();

            $data[$lang_code]['storefront_id'] = $default_storefront->storefront_id;
        } elseif ($storefront_id && $storefront_id !== (int) $data[$lang_code]['storefront_id']) {
            $skip_record = true;
            $processed_data['S']++;
        }
    }
}

/**
 * Replaces the <br> tag with a line break
 *
 * @param string $object Processed item product reviews
 *
 * @return string
 */
function fn_br_to_line_break($object)
{
    return str_replace('<br>', PHP_EOL, $object);
}

/**
 * Replaces the line break with the <br> tag
 *
 * @param string $object Processed item product reviews
 *
 * @return string
 */
function fn_line_break_to_br($object)
{
    return str_replace(PHP_EOL, '<br>', trim($object, "\r\n"));
}
