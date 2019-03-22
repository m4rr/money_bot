# https://regex101.com/r/ics2ad/3

Symbols = "a?c?h?k?u?s?[$€£₽฿₪]"
Regex = /-?(#{Symbols})?(\d+[ \d.,]*)(mm(?!\w)|m(?!\w)|k(?!\w)|к|тыщ[а-я]{0,2}|тыс[а-я]{0,4}|млн|лям[а-я]{0,2}|миллион[а-я]{0,2}|млрд|миллиард[а-я]{0,2})? ?#{Symbols}|dollar|доллар|бакс|евро|фунт|руб|бат|тенге|рингг?ит|канадск[а-я]{0,2} доллар|сингапурск[а-я]{0,2} доллар|[a-zA-Z]{3})?/i

def global_scan text 
  text
    .gsub("\u00A0", " ") # nbsp replace
    .scan(Regex)
    .collect { |match|
      cur = match[0] || match[3]

      cur.nil? ? nil : { amount: match[1].strip, unit: match[2], currency: cur }
    }
    .compact
    .uniq
end

def parse_currency value
  # match aliases
  case value.to_s.strip.downcase
  when "us$" # top priority for the exact match
    :USD
  when "a$"
    :AUD
  when /c\$|канадск/i
    :CAD
  when "hk$"
    :HKD
  when /s\$|сингапурск/i
    :SGD
  when /\$|dollar|доллар|бакс/i # other matches
    :USD
  when /€|евро/i
    :EUR
  when /£|фунт/i
    :GBP
  when /₽|руб/i
    :RUB
  when /฿|бат|BHT/i
    :THB
  when "₪"
    :ILS
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
  when :HKD
    "HK$"
  when :ILS
    "₪"
  else
    cur.to_s
  end
end