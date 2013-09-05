# Валидатор данных, Validator

Модуль **[PaynetEasy::PaynetEasyApi::Util::Validator](../../lib/paynet_easy/paynet_easy_api/util/validator.rb)** предоставляет следующие методы для валидации данных:
* **[validate_by_rule()](#validate_by_rule)**: валидация с помощью предопределенного правила или регулярного выражения

### <a name="validate_by_rule"></a>validate_by_rule(): валидация с помощью предопределнного правила

Для удобной валидации данных в **[Validator](../../lib/paynet_easy/paynet_easy_api/util/validator.rb)** реализован метод **[validate_by_rule()](../../lib/paynet_easy/paynet_easy_api/util/validator.rb#L87)** и набор констант с правилами валидации. Список доступных правил:

Константа                       |Правило валидации          |Описание
--------------------------------|---------------------------|--------
Validator::EMAIL                |/@+/                       |Validate value as email
Validator::IP                   |URI::ABS_URI === ip        |Validate value as IP address
Validator::URL                  |!!IPAddr.new(url)          |Validate value as URL
Validator::MONTH                |(1..12).include? month.to_i|Validate value as month
Validator::YEAR                 |/^[0-9]{1,2}$/i            |Validate value as year
Validator::PHONE                |/^[0-9\-\+\(\)\s]{6,15}$/i |Validate value as phone number
Validator::AMOUNT               |/^[0-9\.]{1,11}$/i         |Validate value as payment amount
Validator::CURRENCY             |/^[A-Z]{1,3}$/i            |Validate value as currency
Validator::CVV2                 |/^[\S\s]{3,4}$/i           |Validate value as card verification value
Validator::ZIP_CODE             |/^[\S\s]{1,10}$/i          |Validate value as zip code
Validator::COUNTRY              |/^[A-Z]{1,2}$/i            |Validate value as two-letter country or state code
Validator::DATE                 |/^[0-9]{6}$/i              |Validate value as date in format MMDDYY
Validator::SSN                  |/^[0-9]{1,4}$/i            |Validate value as last four digits of social security number
Validator::CREDIT_CARD_NUMBER   |/^[0-9]{1,20}$/i           |Validate value as credit card number
Validator::ID                   |/^[\S\s]{1,20}$/i          |Validate value as ID (client, paynet, card-ref, etc.)
Validator::LONG_STRING          |/^[\S\s]{1,128}$/i         |Validate value as long string
Validator::MEDIUM_STRING        |/^[\S\s]{1,50}$/i          |Validate value as medium string

Метод принимает три параметра:
* Значение для валидации
* Имя правила или регулярное выражение для валидации
* Флаг, определяющий поведение метода в том случае, если значение не прошло валидацию
    * **true** - будет брошено исключение
    * **false** - будет возвращен булевый результат проверки
Пример использования метода:

```ruby
require 'paynet_easy_api'
require 'util/validator'

include PaynetEasy::PaynetEasyApi::Util

p Validator.validate_by_rule('test@mail.com', Validator::EMAIL, false)  # true
p Validator.validate_by_rule('some string', '#\d#', false)              # false

# prints 'invalid'
begin
  Validator.validate_by_rule('test[at]mail.com', Validator::EMAIL)
  puts 'valid'
rescue ValidationError
  puts 'invalid'
end
```