{$show_layouts = $show_layouts|default:true}
{$show_converted_to_css = $show_converted_to_css|default:true}
{$show_reset_button = $show_reset_button|default:true}
{$show_duplicate_style = $show_duplicate_style|default:true}
{$active_style_id = $active_style_id|default:$runtime.layout.style_id}
{$is_can_change_style_name = $current_style.is_can_change_style_name|default:true}
{$content_container = $content_container|default:"tygh_main_container"}

{$header_height = 200}
{$bottom_height = 73}
{$converted_to_css_height = 16}
{$sections_height = 51}

{if !$show_converted_to_css}
    {$header_height = $header_height - $converted_to_css_height}
{/if}
{if $te_sections && $te_sections|@count <= 1}
    {$header_height = $header_height - $sections_height}
{/if}
{if !$show_reset_button}
    {$bottom_height = 0}
{/if}

{$styles_subtitle = ($smarty.const.AREA === "SiteArea::ADMIN_PANEL"|enum) ? __("theme_editor.color_scheme") : __("theme_editor.styles")}
{$icon_path = ($smarty.const.AREA === "SiteArea::ADMIN_PANEL"|enum) ? "common/icon_deprecated.tpl" : "common/icon.tpl"}

<div class="theme-editor-container" id="theme_editor">

<script>
Tygh.tr({
    'theme_editor.style_name': '{__("theme_editor.style_name")|escape:"javascript"}',
    'theme_editor.incorrect_style_name': '{__("theme_editor.incorrect_style_name")|escape:"javascript"}',
    'theme_editor.text_close_editor': '{__("theme_editor.text_close_editor")|escape:"javascript"}',
    'theme_editor.text_close_editor_unsaved': '{__("theme_editor.text_close_editor_unsaved")|escape:"javascript"}',
    'theme_editor.text_reset_changes': '{__("theme_editor.text_reset_changes")|escape:"javascript"}',
    'theme_editor.error_style_exists': '{__("theme_editor.error_style_exists")|escape:"javascript"}',
    'theme_editor.confirm_enable_less': '{__("theme_editor.confirm_enable_less")|escape:"javascript"}',
});
Tygh.te_custom_fonts = {$current_style.custom_fonts|to_json nofilter};
</script>

<form action="{""|fn_url}" method="post" class="cm-ajax" name="theme_editor_form" enctype="multipart/form-data">
{if $theme_manifest.converted_to_css}
    <input type="hidden" name="selected_css_file" value="{$selected_css_file}" />
{else}
    <input type="hidden"
        name="style_id"
        value="{$current_style.style_id}"
        data-ca-is-default="{$current_style.is_default}"
        data-ca-is-can-change-style-name="{($is_can_change_style_name) ? 1 : 0}"
    >
    <input type="hidden" name="style[name]" value="{$current_style.name}">
{/if}
<input type="hidden" name="selected_section" value="{$selected_section}">
<input type="hidden" name="result_ids" value="theme_editor">

<span class="te-nav"><a id="sw_theme_editor_container" class="te-minimize cm-combination" title="{__("theme_editor.hide_show")}">
        {include_ext file=$icon_path
            class="glyph-left-open"
            data=[
                "data-ca-theme-editor" => "minimizeIconClose"
            ]
        }{include_ext file=$icon_path
            class="glyph-right-open hidden"
            data=[
                "data-ca-theme-editor" => "minimizeIconOpen"
            ]
        }
    </a>
<a href="{"customization.disable_mode?type=theme_editor"|fn_url}" class="te-close cm-te-close-editor" title="{__("theme_editor.close")}">{include_ext file=$icon_path class="glyph-cancel"}</a>
        </span>
</span>

<div class="theme-editor {if $theme_manifest.converted_to_css} te-converted-to-css{/if}"
    data-ca-te-use-dynamic-style="{if $runtime.vendor_id}true{else}false{/if}"
    data-ca-te-content-container="{$content_container}"
    data-bp-sidebar="true"
    style="--te-header-height: {$header_height}px; --te-bottom-height: {$bottom_height}px;"
    id="theme_editor_container">
    <div class="te-overlay{if $is_theme_editor_allowed|default:true} hidden{/if}">
        <div class="te-notification-wrapper">
            <p class="notification-content alert-warning">{__("theme_editor.page_cant_be_configured")}</p>
        </div>
    </div>
    <div class="te-header{if !$props_schema} te-header-no-schema{/if}" id="te_styles_list">
        {if $show_layouts}            
        {if $layouts|count == 1}
            <a class="te-layout-name"><span class="te-layout-label">{__("layout")}: </span><span class="te-layout-title te-layout-nolink">{$layout_data.name}</span></a>
        {else}
            <a id="sw_te-layouts" class="te-layout-name cm-combination"><span class="te-layout-label">{__("layout")}: </span><span class="te-layout-title">{$layout_data.name}</span></a>
            <ul id="te-layouts" class="te-layout-dropdown cm-popup-box">
                {foreach $layouts as $layout}
                    <li><a class="cm-te-change-layout" data-ca-layout-id="{$layout.layout_id}" {if $layout_data.layout_id != $layout.layout_id}href="{$theme_url|fn_link_attach:"s_layout=`$layout.layout_id`"}"{/if}>{$layout.name}</a></li>
                {/foreach}
            </ul>
        {/if}
        {/if}
        <span class="te-title">
            {hook name="theme_editor:title"}
            {__("theme_editor")}
            {if $show_converted_to_css && !$theme_manifest.converted_to_css && !$runtime.vendor_id}
                <a class="te-action-link cm-te-convert-to-css cm-confirm">
                    <span class="te-action-link-title">{__('theme_editor.convert_to_css')}&nbsp;{include_ext file=$icon_path class="ty-icon-help-circle icon-question-sign cm-tooltip" title=__('theme_editor.text_convert_to_css')}</span>
                </a>
            {/if}
            {/hook}
        </span>

        {if !$theme_manifest.converted_to_css}

            {if $props_schema}
            <span class="te-subtitle">{$styles_subtitle}</span>
            <div class="te-header-menu-wrap">
                <div class="te-header-menu-wrap-left">
                    {$current_style_name = $current_style.name}

                    <div class="te-select-box cm-te-selectbox te-theme" tabindex="0"><span class="cm-style-title">{$current_style_name|default:__("none")}</span>{include_ext file=$icon_path class="glyph-down-open te-select-box__icon"}
                    <ul class="te-select-dropdown" id="elm_te_styles">
                        {foreach from=$styles_list item="s_item"}
                            <li class="{if $active_style_id === $s_item.style_id}active{/if}">
                                <a class="cm-te-load-style te-list-item {if $active_style_id === $s_item.style_id}active{/if}"
                                    data-ca-target-id="theme_editor"
                                    href="{"theme_editor.view?style_id=`$s_item.style_id`"|fn_url}"
                                    data-ca-style-id="{$s_item.style_id}"
                                    data-ca-style-name="{$s_item.name}">
                                        {$s_item.name}
                                </a>

                                {if $show_duplicate_style}
                                <a class="ty-icon-wrap-duplicate cm-te-duplicate-style" data-ca-style-id="{$s_item.style_id}">
                                    {include_ext file=$icon_path
                                        class="ty-icon-docs icon-copy te-duplicate-style__icon"
                                        title=__("clone")
                                    }
                                </a>
                                {/if}

                                {if $s_item.is_removable|default:true}
                                    <a class="ty-icon-wrap-remove cm-ajax cm-confirm" data-ca-target-id="te_styles_list" href="{"theme_editor.delete_style?style_id=`$s_item.style_id`"|fn_url}">
                                        {include_ext file=$icon_path
                                            class="ty-icon-trashcan icon-trash te-delete-style__icon"
                                            title=__("delete")
                                        }
                                    </a>
                                {/if}
                            </li>
                        {foreachelse}
                            <li class="active">
                                <a class="cm-te-load-style te-list-item active">--</a>
                            </li>
                        {/foreach}
                    </ul>
                    </div>
                </div>
                <div class="te-header-menu-wrap-right">
                    <button class="te-btn-action ty-float-right" type="submit" name="dispatch[theme_editor.save]">{__("save")}</button>
                </div>
            </div>
            {/if}

            {if $te_sections && $te_sections|@count > 1}
                <span class="te-subtitle">{__("theme_editor.customize")}</span>
                <div class="te-select-box cm-te-selectbox te-customize" tabindex="0">
                    <span>{__($te_sections.$selected_section)}</span>{include_ext file=$icon_path class="glyph-down-open te-select-box__icon"}
                    <ul class="te-select-dropdown cm-te-sections">
                        {foreach from=$te_sections key="section" item="s"}
                        <li {if $selected_section == $section}class="active"{/if} data-ca-target-id="{$section}">{__($s)}</li>
                        {/foreach}
                    </ul>
                </div>
            {/if}
            {if !$props_schema}
                <div class="te-no-schema">
                    <button class="te-btn-action ty-float-right" type="submit" name="dispatch[theme_editor.save]">{__("save")}</button>
                </div>
            {/if}
        {else}
            <span class="te-subtitle">{__("files")}</span>
            <div class="te-header-menu-wrap">
                <div class="te-header-menu-wrap-left">
                    <div class="te-select-box cm-te-selectbox te-theme" tabindex="0"><span class="cm-style-title">{$selected_css_file|default:__("none")}</span>{include_ext file=$icon_path class="glyph-down-open te-select-box__icon"}
                        <ul class="te-select-dropdown">
                            {foreach from=$css_files_list item="css_file"}
                                <li class="{if $css_file == $selected_css_file}active{/if}">
                                    <a class="te-list-item {if $css_file == $selected_css_file}active{/if} cm-te-change-css-file" data-ca-target-id="theme_editor" href="{"theme_editor.view?selected_css_file=`$css_file`"|fn_url}">{$css_file}</a>
                                </li>
                            {foreachelse}
                                <li class="active">
                                    <a class="te-list-item active">--</a>
                                </li>
                            {/foreach}
                        </ul>
                    </div>
                </div>
                <div class="te-header-menu-wrap-right">
                    <button class="te-btn-action float-right" type="submit" name="dispatch[theme_editor.save]">{__("save")}</button>
                </div>
            </div>


        {/if}
    <!--te_styles_list--></div>
<div class="te-content{if !$props_schema} te-content-no-schema{/if}">
<div class="te-section cm-te-disable-scroll">
{if !$theme_manifest.converted_to_css}

    {if $te_sections.te_general}
    <div class="te-wrap te-general cm-te-section {if $selected_section != "te_general"}hidden{/if}" id="te_general">
        <div class="te-inner-wrap">
            <div class="te-general-group">

                {if $cse_logos && $cse_logos.favicon}
                    {assign var="id" value=$cse_logos.favicon.logo_id}
                    {assign var="image" value=$cse_logos.favicon.image}
                {else}
                    {assign var="id" value=0}
                    {assign var="image" value=[]}
                {/if}

                <input type="text" class="hidden" name="logotypes_image_data[{$id}][type]" value="M">
                <input type="text" class="hidden" name="logotypes_image_data[{$id}][object_id]" value="{$id}">

                <div class="te-image te-favicon-wrap clearfix">
                    <span class="te-bg-title">{__("theme_editor.favicon")}</span>{include file="backend:views/theme_editor/components/fileuploader.tpl" var_name="logotypes_image_icon[`$id`]" disabled=$current_style.is_default}
                    <div class="te-favicon cm-te-logo" data-ca-image-area="favicon" style="background-image: url('{$image.image_path}'); background-repeat: no-repeat; background-position: center center;"></div>
                    <div class="te-description">{__("theme_editor.favicon_size")}</div>
                </div>

            </div>

            {foreach from=$props_schema.general.fields key="name" item="field"}

                {if $field.type == "checkbox"}
                    <div class="te-general-group">
                        <div class="te-checkbox clearfix">
                            <label for="elm_toggle_general_{$name}">
                                <input type="hidden" name="style[data][{$name}]" value="false" class="cm-te-value-changer" />
                                <input type="checkbox" name="style[data][{$name}]" class="cm-te-value-changer" id="elm_toggle_general_{$name}" value="true" {if $current_style.data.$name == "true"}checked="checked"{/if}><span class="te-toggle"><span class="te-toggle-on">{__("theme_editor.on")}</span><span class="te-toggle-off">{__("theme_editor.off")}</span><span class="te-toggle-trigger"></span></span><span class="te-bg-title">{__($field.description)}</span></label>
                        </div>
                    </div>
                {/if}

            {/foreach}
        </div>

        {if $show_reset_button}
        <div class="te-reset-wrap"><button class="te-btn cm-te-reset">{__("theme_editor.reset_general")}</button></div>
        {/if}
    <!--te_general--></div>
    {/if}

    {if $te_sections.te_css}
    <div class="te-wrap te-css cm-te-section {if $selected_section != "te_css"}hidden{/if}" id="te_css">
        <div class="te-inner-wrap">
            <textarea name="style[custom_css]" cols="30" rows="10">{$current_style.custom_css}</textarea>
        </div>

        {if $show_reset_button}
        <div class="te-reset-wrap"><button class="te-btn cm-te-reset">{__("theme_editor.reset_css")}</button></div>
        {/if}

    <!--te_css--></div>
    {/if}

    {if $te_sections.te_logos}
    <div class="te-wrap te-logos cm-te-section {if $selected_section != "te_logos"}hidden{/if}" id="te_logos">

        <div class="te-tabs cm-te-tabs">
            <ul class="te-pills">
                {foreach from=$cse_logo_types key="type" item="logo"}
                {if $type == "favicon"}
                    {continue}
                {/if}
                <li {if $type == "theme"}class="active"{/if}><a data-ca-target-id="elm_logo_section_{$type}" title="{__("theme_editor_logo.`$type`")}"><span>{__("theme_editor_logo.`$type`")}</span></a></li>
                {/foreach}
            </ul>

            {foreach from=$cse_logo_types key="type" item="logo"}
                {if $type == "favicon"}
                    {continue}
                {/if}

                {if $cse_logos && $cse_logos.$type}
                    {assign var="id" value=$cse_logos.$type.logo_id}
                    {assign var="image" value=$cse_logos.$type.image}
                {else}
                    {assign var="id" value=0}
                    {assign var="image" value=[]}
                {/if}

                <div class="cm-te-tab-contents" {if $type != "theme"}style="display:none;"{/if} id="elm_logo_section_{$type}">
                    <input type="text" class="hidden" name="logotypes_image_data[{$id}][type]" value="M">
                    <input type="text" class="hidden" name="logotypes_image_data[{$id}][object_id]" value="{$id}">
                    <div class="attach-images">
                        <div class="upload-box clearfix">
                            <div class="image-wrap pull-left">
                                <div class="te-image">
                                    <div class="te-bg-image cm-te-logo" data-ca-image-area="{$type}" style="background-image: url('{$image.image_path}'); background-repeat: no-repeat; background-position: center center;"></div>
                                </div>
                                <div class="logo-alt"><input type="text" class="cm-image-field" id="alt_text_{$a}" name="logotypes_image_data[{$id}][image_alt]" value="{$image.alt}" placeholder="{__("alt_text")}"></div>
                            </div>

                            {hook name="theme_editor:logo_uploader"}
                            <div class="te-logos-upload clearfix">
                                <span class="te-bg-title">{__("image")}&nbsp;</span>
                                {include file="backend:views/theme_editor/components/fileuploader.tpl" var_name="logotypes_image_icon[`$id`]" disabled=$current_style.is_default}
                            </div>
                            {/hook}
                        </div>
                    </div>
                </div>
            {/foreach}
        </div>

        {*
        {if $show_reset_button}
        <div class="te-reset-wrap"><button class="te-btn cm-te-reset">{__("theme_editor.reset_logos")}</button></div>
        {/if}
        *}
    <!--te_logos--></div>
    {/if}

    {if $te_sections.te_colors}
    <div class="te-wrap te-colors cm-te-section {if $selected_section != "te_colors"}hidden{/if}" id="te_colors">

        {foreach from=$props_schema.colors.fields key="name" item="field"}
        <div class="te-colors clearfix">
            <label for="elm_te_{$name}">{__($field.description)}</label>

            {$cp_value = ($current_style.data.$name)|default:(($field.default)|default:"#ffffff")}

            {include file="backend:views/theme_editor/components/colorpicker.tpl" cp_name="style[data][`$name`]" cp_id="storage_elm_te_`$name`" cp_value=$cp_value cp_class="cm-te-value-changer" cp_storage="theme_editor"}
        </div>
        {/foreach}

        {if $show_reset_button}
        <div class="te-reset-wrap"><button class="te-btn cm-te-reset">{__("theme_editor.reset_colors")}</button></div>
        {/if}

    <!--te_colors--></div>
    {/if}

    {if $te_sections.te_fonts}
    <div class="te-wrap te-fonts cm-te-section {if $selected_section != "te_fonts"}hidden{/if}" id="te_fonts">
        <div class="te-inner-wrap">
            {foreach from=$props_schema.fonts.fields key="name" item="field"}
            <div class="ty-control-group control-group te-font-group">
                <label for="elm_te_{$name}">{__($field.description)}</label>
                <div class="te-select-box cm-te-selectbox cm-te-google cm-te-value-changer" tabindex="0" data-ca-select-box-default="{$current_style.data.$name}"><span></span>{include_ext file=$icon_path class="glyph-down-open te-select-box__icon"}
                    <input type="text" class="hidden cm-te-selectbox-storage" name="style[data][{$name}]" value="{if $current_style.data.$name}{$current_style.data.$name}{else}{$props_schema.fonts.families|key}{/if}">

                    <ul class="te-select-dropdown">
                        <li class="te-selectbox-group cm-te-selectbox-group">{__("theme_editor.system_fonts")}</li>

                        {foreach from=$props_schema.fonts.families key="family" item="family_name"}
                        <li data-ca-select-box-value="{$family}" {if $current_style.data.$name == $family}class="active"{/if} style="font-family: {$family}">{$family_name}</li>
                        {/foreach}

                        <li class="te-selectbox-group cm-te-selectbox-group cm-te-google-popular">{__("theme_editor.popular_fonts")}</li>
                        <li class="te-selectbox-group cm-te-selectbox-group cm-te-google-other">{__("theme_editor.other_fonts")}</li>
                        <li class="hidden te-selectbox-group cm-te-selectbox-group cm-te-google-custom"></li>
                    </ul>
                </div>

                {if $field.properties.size}
                    {$size_name = $field.properties.size.match}
                    {$current_value = $current_style.data.$size_name|replace:$field.properties.size.unit:""}

                    <div class="te-select-box te-font-size cm-te-selectbox cm-te-value-changer" tabindex="0"><span>{$current_value}</span>{include_ext file=$icon_path class="glyph-down-open te-select-box__icon"}
                        <input type="text" class="hidden cm-te-selectbox-storage" name="style[data][{$size_name}]" value="{$current_style.data.$size_name}">
                        <ul class="te-select-dropdown">
                            {foreach from=$field.properties.size.values item="font_size"}
                            <li data-ca-select-box-value="{$font_size}px" {if $current_value == $font_size}class="active"{/if}>{$font_size}</li>
                            {/foreach}
                        </ul>
                    </div>
                {/if}

                {if $field.properties.style}
                {foreach from=$field.properties.style key="key" item="prop"}
                {$prop_name = $prop.match}

                <div class="te-font-style-wrap">
                    <input type="hidden" name="style[data][{$prop_name}]" value="{$prop.default}" />
                    <input class="cm-te-value-changer te-font-style-checkbox" type="checkbox" id="font_style_{$name}_{$key}" name="style[data][{$prop_name}]" value="{$prop.property}" {if $current_style.data.$prop_name == $prop.property}checked="checked"{/if} /><label for="font_style_{$name}_{$key}" class="te-font-style {$prop.property}">{$key}</label>
                </div>
                {/foreach}
                {/if}
            </div>
            {/foreach}
        </div>

    {if $show_reset_button}
    <div class="te-reset-wrap"><button class="te-btn cm-te-reset">{__("theme_editor.reset_fonts")}</button></div>
    {/if}

    <!--te_fonts--></div>
    {/if}

    {if $te_sections.te_backgrounds}
    <div class="te-wrap te-bg cm-te-section {if $selected_section != "te_backgrounds"}hidden{/if}" id="te_backgrounds">

        <div class="te-inner-wrap">
            {hook name="theme_editor:backgrounds"}
            {foreach from=$props_schema.backgrounds.fields key="name" item="field"}
            <div class="ty-control-group te-bg-group">
                <label for="elm_te_{$name}">{__($field.description)}</label>

                <div>
                    {if $field.properties.color}
                        {$field_name = $field.properties.color.match}

                        <div class="te-color-picker-container te-colors clearfix">
                            <span class="te-bg-title">{__($field.properties.color.description)|default:__("theme_editor.background_color")}&nbsp;</span>

                            {if $field.gradient || $field.transparent || $field.full_width}
                            <a id="sw_backgrounds_adv_color_{$name}" class="cm-combination te-advanced-options">{include_ext file=$icon_path class="glyph-cog"}</a>
                            {/if}

                            {$color = $current_style.data.$field_name|replace:"transparent":""}

                            {include file="backend:views/theme_editor/components/colorpicker.tpl" cp_name="style[data][`$field_name`]" cp_id="storage_elm_te_`$name`" cp_value=$color|default:"#ffffff" cp_class="cm-te-value-changer" cp_storage="theme_editor"}
                        </div>
                    {/if}

                    {if $field.gradient || $field.transparent || $field.full_width}
                    <div id="backgrounds_adv_color_{$name}" class="te-bg-advanced hidden clearfix">
                            <div class="te-advanced-connector"></div>

                        {if $field.gradient}
                        {$field_gradient = $field.gradient.match}
                        <div class="te-gradient-color clearfix">
                            <span class="te-bg-title">{__("theme_editor.gradient")}&nbsp;</span>
                            {$gradient_color = $current_style.data.$field_gradient|default:$current_style.data.$field_name}
                            {include file="backend:views/theme_editor/components/colorpicker.tpl" cp_name="style[data][`$field_gradient`]" cp_id="storage_elm_te_`$name`_gradient" cp_value=($gradient_color|replace:"transparent":"")|default:"#ffffff" cp_class="cm-te-value-changer" cp_storage="theme_editor"}
                        </div>
                        {/if}

                        {if $field.full_width}
                            {if $field.full_width.type}
                            <div class="te-fullwidth te-checkbox clearfix">
                                <label for="elm_toggle_full_width_{$name}">
                                    <input type="hidden" name="style[data][{$field.full_width.match}]" value="false" class="cm-te-value-changer" />
                                    <input type="checkbox" name="style[data][{$field.full_width.match}]" class="cm-te-value-changer" id="elm_toggle_full_width_{$name}" value="true" {if $current_style.data[$field.full_width.match] == "true"}checked="checked"{/if}>
                                    <span class="te-toggle">
                                        <span class="te-toggle-on">{__("theme_editor.on")}</span>
                                        <span class="te-toggle-off">{__("theme_editor.off")}</span>
                                        <span class="te-toggle-trigger"></span>
                                    </span>
                                        <span class="te-bg-title">{__("theme_editor.full_width")}</span>
                                    </label>
                            </div>
                            {else}
                            <div class="te-fullwidth te-checkbox clearfix">
                                <label for="elm_toggle_full_width_{$name}">
                                    <input type="hidden" name="style[data][copy][full_width][{$name}]" value="0">
                                    <input type="checkbox" name="style[data][copy][full_width][{$name}]" class="cm-te-value-changer" id="elm_toggle_full_width_{$name}" value="1" {if $current_style.data[$field.properties.color.match] == $current_style.data[$field.full_width.match]}checked="checked"{/if}>
                                    <span class="te-toggle">
                                        <span class="te-toggle-on">{__("theme_editor.on")}</span>
                                        <span class="te-toggle-off">{__("theme_editor.off")}</span>
                                        <span class="te-toggle-trigger"></span>
                                    </span>
                                        <span class="te-bg-title">{__("theme_editor.full_width")}</span>
                                </label>
                            </div>
                            {/if}
                        {/if}


                        {if $field.transparent}
                        <div class="te-transparent te-checkbox clearfix">
                            <label for="elm_toggle_transparent_{$name}">
                                <input type="hidden" name="style[data][{$field.transparent.match}]" value="false" class="cm-te-value-changer">
                                <input type="checkbox" name="style[data][{$field.transparent.match}]" class="cm-te-value-changer" id="elm_toggle_transparent_{$name}" value="true" {if $current_style.data[$field.transparent.match] == "true"}checked="checked"{/if}>
                                <span class="te-toggle">
                                    <span class="te-toggle-on">{__("theme_editor.on")}</span>
                                    <span class="te-toggle-off">{__("theme_editor.off")}</span>
                                    <span class="te-toggle-trigger"></span>
                                </span>
                                <span class="te-bg-title">{__("theme_editor.transparent")}</span>
                            </label>
                        </div>
                        {/if}
                    </div>
                    {/if}

                    {if $field.properties.pattern}
                        <div class="te-bg-pattern-group clearfix">
                            <span class="te-bg-title">{__("theme_editor.pattern")}</span>
                            <a id="sw_backgrounds_adv_pattern_{$name}" class="te-advanced-options cm-combination">{include_ext file=$icon_path class="glyph-cog"}</a>
                            <div id="elm_preview_{$name}" class="te-pattern-preview {if !$current_style.parsed} te-pattern-empty{/if} input-prepend cm-te-pattern-selector" data-ca-pattern-dialog="backgrounds_adv_pattern_selector_{$name}">
                                {if $current_style.parsed}
                                    <div class="te-pattern-preview__img cm-pattern-preview__img"
                                        data-te-pattern-preview-img-url="{$current_style.parsed[$field.properties.pattern]}"
                                        style="--te-pattern-preview-img: url('{$current_style.parsed[$field.properties.pattern]}');"
                                    ></div>
                                {else}
                                    {include_ext file=$icon_path class="glyph-image te-pattern-empty__icon"}
                                {/if}
                            </div>
                            <div id="backgrounds_adv_pattern_selector_{$name}" class="hidden te-bg-pattern-selector cm-te-patterns-container">
                                <div class="te-bg-pattern-container">
                                    <div class="te-bg-pattern-list">
                                        <ul class="cm-te-pattern-list" data-ca-holder-id="elm_holder_{$name}">
                                            <li><div class="te-pattern-preview te-pattern-empty cm-te-select-pattern">
                                                    {include_ext file=$icon_path class="glyph-image te-pattern-empty__icon"}
                                                </div></li>
                                            {foreach from=$theme_patterns item="pattern"}
                                                <li><div class="te-pattern-preview cm-te-select-pattern">
                                                        <div class="te-pattern-preview__img cm-pattern-preview__img"
                                                            data-te-pattern-preview-img-url="{$pattern}?{$smarty.const.TIME}"
                                                            style="--te-pattern-preview-img: url('{$pattern}?{$smarty.const.TIME}');"
                                                        ></div>
                                                    </div></li>
                                            {/foreach}
                                            <li class="divider"></li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                            <input type="text" class="hidden cm-te-pattern-holder cm-te-value-changer" id="elm_holder_{$name}" name="style[data][{$field.properties.pattern}]" data-ca-preview-id="elm_preview_{$name}" value="{$current_style.parsed[$field.properties.pattern]|default:"transparent"}">
                        </div>
                    {/if}

                    <div id="backgrounds_adv_pattern_{$name}" class="te-bg-advanced hidden">
                        {if $field.properties.pattern}
                            <div class="te-bg-custome-image clearfix">
                                <span class="te-bg-title">{__("theme_editor.upload_image")}</span>
                            {include file="backend:views/theme_editor/components/fileuploader.tpl" var_name="backgrounds[`$field.properties.pattern`]" disabled=$current_style.is_default}
                            </div>
                        {/if}

                        {if $field.properties.position}
                            <div class="te-advanced-connector"></div>
                            <div class="te-bg-position clearfix">
                            <span class="te-bg-title">{__("theme_editor.position")}&nbsp;</span>
                                <div class="sse-bg-position-main-wrap clearfix">
                                    <div class="te-bg-position-wrap clearfix">
                                        {strip}
                                            <div class="te-bg-position-item">
                                                <input class="cm-te-value-changer" type="radio" id="top_left" name="style[data][{$field.properties.position}]" value="top left" {if $current_style.data[$field.properties.position] == "top left"}checked="checked"{/if} />
                                                <label for="top_left">{include_ext file=$icon_path class="glyph-arrow-up-left"}</label>
                                            </div>
                                            <div class="te-bg-position-item"><input class="cm-te-value-changer" type="radio" id="top_center" name="style[data][{$field.properties.position}]" value="top center" {if $current_style.data[$field.properties.position] == "top center"}checked="checked"{/if} />
                                            <label for="top_center">{include_ext file=$icon_path class="glyph-arrow-up"}</label></div>
                                            <div class="te-bg-position-item"><input class="cm-te-value-changer" type="radio" id="top_right" name="style[data][{$field.properties.position}]" value="top right" {if $current_style.data[$field.properties.position] == "top right"}checked="checked"{/if} />
                                            <label for="top_right">{include_ext file=$icon_path class="glyph-arrow-up-right"}</label></div>
                                        {/strip}
                                    </div>
                                    <div class="te-bg-position-wrap clearfix">
                                        {strip}
                                            <div class="te-bg-position-item">
                                                <input class="cm-te-value-changer" type="radio" id="center_left" name="style[data][{$field.properties.position}]" if="center_left" value="center left" {if $current_style.data[$field.properties.position] == "center left"}checked="checked"{/if} />
                                                <label for="center_left">{include_ext file=$icon_path class="glyph-arrow-left"}</label>
                                            </div>
                                            <div class="te-bg-position-item">
                                                <input class="cm-te-value-changer" type="radio" id="center_center" name="style[data][{$field.properties.position}]" value="center center" {if $current_style.data[$field.properties.position] == "center center"}checked="checked"{/if} />
                                                <label for="center_center">{include_ext file=$icon_path class="glyph-square"}</label>
                                            </div>
                                            <div class="te-bg-position-item">
                                                <input class="cm-te-value-changer" type="radio" id="center_right" name="style[data][{$field.properties.position}]" value="center right" {if $current_style.data[$field.properties.position] == "center right"}checked="checked"{/if} />
                                                <label for="center_right">{include_ext file=$icon_path class="glyph-arrow-right"}</label>
                                            </div>
                                        {/strip}
                                    </div>
                                    <div class="te-bg-position-wrap clearfix">
                                        {strip}
                                            <div class="te-bg-position-item">
                                                <input class="cm-te-value-changer" type="radio" id="bottom_left" name="style[data][{$field.properties.position}]" value="bottom left" {if $current_style.data[$field.properties.position] == "bottom left"}checked="checked"{/if} />
                                                <label for="bottom_left">{include_ext file=$icon_path class="glyph-arrow-down-left"}</label>
                                            </div>
                                            <div class="te-bg-position-item">
                                                <input class="cm-te-value-changer" type="radio" id="bottom_center" name="style[data][{$field.properties.position}]" value="bottom center" {if $current_style.data[$field.properties.position] == "bottom center"}checked="checked"{/if} />
                                                <label for="bottom_center">{include_ext file=$icon_path class="glyph-arrow-down"}</label>
                                            </div>
                                            <div class="te-bg-position-item">
                                                <input class="cm-te-value-changer" type="radio" id="bottom_right" name="style[data][{$field.properties.position}]" value="bottom right" {if $current_style.data[$field.properties.position] == "bottom right"}checked="checked"{/if} />
                                                <label for="bottom_right">{include_ext file=$icon_path class="glyph-arrow-down-right"}</label>
                                            </div>
                                        {/strip}
                                    </div>
                                </div>
                            </div>
                        {/if}

                        {if $field.properties.repeat}
                        <div>
                            {capture name="repeat_content"}
                                <input type="text" class="hidden" name="style[data][{$field.properties.repeat}]" value="{$current_style.data[$field.properties.repeat]|default:"repeat"}">
                                <ul class="te-select-dropdown">
                                    <li data-ca-select-box-value="repeat" {if $current_style.data[$field.properties.repeat] == "repeat"}class="active" {$repeat_title = __("theme_editor.repeat")}{/if}>{__("theme_editor.repeat")}</li>
                                    <li data-ca-select-box-value="repeat-x" {if $current_style.data[$field.properties.repeat] == "repeat-x"}class="active" {$repeat_title = __("theme_editor.repeat_x")}{/if}>{__("theme_editor.repeat_x")}</li>
                                    <li data-ca-select-box-value="repeat-y" {if $current_style.data[$field.properties.repeat] == "repeat-y"}class="active" {$repeat_title = __("theme_editor.repeat_y")}{/if}>{__("theme_editor.repeat_y")}</li>
                                    <li data-ca-select-box-value="no-repeat" {if $current_style.data[$field.properties.repeat] == "no-repeat"}class="active" {$repeat_title = __("theme_editor.no_repeat")}{/if}>{__("theme_editor.no_repeat")}</li>
                                </ul>
                            {/capture}

                            <div class="te-select-box cm-te-selectbox cm-te-value-changer" tabindex="0"><span>{$repeat_title|default:__("theme_editor.repeat")}</span>{include_ext file=$icon_path class="glyph-down-open te-select-box__icon"}
                                {$smarty.capture.repeat_content nofilter}
                            </div>
                        </div>
                        {/if}

                        {if $field.properties.attachment}
                        <div>
                            {capture name="scroll_content"}
                                <input type="text" class="hidden" name="style[data][{$field.properties.attachment}]" value="{$current_style.data[$field.properties.attachment]|default:"scroll"}">
                                <ul class="te-select-dropdown">
                                    <li data-ca-select-box-value="scroll" {if $current_style.data[$field.properties.attachment] == "scroll"}class="active" {$scroll_title = __("theme_editor.scroll")}{/if}>{__("theme_editor.scroll")}</li>
                                    <li data-ca-select-box-value="fixed" {if $current_style.data[$field.properties.attachment] == "fixed"}class="active" {$scroll_title = __("theme_editor.fixed")}{/if}>{__("theme_editor.fixed")}</li>
                                </ul>
                            {/capture}

                            <div class="te-select-box cm-te-selectbox cm-te-value-changer" tabindex="0"><span>{$scroll_title|default:__("theme_editor.scroll")}</span>{include_ext file=$icon_path class="glyph-down-open te-select-box__icon"}
                                {$smarty.capture.scroll_content nofilter}
                            </div>
                        </div>
                        {/if}
                    </div>

                </div>
            </div>
            {/foreach}
            {/hook}
        </div>

        {if $show_reset_button}
        <div class="te-reset-wrap"><button class="te-btn cm-te-reset">{__("theme_editor.reset_backgrounds")}</button></div>
        {/if}

    <!--te_backgrounds--></div>
    {/if}
{else}
    <div class="te-wrap te-css cm-te-section">
        <div class="te-inner-wrap">
            <div id="css_content" class="cm-te-css-editor">{$css_content}</div>
        </div>

        <div class="te-reset-wrap te-enable-less-container">
            <button class="te-btn cm-te-restore-less">{__("theme_editor.enable_less")}</button>
            <span class="te-warning-info">{__("theme_editor.warning_css_changes_will_be_reverted") nofilter}</span>
        </div>

    </div>

{/if}
</div>
</div>


</div>

</form>
<!--theme_editor--></div>
