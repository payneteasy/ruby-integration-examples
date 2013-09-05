# Ruby Library for PaynetEasy API integration [![Build Status](https://travis-ci.org/payneteasy/ruby-library-payneteasy-api.png?branch=master)](https://travis-ci.org/payneteasy/ruby-library-payneteasy-api)
## Доступная функциональность

Данная библиотека позволяет производить оплату с помощью [merchant PaynetEasy API](http://wiki.payneteasy.com/index.php/PnE:Merchant_API). На текущий момент реализованы следующие платежные методы:
- [x] [Sale Transactions](http://wiki.payneteasy.com/index.php/PnE:Sale_Transactions)
- [x] [Preauth/Capture Transactions](http://wiki.payneteasy.com/index.php/PnE:Preauth/Capture_Transactions)
- [x] [Transfer Transactions](http://wiki.payneteasy.com/index.php/PnE:Transfer_Transactions)
- [x] [Return Transactions](http://wiki.payneteasy.com/index.php/PnE:Return_Transactions)
- [x] [Recurrent Transactions](http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions)
- [x] [Payment Form Integration](http://wiki.payneteasy.com/index.php/PnE:Payment_Form_integration)
- [ ] [Buy Now Button integration](http://wiki.payneteasy.com/index.php/PnE:Buy_Now_Button_integration)
- [ ] [eCheck integration](http://wiki.payneteasy.com/index.php/PnE:eCheck_integration)
- [ ] [Western Union Integration](http://wiki.payneteasy.com/index.php/PnE:Western_Union_Integration)
- [ ] [Bitcoin Integration](http://wiki.payneteasy.com/index.php/PnE:Bitcoin_integration)
- [ ] [Loan Integration](http://wiki.payneteasy.com/index.php/PnE:Loan_integration)
- [ ] [Qiwi Integration](http://wiki.payneteasy.com/index.php/PnE:Qiwi_integration)
- [x] [Merchant Callbacks](http://wiki.payneteasy.com/index.php/PnE:Merchant_Callbacks)

## Системные требования

* Ruby >= 1.9.3

## Установка

1. Установите bundler, если его еще нет: `gem install bundler`
2. Перейдите в папку проекта: `cd my/project/directory`
3. Создайте Gemfile проекта для bundler, если его еще нет: `bundle init`
4. Добавьте библиотеку в зависимости проекта:
      * С помощью консоли, выполнив команду `echo "gem 'payneteasy-payneteasyapi'" >> Gemfile`
      * С помощью текстового редактора. добавив строку `gem 'payneteasy-payneteasyapi'` в файл Gemfile
      в корневой папке проекта
5. Установите зависимости: `bundle install`

## Запуск тестов

1. Установите пакет `rubygems-test`, если его еще нет: `gem install rubygems-test`
2. Запустите тесты: `gem test payneteasy-payneteasyapi`

## Использование

* [Простой пример использования библиотеки](doc/00-basic-tutorial.md)
* [Внутренняя структура библиотеки](doc/01-library-internals.md)
    * [Семейство классов для хранения и обмена данными, PaynetEasy::PaynetEasyApi::PaymentData](doc/library-internals/00-payment-data.md)
    * [Фронтенд библиотеки, PaynetEasy::PaynetEasyApi::PaymentProcessor](doc/library-internals/01-payment-processor.md)
    * [Валидатор данных, PaynetEasy::PaynetEasyApi::Util::Validator](doc/library-internals/02-validator.md)
    * [Класс для работы с цепочками свойств, PaynetEasy::PaynetEasyApi::Util::PropertyAccessor](doc/library-internals/03-property-accessor.md)
* [Интеграция различных платежных сценариев](doc/02-payment-scenarios.md)
    * [Sale transactions](doc/payment-scenarios/00-sale-transactions.md)
    * [Preauth/Capture Transactions](doc/payment-scenarios/01-preauth-capture-transactions.md)
    * [Transfer Transactions](doc/payment-scenarios/02-transfer-transactions.md)
    * [Return Transactions](doc/payment-scenarios/03-return-transactions.md)
    * [Recurrent Transactions](doc/payment-scenarios/04-recurrent-transactions.md)
    * [Payment Form Integration](doc/payment-scenarios/05-payment-form-integration.md)
    * [Merchant Callbacks](doc/payment-scenarios/06-merchant-callbacks.md)