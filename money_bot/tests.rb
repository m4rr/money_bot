path = File.expand_path(File.dirname(__FILE__))
load "#{path}/parser.rb"

def usd_base_json
  {
    'rates' => {
      'AED' => 3.673035,
      'AFN' => 75.349867,
      'ALL' => 109.62,
      'AMD' => 485.067536,
      'ANG' => 1.785195,
      'AOA' => 310.427,
      'ARS' => 37.544542,
      'AUD' => 1.40218,
      'AWG' => 1.799996,
      'AZN' => 1.7025,
      'BAM' => 1.721067,
      'BBD' => 2,
      'BDT' => 83.931,
      'BGN' => 1.718934,
      'BHD' => 0.377027,
      'BIF' => 1815,
      'BMD' => 1,
      'BND' => 1.576121,
      'BOB' => 6.91065,
      'BRL' => 3.799395,
      'BSD' => 1,
      'BTC' => 0.00027989181,
      'BTN' => 71.149836,
      'BWP' => 10.528038,
      'BYN' => 2.153216,
      'BZD' => 2.015976,
      'CAD' => 1.335602,
      'CDF' => 1631,
      'CHF' => 0.995747,
      'CLF' => 0.024214,
      'CLP' => 672.7,
      'CNH' => 6.796372,
      'CNY' => 6.7919,
      'COP' => 3150,
      'CRC' => 598.172003,
      'CUC' => 1,
      'CUP' => 25.75,
      'CVE' => 97.3795,
      'CZK' => 22.569308,
      'DJF' => 178.05,
      'DKK' => 6.561825,
      'DOP' => 50.565,
      'DZD' => 118.598263,
      'EGP' => 17.901,
      'ERN' => 14.997108,
      'ETB' => 28.5,
      'EUR' => 0.878802,
      'FJD' => 2.126609,
      'FKP' => 0.765293,
      'GBP' => 0.765293,
      'GEL' => 2.654375,
      'GGP' => 0.765293,
      'GHS' => 4.935,
      'GIP' => 0.765293,
      'GMD' => 49.54,
      'GNF' => 9190,
      'GTQ' => 7.727306,
      'GYD' => 209.069507,
      'HKD' => 7.845356,
      'HNL' => 24.465053,
      'HRK' => 6.5359,
      'HTG' => 78.512002,
      'HUF' => 279.505952,
      'IDR' => 14141.65,
      'ILS' => 3.673525,
      'IMP' => 0.765293,
      'INR' => 71.245246,
      'IQD' => 1190,
      'IRR' => 42105,
      'ISK' => 120.424815,
      'JEP' => 0.765293,
      'JMD' => 131.98,
      'JOD' => 0.709607,
      'JPY' => 109.64116667,
      'KES' => 101.31,
      'KGS' => 68.689579,
      'KHR' => 4016,
      'KMF' => 433.500774,
      'KPW' => 900,
      'KRW' => 1127.81,
      'KWD' => 0.303387,
      'KYD' => 0.833521,
      'KZT' => 378.228045,
      'LAK' => 8560,
      'LBP' => 1512.390101,
      'LKR' => 182.19,
      'LRD' => 160.000478,
      'LSL' => 13.89,
      'LYD' => 1.389822,
      'MAD' => 9.5563,
      'MDL' => 17.082435,
      'MGA' => 3610,
      'MKD' => 54.095,
      'MMK' => 1540.826131,
      'MNT' => 2453.75,
      'MOP' => 8.082021,
      'MRO' => 357,
      'MRU' => 36.41,
      'MUR' => 34.347,
      'MVR' => 15.509974,
      'MWK' => 728.601213,
      'MXN' => 19.101393,
      'MYR' => 4.135736,
      'MZN' => 61.65102,
      'NAD' => 13.86,
      'NGN' => 363.25,
      'NIO' => 32.58,
      'NOK' => 8.586786,
      'NPR' => 113.77304,
      'NZD' => 1.473796,
      'OMR' => 0.385002,
      'PAB' => 1,
      'PEN' => 3.335001,
      'PGK' => 3.355,
      'PHP' => 52.7085,
      'PKR' => 139.86,
      'PLN' => 3.77072,
      'PYG' => 6058.048724,
      'QAR' => 3.6411,
      'RON' => 4.183403,
      'RSD' => 104.1,
      'RUB' => 66.1245,
      'RWF' => 884,
      'SAR' => 3.750254,
      'SBD' => 8.072908,
      'SCR' => 13.65,
      'SDG' => 47.56,
      'SEK' => 9.017865,
      'SGD' => 1.359642,
      'SHP' => 0.765293,
      'SLL' => 8390,
      'SOS' => 580,
      'SRD' => 7.458,
      'SSP' => 130.2634,
      'STD' => 21050.59961,
      'STN' => 21.58,
      'SVC' => 8.751555,
      'SYP' => 514.980061,
      'SZL' => 13.842056,
      'THB' => 31.734,
      'TJS' => 9.441217,
      'TMT' => 3.50998,
      'TND' => 2.965298,
      'TOP' => 2.26281,
      'TRY' => 5.284188,
      'TTD' => 6.78415,
      'TWD' => 30.878981,
      'TZS' => 2315.3,
      'UAH' => 27.896,
      'UGX' => 3692.46854,
      'USD' => 1,
      'UYU' => 32.639118,
      'UZS' => 8369,
      'VEF' => 248487.642241,
      'VES' => 1000.225839,
      'VND' => 23171.439561,
      'VUV' => 111.256375,
      'WST' => 2.609539,
      'XAF' => 576.456398,
      'XAG' => 0.06529564,
      'XAU' => 0.00077992,
      'XCD' => 2.70255,
      'XDR' => 0.716509,
      'XOF' => 576.456398,
      'XPD' => 0.00074159,
      'XPF' => 104.868987,
      'XPT' => 0.00126423,
      'YER' => 250.374262,
      'ZAR' => 13.833742,
      'ZMW' => 11.956,
      'ZWL' => 322.355011
    }
  }
end

def run_tests
  should_puts = false

  result = true

  result &= parse_text("1 ляе").to_i < parse_text("$10 mm ").to_i
  result &= parse_text("1 тенге").to_i < parse_text("$10 mm ").to_i
  result &= parse_text("1 KZT").to_i < parse_text("$10 mm ").to_i
  result &= parse_text("1 KRW").to_i < parse_text("$10 mm ").to_i
  result &= parse_text("1 MYR").to_i < parse_text("$10 mm ").to_i

  result &= handle_thousands_separtor("1,000,000.01") == 1000000.01
  result &= handle_thousands_separtor("1,000") == 1000
  result &= handle_thousands_separtor("1000000,01") == 1000000.01
  result &= handle_thousands_separtor("1,000,000") == 1000000
  result &= handle_thousands_separtor("0,015") == 0.015

  result &= handle_thousands_separtor("-1") == -1

  result &= handle_thousands_separtor("0.0.0") == 0

  result &= parse_text("1$") == parse_text("$1")
  puts("$1", result, "$1") if should_puts
  result &= parse_text("1k$") == parse_text("$1k")
  puts("$1k", result, "") if should_puts
  result &= parse_text("5,0 руб") == parse_text("5.0 rub")
  puts("5.0 rub", result, "") if should_puts
  result &= parse_text("1.000.000,01 cad") < parse_text("1,000,000.01 usd")
  puts("1,000,000.01 usd", result, "") if should_puts
  result &= parse_text("kek 10 000 $ kek") == parse_text("10 тысячей $")
  puts("10 тысячейй $", result, "") if should_puts
  result &= parse_text("500 тысяч канадских долларов") == parse_text("500 000 CAD")
  puts("500 000 CAD", result, "") if should_puts
  result &= parse_text("150 $").to_i < parse_text("150к €").to_i
  puts("150к €", result, "") if should_puts
  result &= parse_text("10 рублей").to_f > parse_text("3 рубля").to_f
  puts("3 рубля", parse_text("10 рублей"), parse_text("3 рубля"), result, "") if should_puts
  result &= parse_text("15.000₽").to_i < parse_text("9,99 $").to_i
  puts(handle_thousands_separtor("15.000"), handle_thousands_separtor("9,99"), result, "") if should_puts
  result &= parse_text("0.99 $").to_i < parse_text("$10 mm ").to_i
  puts("$10 mm ", result, "") if should_puts

  result
end

if run_tests == false
  puts "tests failed"
  exit 1
end

puts "tests succeeded"
