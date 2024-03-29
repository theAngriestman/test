<?php


namespace Tygh\Tests\Unit\Mailer\MessageBuilders;

use Tygh\Template\IContext;

class DBTemplateMessageBuilder extends \Tygh\Mailer\MessageBuilders\DBTemplateMessageBuilder
{
    protected function getContext($data, $area, $lang_code)
    {
        return new Context();
    }

    protected function getCompany($company_id, $lang_code, $area = '')
    {
        return MessageBuilder::getCompanyTest($company_id, $lang_code);
    }

    protected function getDefaultCompanyId()
    {
        return MessageBuilder::getDefaultCompanyIdTest();
    }

    protected function getImageSize($real_path)
    {
        return MessageBuilder::getImageSizeTest($real_path);
    }

    protected function getImageExtension($mime_type)
    {
        return MessageBuilder::getImageExtensionTest($mime_type);
    }

    protected function allowedFor($edition)
    {
        return MessageBuilder::allowedForTest($edition);
    }

    public function validateAddress($email)
    {
        return MessageBuilder::validateAddressTest($email);
    }

    public function getStorefrontId()
    {
        return 1;
    }
}

class Context implements IContext
{
    public $data = array();
    
    /**
     * @inheritDoc
     */
    public function getLangCode()
    {
        return 'en';
    }

    /**
     * @inheritDoc
     */
    public function getLanguageDirection()
    {
        return 'ltr';
    }
    
    /**
     * @inheritDoc
     */
    public function getArea()
    {
        return 'A';
    }
}
