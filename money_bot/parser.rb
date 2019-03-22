path = File.expand_path(File.dirname(__FILE__))
load "#{path}/regexg.rb"

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
  when "us$"
    :USD
  when "hk$"
    :HKD
  when /сингапурск|s\$/i
    :SGD
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

def pretty_currency cur
  case cur
  when :RUB
    "₽"
  when :USD
    "$"
  when :GBP
    "£"
  when :EUR
     "€"
  when :SGD
    "S$"
  else
    cur.to_s
  end
end

def parse_amount(value, unit)
  amount = handle_thousands_separtor value

  case unit
  when /mm|мм|млрд|миллиард/i
    amount *= 1_000_000_000
  when /m|м|kk|кк|млн|лям|миллион/i
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
  raise ArgumentError, "value is too big", hash.to_s if amount.to_i.to_s.length > 31 # skip overflow

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

  to_currency = pretty_currency(to_currency)

  { result: "#{group_by_3 result} #{to_currency}", origin: hash }
end

def parse_text_global text
  if text.nil?
    return nil
  end

  global_scan(text)
    .collect { |x| convert_values(x) }
    .compact
end

def max (a, b)
  a > b ? a : b
end

def parse_message message_text
  parsed = parse_text_global(message_text)

  if parsed.nil? || parsed.empty?
    nil

  elsif parsed.length == 1
    parsed.first[:result]

  else
    origin_max_len = 0
    result_max_len = 0
    
    parsed.each { |temp_obj| 
      unit = temp_obj[:origin][:unit] || ""
      curr = pretty_currency(parse_currency(temp_obj[:origin][:currency]))
      origin = temp_obj[:origin][:amount] + unit + " " + curr

      origin_max_len = max(origin_max_len, origin.length)
      result_max_len = max(result_max_len, temp_obj[:result].length)
    }

    multi_text = parsed.reduce("") { |memo, obj|
      unit = obj[:origin][:unit] || ""
      curr = pretty_currency(parse_currency(obj[:origin][:currency]))
      origin = obj[:origin][:amount] + unit + " " + curr
      
      memo + "`" + origin.rjust(origin_max_len) + " = " + obj[:result].rjust(result_max_len) + "`\n"
    }

    multi_text
  end
end

def parse_text text
  # legacy shortcut for tests
  res = parse_text_global(text).first
  
  res[:result] if !res.nil?
end
