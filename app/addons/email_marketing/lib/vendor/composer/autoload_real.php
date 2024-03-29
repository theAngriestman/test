<?php

// autoload_real.php @generated by Composer

class ComposerAutoloaderInitf131d2950851b588b6467c6b6bfc7fe7
{
    private static $loader;

    public static function loadClassLoader($class)
    {
        if ('Composer\Autoload\ClassLoader' === $class) {
            require __DIR__ . '/ClassLoader.php';
        }
    }

    /**
     * @return \Composer\Autoload\ClassLoader
     */
    public static function getLoader()
    {
        if (null !== self::$loader) {
            return self::$loader;
        }

        spl_autoload_register(array('ComposerAutoloaderInitf131d2950851b588b6467c6b6bfc7fe7', 'loadClassLoader'), true, true);
        self::$loader = $loader = new \Composer\Autoload\ClassLoader(\dirname(__DIR__));
        spl_autoload_unregister(array('ComposerAutoloaderInitf131d2950851b588b6467c6b6bfc7fe7', 'loadClassLoader'));

        require __DIR__ . '/autoload_static.php';
        \Composer\Autoload\ComposerStaticInitf131d2950851b588b6467c6b6bfc7fe7::getInitializer($loader)();

        $loader->register(true);

        return $loader;
    }
}
