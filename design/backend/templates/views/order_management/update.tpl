{$result_ids = "om_ajax_*"}
{$enable_required = false}

{script src="js/tygh/order_management.js"}
{script src="js/tygh/order_management_events.js"}

{script src="js/tygh/exceptions.js"}

<div class="hidden">
    {$users_shared_force = false}
    {if "ULTIMATE"|fn_allowed_for}
        {if $settings.Stores.share_users == "Y"}
            {$users_shared_force = true}
        {/if}
{/if}
    {include file="views/order_management/components/customer_info_update.tpl"
        enable_required=$enable_required
        allow_email_required_contacts=true
        allow_email_required_profile=false
    }
</div>

<form action="{""|fn_url}" method="post" class="admin-content-external-form" name="om_cart_form" enctype="multipart/form-data">
{$ORDER_MANAGEMENT}
<input type="hidden" name="result_ids" value="{$result_ids}" />
<input type="hidden" name="order_id" value="{$cart.order_id}" />

{capture name="sidebar"}
    {if $cart.order_id || $cart.user_data}
        {assign var="is_edit" value=true}
    {/if}
    {* Status *}
    {include file="views/order_management/components/status.tpl"}

    <div id="om_ajax_customer_info">
        {* Customer info *}
        {include file="views/order_management/components/profiles_info.tpl" tabindex="2" user_data=$cart.user_data location="O" is_edit=$is_edit allow_reselect_customer=!$cart.order_id}
    <!--om_ajax_customer_info--></div>
{/capture}

{capture name="mainbox"}

<div class="orders-wrap">
    <div>
        <div class="buttons-container">
            {hook name="order_management:buttons_container"}
                <div class="inline-block mobile-hide" id="button_trash_products">
                    {if $cart_products}
                    {btn type="delete_selected" dispatch="dispatch[order_management.delete]" form="om_cart_form" class="cm-skip-validation" icon="icon-trash"}
                    {/if}
                <!--button_trash_products--></div>
            {/hook}
        </div>

        <div class="cm-om-totals" id="om_ajax_update_totals">
        {if $is_empty_cart}
        <label class="hidden cm-required" for="products_required">{__("products_required")}</label>
        <input type="hidden" id="products_required" name="products_required" value="" />
        {/if}

        {* Products *}
        {include file="views/order_management/components/products.tpl" tabindex="1" autofocus="true"}
        <hr>
        <div class="row-fluid">
            <div class="span6">
            {if empty($cart.disable_promotions)}
                {* Discounts *}
                {include file="views/order_management/components/discounts.tpl"}
            {/if}
            {hook name="order_management:totals_extra"}
            {/hook}
            </div>

            <div class="span6">
            {* Totals *}
            {include file="views/order_management/components/totals.tpl"}
            </div>
        </div>
        <!--om_ajax_update_totals--></div>

        {if fn_allowed_for("MULTIVENDOR:ULTIMATE")}
            <div class="clearfix">
                <div class="control-group">
                    <label class="control-label">{__("storefront")}</label>
                    <div class="controls">
                        {include file="views/storefronts/components/picker/picker.tpl"
                            input_name="storefront_id"
                            item_ids=[$selected_storefront_id]
                            show_advanced=false
                        }
                    </div>
                </div>
            </div>
        {/if}

        {capture name="note"}
        <div class="note clearfix row-fluid">
            <div class="span6">
                <label for="customer_notes">{__("customer_notes")}</label>
                <textarea class="span12" name="customer_notes" id="customer_notes" cols="40" rows="5">{$cart.notes}</textarea>
            </div>
            <div class="span6">
                <label for="order_details">{__("staff_only_notes")}</label>
                <textarea class="span12" name="update_order[details]" id="order_details" cols="40" rows="5">{$cart.details}</textarea>
            </div>
        </div>
        {/capture}

        <div class="clearfix">
            {$notify_customer_status = false}
            {$notify_department_status = false}
            {$notify_vendor_status = false}

            {hook name="order_management:notify_checkboxes"}
                <div class="control-group">
                    <label for="notify_user" class="checkbox">{__("notify_customer")}
                    <input type="checkbox" class="" {if $notify_customer_status == true} checked="checked" {/if} name="notify_user" id="notify_user" value="Y" /></label>
                </div>
                <div class="control-group">
                    <label for="notify_department" class="checkbox">{__("notify_orders_department")}
                    <input type="checkbox" class="" {if $notify_department_status == true} checked="checked" {/if} name="notify_department" id="notify_department" value="Y" /></label>
                </div>
                {if fn_allowed_for("MULTIVENDOR")}
                <div class="control-group">
                    <label for="notify_vendor" class="checkbox">{__("notify_vendor")}
                    <input type="checkbox" class="" {if $notify_vendor_status == true} checked="checked" {/if} name="notify_vendor" id="notify_vendor" value="Y" /></label>
                </div>
                {/if}
            {/hook}
        </div>
    </div>

    <div>
        <div class="orders-right-pane form-horizontal">
            {* Payment method *}
            <div class="payments" id="om_ajax_update_payment">
                {include file="views/order_management/components/payment_method.tpl"
                    enable_required=$enable_required
                }
            <!--om_ajax_update_payment--></div>

            {* Shipping method*}
            <div class="shippings" id="om_ajax_update_shipping">
                {include file="views/order_management/components/shipping_method.tpl"}
            <!--om_ajax_update_shipping--></div>
        </div>
        {$smarty.capture.note nofilter}
    </div>
</div>

{/capture}

{capture name="buttons"}
{* Order buttons *}
    {if $cart.order_id == ""}
        {$_but_text = __("create")}
        {$but_text_ = __("create_process_payment")}
        {$title_start = __("create_new_order")}
        {$_tabindex = "3"}
    {else}
        {$_but_text = __("save")}
        {$but_text_ = __("save_process_payment")}
        {$title_start = __("editing_order")}
        {$_tabindex = "3"}
    {/if}

    {capture name="tools_list"}
        {hook name="order_management:update_tools_list"}{/hook}
    {/capture}
    {dropdown content=$smarty.capture.tools_list}

    {if $cart.order_id != ""}
        {include file="buttons/button.tpl" but_text=__("cancel") but_role="action" but_href="orders.details?order_id=`$cart.order_id`"}
    {/if}

    {include file="buttons/button.tpl" but_text=$_but_text but_name="dispatch[order_management.place_order.save]" but_role="button_main" tabindex=$_tabindex}
{/capture}

{capture name="mainbox_title"}{strip}
    {if $cart.order_id == ""}{strip}
    {/strip}{else}{strip}
        #{$cart.order_id} {""}</span>
        <span class="f-small">
        / {$cart.order_timestamp|date_format:"`$settings.Appearance.date_format`"}, {$cart.order_timestamp|date_format:"`$settings.Appearance.time_format`"}
        </span>
    {/strip}{/if}
{/strip}{/capture}

<div id="order_update">
{include file="common/mainbox.tpl" title_start=$title_start title_end=$smarty.capture.mainbox_title sidebar=$smarty.capture.sidebar content=$smarty.capture.mainbox buttons=$smarty.capture.buttons sidebar_icon="icon-user"}
<!--order_update--></div>

</form>
