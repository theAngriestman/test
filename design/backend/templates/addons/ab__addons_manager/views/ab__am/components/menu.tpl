{if $addon}
    {$menu = fn_ab__am_get_addon_menu($addon, $active_href)}
    {if $menu}
        {capture name="adv_buttons"}
            {$smarty.capture.adv_buttons nofilter}
            {capture name="tools_list"}
                {foreach $menu as $m}
                    <li{if $m.active == "Y"} class="active"{/if}>{btn type="list" text=__($m@key) href=$m.href data=$m.attrs}</li>
                {/foreach}

                {if $addon != 'ab__addons_manager'}
                    <li class="divider"></li>
                    <li>{btn type="list" target="_blank" text=__('ab__am.addons') href='ab__am.addons'}</li>
                {/if}
            {/capture}
            {dropdown content=$smarty.capture.tools_list icon='ab__icon' class='ab__am-menu' }
        {/capture}
    {/if}
{/if}
