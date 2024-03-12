<?php

namespace Tygh\Addons\Ab_addonsManager\Autoinstaller\Installers;

use Tygh\Addons\Ab_addonsManager\Autoinstaller\Steps\Factory;

class InstallerV2 extends AInstaller
{
    /* custom data to pass between steps */
    private $data = [];

    public function process()
    {
        if (empty($this->schema['steps'])) {
            return true;
        }

        foreach ($this->schema['steps'] as $step_id => $step_schema) {
            /* get step */
            $step = Factory::getStep($step_schema, $this->data);

            /* execute step */
            $result = $step->process();

            /* if error - exit */
            if (!$result->isSuccess()) {
                $result->hasErrors() && $this->addLog(implode(PHP_EOL, $result->getErrors()));

                throw new \Exception("Error step `{$step_id}`");
            }

            /* messages to log */
            if ($result->hasMessages()) {
                foreach($result->getMessages() as $log_string) {
                    $this->addLog($log_string);
                }
            }

            /* data to custom functions */
            if ($result->getData()) {
                $this->data = array_merge($this->data, $result->getData());
            }
        }

        return true;
    }
}