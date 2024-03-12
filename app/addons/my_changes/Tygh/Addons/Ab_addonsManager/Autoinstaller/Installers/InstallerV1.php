<?php

namespace Tygh\Addons\Ab_addonsManager\Autoinstaller\Installers;

class InstallerV1 extends AInstaller
{
    public function process()
    {
        foreach ($this->schema['steps'] as $step => $functions) {
            fn_get_schema('autoinstall', "$step.functions");

            foreach ($functions as $function) {
                if (!is_array($function)) {
                    $func_name = $function;
                    $args = [];
                } else {
                    $func_name = array_shift($function);
                    $args = $function;
                }

                if (!empty($args)) {
                    foreach ($args as &$arg) {
                        if (is_string($arg) && substr($arg, 0, 1) == '@' && isset($this->schema['config'][substr($arg, 1)])) {
                            $arg = $this->schema['config'][substr($arg, 1)];
                        }
                    }
                }

                if (function_exists($func_name)) {
                    try {
                        $r = call_user_func_array($func_name, $args);
                    } catch (\Exception $e) {
                        throw new \Exception("Error step `{$step}`: {$e->getMessage()}");
                    }

                    if (!empty($r) && is_string($r)) {
                        $this->addLog($r);
                    }
                }
            }
        }

        return true;
    }
}