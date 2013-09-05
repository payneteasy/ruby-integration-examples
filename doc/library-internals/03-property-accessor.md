# Модуль для работы с цепочками свойств, PropertyAccessor

В процессе работы с данными платежа возникает необходимость читать и изменять свойства объектов, хранящихся в PaymentTransaction. Например, для чтения email клиента необходимо вызвать `payment_transaction.payment.customer.email`, а для записи - `payment_transaction.payment.customer.email = ''`. Для удобного выполнения этих операций в модуле **[PaynetEasy::PaynetEasyApi::Util::PropertyAccessor](../../lib/paynet_easy/paynet_easy_api/util/property_accessor.rb)** реализованы следующие методы:
* **[get_value()](#get_value)**: удобное чтение данных по цепочке свойств
* **[set_value()](#set_value)**: удобная запись данных по цепочке свойств

### <a name="get_value"></a> get_value(): удобное чтение данных по цепочке свойств

Метод предназначен для чтения данных из цепочки свойств. Цепочка свойств описывает порядок получения свойств из переданного объекта. Так, для цепочки `payment.billing_address.first_line` будет получено значение свойства `first_line` из объекта, хранящегося в свойстве `billing_address`, хранящегося в свойстве `payment`. Для получения свойств используются методы-геттеры полей объекта.
Метод принимает три параметра:
* Объект, цепочку свойств которого можно прочитать
* Цепочка свойств
* Флаг, определяющий поведение метода в том случае, если геттер для свойства не был найден или если свойство, в котором ожидался объект, пустое:
    * **true** - будет брошено исключение
    * **false** - будет возвращен `null`

Пример использования метода:
```ruby
require 'paynet_easy_api'
require 'util/property_accessor'

include PaynetEasy::PaynetEasyApi::PaymentData
include PaynetEasy::PaynetEasyApi::Util

payment_transaction = PaymentTransaction.new(
{
  'payment' => Payment.new(
  {
    'credit_card' => CreditCard.new(
    {
      'expire_year' => '14'
    })
  })
})

p PropertyAccessor.get_value(payment_transaction, 'payment.credit_card.expire_year') # 2014
p PropertyAccessor.get_value(payment_transaction, 'payment.credit_card.expire_month', false) # nil

# prints 'empty'
begin
  PropertyAccessor.get_value(payment_transactions, 'payment.creditCard.expireMonth')
rescue RuntimeError
  puts 'empty'
end
```

### <a name="set_value"></a> set_value(): удобное изменение данных по цепочке свойств

Метод предназначен для изменения данных по цепочке свойств. Цепочка свойств описывает порядок получения свойств из переданного объекта. Так, для цепочки `payment.billing_address.first_line` будет изменено значение свойства `first_line` из объекта, хранящегося в свойстве `billing_address`, хранящегося в свойстве `payment`. Для получения свойств используются методы-геттеры для полей объекта, для изменения - методы-сеттеры, названия которых образованы добавлением префикса `set` к имени свойства. Таким образом, изменение данных для цепочки `payment.billingAddress.
Метод принимает четыре параметра:
* Объект, цепочку свойств которого можно прочитать
* Цепочка свойств
* Новое значение
* Флаг, определяющий поведение метода в том случае, если геттер или сеттер для свойства не был найден или если свойство, в котором ожидался объект, пустое:
    * **true** - будет брошено исключение
    * **false** - будет возвращен `nil`

Пример использования метода:
```ruby
require 'paynet_easy_api'
require 'util/property_accessor'

include PaynetEasy::PaynetEasyApi::PaymentData
include PaynetEasy::PaynetEasyApi::Util

payment_transaction = PaymentTransaction.new(
{
  'payment' => Payment.new(
  {
    'credit_card' => CreditCard.new(
    {
      'expire_year' => '14'
    })
  })
})

PropertyAccessor.set_value(payment_transaction, 'payment.credit_card.expire_year', 15)
p PropertyAccessor.get_value(payment_transaction, 'payment.credit_card.expire_year') # 15

PropertyAccessor.set_value(payment_transaction, 'payment.credit_card.non_existent_property', 'value', false) # nothing will happen

# prints 'nonexistent property'
begin
  PropertyAccessor.set_value(payment_transaction, 'payment.credit_card.non_existent_property', 'value')
rescue RuntimeError
  puts 'nonexistent property'
end
```
