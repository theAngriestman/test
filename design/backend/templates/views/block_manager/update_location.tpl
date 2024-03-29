{if !$location.location_id}
    {$html_id = "0"}
{else}
    {$html_id = $location.location_id}
{/if}
{$tabs_count = ($dynamic_object_scheme) ? 2 : 1}

<form action="{""|fn_url}" method="post" enctype="multipart/form-data" class=" form-horizontal" name="location_{$html_id}_update_form">
<div id="location_properties_{$html_id}">
    <input type="hidden" id="s_layout" name="s_layout" value="{$location.layout_id}" />
    <input type="hidden" name="result_ids" value="location_properties_{$html_id}" class="cm-no-hide-input"/>
    <input type="hidden" name="location" value="{$location.location_id}" />
    <input type="hidden" name="location_data[location_id]" value="{$location.location_id}" />

    <div class="tabs cm-j-tabs tabs--enable-fill tabs--count-{$tabs_count}">
        <ul class="nav nav-tabs">
            <li id="location_general_{$html_id}" class="cm-js active"><a>{__("general")}</a></li>
            {if $dynamic_object_scheme}
                <li id="location_object_{$dynamic_object_scheme.object_type}" class="cm-js"><a>{__($dynamic_object_scheme.object_type)}</a></li>
            {/if}
        </ul>
    </div>

    <div class="cm-tabs-content" id="tabs_content_location_{$html_id}">
        <div id="content_location_general_{$html_id}">
            {hook name="block_manager:update_location_general"}
                <div class="control-group">
                    <label for="location_dispatch_{$html_id}" class="cm-required control-label">{__("dispatch")}: </label>
                    <div class="controls"><select id="location_dispatch_{$html_id}_select" name="location_data[dispatch]" class="cm-select-with-input-key cm-reload-form">
                            {foreach $dispatch_descriptions as $k => $v}
                                <option value="{$k}" {if $location.dispatch == $k}selected="selected"{$selected = 1}{/if}>{$v}</option>
                                {if $location.dispatch == $k}
                                    {$not_custom_dispatch = "1"}
                                {/if}
                            {/foreach}
                            <option value="" {if !$selected}selected="selected"{/if}>{__("custom")}</option>
                        </select>
                        <input id="location_dispatch_{$html_id}" class="input-text{if $not_custom_dispatch} input-text-disabled{/if}" {if $not_custom_dispatch}disabled{/if} name="location_data[dispatch]" value="{$location.dispatch}" type="text"></div>
                </div>
                <div class="control-group">
                    <label for="location_name" class="cm-required control-label">{__("name")}: </label>
                    <div class="controls">
                        <input id="location_name" type="text" name="location_data[name]" value="{$location.name}">
                    </div>
                </div>

                <div class="control-group">
                    <label for="location_title" class="control-label">{__("page_title")}: </label>
                    <div class="controls">
                        <input id="location_title" type="text" name="location_data[title]" value="{$location.title}">
                        {if $location.is_default}
                            <div>
                                <label class="checkbox inline"><input type="checkbox" name="location_data[copy_translated][]" value="title" />{__("copy_to_other_locations")}</label>
                            </div>
                        {/if}
                        <p class="muted description">{__("ttc_page_title")}</p>
                    </div>
                </div>

                <div class="control-group">
                    <label for="location_meta_descr" class="control-label">{__("meta_description")}: </label>
                    <div class="controls">
                        <textarea id="location_meta_descr" name="location_data[meta_description]" class="span9" cols="55" rows="4">{$location.meta_description}</textarea>
                        {if $location.is_default}
                        <label class="checkbox inline"><input type="checkbox" name="location_data[copy_translated][]" value="meta_description" />{__("copy_to_other_locations")}</label>
                        {/if}
                    </div>
                </div>

                <div class="control-group">
                    <label for="location_meta_key" class="control-label">{__("meta_keywords")} </label>
                    <div class="controls">
                        <textarea id="location_meta_key" name="location_data[meta_keywords]" class="span9" cols="55" rows="4">{$location.meta_keywords}</textarea>
                        {if $location.is_default}
                        <label class="checkbox inline"><input type="checkbox" name="location_data[copy_translated][]" value="meta_keywords" />{__("copy_to_other_locations")}</label>
                        {/if}
                    </div>
                </div>

                <div class="control-group">
                    <label for="location_custom_html" class="control-label">{__("head_custom_html")}</label>
                    <div class="controls">
                        <textarea id="location_custom_html" name="location_data[custom_html]" class="span9" cols="55" rows="4">{$location.custom_html}</textarea>
                        {if $location.is_default}
                            <label class="checkbox inline"><input type="checkbox" name="location_data[copy][]" value="custom_html" />{__("copy_to_other_locations")}</label>
                        {/if}
                        <p class="muted description">{__("tt_views_block_manager_update_location_head_custom_html") nofilter}</p>
                    </div>
                </div>

                <div class="control-group">
                    <label for="location_is_default" class="control-label">{__("default")} </label>
                    <div class="controls">
                        <input type="hidden" name="location_data[is_default]" value="N">
                        <input type="checkbox" name="location_data[is_default]" value="Y" id="location_is_default" {if $location.is_default}checked="checked" disabled="disabled"{/if}>
                        <p class="muted description">{__("tt_views_block_manager_update_location_default")}</p>
                    </div>
                </div>

                <div class="control-group">
                    <label for="location_position" class="control-label">{__("position")}: </label>
                    <div class="controls">
                        <input id="location_position" type="text" name="location_data[position]" value="{$location.position}">
                    </div>
                </div>
            {/hook}
        </div>
        {if $dynamic_object_scheme}
            <div id="content_location_object_{$dynamic_object_scheme.object_type}">
                {include_ext
                    file=$dynamic_object_scheme.picker
                        data_id="location_`$html_id`_object_ids"
                        input_name="location_data[object_ids]"
                        item_ids=$location.object_ids
                        view_mode="links"
                        params_array=$dynamic_object_scheme.picker_params
                        start_pos=$start_position
                    }
            </div>
        {/if}
    </div>
<!--location_properties_{$html_id}--></div>
<div class="buttons-container">
    {if !$location.is_default && $location.location_id > 0}
        <div class="botton-picker-remove pull-left">
            <a class="cm-confirm cm-post btn cm-tooltip" href="{"block_manager.delete_location?location_id=`$location.location_id`"|fn_url}" title="Remove current location">
                {include_ext file="common/icon.tpl" class="icon-trash"}
            </a>
        </div>
    {/if}
    {include file="buttons/save_cancel.tpl" but_name="dispatch[block_manager.update_location]" cancel_action="close" save=$html_id}
</div>
</form>
