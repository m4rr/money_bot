def handle_thousands_separtor value
  value.to_s.delete! ' _'

  if value.include?('.') && value.include?(',') # 1,000,000.01 usd
    value.delete! ','
  elsif value.include?(',') && value.index(/\d{3}$/) != nil && value[0] != '0' # 1,000 / 0,015
    value.delete! ','
  elsif value.include?(',') # 1000000,01 rub
    value.sub!(',', '.')
  end

  value.to_f
end

def parse_currency value
  # match aliases
  case value.to_s.strip
  when /канадск/i
    :CAD
  when /\$|dollar|доллар|бакс/i
    :USD
  when /€|евро/i
    :EUR
  when /£|фунт/i
    :GBP
  when /₽|руб/i
    :RUB
  when /฿|бат|BHT/i
    :THB
  when /тенге/i
    :KZT
  when /рингг?ит/i
    :MYR
  else
    cur = value.to_s.strip.upcase
    if usd_base_json['rates'][cur].nil?
      :not_expected
    else
      # any currencies matched by ALPHA3 - pass
      cur.to_sym
    end
  end
end

def parse_amount(value, unit)
  amount = handle_thousands_separtor value

  case unit
  when /mm|млрд|миллиард/i
    amount *= 1_000_000_000
  when /m|млн|лям|миллион/i
    amount *= 1_000_000
  when /k|к|тыщ|тыс/i
    amount *= 1_000
  end

  amount
end

def parse_rate from_currency
  rate = usd_base_json['rates']['RUB'].to_f

  if from_currency == :USD || from_currency == :RUB
    return rate
  end

  # other currencies
  usd_based_rate = usd_base_json['rates'][from_currency.to_s].to_f
  rate /= usd_based_rate

  rate
end

# 1000000 to 1 000 000
def group_by_3 number
  number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
end

# convert values from given hash of `{ amount, unit, currency }`
def convert_values hash
  from_currency = parse_currency(hash[:currency])
  return nil if from_currency == :not_expected
  return nil if from_currency == nil

  rate = parse_rate from_currency
  return nil if rate == 0

  amount = parse_amount(hash[:amount], hash[:unit])
  result = from_currency == :RUB ? (amount / rate) : (amount * rate)
  return nil if !result.finite?

  to_currency = from_currency == :RUB ? :USD : :RUB

  if to_currency == :RUB && result < 10 || result < 1
    # round to .000 if valuable < 1
    result = result.round(3)
  elsif to_currency == :RUB && result < 100 || result < 10
    # round to .00 if valuable < 10
    result = result.round(2)
  else
    result = result.round
  end

  "#{group_by_3 result} #{to_currency}"
end

def parse_text text
  case text
  when '/start'
    :start
  when '/stop'
    :stop
  when /гугол/i
    'Ираклий, ну хватит!'
  # https://regexr.com/3uar8
  when /-?([$€£₽฿])?(\d+[ \d.,]*)(mm(?!\w)|m(?!\w)|k(?!\w)|к|тыщ|тыс[а-я]{0,4}|млн|лям[а-я]{0,2}|миллион[а-я]{0,2}|млрд|миллиард[а-я]{0,2})? ?([$€£₽฿]|dollar|доллар|бакс|евро|фунт|руб|бат|тенге|рингг?ит|канадск[а-я]{0,2} доллар|[a-zA-Z]{3})?/i
    convert_values({ amount: $2, unit: $3, currency: $1 || $4 })
  end
end
