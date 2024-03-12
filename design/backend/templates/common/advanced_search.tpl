{script src="js/tygh/advanced_search.js"}
{if $search_filters}
    {capture name="simple_search" assign="simple_search"}
        {include file="components/search_filters/search_filters.tpl"
            search_filters=$search_filters
            dispatch=$dispatch
        }
    {/capture}
{/if}
<script>
Tygh.tr('object_exists', '{__("object_exists")|escape:"javascript"}');
</script>

<input type="hidden" name="is_search" value="Y" />
{assign var="a_id" value=$dispatch|fn_crc32|string_format:"s_%s"}
{assign var="views" value=$view_type|default:""|fn_get_views}
{$show_search_button = $show_search_button|default:true}
{$is_save_state = $is_save_state|default:true}
{$save_state = ($is_save_state) ? "cm-save-state" : ""}
{$is_save_saved_search_active = $is_save_saved_search_active|default:false}

{if !$in_popup}
    {if $simple_search}
    <div class="simple-search-common" id="simple_search_common">
        <div id="simple_search">
            {$simple_search nofilter}
        </div>
    </div>
    {/if}
    <div class="sidebar-field advanced-search-field">
        {if $show_search_button}
            {include file="buttons/search.tpl" but_name="dispatch[`$dispatch`]" method="GET" but_meta="advanced-search-field__search"}
        {/if}
        {if !$no_adv_link}
            <a class="advanced-search cm-dialog-opener" id="adv_search_opener" data-ca-target-id="adv_search" href="#">{__("advanced_search")}</a>
        {/if}
    </div>

<div id="{$a_id}">
    <div class="hidden adv-search" id="adv_search" title="{__("advanced_search")}">
        {if $simple_search}
            <div class="group" id="simple_search_popup"></div>
        {/if}

        {$advanced_search nofilter}

        <div class="modal-footer buttons-container">
            {if !$not_saved}
                <div class="pull-left">
                    {if $smarty.request.dispatch|strpos:".picker" === false && !$is_save_saved_search_active}
                    <span class="pull-left">{__("save_this_search_as")}</span>
                    <div class="input-append">
                    <input type="text" id="view_name" name="new_view" value="{if $search.view_id && $views[$search.view_id]}{$views[$search.view_id].name}{/if}" placeholder="{__("name")}" class="input-medium" />
                        {include file="buttons/button.tpl" but_text=__("save") but_id="adv_search_save" but_role="advanced-search"}
                        </div>
                    {/if}
                </div>
            {/if}
            <div class="pull-right">
                <a class="cm-dialog-closer cm-cancel tool-link btn bulkedit-unchanged" data-dismiss="modal">{__("cancel")}</a>
                {include file="buttons/search.tpl" but_name="dispatch[`$dispatch`]" but_role="submit" method="GET"}
            </div>
        </div>
    </div>
</div>

{else}
    {$simple_search nofilter}
    {if !$search_filters
        || $advanced_search && $advanced_search|trim != ""
        || (!$not_saved && $smarty.request.dispatch|strpos:".picker" === false)
    }
        <div class="sidebar-field in-popup">
            <div class="btn-group">
                {if !$search_filters}
                    {include file="buttons/search.tpl" but_name="dispatch[`$dispatch`]"}
                {/if}
                {if $advanced_search && $advanced_search|trim != ""
                    || (!$not_saved && $smarty.request.dispatch|strpos:".picker" === false)
                }
                    <a id="sw_{$a_id}" class="btn cm-combination {$save_state}" title="{__("advanced_search_options")}">
                        {$icon_chevron_down = "icon-chevron-down cm-combination `$save_state`{if $smarty.cookies.$a_id} hidden{/if}"}
                        {$icon_chevron_up = "icon-chevron-up cm-combination `$save_state`{if !$smarty.cookies.$a_id} hidden{/if}"}
                        {include_ext file="common/icon.tpl"
                            class=$icon_chevron_down
                            id="on_`$a_id`"
                        }
                        {include_ext file="common/icon.tpl"
                            class=$icon_chevron_up
                            id="off_`$a_id`"
                        }
                    </a>
                {/if}
            </div>
        </div>
    {/if}
    <div id="{$a_id}" class="search-advanced {if !$smarty.cookies.$a_id}hidden{/if}">
        {$advanced_search nofilter}
    </div>
{/if}
