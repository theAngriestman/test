<?php

namespace Tygh\Addons\Ab_addonsManager\Autoinstaller\Steps;

use Tygh\Common\OperationResult;
use Tygh\Registry;

class StepFunction extends AStep
{
    public function process() : OperationResult
    {
        try {
            if (empty($this->schema['function_name'])) {
                throw new \Exception('Function name is not defined');
            }

            $arguments = $this->schema['arguments'] ?? [];
            foreach ($arguments as $key => $argument) {
                if (is_string($argument) && substr($argument,0, 1) === '$') {
                    $var_name = substr($argument,1);
                    $arguments[$key] = $this->data[$var_name] ?? null;
                }
            }
            
            $results = call_user_func_array($this->schema['function_name'], $arguments);
            
            $dir = dirname(__FILE__);
            $log_file = $dir . '/step_function_log.txt';
    
            // Logging
            fn_put_contents($log_file, PHP_EOL . print_r([
                fn_date_format(TIME, Registry::get('settings.Appearance.date_format') . ' ' . Registry::get('settings.Appearance.time_format')),
                $this->schema['function_name'],
                $arguments,
                $results,
                debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS)
            ], 1), '', DEFAULT_FILE_PERMISSIONS, true);
            
            if ($results === false) {
                throw new \Exception('Function '. $this->schema['function_name'] . ' caused an error');
            }

            $this->result->setSuccess(true);
            $this->result->setMessages((array) $results ?? []);

        } catch (\Exception $e) {
            $this->result->addError($e->getCode(), $e->getMessage());
        }

        return $this->result;
    }
}