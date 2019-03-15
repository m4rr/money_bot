# https://regex101.com/r/ics2ad/1

Regex = /-?(s?[$€£₽฿])?(\d+[ \d.,]*)(mm(?!\w)|m(?!\w)|k(?!\w)|к|тыщ|тыс[а-я]{0,4}|млн|лям[а-я]{0,2}|миллион[а-я]{0,2}|млрд|миллиард[а-я]{0,2})? ?(s?[$€£₽฿]|dollar|доллар|бакс|евро|фунт|руб|бат|тенге|рингг?ит|канадск[а-я]{0,2} доллар|сингапурск[а-я]{0,2} доллар|[a-zA-Z]{3})?/i

def global_scan text 
  res = text.scan(Regex).collect { |match|
    cur = match[0] || match[3]
    
    if cur.nil? 
      nil 
    else
      { amount: match[1].strip, unit: match[2], currency: cur }
    end
  }
  .compact
end

# puts(global_scan("такси – это 19 вместо s$11 за автобус и 5 $"))
