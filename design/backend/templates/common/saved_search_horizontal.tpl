{if $dispatch && $view_type}
    {$saved_search_count_min_threshold = 4}
    {$saved_search_count_max_threshold = 7}
    {$new_search = $allow_new_search|default: true}
    {$views = $view_type|fn_get_views}
    {$return_current_url = $config.current_url|fn_query_remove:"view_id":"new_view"}
    {$redirect_current_url = $config.current_url|escape:url}
    {$saved_search_count_threshold = ($context_search)
        ? $saved_search_count_min_threshold
        : $saved_search_count_max_threshold
    }
    {$saved_search_count_threshold = $saved_search_count_threshold - 1} {* "All" view *}
    {$views_active_before_threshold = []}
    {$temp_views = $views}

    {* Fill pills if there are fewer than 7 *}
    {$enable_fill = $enable_fill|default:true}

    {* Add "All" and "Save this search as" tabs *}
    {$views_count = ($search_filters_type === "in_content" && $new_search) ? $views|@count + 2 : $views|@count + 1}

    {if $views}
        {capture name="move_active_before_threshold"}
            {foreach $temp_views as $view}
                {if $view@iteration <= $saved_search_count_threshold || $view.view_id !== $search.view_id}
                    {continue}
                {/if}
                {$active_view = $temp_views|array_splice:($view@index):1}
                {$temp_views|array_splice:($saved_search_count_threshold - 1):0:$active_view}
                {break}
            {/foreach}
            {foreach $temp_views as $view}
                {$views_active_before_threshold[$view.view_id] = $view}
            {/foreach}
        {/capture}
    {/if}

    <div class="pills {if $enable_fill}pills--enable-fill{/if} pills--count-{$views_count}">
        <ul class="nav nav-pills saved-search-horizontal">
            <li class="saved-search__item saved-search__item--horizontal {if !$search.view_id && !$search.temp_view}active{/if}">
                <a href="{"`$dispatch`.reset_view?`$view_suffix`"|fn_url}" class="saved-search__item-name saved-search__item-name--horizontal">{__("all")}</a>
            </li>
            {if $views}
                {foreach $views_active_before_threshold as $view name=views}
                    {if $view@iteration > $saved_search_count_threshold}
                        {continue}
                    {/if}
                    {if $view.view_id === $search.view_id
                        && (
                            $last_view_current_object_schema.allow_default_view
                            || $new_search
                        )
                    }
                    <li class="dropdown active saved-search__item saved-search__item--horizontal">
                        <a data-toggle="dropdown" class="cm-view-name dropdown-toggle saved-search__item-name saved-search__item-name--horizontal" href="#">
                            {$view.name} <b class="caret"></b>
                        </a>
                        <ul class="dropdown-menu">
                            {if $last_view_current_object_schema.allow_default_view}
                                <li>
                                    {if $view.is_default === "YesNo::YES"|enum}
                                        <a href="{"`$dispatch`.unset_default_view?view_id=`$view.view_id`&redirect_url=`$redirect_current_url`"|fn_url}"
                                            class="cm-confirm"
                                            {([
                                                "data-ca-confirm-text" => __("saved_search.set_as_non_default_confirm", [
                                                        "[name]" => $view.name
                                                    ])
                                            ])|render_tag_attrs nofilter}
                                        >
                                            <span class="flex-inline top">
                                                {include_ext file="common/icon.tpl" class="icon-pushpin"}
                                            </span>
                                            {__("saved_search.set_as_non_default")}
                                        </a>
                                    {else}
                                        <a href="{"`$dispatch`.set_default_view?view_id=`$view.view_id`&redirect_url=`$redirect_current_url`"|fn_url}"
                                            class="cm-confirm"
                                            {([
                                                "data-ca-confirm-text" => __("saved_search.set_as_default_confirm", [
                                                        "[name]" => $view.name
                                                    ])
                                            ])|render_tag_attrs nofilter}
                                        >
                                            <span class="flex-inline top">
                                                {include_ext file="common/icon.tpl" class="icon-pushpin"}
                                            </span>
                                            {__("saved_search.set_as_default")}
                                        </a>
                                    {/if}
                                </li>
                            {/if}
                            {if $new_search}
                                <li>
                                    <a href="{"`$dispatch`.delete_view?view_id=`$view.view_id`&redirect_url=`$redirect_current_url`"|fn_url}"
                                        class="cm-confirm text-error"
                                    >
                                        <span class="flex-inline top">
                                            {include_ext file="common/icon.tpl" class="icon-trash"}
                                        </span>
                                        {__("delete")}
                                    </a>
                                </li>
                            {/if}
                        </ul>
                    </li>
                    {elseif $view.view_id === $search.view_id}
                    <li class="active saved-search__item saved-search__item--horizontal">
                        <a class="cm-view-name saved-search__item-name" href="#">
                            {$view.name}
                        </a>
                    </li>
                    {else}
                    <li class="saved-search__item saved-search__item--horizontal">
                        <a class="cm-view-name saved-search__item-name saved-search__item-name--horizontal
                        {if $last_view_current_object_schema.allow_default_view}
                            saved-search__item-name--default-view
                        {/if}
                        "
                            data-ca-view-id="{$view.view_id}"
                            href="{"`$dispatch`?view_id=`$view.view_id``$view_additional_parameters`&`$view_suffix`"|fn_url}"
                        >
                            {$view.name}
                        </a>
                    </li>
                    {/if}
                {/foreach}
            {/if}

            {if $search.temp_view}
                <li class="saved-search__item saved-search__item--horizontal active">
                    <a href="#">{__("custom_search")}</a>
                </li>
            {/if}

            {if $views && $views_active_before_threshold|@count > $saved_search_count_threshold}
                {capture name="tools_list"}
                    {foreach $views_active_before_threshold as $title => $view}
                        {if $view@iteration <= $saved_search_count_threshold}
                            {continue}
                        {/if}
                        <li class="saved-search__dropdown-item {if $view.view_id === $search.view_id}active{/if} {if $view.wrapper_class}{$view.wrapper_class}{/if}">
                            {btn type=$view.type|default:"list"
                                href="`$dispatch`?view_id=`$view.view_id``$view_additional_parameters`&`$view_suffix`"
                                text=$view.name
                                title=$view.description
                                id=$view.id
                                method=$view.method
                                target=$view.target
                                process=$view.process
                                class=($view.meta) ? "saved-search__dropdown-item-name `$view.meta`" : "saved-search__dropdown-item-name"
                                form=$view.form
                                dispatch=$view.dispatch
                                target=$view.target
                                data=[
                                    "data-ca-view-id" => $view.view_id
                                ]
                                onclick=$view.onclick
                                raw=$view.raw
                                icon=$view.icon
                            }
                        </li>
                    {/foreach}
                {/capture}
                {include file="common/tools.tpl"
                    prefix="saved_search_horizontal"
                    hide_actions=true
                    tools_list=$smarty.capture.tools_list
                    tool_meta="saved-search__item-more"
                    link_text=__("saved_search.more")
                    override_meta="saved-search__item-name--horizontal"
                    caret=true
                }
            {/if}

            {if $search_filters_type === "in_content" && $new_search}
                <li class="saved-search__item saved-search__item--horizontal">
                    <a class="saved-search__item-name saved-search__item-name--horizontal saved-search__item-name--new cm-dialog-opener"
                        id="opener_search_save"
                        data-ca-target-id="content_search_save"
                        href="#"
                    >
                        {include_ext file="common/icon.tpl" class="icon-plus"}
                    </a>
                </li>
            {/if}
        </ul>
    </div>
{/if}
