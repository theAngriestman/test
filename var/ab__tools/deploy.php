<?php
$data = get_data();
error_reporting(E_ALL);
ini_set('display_errors', 1);
if (empty($data[0])) {
    echo 'Не переданий параметр вітки для ' . __FILE__ . PHP_EOL;
    return;
}
if (empty($data[1])) {
    echo 'Не переданий параметр послідовності дій для ' . __FILE__ . PHP_EOL;
    return;
}
if (empty($data[2])) {
    echo 'Не переданий параметр php_executable для ' . __FILE__ . PHP_EOL;
    return;
}

list($branch, $action_sequence, $php_executable) = $data;

$branch_dir = __DIR__ . '/branches/' . $branch . '/';
$log_dir = $branch_dir . 'log.log';
$logger = new Logger($log_dir);

$logger->info('Початок обробки завдань ' . $action_sequence);
if (file_exists($branch_dir . 'actions.json')) {
    $dir_root = str_replace('/var/ab__tools','',__DIR__);
    $logger->info('__DIR__ ' . __DIR__);
    $logger->info('$dir_root  ' . $dir_root);

    define('AREA', 'A');
    define('NO_SESSION', true);
    require_once ($dir_root . '/init.php');

     $config = \Tygh\Registry::get('config');

//    $base_dir = Registry::get('config.dir.root');
//    $admin_index = Registry::get('config.admin_index')
//    $base_dir = '/home/lev/reset_script/';
//    $admin_index = 'admin.php';


    $json = file_get_contents($branch_dir . 'actions.json');
    $content = json_decode($json, true);

    if (!empty($content[$action_sequence])) {
        $logger->info('Обробка секції ' . $action_sequence);
        foreach ($content[$action_sequence] as $action_type => $actions) {
            $logger->info('Обробка дій типу ' . $action_type);
            if ($action_type === 'actions') {
                foreach ($actions as $action) {
                    $action_file = $branch_dir . 'actions/' . $action . '.php';
                    if (!file_exists($action_file)) {
                        $logger->waning(sprintf('Не вдалося обробити завдання %s. Файл %s відсутній', $action, $action_file));
                        continue;
                    }
                    $logger->info('Виконуємо ' . $action);
                    require_once $action_file;
                }
            } elseif ($action_type === 'upgrades') {
                $job = new Job(
                    $config['db_host'],
                    $config['db_user'],
                    $config['db_password'],
                    $config['db_name'],
                    DIR_ROOT,
                    $logger,
                    $php_executable,
                    $config['admin_index']
                );
                $logger->info('Виконуємо оновлення модулів і ядра');
                foreach ($actions as $id => $version) {
                    $logger->info(sprintf('Оновлюємо %s до версії %s', $id, $version));
                    $job->upgrade_to($id, $version);
                }
            }
        }
    }
} else {
    $msg = 'Помилка. Файл actions.json не знайдено';
    $logger->error($msg);
}


function get_data()
{
    $data = array();
    $argv = $_SERVER['argv'];
    $totalArgv = count($argv);
    if ($totalArgv > 1) {
        for ($x = 1; $x < $totalArgv; $x++) {
            if (!empty($argv[$x])) {
                $data[] = trim($argv[$x]);
            }
        }
    }
    return $data;
}


class Logger
{
    /**
     * Error message level.
     */
    const LEVEL_ERROR = 'error';

    /**
     * Warning message level.
     */
    const LEVEL_WARNING = 'warning';

    /**
     * Informational message level.
     */
    const LEVEL_INFO = 'info';

    /**
     * @var int number of log files used for rotation.
     */
    private $max_log_files;

    /**
     * @var int maximum log file size, in kilo-bytes.
     */
    private $max_file_size;

    /**
     * @var string Log file path
     */
    private $file_path;

    /**
     * @var int the permission to be set for newly created log files.
     */
    private $dir_mode;

    /**
     * @var int the permission to be set for newly created directories.
     */
    private $file_mode;

    /**
     * Initializes the logger.
     *
     * @param string $file_path Log file path
     * @param int $file_mode The permission to be set for newly created directories.
     * @param int $dir_mode The permission to be set for newly created log files.
     * @param int $max_file_size Maximum log file size, in kilo-bytes.
     * @param int $max_log_files Number of log files used for rotation.
     */
    public function __construct($file_path, $file_mode = 0664, $dir_mode = 0775, $max_file_size = 10240, $max_log_files = 5)
    {
        $this->file_path = $file_path;
        $this->max_file_size = $max_file_size;
        $this->max_log_files = $max_log_files;
        $this->file_mode = $file_mode;
        $this->dir_mode = $dir_mode;

        $dir = dirname($file_path);

        if (!is_dir($dir)) {
            @mkdir($dir, $this->dir_mode);
            chmod($dir, $this->dir_mode);
        }

        if (@filesize($this->file_path) > $this->max_file_size * 1024) {
            $this->rotateFiles();
        }

        if (!file_exists($this->file_path)) {
            @touch($this->file_path);
            chmod($this->file_path, $this->file_mode);
        }
    }

    /**
     * Logs a message
     *
     * @param string $message The message to be logged.
     * @param string $level The level of the message.
     * @param string $category The category of the message.
     */
    public function log($message, $level, $category = null)
    {
        $line = sprintf('%s [%s] [%s]: %s', date('Y-m-d H:i:s'), $level, $category, trim($message));
        $line .= "\n";

        file_put_contents($this->file_path, $line, FILE_APPEND);
        print_r(sprintf('[%s] [%s]: %s', $level, $category, trim($message)) . "\n");
    }

    /**
     * Logs a warning message
     *
     * @param string $message The message to be logged.
     * @param string $category The category of the message.
     */
    public function waning($message, $category = null)
    {
        $this->log($message, self::LEVEL_WARNING, $category);
    }

    /**
     * Logs a info message
     *
     * @param string $message The message to be logged.
     * @param string $category The category of the message.
     */
    public function info($message, $category = null)
    {
        $this->log($message, self::LEVEL_INFO, $category);
    }

    /**
     * Logs a error message
     *
     * @param string $message The message to be logged.
     * @param string $category The category of the message.
     */
    public function error($message, $category = null)
    {
        $this->log($message, self::LEVEL_ERROR, $category);
    }

    /**
     * Rotates log files.
     */
    protected function rotateFiles()
    {
        $file = $this->file_path;

        for ($i = $this->max_log_files; $i >= 0; --$i) {
            $rotate_file = $file . ($i === 0 ? '' : '.' . $i);

            if (is_file($rotate_file)) {
                if ($i === $this->max_log_files) {
                    @unlink($rotate_file);
                } else {
                    @rename($rotate_file, $file . '.' . ($i + 1));
                }
            }
        }
    }
}

class Job
{
    private $db_connection;
    private $db_host;
    private $db_user;
    private $db_pass;
    private $db_name;
    private $db_result;
    private $subdir;
    private $php_executable;

    private $admin_index;

    private $logger;

    /**
     * @param $db_host
     * @param $db_user
     * @param $db_pass
     * @param $db_name
     * @param $subdir
     * @param $php_executable
     * @param $logger Logger
     */
    public function __construct($db_host, $db_user, $db_pass, $db_name, $subdir, $logger, $php_executable = 'php', $admin_index = 'admin.php')
    {
        $this->db_host = $db_host;
        $this->db_user = $db_user;
        $this->db_pass = $db_pass;
        $this->db_name = $db_name;
        $this->subdir = $subdir;
        $this->php_executable = $php_executable;
        $this->logger = $logger;
        $this->admin_index = $admin_index;

        $this->db_connection = new mysqli($this->db_host, $this->db_user, $this->db_pass, $this->db_name);
        if (mysqli_connect_error()) {
            $this->logger->error("can not connect to database " . mysqli_connect_error());
        }
    }


    public function db_query($query)
    {
        $this->db_result = $this->db_connection->query($query);
        return $this->db_result;
    }

    public function fetch()
    {
        if (!$this->db_result) {
            return "";
        }
        while ($row = $this->db_result->fetch_assoc()) {
            $rows[] = $row;
        }
        return $rows;
    }

    public function get_cscart_version()
    {
        $file = file_get_contents("{$this->subdir}/config.php");
        $pattern = "/'PRODUCT_VERSION', '(.*)'/";
        if (preg_match($pattern, $file, $mathes)) {
            return $mathes[1];
        }
        return '';
    }

    public function get_addon_version($id)
    {
        $this->db_query("SELECT version FROM cscart_addons WHERE addon = '{$id}'");
        $result = $this->fetch();

        return !empty($result[0]['version']) ? $result[0]['version'] : '';
    }

    public function print_r()
    {
        $args = func_get_args();

        echo(PHP_EOL);
        foreach ($args as $v) {
            echo(print_r($v, true) . PHP_EOL);
        }
        echo(PHP_EOL);
    }

    public function version_compare($a, $b, $op = null)
    {
        $replace_chars = function ($m) {
            return ord(strtolower($m[1]));
        };

        // add dot before groups of letters (version_compare does the same thing)
        $a = preg_replace('#([0-9]+)([a-z]+)#i', '$1.$2', $a);
        $b = preg_replace('#([0-9]+)([a-z]+)#i', '$1.$2', $b);

        // apply ord() to any single letter
        $a = preg_replace_callback('#\b([a-z]{1})\b#i', $replace_chars, $a);
        $b = preg_replace_callback('#\b([a-z]{1})\b#i', $replace_chars, $b);

        if (empty($op)) {
            return version_compare($a, $b);
        } else {
            return version_compare($a, $b, $op);
        }
    }

    public function upgrade_to($id, $version_to)
    {
        $iterations = 50;
        if ($id == 'core') {
            while (strlen($this->get_cscart_version()) && $this->version_compare($this->get_cscart_version(), $version_to, '<') && $iterations > 0) {
                $this->logger->info($this->get_cscart_version() . " < {$version_to}. Doing upgrade core ....");
//                $this->print_r($this->get_cscart_version() . " < {$version_to}. Doing upgrade {$id} ....");
                $this->logger->info("{$this->php_executable} {$this->subdir}/{$this->admin_index} --dispatch=upgrade_center.console upgrade {$id} --no-backup --skip-validator=*");
                shell_exec("{$this->php_executable} {$this->subdir}/{$this->admin_index} --dispatch=upgrade_center.console upgrade {$id} --no-backup --skip-validator=*");
                $this->logger->info("Done. Current version:" . $this->get_cscart_version() . PHP_EOL);

//                $this->print_r();
                $iterations--;
            }
        } else {
            while (strlen($this->get_addon_version($id)) && $this->version_compare($this->get_addon_version($id), $version_to, '<') && $iterations > 0) {
/*                $this->print_r($this->get_addon_version($id) . " < {$version_to}. Doing upgrade {$id} ....");*/
                $this->logger->info($this->get_addon_version($id) . " < {$version_to}. Doing upgrade addon {$id} ....");

                shell_exec("{$this->php_executable}  {$this->subdir}/{$this->admin_index} --dispatch=upgrade_center.console upgrade {$id} --no-backup --skip-validator=*");
//                $this->print_r("Done. Current version:" . $this->get_addon_version($id) . PHP_EOL);
                $this->logger->info("Done. Current version:" . $this->get_addon_version($id) . PHP_EOL);

                $iterations--;
            }
        }
    }

    public function change_addon_status($id, $status)
    {
//        $this->print_r("Change addon status: {$id} -> {$status}");
        $this->logger->info("Change addon status: {$id} -> {$status}");

        $this->db_query("UPDATE cscart_addons SET status = '{$status}' WHERE addon = '{$id}'");
    }

    public function clear_cache()
    {
//        $this->print_r("Clear cache: rm -fr ./{$this->subdir}/var/cache");
        $this->logger->info("Clear cache: rm -fr {$this->subdir}/var/cache");
        shell_exec("rm -fr {$this->subdir}/var/cache");
    }
}
