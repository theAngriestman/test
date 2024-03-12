<?php

namespace Tygh\Addons\Ab_addonsManager\Autoinstaller\Installers;

class Factory
{
    public static function getInstaller($schema)
    {
        $schema_version = empty($schema['version']) ? 1 : intval($schema['version']);

        if ($schema_version === 2) {
            $installer = new InstallerV2($schema);
        } else {
            $installer = new InstallerV1($schema);
        }

        return $installer;
    }
}