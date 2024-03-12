{if $items}{strip}
    {$actions_count_threshold = 3}
    {$processed_items = []}

    {* Check view permissions *}
    {foreach $items as $title => $item}
        {if $item.method}
            {$method = $item.method|upper}
        {/if}
        {if !$item.href|fn_check_view_permissions:{$method|default:"GET"}
            || !$item.dispatch|fn_check_view_permissions:{$method|default:"POST"}
        }
            {continue}
        {/if}
        {$processed_items[$title] = $item}
    {/foreach}

    {foreach $processed_items as $title => $item}
        {if $item@iteration > $actions_count_threshold}
            {continue}
        {/if}
        {if $item.wrapper_class}<span class="shift-left shift-right {$item.wrapper_class}">{/if}
            {btn type=$item.type|default:"text"
                href=$item.href|default:""
                text=$item.text|default:__($title)
                title=$item.title|default:""
                id=$item.id|default:""
                class="btn dynamic-actions-btn `$item.class` `$item.meta`"
                dispatch=$item.dispatch|default:""
                form=$item.form|default:""
                method=$item.method|default:""
                target=$item.target|default:""
                target_id=$item.target_id|default:""
                process=$item.process|default:""
                onclick=$item.onclick|default:""
                raw=$item.raw|default:""
                icon=$item.icon|default:""
                data=$item.data|default:[]
            }
        {if $item.wrapper_class}</span>{/if}
    {/foreach}

    {if $processed_items|@count > $actions_count_threshold}
        {capture name="tools_list"}
            {foreach $processed_items as $title => $item name="actions"}
                {if $item@iteration <= $actions_count_threshold}
                    {continue}
                {/if}
                <li {if $item.wrapper_class}class="{$item.wrapper_class}"{/if}>
                    {btn type=$item.type|default:"list"
                        href=$item.href|default:""
                        text=$item.text|default:__($title)
                        title=$item.title|default:""
                        id=$item.id|default:""
                        class=$item.class|default:$item.meta
                        dispatch=$item.dispatch|default:""
                        form=$item.form|default:""
                        method=$item.method|default:""
                        target=$item.target|default:""
                        target_id=$item.target_id|default:""
                        process=$item.process|default:""
                        onclick=$item.onclick|default:""
                        raw=$item.raw|default:""
                        icon=$item.icon|default:""
                        data=$item.data|default:[]
                    }
                </li>
            {/foreach}
        {/capture}
        {include file="common/tools.tpl"
            hide_actions=true
            tools_list=$smarty.capture.tools_list
            link_text=__("more_actions")
            caret=true
            prefix="actions_menu"
        }
    {/if}
{/strip}{/if}