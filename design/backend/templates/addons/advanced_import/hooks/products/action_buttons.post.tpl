{if fn_check_permissions("import_presets", "update", "admin", "POST")}
    {$buttons_import_href = "import_presets.manage&object_type=products"}

    {* Export *}
    {$buttons.import.href = $buttons_import_href scope=parent}
{/if}