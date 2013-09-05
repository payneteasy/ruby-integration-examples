# Классы для хранения и передачи данных

Семейство классов для хранения данных и обмена данными между библиотекой и CMS мерчанта. Расположены в пространстве имен **[PaynetEasy::PaynetEasyApi::PaymentData](../../lib/paynet_easy/paynet_easy_api/payment_data)**. Представлены
следующими классами объектов:
* [PaymentTransaction](#PaymentTransaction)
* [Payment](#Payment)
* [QueryConfig](#QueryConfig)
* [Customer](#Customer)
* [BillingAddress](#BillingAddress)
* [CreditCard](#CreditCard)
* [RecurrentCard](#RecurrentCard)

Каждый из классов позволяет наполнять объект данными как с помощью хэша, переданного в конструктор, так и с помощью сеттеров. При использовании хэша в качестве ключа для данных необходимо использовать название свойства класса.

##### Использование массива и underscored названий свойств класса

```ruby
payment = Payment.new(
{
  'client_id'   => 'CLIENT-112233',
  'paynet_id'   => 'PAYNET-112233',
  'description' => 'test payment'
})
```
##### Использование сеттеров

```ruby
payment = Payment.new

payment.client_id   = 'CLIENT-112233'
payment.paynet_id   = 'PAYNET-112233'
payment.description = 'test payment'
```

### <a name="PaymentTransaction"></a> PaymentTransaction

Центральным объектом для хранения и передачи данных является объект класса **[PaynetEasy::PaynetEasyApi::PaymentData::PaymentTransaction](../../lib/paynet_easy/paynet_easy_api/payment_data/payment_transaction.rb)**. Именно он передается из CMS в библиотеку
при выполнении любого запроса. Хранит следующие данные:

Свойство класса     |Тип                        |Поле запроса   |Назначение
--------------------|---------------------------|---------------|-------------------------------------------------------
processor_type      |string                     |               |Transaction processor type (query, callback)
processor_name      |string                     |               |Transaction processor name (query or callback name)
status              |string                     |               |Transaction status (new, processing, approved, filtered, declined, error)
payment             |[Payment](#Payment)        |               |Платеж, для которого создана транзакция
query_config        |[QueryConfig](#QueryConfig)|               |Payment query config
errors              |array                      |               |Transaction processing errors

Поля **processor_type** и **processor_name** заполняются обработчиком транзакции после формирования платежного запроса. Поле **status** изменяется на основе данных ответа от сервера PaynetEasy.

### <a name="Payment"></a> Payment

Объект класса **[PaynetEasy::PaynetEasyApi::PaymentData::Payment](../../lib/paynet_easy/paynet_easy_api/payment_data/payment.rb)**. Используется при выполнении всех запросов. Хранит следующие данные:

Свойство класса     |Тип                                |Поле запроса   |Назначение
--------------------|-----------------------------------|---------------|-------------------------------------------------------
client_id           |string                             |client_orderid |Merchant payment identifier
paynet_id           |string                             |orderid        |Unique identifier of transaction assigned by PaynetEasy
description         |string                             |order_desc     |Brief payment description
destination         |string                             |destination    |Destination to where the payment goes
amount              |float                              |amount         |Amount to be charged
currency            |string                             |currency       |Three-letter currency code
comment             |string                             |comment        |A short comment for payment
status              |string                             |               |Payment status (new, preauth, capture, return)
customer            |[Customer](#Customer)              |               |Payment customer
billing_address     |[BillingAddress](#BillingAddress)  |               |Payment billing address
credit_card         |[CreditCard](#CreditCard)          |               |Payment credit card
recurrent_card_from |[RecurrentCard](#RecurrentCard)    |               |Payment source recurrent card
recurrent_card_to   |[RecurrentCard](#RecurrentCard)    |               |Payment destination recurrent card

Поле **status** заполняется обработчиком транзакции после формирования платежного запроса в зависимости от того, какую платежную операцию реализует обработчик.

### <a name="QueryConfig"></a> QueryConfig

Объект класса **[PaynetEasy::PaynetEasyApi::PaymentData::QueryConfig](../../lib/paynet_easy/paynet_easy_api/payment_data/query_config.rb)**. Используется при выполнении всех запросов. Хранит следующие данные:

Свойство класса       |Тип    |Поле запроса       |Назначение
----------------------|-------|-------------------|-------------------------------------------------------
login                 |string |login              |Merchant login
site_url              |string |site_url           |URL the original payment is made from
redirect_url          |string |redirect_url       |URL the customer will be redirected to upon completion of the transaction
callback_url          |string |server_callback_url|URL the transaction result will be sent to
end_point             |integer|                   |Merchant end point
signing_key           |string |                   |Merchant key for payment signing
gateway_mode          |string |                   |Gateway mode (sandbox, production)
gateway_url_sandbox   |string |                   |Sandbox gateway url
gateway_url_production|string |                   |Production gateway url

Значение свойства **end_point** участвует в формировании URL для вызова платежного метода шлюза PaynetEasy, а свойства **signing_key** - в формировании подписи для данных платежа. Значения свойств **gateway_url_sandbox** и **gateway_url_production** содержат ссылки на sandbox и production гейты. Выбор между этими url осуществляется на основе значения поля **gateway_mode**, если значение поля `QueryConfig::GATEWAY_MODE_SANDBOX`, то будет выбран url **gateway_url_sandbox**, если `QueryConfig::GATEWAY_MODE_PRODUCTION` - то url **gateway_url_production**.

### <a name="Customer"></a> Customer

Объект класса **[PaynetEasy::PaynetEasyApi::PaymentData::Customer](../../lib/paynet_easy/paynet_easy_api/payment_data/customer.rb)**. Используется при выполнении следующих запросов:
* [sale](../payment-scenarios/00-sale-transactions.md#sale)
* [preauth](../payment-scenarios/01-preauth-capture-transactions.md#preauth)
* [sale-form, preauth-form, transfer-form](../payment-scenarios/05-payment-form-integration.md#form)
* [make-rebill](../payment-scenarios/04-recurrent-transactions.md#make-rebill)
* [transfer-by-ref](../payment-scenarios/02-transfer-transactions.md#transfer-by-ref)

Объект хранит следующие данные:

Свойство класса     |Тип    |Поле запроса   |Назначение
--------------------|-------|---------------|-------------------------------------------------------
first_name          |string |first_name     |Customer’s first name
last_name           |string |last_name      |Customer’s last name
email               |string |email          |Customer’s email address
ip_address          |string |ipaddress      |Customer’s IP address
birthday            |string |birthday       |Customer’s date of birth, in the format MMDDYY
ssn                 |string |ssn            |Last four digits of the customer’s social security number

### <a name="BillingAddress"></a> BillingAddress

Объект класса **[PaynetEasy::PaynetEasyApi::PaymentData::BillingAddress](../../lib/paynet_easy/paynet_easy_api/payment_data/billing_address.rb)**. Используется при выполнении следующих запросов:
* [sale](../payment-scenarios/00-sale-transactions.md#sale)
* [preauth](../payment-scenarios/01-preauth-capture-transactions.md#preauth)
* [sale-form, preauth-form, transfer-form](../payment-scenarios/05-payment-form-integration.md#form)

Объект хранит следующие данные:

Свойство класса     |Тип    |Поле запроса   |Назначение
--------------------|-------|---------------|-------------------------------------------------------
country             |string |country        |Customer’s two-letter country code
state               |string |state          |Customer’s two-letter state code
city                |string |city           |Customer’s city
first_line          |string |address1       |Customer’s address line 1
zip_code            |string |zip_code       |Customer’s ZIP code
phone               |string |phone          |Customer’s full international phone number, including country code
cell_phone          |string |cell_phone     |Customer’s full international cell phone number, including country code

### <a name="CreditCard"></a> CreditCard

Объект класса **[PaynetEasy::PaynetEasyApi::PaymentData::CreditCard](../../lib/paynet_easy/paynet_easy_api/payment_data/credit_card.rb)**. Используется при выполнении следующих запросов:
* [sale](../payment-scenarios/00-sale-transactions.md#sale)
* [preauth](../payment-scenarios/01-preauth-capture-transactions.md#preauth)

Объект хранит следующие данные:

Свойство класса     |Тип    |Поле запроса       |Назначение
--------------------|-------|-------------------|-------------------------------------------------------
cvv2                |integer|cvv2               |RecurrentCard CVV2
card_printed_name   |string |card_printed_name  |Card holder name
credit_card_number  |string |credit_card_number |Credit card number
expire_year         |integer|expire_year        |Card expiration year
expire_month        |integer|expire_month       |Card expiration month

### <a name="RecurrentCard"></a> RecurrentCard

Объект класса **[PaynetEasy::PaynetEasyApi::PaymentData::RecurrentCard](../../lib/paynet_easy/paynet_easy_api/payment_data/recurrent_card.rb)**. Используется при выполнении следующих запросов:
* [create-card-ref](../payment-scenarios/04-recurrent-transactions.md#create-card-ref)
* [get-card-info](../payment-scenarios/04-recurrent-transactions.md#get-card-info)
* [make-rebill](../payment-scenarios/04-recurrent-transactions.md#make-rebill)
* [transfer-by-ref](../payment-scenarios/02-transfer-transactions.md#transfer-by-ref)

Объект хранит следующие данные:

Свойство класса     |Тип    |Поле запроса       |Назначение
--------------------|-------|-------------------|-------------------------------------------------------
paynet_id           |integer|cardrefid          |RecurrentCard PaynetEasy ID
cvv2                |integer|cvv2               |RecurrentCard CVV2
card_printed_name   |string |                   |Card holder name
expire_year         |integer|                   |Card expiration year
expire_month        |integer|                   |Card expiration month
bin                 |integer|                   |Bank Identification Number
last_four_digits    |integer|                   |The last four digits of PAN (card number)
