{*
    $search_filters
    $dispatch
*}

{script src="js/tygh/search_filters.js"}
{if $search_filters}
    {$is_save_saved_search_active = false}
    {$form_id = $form_id|default:"search_form"}
    {$add_filter_variant_item_state = []}
    <div class="search-filters" data-ca-search-filters="main">
    {if $dispatch}
        {include file="buttons/search.tpl" but_name="dispatch[`$dispatch`]" method="GET" but_meta="hidden" but_id="search_filters_submit"}
    {/if}
        <div class="search-filters__content">
            {foreach $search_filters as $search_filter}
                {if isset($search_filter.is_enabled) && !$search_filter.is_enabled}
                    {continue}
                {/if}
                {$is_show = false}
                {$is_has_value = false}
                {$is_show_clear_filter_btn = false}
                {$add_filter_variant_item_state[$search_filter.id] = [
                    show => false
                ]}
                {capture name="search_filters_item"}
                {* Hidden *}
                {if $search_filter.is_hidden}
                    {$search_filter_item_attributes = [
                        "data-ca-search-filters-is-hidden" => "true"
                    ]}
                    {$search_filter.content nofilter}
                {* Popup for big content *}
                {elseif $search_filter.type === "popup" && $search_filter.content && $search_filter.content|trim !== ""}
                    {$search_filter_item_class = "search-filters__popup"}
                    {$is_has_value = true}
                    {capture name="popup_content"}
                        {$search_filter.content nofilter}
                        <div class="modal-footer buttons-container">
                            <div class="pull-right">
                                <a class="cm-dialog-closer btn btn-primary"
                                    data-dismiss="modal"
                                    data-ca-search-filters="closePopup"
                                >{__("close")}</a>
                            </div>
                        </div>
                    {/capture}
                    {include file="common/popupbox.tpl"
                        id=$search_filter.id
                        text=$search_filter.label
                        link_text=$search_filter.label
                        act="button"
                        but_meta="btn-small search-filters__button-popup cm-search-filters-button"
                        content=$smarty.capture.popup_content
                        assign="popupbox_content"
                    }
                    {if !$popupbox_content || $popupbox_content && $popupbox_content|trim === ""}
                        {*
                            FIXME: Smarty bug: {capture} breaks {continue} in the {foreach}.
                            When {continue} you must explicitly close the {сapture}.
                            For {capture name="search_filters_item"}
                        *}
                        {/capture}
                        {continue}
                    {/if}

                    {$popupbox_content nofilter}
                {elseif ($search_filter.data && $search_filter.type !== "popup") || $search_filter.id}
                        {btn type="button"
                            raw=true
                            text="`$search_filter.label` <span class=\"caret\"></span>"
                            class="btn btn-small dropdown-toggle search-filters__dropdown-toggle cm-search-filters-button"
                            data=[
                                "data-toggle" => "dropdown"
                            ]
                        }
                        <ul class="dropdown-menu search-filters__dropdown-menu" data-ca-search-filters="dropdownMenu">
                            {* Checkbox list: select multiple items *}
                            {if $search_filter.type === "checkbox"}
                                {$is_show_clear_filter_btn = true}
                                {foreach $search_filter.nested_data as $item}
                                    {if $_REQUEST[$item.key]}
                                        {$is_show = true}
                                        {$add_filter_variant_item_state[$search_filter.id] = [
                                            show => true
                                        ]}
                                    {/if}
                                    {if $item.is_checked}
                                        {$is_has_value = true}
                                    {/if}
                                    <li>
                                        <div class="search-filters__content-variant-item">
                                            <label for="{$item.key}" class="checkbox">
                                                <input type="checkbox"
                                                    value="{($item === false)
                                                        ? ""
                                                        : $item.value|default:("YesNo::YES"|enum)
                                                    }"
                                                    {if $item.is_checked}checked="checked"{/if}
                                                    name="{$item.key}"
                                                    id="{$item.key}"
                                                    data-ca-search-filters="field"
                                                />
                                                {$item.label}
                                            </label>
                                        </div>
                                    </li>
                                {/foreach}
                            {* Radio list: select one item *}
                            {elseif $search_filter.type === "radio"}
                                {$is_show_clear_filter_btn = true}
                                {foreach $search_filter.nested_data as $item}
                                    {if $_REQUEST[$search_filter.id]}
                                        {$is_show = true}
                                        {$add_filter_variant_item_state[$search_filter.id] = [
                                            show => true
                                        ]}
                                    {/if}
                                    {if $item.is_checked && $item@index !== 0}
                                        {$is_has_value = true}
                                    {/if}
                                    <li>
                                        <div class="search-filters__content-variant-item">
                                            <label for="{$item.key}" class="radio">
                                                <input type="radio"
                                                    value="{($item.value === false)
                                                        ? "" :
                                                        $item.value|default:("YesNo::YES"|enum)
                                                    }"
                                                    {if $item.is_checked}checked="checked"{/if}
                                                    name="{$search_filter.id}"
                                                    id="{$item.key}"
                                                    data-ca-search-filters="field"
                                                />
                                                {$item.label}
                                            </label>
                                        </div>
                                    </li>
                                {/foreach}
                            {* Range: select range of two fields *}
                            {elseif $search_filter.type === "range"}
                                {$is_show_clear_filter_btn = true}
                                {if $_REQUEST[$search_filter.data.name_from]
                                    || $_REQUEST[$search_filter.data.name_to]
                                }
                                    {$is_show = true}
                                    {$add_filter_variant_item_state[$search_filter.id] = [
                                        show => true
                                    ]}
                                {/if}
                                {if $search_filter.data.value_from || $search_filter.data.value_to}
                                    {$is_has_value = true}
                                {/if}
                                <li>
                                    <div class="search-filters__item">
                                        <div>
                                            <label for="{$search_filter.data.name_from}">
                                                {$search_filter.data.label_from|default:__("search_range_from")}
                                            </label>
                                            <input type="text"
                                                class="input-fill"
                                                name="{$search_filter.data.name_from}"
                                                id="{$search_filter.data.name_from}"
                                                value="{$search_filter.data.value_from}"
                                                {if $search_filter.data.placeholder_from}
                                                    placeholder={$search_filter.data.placeholder_from}
                                                {/if}
                                                data-ca-search-filters="field"
                                            />
                                        </div>
                                        <div>
                                            <label for="{$search_filter.data.name_to}">
                                                {$search_filter.data.label_to|default:__("search_range_to")}
                                            </label>
                                            <input type="text"
                                                class="input-fill"
                                                name="{$search_filter.data.name_to}"
                                                id="{$search_filter.data.name_to}"
                                                value="{$search_filter.data.value_to}"
                                                {if $search_filter.data.placeholder_to}
                                                    placeholder={$search_filter.data.placeholder_to}
                                                {/if}
                                                data-ca-search-filters="field"
                                            />
                                        </div>
                                    </div>
                                </li>
                            {* Dropdown with raw content *}
                            {elseif $search_filter.type === "dropdown"}
                                <li>
                                    <div class="search-filters__item-raw">
                                        {$search_filter.content nofilter}
                                    </div>
                                </li>
                            {* Default: Simple input *}
                            {else}
                                {$is_show_clear_filter_btn = true}
                                {if $_REQUEST[$search_filter.id]}
                                    {$is_show = true}
                                    {$add_filter_variant_item_state[$search_filter.id] = [
                                        show => true
                                    ]}
                                {/if}
                                {if $search_filter.value}
                                    {$is_has_value = true}
                                {/if}
                                <li>
                                    <div class="search-filters__item">
                                        <label for="{$search_filter.id}">{$search_filter.label}</label>
                                        <input type="text"
                                            class="input-fill"
                                            name="{$search_filter.id}"
                                            id="{$search_filter.id}"
                                            value="{$search_filter.value}"
                                            placeholder="{$search_filter.placeholder}"
                                            data-ca-search-filters="field"
                                        />
                                    </div>
                                </li>
                            {/if}
                        </ul>
                {/if}
                {/capture}

                {* Render search filters item *}
                {$clear_filter_btn_class = ($is_has_value) ? "" : "hidden"}
                <div class="btn-group
                        {if !$is_show && $search_filter.category !== "primary"}hidden{/if}
                        {$search_filter_item_class|default:"search-filters__dropdown"}
                    "
                    data-ca-search-filters="item"
                    data-ca-search-filters-item-type="{$search_filter.type}"
                    data-ca-search-filters-id="{$search_filter.id}"
                    {if $search_filter_item_attributes}
                        {$search_filter_item_attributes|render_tag_attrs nofilter}
                    {/if}
                >
                    {if $is_show_clear_filter_btn}
                        {btn type="button"
                            icon="icon-remove"
                            class="btn btn-small search-filters__clear-filter-btn `$clear_filter_btn_class`"
                            data=[
                                "data-ca-search-filters" => "clearFilterBtn"
                            ]
                        }
                    {/if}
                    {$smarty.capture.search_filters_item nofilter}
                </div>
            {/foreach}

            {* Add filter *}
            {include_ext file="common/icon.tpl"
                source="plus"
                class="search-filters__add-filter-icon"
                assign="add_filter_icon"
            }
            <div class="dropdown search-filters__add-filter"
                data-ca-search-filters="addFilter"
            >
                {btn type="button"
                    raw=true
                    text="<span class=\"mobile-hidden\">{__("search_add_filter")}</span>`$add_filter_icon`"
                    class="btn btn-small dropdown-toggle search-filters__add-filter-dropdown-toggle"
                    data=[
                        "data-toggle" => "dropdown",
                        "data-ca-search-filters" => "addFilterBtn"
                    ]
                }
                <ul class="dropdown-menu search-filters__add-filter-dropdown-menu" data-ca-search-filters="addFilterDropdownMenu">
                    {foreach $search_filters as $search_filter}
                        {if $search_filter.category === "primary"
                            || isset($search_filter.is_enabled) && !$search_filter.is_enabled
                        }
                            {continue}
                        {/if}
                        {$is_show = $add_filter_variant_item_state[$search_filter.id].show}
                        <li data-ca-search-filters="addFilterVariantItem" {if $is_show}class="hidden"{/if}>
                            <label for="search_filters_add_filter_{$search_filter.id}" class="checkbox search-filters__add-filter-content-variant-item-label">
                                <input type="checkbox"
                                    form="search_filters_add_filter"
                                    value="{($is_show) ? ("YesNo::YES"|enum) : ("YesNo::NO"|enum)}"
                                    {if $is_show}checked="checked"{/if}
                                    name="search_filters_add_filter_{$search_filter.id}"
                                    id="search_filters_add_filter_{$search_filter.id}"
                                    data-ca-search-filters-add-filter-id="{$search_filter.id}"
                                    data-ca-search-filters-add-filter-type="{$search_filter.type}"
                                    data-ca-search-filters-update="ignore"
                                    class="hidden"
                                />
                                {$search_filter.label nofilter}
                            </label>
                        </li>
                    {/foreach}
                </ul>
            </div>

            {if !$not_saved && $smarty.request.dispatch|strpos:".picker" === false}
                {$is_save_saved_search_active = true}
                {capture name="search_save"}
                    <div class="form-horizontal">
                        <div class="control-group">
                            <label for="view_name" class="control-label cm-required">{__("name")}</label>
                            <div class="controls">
                                <input type="text"
                                    id="view_name"
                                    name="new_view"
                                    class="input-large"
                                    value="{if $search.view_id && $views[$search.view_id]}{$views[$search.view_id].name}{/if}"
                                    form="{$form_id}"
                                    data-ca-search-filters-update="ignore"
                                />
                            </div>
                        </div>
                    </div>
                    <div class="buttons-container">
                        <a class="cm-dialog-closer cm-inline-dialog-closer tool-link btn">{__("cancel")}</a>
                        {if ""|fn_check_view_permissions}
                            {include file="buttons/button.tpl"
                                but_text=__("save")
                                but_role="button_main"
                                but_meta="btn-primary"
                                but_id="adv_search_save"
                                but_type="button"
                            }
                        {/if}
                    </div>
                {/capture}
                {include file="common/popupbox.tpl"
                    id="search_save"
                    text=__("save_this_search_as")
                    content=$smarty.capture.search_save
                    link_class="cm-dialog-auto-size btn-small hidden"
                    title=__("save_this_search_as")
                    act="general"
                    link_text=__("save_this_search_as")
                }
            {/if}
        </div>
    </div>
    {* Export *}
    {$is_save_saved_search_active = $is_save_saved_search_active scope=parent}
{/if}
