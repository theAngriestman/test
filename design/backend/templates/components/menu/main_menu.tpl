{if $navigation.static.central || $navigation.static.top}{strip}
    {$default_menu_item_icon = "file_alt"}
    {$selected_id_path = "`$navigation.selected_tab`/`$navigation.subsection`"}
    {$level = $level|default:1}
    {$prefix = $prefix|default:""}
    {$suffix = $suffix|default:"1"}
    {$item_title_limit = 15}
    {$show_collapse_default = $show_collapse_default|default:true}
    {$attrs_wrapper = (isset($item_parent.attrs.wrapper))
        ? ($attrs_wrapper|array_merge:$item_parent.attrs.wrapper)
        : ($attrs_wrapper|default:[])
    }
    {if !isset($item_parent.attrs.wrapper)}
        {$item_parent.attrs.wrapper = []}
    {/if}

    {function menu_attrs attrs=[]}{foreach $attrs as $attr => $value}{$attr}="{$value}" {/foreach}{/function}

    <div class="accordion main-menu-{$level}" {menu_attrs attrs=$attrs_wrapper} id="{$prefix}_main_menu_{$suffix}">
        {foreach $items as $item_key => $item}
            {if $item.status === "ObjectStatuses::DISABLED"|enum && !$item.is_show}
                {continue}
            {/if}
            {$item_title = $item.title|default:__($item_key)}
            {$item_icon = $item.icon|default:$default_menu_item_icon}
            {capture name="main_menu_item"}
                {$selected_item = $item.id === $navigation.selected_tab || $item.id_path === $selected_id_path}
                <div class="accordion-group main-menu-{$level}__item {$item.attrs.class}" {""}
                    {menu_attrs attrs=$item.attrs.main}
                >
                    {if $item.type === "title_divider"}
                        {* Title divider *}
                        <div>
                            <div class="main-menu-{$level}__link main-menu-{$level}__link--title-divider {""}
                                {$item.attrs.class_href}" {""}
                                {menu_attrs attrs=$item.attrs.href}
                            >
                                <span class="main-menu-{$level}__link-icon">
                                    {include_ext file="common/icon.tpl"
                                        source=$item_icon
                                        class="main-menu-`$level`__icon"
                                    }
                                </span>
                                <span class="main-menu-{$level}__link-content">
                                    {$item_title}
                                </span>
                            </div>
                        </div>
                    {elseif $item.type === "divider"}
                        {* Divider *}
                        <div><div class="main-menu-{$level}__divider"></div></div>
                    {elseif $item.items || $item.subitems}
                        {* Nested menu accordion *}
                        <div class="accordion-heading main-menu-{$level}__accordion-heading">
                            <a href="#{$prefix}_main_menu_{$suffix}_{$item@iteration}_body" {""}
                                class="accordion-toggle main-menu-{$level}__link cm-no-ajax {""}
                                    {if $selected_item}main-menu-{$level}__toggle--active {""}{/if}
                                    {$item.attrs.class_href}" {""}
                                {if $item.new_window === "YesNo::YES"|enum}target="_blank" {""}{/if}
                                data-toggle="collapse" {""}
                                data-parent="#{$prefix}_main_menu_{$suffix}" {""}
                                {menu_attrs attrs=$item.attrs.href}
                            >
                                {if $level === 1}
                                    <span class="main-menu-{$level}__link-icon">
                                        {include_ext file="common/icon.tpl"
                                            source=$item_icon
                                            class="main-menu-`$level`__icon"
                                        }
                                    </span>
                                {/if}
                                <span class="main-menu-{$level}__link-content">
                                    {$item_title}
                                </span>
                            </a>
                        </div>
                        <div id="{$prefix}_main_menu_{$suffix}_{$item@iteration}_body" {""}
                            class="accordion-body collapse {if $show_collapse_default}collapse--overflow-default{/if} {if $selected_item}in{/if}"
                        >
                            <div class="accordion-inner main-menu-{$level}__accordion-inner">
                                {include file="components/menu/main_menu.tpl"
                                    items=$item.items|default:$item.subitems
                                    level=$level + 1
                                    suffix="`$suffix`_`$item@iteration`"
                                    item_parent=$item
                                    item_key_parent=$item_key
                                }
                            </div>
                        </div>
                    {else}
                        {* Link menu item *}
                        <div class="main-menu-{$level}__link-wrapper">
                            {if $item.type === "button"}
                            <button {""}
                            {else}
                            <a href="{if $item.href}{$item.href|fn_url}{else}#{$item_key}{/if}" {""}
                            {/if}
                                {if $item.id_path}
                                    id="{$item.id_path|replace:"/":"_"|replace:".":"_"}" {""}
                                {/if}
                                class="main-menu-{$level}__link {""}
                                    {if $item.active}main-menu-{$level}__link--active {""}{/if}
                                    {$item.attrs.class_href}" {""}
                                {if $item.new_window === "YesNo::YES"|enum}target="_blank" {""}{/if}
                                {if $item_title|count_characters:true > $item_title_limit}
                                    title="{$item_title}" {""}
                                {/if}
                                {menu_attrs attrs=$item.attrs.href}
                            >
                                {if $level === 1}
                                    <span class="main-menu-{$level}__link-icon">
                                        {include_ext file="common/icon.tpl" source=$item_icon
                                            class="main-menu-`$level`__icon"
                                        }
                                    </span>
                                {/if}
                                <span class="main-menu-{$level}__link-content">
                                    {$item_title}
                                </span>
                            {if $item.type === "button"}
                            </button>
                            {else}
                            </a>
                            {/if}
                        </div>
                    {/if}
                </div>
            {/capture}
            {$extra_params_block = ($level === 1) ? [
                id_path => $item.id_path,
                menu_level => 1
            ] : [
                id_path => $item.id_path
            ]}
            {include file="views/block_manager/frontend_render/block.tpl"
                content=$smarty.capture.main_menu_item
                block=$item
                is_clearfix=false
                location_data=$location_data
                snapping_id=$item.id_path
                object_type="menu_item"
                parent_grid=[
                    location_id => $item.section
                ]
                suffix=$id
                popup_title="{__("admin_menu.edit_item_title")}: `$item_title|truncate:100`"
                show_delete=!$item.is_main
                is_popup=true
                block_menu_compact=true
                return_url=$config.current_url|escape:url
                extra_params=$extra_params_block
                is_editing_allowed=$item.is_editing_allowed
            }
        {/foreach}
        {$extra_params_add = ($level === 1) ? [
            id_path => 0,
            menu_level => 1
        ] : [
            id_path => $item.id_path
        ]}
        {include file="components/menu/add_item.tpl"
            menu_name=$item_parent.title|default:__($item_key_parent)
            id=$item_key_parent
            has_items=($item_parent.items || $item_parent.subitems)
            extra_params=$extra_params_add
            is_subitem=($item_parent.items || $item_parent.subitems)
        }
    </div>
{/strip}{/if}