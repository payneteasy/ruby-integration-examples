# Фронтенд библиотеки, PaymentProcessor

Фронтенд библиотеки представлен классом **[PaynetEasy::PaynetEasyApi::PaymentProcessor](../../lib/paynet_easy/paynet_easy_api/payment_processor.rb)**. Класс предоставляет следующие методы:
* **[execute_query()](#execute_query)**: выполнение запроса к PaynetEasy
* **[process_customer_return()](#process_customer_return)**: обработка данных, полученных от PaynetEasy при возвращении пользователя с платежного шлюза
* **[process_paynet_easy_callback()](#process_paynet_easy_callback)**: обработка данных, полученных от PaynetEasy при поступлении коллбэка от PaynetEasy
* **[set_handlers()](#set_handlers)**: установка обработчиков для различных событий, происходящих при обработке платежной транзакции

### <a name="execute_query"></a>execute_query(): выполнение запроса к PaynetEasy

Некоторые сценарии обработки платежа имеют асинхронную природу и состоят из нескольких запросов. Так, некоторые запросы не возвращают результат платежа сразу и требуют многократного выполнения запроса **status**, после которого клиент может быть отправлен на шлюз PaynetEasy для проведения дополнительных шагов авторизации. После возвращения клиента на сервис мерчанта необходима обработка данных, полученных от шлюза.
<a name="async_queries_list"></a>Cписок асинхронных запросов:
* sale
* preauth
* capture
* return
* make-rebill
* transfer-by-ref

Ознакомиться с обработкой таких запросов можно в следующих файлах:
* [Пример выполнения запроса sale](../../example/sale.rb)
* [Пример выполнения запроса preauth](../../example/preauth.rb)
* [Пример выполнения запроса capture](../../example/capture.rb)
* [Пример выполнения запроса return](../../example/return.rb)
* [Пример выполнения запроса make-rebill](../../example/make-rebill.rb)
* [Пример выполнения запроса transfer-by-ref](../../example/transfer-by-ref.rb)

Отдельный сценарий обработки необходим и при интеграции платежной формы. Запрос к шлюзу возвращает ссылку на платежную форму, на которую должен быть отправлен клиент. После заполнения и отправки данных шлюз обрабатывает платежную форму и возвращает клиента на сервис мерчанта. После возвращения клиента на сервис мерчанта необходима обработка данных, полученных от шлюза.
<a name="form_queries_list"></a>Список запросов для интеграции платежной формы:
* sale-form
* preauth-form
* transfer-form

Ознакомиться с обработкой таких запросов можно в следующих файлах:
* [Пример выполнения запроса sale-form](../../example/sale-form.rb)
* [Пример выполнения запроса preauth-form](../../example/preauth-form.rb)
* [Пример выполнения запроса transfer-form](../../example/transfer-form.rb)

Некоторые операции с платежами не требуют сложных сценариев обработки и выполняются с помощью одного запроса.
Список простых операций над платежом:
* create-card-ref
* get-card-info
* status

Ознакомиться с обработкой таких запросов можно в следующих файлах:
* [Пример выполнения запроса create-card-ref](../../example/create-card-ref.rb)
* [Пример выполнения запроса get-card-info](../../example/get-card-info.rb)
* [Пример выполнения запроса status](../../example/status.rb)

Для удобного выполнения запросов к PaynetEasy в **PaymentProcessor** реализован метод **[execute_query()](../../lib/paynet_easy/paynet_easy_api/payment_processor.rb#L62)**.
Метод принимает два параметра:
* Название запроса
* Платежная транзакция для обработки

### <a name="process_customer_return"></a>process_customer_return(): обработка данных, полученных от PaynetEasy при возвращении клиента

Каждый [асинхронный запрос](#async_queries_list) может завершиться перенаправлением пользователя на платежный шлюз для выполнения дополнительных действий, а каждый [запрос для интеграции платежной формы](#form_queries_list) обязательно содержит такое перенаправление. Каждый раз при возвращении пользователя на сервис мерчанта передаются данные с результатом обработки платежа. Также, если в [конфигурации стартового запроса](../00-basic-tutorial.md#stage_1_step_3) был задан ключ **server_callback_url**, то через некоторое время PaynetEasy вызовет этот url и передаст ему данные, описанные в wiki PaynetEasy в разделе [Merchant Callbacks](http://wiki.payneteasy.com/index.php/PnE:Merchant_Callbacks). Для удобной обработки этих данных в **PaymentProcessor** реализован метод **[process_customer_return()](../../lib/paynet_easy/paynet_easy_api/payment_processor.rb#L85)**.
Метод принимает два параметра:
* Объект с данными, полученными при возвращении пользователя от PaynetEasy
* Платежная транзакция для обработки

Ознакомиться с использованием данного метода можно в следующих файлах:
* [Базовый пример использования библиотеки](../00-basic-tutorial.md#stage_2)
* [Пример выполнения запроса sale](../../example/sale.rb#L91)
* [Пример выполнения запроса preauth](../../example/preauth.rb#L91)
* [Пример выполнения запроса sale-form](../../example/sale-form.rb#L70)
* [Пример выполнения запроса preauth-form](../../example/preauth-form.rb#70)
* [Пример выполнения запроса transfer-form](../../example/transfer-form.rb#70)

### <a name="process_paynet_easy_callback"></a>process_paynet_easy_callback(): обработка удаленного вызова от PaynetEasy

После выполнения [асинхронного запроса](#async_queries_list) или [запроса для интеграции платежной формы](#form_queries_list), если в [конфигурации стартового запроса](../00-basic-tutorial.md#stage_1_step_3) был задан ключ **server_callback_url**, то через некоторое время PaynetEasy вызовет этот url и передаст ему данные, описанные в wiki PaynetEasy в разделе [Merchant Callbacks](http://wiki.payneteasy.com/index.php/PnE:Merchant_Callbacks). Для удобной обработки этих данных в **PaymentProcessor** реализован метод **[process_paynet_easy_callback()](../../lib/paynet_easy/paynet_easy_api/payment_processor.rb#L96)**.
Метод принимает два параметра:
* Объект с данными, полученными при возвращении пользователя от PaynetEasy
* Платежная транзакция для обработки

Ознакомиться с использованием данного метода можно в следующих файлах:
* [Пример выполнения запроса sale](../../example/sale.rb#L102)
* [Пример выполнения запроса preauth](../../example/preauth.rb#L102)
* [Пример выполнения запроса sale-form](../../example/sale-form.rb#L81)
* [Пример выполнения запроса preauth-form](../../example/preauth-form.rb#81)
* [Пример выполнения запроса transfer-form](../../example/transfer-form.rb#81)

### <a name="set_handlers"></a> set_handlers(): установка обработчиков для различных событий, происходящих при обработке заказа

**PaymentProcessor** скрывает от конечного пользователя алгоритм обработки заказа в методах **[execute_query()](#execute_query)**, **[process_customer_return()](#process_customer_return)** и **[process_paynet_easy_callback()](process_paynet_easy_callback)**. При этом во время обработки заказа возникают ситуации, обработка которых должна быть реализована на стороне сервиса мерчанта. Для обработки таких ситуаций в **PaymentProcessor** реализована система событий и их обработчиков. Обработчики могут быть установлены тремя разными способами:
* Передача хэша с обработчиками в [конструктор класса **PaymentProcessor**](../../lib/paynet_easy/paynet_easy_api/payment_processor.rb#L51)
* Передача хэша с обработчиками в метод [**set_handlers()**](../../lib/paynet_easy/paynet_easy_api/payment_processor.rb#L150)
* Установка обработчиков по одному с помощью метода **[set_handler()](../../lib/paynet_easy/paynet_easy_api/payment_processor.rb#L140)**

Список обработчиков событий:
* **HANDLER_SAVE_CHANGES** - обработчик для сохранения платежной транзакции. Вызывается, если данные платежной транзакции изменены. Должен реализовывать сохранение платежной транзакции в хранилище. Принимает следующие параметры:
    * Платежная транзакция
    * Ответ от PaynetEasy (опционально, не доступен, если произошла ошибка на этапе формирования или выполнения запроса к PaynetEasy)
* **HANDLER_STATUS_UPDATE** - обработчик для обновления статуса платежной транзакции. Вызывается, если статус платежной транзакции не изменился с момента последней проверки. Должен реализовывать запуск проверки статуса платежной транзакции. Принимает следующие параметры:
    * Ответ от PaynetEasy
    * Платежная транзакция
* **HANDLER_SHOW_HTML** - обработчик для вывода HTML-кода, полученного от PaynetEasy. Вызывается, если необходима 3D-авторизация пользователя. Должен реализовывать вывод HTML-кода из ответа от PaynetEasy в браузер клиента. Принимает следующие параметры:
    * Ответ от PaynetEasy
    * Платежная транзакция
* **HANDLER_REDIRECT** - обработчик для перенаправления клиента на платежную форму PaynetEasy. Вызывается после выполнения запроса [sale-form, preauth-form или transfer-form](../payment-scenarios/05-payment-form-integration.md). Должен реализовывать перенаправление пользователя на URL из ответа от PaynetEasy. Принимает следующие параметры:
    * Ответ от PaynetEasy
    * Платежная транзакция
* **HANDLER_FINISH_PROCESSING** - обработчик для дальнейшей обработки платежной транзакции сервисом мерчанта после завершения обработки библиотекой. Вызывается, если нет необходимости в дополнительных шагах для обработки транзакции. Принимает следующие параметры:
    * Платежная транзакция
    * Ответ от PaynetEasy (опционально, не доступен, если обработка платежной транзакции уже была завершена ранее)
* **HANDLER_CATCH_EXCEPTION** - обработчик для исключения. Вызывается, если при обработке платежной транзакции произошло исключение. **Внимание!** Если этот обработчик не установлен, то исключение будет брошено из библиотеки выше в сервис мерчанта. Принимает следующие параметры:
    * Исключение
    * Платежная транзакция
    * Ответ от PaynetEasy (опционально, не доступен, если произошла ошибка на этапе формирования или выполнения запроса к PaynetEasy)

Метод принимает один параметр:
* Хэш с обработчиками событий. Ключами элементов хэша являются названия обработчиков, заданные в константах класса, значениями - любые значения типа [Proc](http://www.ruby-doc.org/core-2.0.0/Proc.html)

Пример вызова метода с простейшими обработчиками:

```ruby
require 'paynet_easy_api'
require 'cgi'
require 'cgi/session'

$_CGI     = CGI.new('html5')
$_SESSION = CGI::Session.new $_CGI

paymentProcessor = PaymentProcessor.new
paymentProcessor.set_handlers(
{
    PaymentProcessor::HANDLER_SAVE_CHANGES      => ->(payment_transaction, response) do
      $_SESSION['payment_transaction'] = Marshal.dump payment_transaction
    end,
    PaymentProcessor::HANDLER_STATUS_UPDATE     => ->(response, payment_transaction) do
      current_location = "http://#{ENV['HTTP_HOST']}/#{ENV['REQUEST_URI']}?stage=updateStatus"
      puts $_CGI.header('status' => 'REDIRECT', 'location' => current_location)
    end,
    PaymentProcessor::HANDLER_SHOW_HTML         => ->(response, payment_transaction) do
      puts $_CGI.header
      puts response.html
    end,
    PaymentProcessor::HANDLER_REDIRECT          => ->(response, payment_transaction) do
      puts $_CGI.header('status' => 'REDIRECT', 'location' => response.redirect_url)
      exit
    end,
    PaymentProcessor::HANDLER_FINISH_PROCESSING => ->(payment_transaction, response = nil) do
      puts $_CGI.header
      puts <<HTML
        <pre>
          Payment processing finished.
          Payment status: '#{payment_transaction.payment.status}'
          Payment transaction status: '#{payment_transaction.status}'
        </pre>
HTML
    end,
    PaymentProcessor::HANDLER_CATCH_EXCEPTION   => ->(exception, payment_transaction, response = nil) do
      puts $_CGI.header
      puts <<HTML
        <pre>
          Exception catched.
          Exception message: '#{exception.message}'
          Exception backtrace:
          #{exception.backtrace}
        </pre>
HTML
    end
})
```