{script src="js/tygh/tabs.js"}

{if !$active_tab}
    {assign var="active_tab" value=$smarty.request.selected_section}
{/if}

{assign var="empty_tab_ids" value=$content|empty_tabs}
{$show_tabs_navigation = $show_tabs_navigation|default:true}

{* Fill tabs if there are more than 7 *}
{$enable_fill = $enable_fill|default:true}

{if $navigation.tabs}

{$with_conf = false}
{capture name="tab_items"}
    {foreach $navigation.tabs as $key => $tab}
        {if (!$tabs_section || $tabs_section == $tab.section) && ($tab.hidden || !$key|in_array:$empty_tab_ids)}
        <li id="{$key}{$id_suffix}" class="{if $tab.hidden == "YesNo::YES"|enum}hidden {/if}{if $tab.js}cm-js{elseif $tab.ajax}cm-js cm-ajax{if $tab.ajax_onclick} cm-ajax-onclick{/if}{/if}{if $key == $active_tab} active{/if} {if $tab.properties}extra-tab{/if}">
            {if $key == $active_tab}{$active_tab_extra nofilter}{/if}

            {if $tab.properties}
                {$with_conf = true}
                {btn type="dialog" class="cm-ajax-force hand icon-cog" title=$tab.properties.title target_id="content_properties_`$key``$id_suffix`" href=$tab.properties.href}
            {/if}

            <a {if $tab.href}href="{$tab.href|fn_url}"{/if}>{$tab.title}</a>
        </li>
        {/if}
    {/foreach}
{/capture}

{capture name="tabs_navigation" assign=tabs_navigation}
<div class="cm-j-tabs{if $track} cm-track{/if} tabs {if $with_conf}tabs-with-conf{/if} {if $enable_fill}tabs--enable-fill{/if} tabs--count-{$navigation.tabs|@count} {$meta_tabs}">
    <ul class="nav nav-tabs">
        {$smarty.capture.tab_items nofilter}
    </ul>
</div>
{/capture}
{if $show_tabs_navigation}
    {$smarty.capture.tabs_navigation nofilter}
{/if}
<div class="cm-tabs-content">
    {$content nofilter}
</div>
{else}
    {$content nofilter}
{/if}
{if !$show_tabs_navigation}
    {* Export *}
    {$tabs_navigation = $tabs_navigation scope=parent}
{/if}