# https://regex101.com/r/ics2ad/4

Symbols = '[a-zA-Z]{3}|[a-zA-Z]{0,2}[$€£₽฿₪¥ლ₴]'
Regex = /-?(#{Symbols})?(\d[ .,\d]*(?!\w\w))(mm(?!\w)|m(?!\w)|k(?!\w)|к|тыщ[а-я]{0,2}|тыс[а-я]{0,4}|млн|лям[а-я]{0,2}|миллион[а-я]{0,2}|млрд|миллиард[а-я]{0,2})? ?(#{Symbols}|dollar|доллар|бакс|евро|фунт|руб|бат|тенге|рингг?ит|канадск[а-я]{0,2} доллар|сгд|сингапурск[а-я]{0,2} доллар|хкд|гривн|грн|лари|злоты|zl|zł|[a-zA-Z]{3})? ?(to ([a-zA-Z]{3}))?/i

def global_scan text
  text
    .gsub('\u00A0', ' ') # nbsp replace
    .scan(Regex)
    .collect { |match| # map texts to structs
      cur = match[0] || match[3]

      cur.nil? ? nil : { amount: match[1].strip, unit: match[2], currency: cur, to: match[5] }
    }
    .compact # flatmap (remove nils)
    .uniq # remove equal results
    .first(10)
end

def parse_currency value
  # match aliases
  case value.to_s.strip.downcase
  when 'a$'
    :AUD
  when 'c$', /канадск/i
    :CAD
  when 'hk$', 'хкд'
    :HKD
  when 's$', 'сгд', /сингапурск/i
    :SGD
  when 'us$', '$', /dollar|доллар|бакс/i # other matches
    :USD
  when /€|евро/i
    :EUR
  when /£|фунт/i
    :GBP
  when /₽|руб/i
    :RUB
  when /฿|бат|BHT/i
    :THB
  when '₪'
    :ILS
  when '¥'
    :CNY
  when /тенге/i
    :KZT
  when /рингг?ит/i
    :MYR
  when /₴|грн|гривн/i
    :UAH
  when /ლ|лари/i
    :GEL
  when /злоты|zł|zl/
    :PLN
  else
    cur = value.to_s.strip.upcase
    if usd_base_json['rates'][cur].nil?
      nil
    else
      # any currencies matched by ALPHA3 - pass
      cur.to_sym
    end
  end
end

def pretty_currency cur
  case cur
  when :RUB
    '₽'
  when :USD
    '$'
  when :GBP
    '£'
  when :EUR
    '€'
  when :SGD
    'S$'
  when :HKD
    'HK$'
  when :PLN
    'zł'
  else
    cur.to_s
  end
end
