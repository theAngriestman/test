{$buttons.cities = [
    href => "cities.manage",
    text => __('edit_cities')
]}

{* Export $navigation.dynamic.actions *}
{$navigation.dynamic.actions = $navigation.dynamic.actions|array_merge:$buttons scope=parent}
