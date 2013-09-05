# Merchant callbacks

## Общие положения

* В данной статье описывается исключительно работа с библиотекой. Полная информация о Merchant callbacks расположена в [статье в wiki PaynetEasy](http://wiki.payneteasy.com/index.php/PnE:Merchant_Callbacks).
* Описание работы с цепочками свойств можно найти в описании класса **[PropertyAccessor](../library-internals/03-property-accessor.md)**

## <a name="main-callbacks"></a> Sale, Return, Chargeback callbacks

После завершения обработки платежа на стороне PaynetEasy, данные с результатом обработки передаются в сервис мерчанта с помощью обратного вызова. Это необходимо, чтобы платеж был обработан сервисом мерчанта независимо от того, выполнил пользователь корректно возврат с шлюза PaynetEasy или нет. Обработка этих данных совпадает с обработкой данных для [sale-form, preauth-form или transfer-form](05-payment-form-integration.md) и описана в [базовом примере использования библиотеки](../00-basic-tutorial.md#stage_2).
При обработке платежа библиотека сначала проверяет наличие необходимых полей в данных обратного вызова, а потом сравнивает значения некоторых полей в платеже и данных обратного вызова. После проверки в платеже обновляется поле **status**.

##### Обязательные параметры данных обратного вызова

Поле запроса        |Цепочка свойств платежа для проверки
--------------------|---------------------------------------
orderid             |payment.paynet_id
merchant_order      |payment.client_id
client_orderid      |payment.client_id
amount              |payment.amount
status              |
type                |
control             |

* [Пример выполнения запроса sale](../../example/sale.rb#L81)
* [Пример выполнения запроса preauth](../../example/preauth.rb#L81)
* [Пример выполнения запроса sale-form](../../example/sale-form.rb#L66)
* [Пример выполнения запроса preauth-form](../../example/preauth-form.rb#66)
* [Пример выполнения запроса transfer-form](../../example/transfer-form.rb#66)
