{$show_company = $show_company|default:true}
{$name = $runtime.company_data.company|default:$settings.Company.company_name}

{if "ULTIMATE"|fn_allowed_for}
    {if $runtime.is_current_storefront_closed || $runtime.are_all_storefronts_closed}
        {$storefront_status_icon = "icon-lock"}
    {elseif $runtime.have_closed_storefronts}
        {$storefront_status_icon = "icon-unlock-alt"}
    {/if}

    {if !$runtime.company_data.company_id}
        {$name = __("all_vendors")}
    {/if}
    {if $runtime.are_all_storefronts_closed}
        {$title = __("no_active_storefronts")}
    {else}
        {$title = __("view_storefront")}
    {/if}
    {$storefront_url = fn_url("profiles.act_as_user?user_id={$auth.user_id}&area=C")}
    <a href="{$storefront_url}" target="_blank" class="top-bar__btn mobile-hidden" title="{$title}">
        <span class="top-bar__btn-inner storefront-menu__btn-inner">
            <img src="{$images_dir}/cart_logo.svg" border="0" alt="" class="storefront-menu__logo"/>
        </span>
    </a>
{/if}
{if "MULTIVENDOR"|fn_allowed_for && !$runtime.simple_ultimate}

    {if $runtime.are_all_storefronts_closed}
        {$storefront_status_icon = "icon-lock"}
    {elseif $runtime.have_closed_storefronts}
        {$storefront_status_icon = "icon-unlock-alt"}
    {/if}

    {if $runtime.is_multiple_storefronts}
        {$storefront_id=$smarty.request.storefront_id|default:$app.storefront->storefront_id}
    {/if}

    {if $show_company}
        {if $auth.user_type == "UserTypes::ADMIN"|enum}
            {$storefront_url = fn_url("profiles.act_as_user?user_id={$auth.user_id}&area=C{if $storefront_id}&storefront_id={$storefront_id}{/if}")}
        {else}
            {$storefront_url = ($runtime.company_id) ? "companies.products?company_id={$runtime.company_id}{if $storefront_id}&storefront_id={$storefront_id}{/if}" : ""}
            {$storefront_url = fn_url($storefront_url, "C")}
            {if $runtime.storefront_access_key}
                {$storefront_url = $storefront_url|fn_link_attach:"store_access_key={$runtime.storefront_access_key}"}
            {/if}
        {/if}
        <a href="{$storefront_url}" target="_blank" class="top-bar__btn mobile-hidden" title="{__("view_storefront")}">
            <span class="top-bar__btn-inner storefront-menu__btn-inner">
                <img src="{$images_dir}/cart_logo.svg" border="0" alt="" class="storefront-menu__logo"/>
            </span>
        </a>
        {if $storefront_status_icon && fn_check_view_permissions("storefronts.manage", "GET")}
            <a href="{"storefronts.manage"|fn_url}" class="top-bar__btn mobile-hidden">
                <span class="top-bar__btn-inner storefront-menu__btn-inner">
                    {include_ext file="common/icon.tpl" class="`$storefront_status_icon` dropdown-menu__icon"}
                </span>
            </a>
        {/if}
        {if $runtime.customization_mode.live_editor}
            {$company_name = $runtime.company_data.company}
        {else}
            {$company_name = $runtime.company_data.company|truncate:43:"...":true}
        {/if}
    {/if}
{/if}