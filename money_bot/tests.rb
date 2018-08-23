path = File.expand_path(File.dirname(__FILE__))
load "#{path}/parser.rb"

def usd_base_json
  {
    'rates' => {
      'RUB' => 66.6,
      'EUR' => 87.6,
      'CAD' => 56.7,
    }
  }
end

def run_tests
  result = true
  
  result &= handle_thousands_separtor("1,000,000.01") == 1000000.01
  result &= handle_thousands_separtor("1,000") == 1000
  result &= handle_thousands_separtor("1000000,01") == 1000000.01
  result &= handle_thousands_separtor("1,000,000") == 1000000
  
  result &= parse_text("1$") == parse_text("$1")
  # puts("$1", result, "")
  result &= parse_text("1k$") == parse_text("$1k")
  # puts("$1k", result, "")
  result &= parse_text("5,0 руб") == parse_text("5.0 rub")
  # puts("5.0 rub", result, "")
  result &= parse_text("1.000.000,01 cad") < parse_text("1,000,000.01 usd")
  # puts("1,000,000.01 usd", result, "")
  result &= parse_text("kek 10 000 $ kek") == parse_text("10 тысячей $")
  # puts("10 тысячейй $", result, "")
  result &= parse_text("500 тысяч канадских долларов") == parse_text("500 000 CAD")
  # puts("500 000 CAD", result, "")
  result &= parse_text("150 $").to_i < parse_text("150к €").to_i
  # puts("150к €", result, "")
  result &= parse_text("10 рублей").to_f > parse_text("3 рубля").to_f
  # puts("3 рубля", parse_text("10 рублей"), parse_text("3 рубля"), result, "")
  result &= parse_text("15.000₽").to_i < parse_text("9,99 $").to_i
  # puts(handle_thousands_separtor("15.000"), handle_thousands_separtor("9,99"), result, "")
  result &= parse_text("0.99 $").to_i < parse_text("$10 mm ").to_i
  # puts("$10 mm ", result, "")
  # puts result
  
  result
end

if run_tests == false 
  puts "tests failed"
  exit 1
end
