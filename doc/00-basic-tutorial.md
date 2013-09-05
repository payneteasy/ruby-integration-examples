# Простой пример использования библиотеки

Разберем выполнение запросов при [интеграции платежной формы](http://wiki.payneteasy.com/index.php/PnE:Payment_Form_integration). Типовая обработка платежа происходит в три этапа. Первый и последний этапы происходят на стороне сервиса мерчанта, а второй - на стороне PaynetEasy.

1. Инициация оплаты:
    1. [Подключение загрузчика классов и необходимых классов](#stage_1_step_1)
    2. [Создание новой платежной транзакции](#stage_1_step_2)
    3. [Создание сервиса для обработки платежей](#stage_1_step_4)
    4. [Запуск обработки платежной транзакции](#stage_1_step_6)
        1. Проверка данных платежной транзакции и формирование на ее основе запроса к PaynetEasy
        3. Изменение статуса платежа **status**
        4. Выполнение запроса для старта обработки платежной транзакции и ее первичной проверки
        5. Получение ответа от PaynetEasy
        6. Изменение статуса платежной транзакции **status** на основе данных ответа
        7. Сохранение платежной транзакции
        8. Перенаправление клиента на платежную форму

2. Процессинг платежной формы:
    1. Заполнение клиентом платежной формы и отправка данных шлюзу PaynetEasy
    2. Обработка данных шлюзом
    3. Возврат пользователя на сервис мерчанта с передачей результата обработки платежной формы

3. Обработка результатов:
    1. [Подключение загрузчика классов и необходимых классов](#stage_2_step_1)
    2. [Загрузка сохраненной платежной транзакции](#stage_2_step_2)
    3. [Создание сервиса для обработки платежей](#stage_2_step_4)
    4. [Запуск обработки данных, полученных при возвращении пользователя с платежной формы](#stage_2_step_6)
        1. Проверка данных, полученные по возвращении клиента с платежной формы PaynetEasy
        2. Изменение статуса платежной транзакции **status**
        3. Сохранение платежной транзакции
        4. Вывод статуса платежа **status** и статуса платежной транзакции **status** на экран

Рассмотрим примеры исходного кода для выполнения обоих этапов. Код для выполнения второго этапа должен выполняться при переходе по ссылке, заданной в настройках по ключу **redirect_url**. Например, разместите исходный код первого этапа в файле `first_stage.rb`, а второго - `second_stage.rb`.

### <a name="stage_1"></a>Начало обработки платежной транзакции

1. <a name="stage_1_step_1"></a>Подключение пакета библиотеки:

    ```ruby
    require 'paynet_easy_api'

    include PaynetEasy::PaynetEasyApi
    include PaynetEasy::PaynetEasyApi::PaymentData
    ```
2. <a name="stage_1_step_2"></a>Создание новой платежной транзакции:
    ##### С использованием массивов, переданных в конструктор:

    ```ruby
    customer = Customer.new(
    {
      'email'                     => 'vass.pupkin@example.com',
      'ip_address'                => '127.0.0.1'
    })

    billing_address = BillingAddress.new(
    {
      'country'                   => 'US',
      'city'                      => 'Houston',
      'state'                     => 'TX',
      'first_line'                => '2704 Colonial Drive',
      'zip_code'                  => '1235',
      'phone'                     => '660-485-6353'
    })

    query_config = QueryConfig.new(
    {
      'end_point'                 =>  253,
      'login'                     => 'rp-merchant1',
      'signing_key'               => '3FD4E71A-D84E-411D-A613-40A0FB9DED3A',
      'redirect_url'              => "http://#{ENV['HTTP_HOST']}/second_stage.rb",
      'gateway_mode'              =>  QueryConfig::GATEWAY_MODE_SANDBOX,
      'gateway_url_sandbox'       => 'https://sandbox.domain.com/paynet/api/v2/',
      'gateway_url_production'    => 'https://payment.domain.com/paynet/api/v2/'
    })

    payment = Payment.new(
    {
      'client_id'                 => 'CLIENT-112244',
      'description'               => 'This is test payment',
      'amount'                    =>  9.99,
      'currency'                  => 'USD',
      'customer'                  =>  customer,
      'billing_address'           =>  billing_address
    })

    payment_transaction = PaymentTransaction.new(
    {
      'payment'                   => payment,
      'query_config'              => query_config
    })
    ```
    ##### С использованием сеттеров:

    ```ruby
    customer            = Customer.new
    customer.email      = 'vass.pupkin@example.com'
    customer.ip_address = '127.0.0.1'

    billing_address             = BillingAddress.new
    billing_address.country     = 'US'
    billing_address.state       = 'TX'
    billing_address.city        = 'Houston'
    billing_address.first_line  = '2704 Colonial Drive'
    billing_address.zip_code    = '1235'
    billing_address.phone       = '660-485-6353'

    query_config                        = QueryConfig.new
    query_config.end_point              = 253
    query_config.login                  = 'rp-merchant1'
    query_config.signing_key            = '3FD4E71A-D84E-411D-A613-40A0FB9DED3A'
    query_config.redirect_url           = "http://#{ENV['HTTP_HOST']}/second_stage.rb"
    query_config.gateway_mode           = QueryConfig::GATEWAY_MODE_SANDBOX
    query_config.gateway_url_sandbox    = 'https://sandbox.domain.com/paynet/api/v2/'
    query_config.gateway_url_production = 'https://payment.domain.com/paynet/api/v2/'

    payment                       = Payment.new
    query_config.client_id        = 'CLIENT-112244'
    query_config.description      = 'This is test payment'
    query_config.amount           = 9.99
    query_config.currency         = 'USD'
    query_config.customer         = customer
    query_config.billing_address  = billing_address

    payment_transaction               = PaymentTransaction.new
    payment_transaction.payment       = payment
    payment_transaction.query_config  = query_config
    ```

    Поля конфигурации запроса **QueryConfig**:
    * **[end_point](http://wiki.payneteasy.com/index.php/PnE:Introduction#Endpoint)** - точка входа для аккаунта мерчанта, выдается при подключении
    * **[login](http://wiki.payneteasy.com/index.php/PnE:Introduction#PaynetEasy_Users)** - логин мерчанта для доступа к панели PaynetEasy, выдается при подключении
    * **signing_key** - ключ мерчанта для подписывания запросов, выдается при подключении
    * **[redirect_url](http://wiki.payneteasy.com/index.php/PnE:Payment_Form_integration#Payment_Form_final_redirect)** - URL, на который пользователь будет перенаправлен после окончания запроса
    * **gateway_mode** - режим работы библиотеки: sandbox, production
    * **gateway_url_sandbox** - ссылка на шлюз PaynetEasy для режима работы sandbox
    * **gateway_url_production** - ссылка на шлюз PaynetEasy для режима работы production

3. <a name="stage_1_step_4"></a>Создание сервиса для обработки платежей:
    ```ruby
    payment_processor = PaymentProcessor.new(
    {
      PaymentProcessor::HANDLER_CATCH_EXCEPTION   => ->(exception, payment_transaction, response = nil) do
        puts $_CGI.header
        puts <<HTML
<pre>
print "Exception catched.
print "Exception message: '#{exception.message}'
print "Exception backtrace:
#{exception.backtrace}
</pre>
HTML
        exit
      end,
      PaymentProcessor::HANDLER_SAVE_CHANGES      => ->(payment_transaction, response) do
        session = CGI::Session.new CGI.new('html5')
        session['payment_transaction'] = Marshal.dump payment_transaction
      end,
      PaymentProcessor::HANDLER_REDIRECT          => ->(response, payment_transaction) do
        puts $_CGI.header('status' => 'REDIRECT', 'location' => response.redirect_url)
        exit
      end
    })
    ```

    Обработчики событий для сервиса:
    * **PaymentProcessor::HANDLER_CATCH_EXCEPTION** - для обработки исключения, если оно было брошено
    * **PaymentProcessor::HANDLER_SAVE_CHANGES** - для сохранения платежной транзакции
    * **PaymentProcessor::HANDLER_REDIRECT** - для переадресации пользователя на URL платежной формы, полученный от PaynetEasy

4. <a name="stage_1_step_6"></a>Запуск обработки платежа:

    ```ruby
    payment_processor.execute_query 'sale-form', payment_transaction
    ```
    Будут выполнены следующие шаги:
    1. Проверка данных платежной транзакции и формирование на ее основе запроса к PaynetEasy
    3. Изменение статуса платежа **status**
    4. Выполнение запроса для старта обработки платежной транзакции и ее первичной проверки
    5. Получение ответа от PaynetEasy
    6. Изменение статуса платежной транзакции **status** на основе данных ответа
    7. Сохранение платежной транзакции обработчиком для `PaymentProcessor::HANDLER_SAVE_PAYMENT`
    8. Перенаправление клиента на платежную форму обработчиком для `PaymentProcessor::HANDLER_REDIRECT`

### <a name="stage_2"></a>Окончание обработки платежной транзакции

1. <a name="stage_2_step_1"></a>Подключение пакета библиотеки:

    ```ruby
    require 'paynet_easy_api'

    include PaynetEasy::PaynetEasyApi
    include PaynetEasy::PaynetEasyApi::PaymentData
    ```
2. <a name="stage_2_step_2"></a>Загрузка сохраненной платежной транзакции:

    ```ruby
      session = CGI::Session.new CGI.new('html5')
      payment_transaction = Marshal.load session['payment_transaction']
    ```

3. <a name="stage_2_step_4"></a>Создание сервиса для обработки платежей:

    ```ruby
    payment_processor = PaymentProcessor.new(
    {
      PaymentProcessor::HANDLER_CATCH_EXCEPTION   => ->(exception, payment_transaction, response = nil) do
        puts $_CGI.header
        puts <<HTML
<pre>
print "Exception catched.
print "Exception message: '#{exception.message}'
print "Exception backtrace:
#{exception.backtrace}
</pre>
HTML
        exit
      end,
      PaymentProcessor::HANDLER_SAVE_CHANGES      => ->(payment_transaction, response) do
        session = CGI::Session.new CGI.new('html5')
        session['payment_transaction'] = Marshal.dump payment_transaction
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
        exit
      end
    })
    ```

    Обработчики событий для сервиса:
    * **PaymentProcessor::HANDLER_CATCH_EXCEPTION** - для обработки исключения, если оно было брошено
    * **PaymentProcessor::HANDLER_SAVE_CHANGES** - для сохранения платежа
    * **PaymentProcessor::HANDLER_FINISH_PROCESSING** - для вывода информации о платеже после окончания обработки

4. <a name="stage_2_step_6"></a>Запуск обработки данных, полученных при возвращении пользователя с платежной формы:

    ```ruby
    # Change hash format from {'key' => ['value']} to {'key' => 'value'} in map block
    post_fields = Hash[CGI.new('html5').params.map {|key, value| [key, value.first]}]

    payment_processor.process_customer_return CallbackResponse.new(post_fields), payment_transaction
    ```
    Будут выполнены следующие шаги:
    1. Проверка данных, полученные по возвращении клиента с платежной формы PaynetEasy
    2. Изменение статуса платежной транзакции **status** на основе проверенных данных
    3. Сохранение платежной транзакции обработчиком для `PaymentProcessor::HANDLER_SAVE_PAYMENT`
    4. Вывод статуса платежа **status** и статуса платежной транзакции **status** на экран обработчиком для `PaymentProcessor::HANDLER_FINISH_PROCESSING`
