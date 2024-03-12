<?php

namespace Tygh\Addons\Ab_addonsManager\DatabaseManager;

use Tygh\Addons\Ab_addonsManager\Exceptions;

class DBManager
{
    public static function copyTables(array $tables)
    {
        if (empty($tables)) {
            throw new Exceptions\ABDBMCopyingException(sprintf('The table list is empty!'));
        }

        foreach ($tables as $original_table => $copy_table) {
            $obj_original = new TableManager($original_table);

            if (!$obj_original->hasTable()) {
                throw new Exceptions\ABDBMCopyingException(sprintf('The table "%s" does not exist!', $original_table));
            }

            try {
                $obj_original->copyTable($copy_table, true);
            } catch (Exceptions\ABTMException | \Exception $e) {
                throw new Exceptions\ABDBMCopyingException(sprintf('Error while copying table "%s": %s', $original_table, $e->getMessage()));
            }
        }
    }

    public static function dropTables(array $tables)
    {
        if (empty($tables)) {
            throw new Exceptions\ABDBMCopyingException(sprintf('The table list is empty!'));
        }

        foreach ($tables as $table) {
            $obj_table = new TableManager($table);

            if ($obj_table->hasTable()) {
                $obj_table->dropTable();
            }
        }
    }
}
