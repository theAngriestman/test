{$buttons.gift_certificates = [
    href => "statuses.manage?type=`$smarty.const.STATUSES_GIFT_CERTIFICATE`",
    text => __("gift_certificates.edit_gift_certificate_statuses")
]}

{* Export $navigation.dynamic.actions *}
{$navigation.dynamic.actions = $navigation.dynamic.actions|array_merge:$buttons scope=parent}