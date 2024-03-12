{if "orders.update_status"|fn_check_view_permissions:"POST"}
    <div class="sidebar-row" style="margin-bottom: 25px;">
        <div class="statuses" id="order_status_block">
			<h6 class="subheader">{__("status")}</h6>
			{hook name="order_management:order_status"}
			{include file="common/select_object.tpl"
				text_wrap=true
				style="field"
				items=$order_statuses
				select_container_name="order_status"
				selected_key=$cart.order_status|default:"O"
			}
			{/hook}
		<!--order_status_block--></div>
	</div>
{/if}