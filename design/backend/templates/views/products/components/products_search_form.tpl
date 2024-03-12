{*
    Import
    ---
    $search
    $dispatch
    $type
    $show_main_search_field
    $show_search_button
*}

{$show_main_search_field = $show_main_search_field|default:true}
{$form_meta = ""}
{$autofocus = ($autofocus === false) ? false : true}
{$search_filters_type = $type}
{$form_id = $form_id|default:"search_form"}
{if $type === "in_content"}
    {$form_meta = "`$form_meta` search-filters-wrapper__form"}
    <div class="search-filters-wrapper">
{elseif $in_popup}
    <div class="adv-search" data-ca-search-filters="advSearch" id="search_filters_adv_search">
    <div class="group">
{else}
    <div class="sidebar-row">
    <h6>{__("admin_search_title")}</h6>
{/if}

{if $page_part}
    {$_page_part="#`$page_part`"}
{/if}

<form action="{""|fn_url}{$_page_part}"
    name="{$product_search_form_prefix}search_form"
    method="get"
    class="cm-disable-empty-all form-edit {$form_meta}" 
    data-ca-target-id="pagination_contents,content_top_navigation"
    data-ca-search-filters="form"
id="{$form_id}">
<input type="hidden" name="type" value="{$search_type|default:"simple"}" {if $autofocus}autofocus="autofocus"{/if} />
{if $smarty.request.redirect_url}
    <input type="hidden" name="redirect_url" value="{$smarty.request.redirect_url}" />
{/if}
{if $selected_section != ""}
    <input type="hidden" id="selected_section" name="selected_section" value="{$selected_section}" />
{/if}
<input type="hidden" name="pcode_from_q" value="{"YesNo::YES"|enum}" />

{if $put_request_vars}
    <div class="hidden" data-ca-search-filters="requestVars">
        {array_to_fields data=$smarty.request skip=["callback"] escape_all=true}
    </div>
{/if}

{$extra nofilter}

{* Content for search forms *}

{* Find results with *}
{$main_search_field = [
    id => "q",
    type => "input",
    category => "primary",
    label => __("find_results_with"),
    value => $search.q
]}

{* Search in category *}
{capture name="category"}
    {if $search.cid|is_array && $search.cid|count === 1}
        {$s_cid = $search.cid|reset}
    {elseif $search.cid|is_array && $search.cid|count !== 1}
        {$s_cid = 0}
    {else}
        {$s_cid = $search.cid}
    {/if}
    {if "categories"|fn_show_picker:$smarty.const.CATEGORY_THRESHOLD}
        <div class="controls">
        {include file="views/categories/components/picker/picker.tpl"
            input_name="cid"
            show_advanced=true
            multiple=false
            show_empty_variant=true
            item_ids=[$s_cid]
            empty_variant_text=__("all_categories")
            dropdown_css_class="object-picker__dropdown--categories"
            object_picker_advanced_btn_class="cm-dialog-destroy-on-close"
            attributes=[
                "data-ca-search-filters" => "field"
            ]
        }
        </div>
    {else}
        {include file="views/categories/components/picker/picker.tpl"
            input_name="cid"
            show_advanced=true
            multiple=false
            show_empty_variant=true
            item_ids=[$s_cid]
            empty_variant_text=__("all_categories")
            dropdown_css_class="object-picker__dropdown--categories"
            object_picker_advanced_btn_class="cm-dialog-destroy-on-close"
            attributes=[
                "data-ca-search-filters" => "field"
            ]
        }
    {/if}
{/capture}

{* Filter items *}
{capture name="filter_items"}
    {if $filter_items}
        <div class="group form-horizontal">
            <div class="control-group">
                {include file="views/products/components/advanced_search_form.tpl"
                    filter_features=$filter_items
                    prefix="filter_"
                    data_name="filter_variants"
                }
            </div>
        </div>
    {/if}
{/capture}

{* Feature items *}
{capture name="feature_items"}
    {if $feature_items}
        <div class="group form-horizontal">
            <div class="control-group">
                {include file="views/products/components/advanced_search_form.tpl"
                    filter_features=$feature_items
                    prefix="feature_"
                    data_name="feature_variants"
                }
            </div>
        </div>
    {elseif $feature_items_too_many}
        <div class="group form-horizontal">
            {__("error_features_too_many_variants")}
        </div>
    {/if}
{/capture}

{* Quantity *}
{$have_amount_filter=0}
{foreach $filter_items as $ff}
    {if $ff.field_type eq "A"}
        {$have_amount_filter=1}
    {/if}
{/foreach}

{* Select vendor *}
{$is_enabled_select_vendor = false}
{$is_hidden_select_vendor = false}
{$select_vendor_label = ("MULTIVENDOR"|fn_allowed_for) ? __("vendor") : __("owner")}
{capture name="select_vendor"}
    {if $picker_selected_company|default:""|fn_string_not_empty}
        {$is_hidden_select_vendor = true}
        <input type="hidden" name="company_id" value="{$picker_selected_company}" />
    {else}
        {include file="common/select_vendor.tpl"}
    {/if}
{/capture}
{if $smarty.capture.select_vendor && $smarty.capture.select_vendor|trim !== ""}
    {$is_enabled_select_vendor = true}
{/if}

{* Status *}
{$all_product_statuses = []}
{$is_checked_some_all_product_statuses = false}
{foreach fn_get_all_product_statuses() as $status_id => $status_name}
    {$is_search_status_equal_status_id = ($search.status === $status_id)}
    {if $is_search_status_equal_status_id}
        {$is_checked_some_all_product_statuses = true}
    {/if}
    {$all_product_statuses["status_`$status_id`"] = [
        key => "status_`$status_id`",
        label => $status_name,
        value => $status_id,
        is_checked => $is_search_status_equal_status_id
    ]}
{/foreach}
{$all_product_statuses = [
    status_empty => [
        key => "status_empty",
        label => "--",
        value => false,
        is_checked => !$is_checked_some_all_product_statuses
    ]
]|array_merge:$all_product_statuses}

{* Order ids *}
{capture name="order_ids"}
    {include file="pickers/orders/picker.tpl"
        item_ids=$search.order_ids
        no_item_text=__("no_items")
        data_id="order_ids"
        input_name="order_ids"
        view_mode="simple"
    }
{/capture}

{* Sort by *}
{capture name="sort_by"}
    {$sort_by_content = []}
    {hook name="products:sort_by_content"}
    {$sort_by_content = $sort_by_content|array_merge:[
        product => [
            id => "product",
            label => __("name"),
            selected => ($search.sort_by === "product")
        ],
        code => [
            id => "code",
            label => __("sku"),
            selected => ($search.sort_by === "code")
        ],
        price => [
            id => "price",
            label => __("price"),
            selected => ($search.sort_by === "price")
        ],
        list_price => [
            id => "list_price",
            label => __("list_price"),
            selected => ($search.sort_by === "list_price")
        ],
        amount => [
            id => "amount",
            label => __("quantity"),
            selected => ($search.sort_by === "amount")
        ],
        status => [
            id => "status",
            label => __("status"),
            selected => ($search.sort_by === "status")
        ]
    ]}
    {/hook}
    <div>
        <label for="sort_by">{__("sort_by")}</label>
        <select name="sort_by" id="sort_by">
            {foreach $sort_by_content as $sort_by_item}
                <option {if $sort_by_item.selected}selected="selected"{/if} value="{$sort_by_item.id}">{$sort_by_item.label}</option>
            {/foreach}
            {* Deprecated hook. Use hook "products:sort_by_content" instead *}
            {hook name="products:select_search"}
            {/hook}
        </select>
    </div>
    <div>
        <select name="sort_order" id="sort_order">
            <option {if $search.sort_order_rev === "desc"}selected="selected"{/if} value="asc">{__("asc")}</option>
            <option {if $search.sort_order_rev === "asc"}selected="selected"{/if} value="desc">{__("desc")}</option>
        </select>
    </div>
{/capture}

{* Creation date *}
{capture name="period"}
    <div class="search-filters__period-selector">
        {include file="common/period_selector.tpl"
            period=$search.period
            form_name="{$product_search_form_prefix}search_form"
        }
    </div>
{/capture}

{* Search forms *}
{$search_filters = []}
{hook name="products:search_data"}

{if $show_main_search_field}
    {$search_filters.q = $main_search_field}
{/if}
{$search_filters = $search_filters|array_merge:[
    price => [
        id => "price",
        type => "range",
        category => "primary",
        label => "{__("price")}&nbsp;({$currencies.$primary_currency.symbol nofilter})",
        data => [
            name_from => "price_from",
            value_from => $search.price_from,
            name_to => "price_to",
            value_to => $search.price_to
        ]
    ],
    category => [
        id => "category",
        type => "dropdown",
        category => "primary",
        label => __("category"),
        content => $smarty.capture.category
    ],
    status => [
        id => "status",
        type => "radio",
        category => "primary",
        label => __("status"),
        nested_data => $all_product_statuses
    ],
    subcats => [
        id => "subcats",
        type => "radio",
        category => "primary",
        label => __("subcategories"),
        nested_data => [
            subcats_yes => [
                key => "subcats_yes",
                label => __("yes"),
                value => "YesNo::YES"|enum,
                is_checked => (
                    ($search.subcats === "YesNo::YES"|enum)
                    || ($search.subcats !== "YesNo::YES"|enum && $search.subcats !== "YesNo::NO"|enum)
                )
            ],
            subcats_no => [
                key => "subcats_no",
                label => __("no"),
                value => "YesNo::NO"|enum,
                is_checked => ($search.subcats === "YesNo::NO"|enum)
            ]
        ]
    ],
    period => [
        id => "period",
        type => "dropdown",
        category => "primary",
        label => __("creation_date"),
        content => $smarty.capture.period
    ],
    sort_by => [
        id => "sort_by",
        type => "dropdown",
        category => "primary",
        label => __("sort_by"),
        content => $smarty.capture.sort_by
    ],
    search_in => [
        id => "search_in",
        type => "checkbox",
        category => "secondary",
        label => __("search_in"),
        nested_data => [
            pname => [
                key => "pname",
                label => __("product_name"),
                is_checked => ($search.pname === "YesNo::YES"|enum)
            ],
            pshort => [
                key => "pshort",
                label => __("short_description"),
                is_checked => ($search.pshort === "YesNo::YES"|enum)
            ],
            pfull => [
                key => "pfull",
                label => __("full_description"),
                is_checked => ($search.pfull === "YesNo::YES"|enum)
            ],
            pkeywords => [
                key => "pkeywords",
                label => __("keywords"),
                is_checked => ($search.pkeywords === "YesNo::YES"|enum)
            ]
        ]
    ],
    filter_items => [
        id => "filter_items",
        type => "popup",
        category => "secondary",
        is_enabled => isset($filter_items),
        label => __("filters"),
        content => $smarty.capture.filter_items
    ],
    feature_items => [
        id => "feature_items",
        type => "popup",
        category => "secondary",
        is_enabled => isset($feature_items),
        label => __("features"),
        content => $smarty.capture.feature_items
    ],
    pcode => [
        id => "pcode",
        type => "input",
        category => "secondary",
        label => __("sku"),
        value => $search.pcode
    ],
    popularity => [
        id => "popularity",
        type => "range",
        category => "secondary",
        label => __("popularity"),
        data => [
            name_from => "popularity_from",
            value_from => $search.popularity_from,
            name_to => "popularity_to",
            value_to => $search.popularity_to
        ]
    ],
    shipping_freight => [
        id => "shipping_freight",
        type => "range",
        category => "secondary",
        label => "{__("shipping_freight")}&nbsp;({$currencies.$primary_currency.symbol nofilter})",
        data => [
            name_from => "shipping_freight_from",
            value_from => $search.shipping_freight_from,
            name_to => "shipping_freight_to",
            value_to => $search.shipping_freight_to
        ]
    ],
    weight => [
        id => "weight",
        type => "range",
        category => "secondary",
        label => "{__("weight")}&nbsp;({$settings.General.weight_symbol})",
        data => [
            name_from => "weight_from",
            value_from => $search.weight_from,
            name_to => "weight_to",
            value_to => $search.weight_to
        ]
    ],
    amount => [
        id => "amount",
        type => "range",
        category => "secondary",
        is_enabled => !$have_amount_filter,
        label => __("quantity"),
        data => [
            name_from => "amount_from",
            value_from => $search.amount_from,
            name_to => "amount_to",
            value_to => $search.amount_to
        ]
    ],
    company_id => [
        id => "company_id",
        type => "popup",
        category => "secondary",
        is_enabled => $is_enabled_select_vendor,
        is_hidden => $is_hidden_select_vendor,
        label => $select_vendor_label,
        content => $smarty.capture.select_vendor
    ],
    free_shipping => [
        id => "free_shipping",
        type => "radio",
        category => "secondary",
        label => __("free_shipping"),
        nested_data => [
            free_shipping_empty => [
                key => "free_shipping_empty",
                label => "--",
                value => false,
                is_checked => ($search.free_shipping !== "YesNo::YES"|enum && $search.free_shipping !== "YesNo::NO"|enum)
            ],
            free_shipping_yes => [
                key => "free_shipping_yes",
                label => __("yes"),
                value => "YesNo::YES"|enum,
                is_checked => ($search.free_shipping === "YesNo::YES"|enum)
            ],
            free_shipping_no => [
                key => "free_shipping_no",
                label => __("no"),
                value => "YesNo::NO"|enum,
                is_checked => ($search.free_shipping === "YesNo::NO"|enum)
            ]
        ]
    ],
    order_ids => [
        id => "order_ids",
        type => "popup",
        category => "secondary",
        label => __("purchased_in_orders"),
        content => $smarty.capture.order_ids
    ],
    updated_in_hours => [
        id => "updated_in_hours",
        type => "input",
        category => "secondary",
        label => __("updated_last"),
        value => $search.updated_in_hours,
        placeholder => __("hour_or_hours")
    ]
]}
{/hook}

{* Deprecated hooks. Use hook "products:search_data" instead *}
{capture name="hook_products_simple_search"}{hook name="products:simple_search"}{/hook}{/capture}
{capture name="hook_companies_products_advanced_search"}{hook name="companies:products_advanced_search"}{/hook}{/capture}
{capture name="hook_products_search_form"}{hook name="products:search_form"}{/hook}{/capture}
{capture name="hook_products_search_in_orders"}{hook name="products:search_in_orders"}{/hook}{/capture}
{capture name="hook_products_advanced_search"}{hook name="products:advanced_search"}{/hook}{/capture}

{capture name="products_search_form_hooks" assign="products_search_form_hooks"}
    {$smarty.capture.hook_products_simple_search nofilter}
    {$smarty.capture.hook_companies_products_advanced_search nofilter}
    {$smarty.capture.hook_products_search_form nofilter}
    {$smarty.capture.hook_products_search_in_orders nofilter}
    {$smarty.capture.hook_products_advanced_search nofilter}
{/capture}

{capture name="products_search_form_hooks_first_block" assign="products_search_form_hooks_first_block"}
    {$smarty.capture.hook_products_simple_search nofilter}
    {$smarty.capture.hook_companies_products_advanced_search nofilter}
    {$smarty.capture.hook_products_search_form nofilter}
    {$smarty.capture.hook_products_search_in_orders nofilter}
{/capture}

{$no_adv_link = $products_search_form_hooks && $products_search_form_hooks|trim === ""}

{capture name="advanced_search"}
{if 
    !$products_search_form_hooks_first_block
    || ($products_search_form_hooks_first_block && $products_search_form_hooks_first_block|trim !== "")
}
<div class="row-fluid">
    <div class="group span12 form-horizontal">
        {$smarty.capture.hook_products_simple_search nofilter}
        {$smarty.capture.hook_companies_products_advanced_search nofilter}
        {$smarty.capture.hook_products_search_form nofilter}
        {$smarty.capture.hook_products_search_in_orders nofilter}
    </div>
</div>
{/if}
{$smarty.capture.hook_products_advanced_search nofilter}
{/capture}

{include file="common/advanced_search.tpl"
    search_filters=$search_filters
    advanced_search=$smarty.capture.advanced_search
    show_search_button=$show_search_button
    no_adv_link=$no_adv_link
    dispatch=$dispatch
    view_type="products"
    in_popup=$in_popup
}

<!--search_form--></form>
{if $type === "in_content"}
    </div>
{elseif $in_popup}
    </div><!--search_filters_adv_search--></div>
{else}
    </div><hr>
{/if}

{* Export *}
{$search_filters_type = $search_filters_type scope=parent}
