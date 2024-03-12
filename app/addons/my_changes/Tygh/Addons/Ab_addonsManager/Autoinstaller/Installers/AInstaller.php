<?php

namespace Tygh\Addons\Ab_addonsManager\Autoinstaller\Installers;

Abstract class AInstaller
{
    protected $schema;
    protected $log = [];

    public function __construct($schema)
    {
        $this->schema = $schema;
    }

    abstract public function process();

    protected function addLog($string)
    {
        $this->log[] = $string;
    }

    public function getLog()
    {
        return $this->log;
    }
}