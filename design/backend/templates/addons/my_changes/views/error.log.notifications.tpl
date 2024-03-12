<div class="ty-product-notification__buttons clearfix">
    <div style="float: left">
        {include file="buttons/button.tpl" but_role="action" but_meta="cm-ajax cm-post btn cm-notification-close" but_text=__("clear") but_href="init.clear_error_log"}
    </div>
    <div style="float: right">
        {$link=fn_url('', 'C')}
        <a href="{"`$link`error.log.txt?t=`$smarty.now`"}" target="_blank" class="btn btn-primary ty-btn__primary ty-btn__big ty-btn">{__("view")}</a>
    </div>
</div>
<div class="ty-product-notification__body cm-notification-max-height" style="overflow-x: auto; overflow-y: auto;">
    <pre style="display: inline-block; white-space: pre; background-color: #efefef; padding: 10px;">{$log nofilter}</pre>
</div>
