<?php

namespace Tygh\Addons\Ab_addonsManager\Autoinstaller;

use Tygh\Addons\Ab_addonsManager\Autoinstaller\Installers\Factory;
use Tygh\Registry;

class Autoinstaller
{
    public function __construct()
    {

    }

    private function get_schema($addon_id)
    {
        return fn_get_schema('autoinstall', $addon_id);
    }

    public function process($addon_id)
    {
        $schema = $this->get_schema($addon_id);
        if (empty($schema) || !is_array($schema)) {
            return true;
        }

        $this->log(PHP_EOL . '[' . $addon_id . ']');

        $installer = Factory::getInstaller($schema);

        try {
            $installer->process();
            if ($log_data = $installer->getLog()) {
                foreach ($log_data as $k => $v) {
                    $this->log($k . ' = "' . addslashes($v) . '"');
                }
            }
        } catch (\Exception $exception) {
            $this->log($exception->getMessage());

            return false;
        }

        return true;
    }

    private function log($string)
    {
        file_put_contents(Registry::get('config.dir.root') . '/autoinstall.log', $string . PHP_EOL, FILE_APPEND);
    }
}
