require 'paynet_easy_api'
require 'cgi'
require 'cgi/session'
require 'erb'

include PaynetEasy::PaynetEasyApi
include PaynetEasy::PaynetEasyApi::PaymentData
include PaynetEasy::PaynetEasyApi::Transport

def start_session()
  $_CGI     = CGI.new('html5')
  $_SESSION = CGI::Session.new $_CGI
  $_POST    = Hash[$_CGI.params.map {|key, value| [key, value.first]}]
  $_GET     = Hash[CGI::parse(ENV['QUERY_STRING']).map {|key, value| [key, value.first]}]
end

# @return   [QueryConfig]
def query_config()
  QueryConfig.new(
  {
    # Точка входа для аккаунта мерчанта, выдается при подключении
    'end_point'                 =>  247,
    # Логин мерчанта, выдается при подключении
    'login'                     => 'rp-merchant1',
    # Ключ мерчанта для подписывания запросов, выдается при подключении
    'signing_key'               => '3FD4E71A-D84E-411D-A613-40A0FB9DED3A',
    # URL на который пользователь будет перенаправлен после окончания запроса
    'redirect_url'              => "http://#{ENV['HTTP_HOST']}#{ENV['SCRIPT_NAME']}?stage=processCustomerReturn",
    # URL на который пользователь будет перенаправлен после окончания запроса
    'callback_url'              => "http://#{ENV['HTTP_HOST']}#{ENV['SCRIPT_NAME']}?stage=processPaynetEasyCallback",
    # Режим работы библиотеки: sandbox, production
    'gateway_mode'              => QueryConfig::GATEWAY_MODE_SANDBOX,
    # Ссылка на шлюз PaynetEasy для режима работы sandbox
    'gateway_url_sandbox'       => 'https://sandbox.domain.com/paynet/api/v2/',
    # Ссылка на шлюз PaynetEasy для режима работы production
    'gateway_url_production'    => 'https://payment.domain.com/paynet/api/v2/'
  })
end

# @return   [PaymentTransaction]
def load_payment_transaction()
  Marshal.load($_SESSION['payment_transaction']) unless $_SESSION['payment_transaction'].nil?
end

# @param    payment_transaction   [PaymentTransaction]
# @param    response              [Response]
def save_payment_transaction(payment_transaction, response)
  $_SESSION['payment_transaction'] = Marshal.dump payment_transaction
end

# @param    response              [Response]
# @param    payment_transaction   [PaymentTransaction]
def display_wait_page(response, payment_transaction)
  puts $_CGI.header
  current_location = "http://#{ENV['HTTP_HOST']}#{ENV['SCRIPT_NAME']}?stage=updateStatus"
  template_path    = File.expand_path './common/wait_page.erb'
  puts ERB.new(File.read(template_path)).result(binding)
  exit
end

# @param    response              [Response]
# @param    payment_transaction   [PaymentTransaction]
def display_response_html(response, payment_transaction)
  puts $_CGI.header
  puts response.html
  exit
end

# @param    response              [Response]
# @param    payment_transaction   [PaymentTransaction]
def redirect_to_response_url(response, payment_transaction)
  puts $_CGI.header('status' => 'REDIRECT', 'location' => response.redirect_url)
  exit
end

# @param    payment_transaction   [PaymentTransaction]
# @param    response              [Response]
def display_ended_payment(payment_transaction, response = nil)
  puts $_CGI.header
  p response.needed_action
  puts <<HTML
<pre>
Payment processing finished.
Payment status: '#{payment_transaction.payment.status}'
Payment transaction status: '#{payment_transaction.status}'
</pre>
HTML
  exit
end

# @param    exception             [Exception]
# @param    payment_transaction   [PaymentTransaction]
# @param    response              [Response]
def display_exception(exception, payment_transaction, response = nil)
  puts $_CGI.header
  puts <<HTML
<pre>
Exception catched.
Exception message: '#{exception.message}'
Exception backtrace:
#{exception.backtrace.join "\n"}
</pre>
HTML
  exit
end

# @return   [PaymentProcessor]
def payment_processor()
  PaymentProcessor.new(
  {
    PaymentProcessor::HANDLER_CATCH_EXCEPTION     => method(:display_exception),
    PaymentProcessor::HANDLER_SAVE_CHANGES        => method(:save_payment_transaction),
    PaymentProcessor::HANDLER_STATUS_UPDATE       => method(:display_wait_page),
    PaymentProcessor::HANDLER_REDIRECT            => method(:redirect_to_response_url),
    PaymentProcessor::HANDLER_SHOW_HTML           => method(:display_response_html),
    PaymentProcessor::HANDLER_FINISH_PROCESSING   => method(:display_ended_payment)
  })
end