{if $name}{strip}
    {*
        Import
        ---
        $name
        $id
        $placeholder
        $form_id
        $value
        $dispatch
    *}
    {$id = $id|default:$name}
    {$placeholder = $placeholder|default:__("search")}
    {$form_id = $form_id|default:"search_form"}

    <div class="context-search">
        <label class="context-search__label">
            <input type="text" {""}
                name="{$name}" {""}
                id="{$id}" {""}
                form="{$form_id}" {""}
                class="input-fill context-search__input" {""}
                {if $value}value="{$value}" {""}{/if}
                placeholder="{$placeholder}"
            />
        </label>
    </div>
{/strip}{/if}