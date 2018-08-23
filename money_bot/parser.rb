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
  case value.to_s.strip
  when /CAD|канадск/i
    :CAD
  when /\$|USD|dollar|доллар|бакс/i
    :USD
  when /€|EUR|евро/i
    :EUR
  when /₽|RUB|руб/i
    :RUB
  else
    :not_expected
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

  if from_currency == :EUR
    usd_eur_rate = usd_base_json['rates']['EUR'].to_f
    rate /= usd_eur_rate
  elsif from_currency == :CAD
    usd_cad_rate = usd_base_json['rates']['CAD'].to_f
    rate /= usd_cad_rate
  end

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

  rate = parse_rate from_currency
  return nil if rate == 0
  
  amount = parse_amount(hash[:amount], hash[:unit])
  result = from_currency == :RUB ? (amount / rate) : (amount * rate)
  
  to_currency = from_currency == :RUB ? :USD : :RUB

  if to_currency == :RUB && result < 10 || result < 1
    result = result.round(3)
  elsif to_currency == :RUB && result < 100 || result < 10
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
  # https://regexr.com/3uar8
  when /([$€₽])?(\d+[ \d.,]*)(mm|m|k|к|тыщ|тыс[а-я]{0,4}|млн|лям[а-я]{0,2}|миллион[а-я]{0,2}|млрд|миллиард[а-я]{0,2})? ?([$€₽]|usd|dollar|eur|rub|cad|руб|доллар|бакс|евро|канадск[а-я]{0,2} доллар)?/i
    convert_values({ amount: $2, unit: $3, currency: $1 || $4 })
  end
end
