{if "{$runtime.controller}.{$runtime.mode}" == 'addons.update' && $smarty.request.addon && preg_match('/^ab[t]?__/', $smarty.request.addon)}
    {include file="addons/ab__addons_manager/views/ab__am/components/menu.tpl" addon=$smarty.request.addon}
    {$adv_buttons=$smarty.capture.adv_buttons|trim scope=parent}
{/if}