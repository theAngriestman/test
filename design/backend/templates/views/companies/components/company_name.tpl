{$type = $type|default:"default"}
{hook name="companies:company_name"}
{if !$runtime.simple_ultimate && ($object.company_id || $object.company_name)}
    {if !$object.company_name}
        {$_company_name = $object.company_id|fn_get_company_name}
    {/if}

    {if $show_hidden_input}
        <input type="hidden" id="company_id_{$object.product_id}" value="{$object.company_id}" />
        <input type="hidden" id="company_name_{$object.product_id}" value="{$object.company_name|default:$_company_name}" />
    {/if}

    {if $auth.user_type !== "UserTypes::VENDOR"|enum}
        {if $type === "basic"}
            <span class="company-name">{$object.company_name|default:$_company_name}</span>
        {else if $type === "simple" || $simple}
            <small class="muted company-name">{$object.company_name|default:$_company_name}</small>
        {else}
            {* default *}
            <p class="muted company-name"><small>{$object.company_name|default:$_company_name}</small></p>
        {/if}
    {/if}
{/if}
{/hook}