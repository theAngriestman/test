<?php

namespace Tygh\Addons\Ab_addonsManager\Autoinstaller\Steps;

class Factory
{
    public static function getStep($schema, $data)
    {
        if (empty($schema['type'])) {
            return false;
        }

        if ($schema['type'] === 'file') {
            $step = new StepFile($schema['params'], $data);
        } else {
            $step = new StepFunction($schema['params'], $data);
        }

        return empty($step) ? false : $step;
    }
}