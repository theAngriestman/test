<?php

namespace Tygh\Addons\Ab_addonsManager\Autoinstaller\Steps;

use Tygh\Common\OperationResult;
use Tygh\Addons\Ab_addonsManager\DemoData;

class StepFile extends AStep
{
    public function process(): OperationResult
    {
        try {
            if (empty($this->schema['filename']) || empty($this->schema['addon'])) {
                throw new \Exception('Filename is not defined');
            }

            $params = [
                'file' => $this->schema['filename'],
                'addon' => $this->schema['addon'],
            ];

            $this->result = DemoData::getFile($params);
            
        } catch (\Exception $e) {
            $this->result->addError($e->getCode(), $e->getMessage());
        }

        return $this->result;
    }
}
