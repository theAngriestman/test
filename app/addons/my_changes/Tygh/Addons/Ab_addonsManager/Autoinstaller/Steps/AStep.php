<?php

namespace Tygh\Addons\Ab_addonsManager\Autoinstaller\Steps;

use Tygh\Common\OperationResult;

Abstract class AStep
{
    protected $schema;
    protected $result;
    protected $data;

    public function __construct($schema, $data)
    {
        $this->schema = $schema;
        $this->data = $data;
        $this->result = new OperationResult();
    }

    abstract public function process() : OperationResult;
}