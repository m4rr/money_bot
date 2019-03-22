@chat_ids = {}
@last_update = nil

def chat_id_inc chat_id
  if @chat_ids.key?(chat_id) 
    @chat_ids[chat_id] += 1
  else
    @chat_ids[chat_id] = 1
  end

  if Time.now.to_i - @last_update.to_i > 30 * 60
    @last_update = Time.now 

    number_of_msgs_sent = 0
    @chat_ids.each do |key, value|
      number_of_msgs_sent += value
    end
    
    return @chat_ids.size.to_s + ' chats: ' + number_of_msgs_sent.to_s + ' msgs sent' if number_of_msgs_sent > 1
  end

  nil
end

def support_msg text
  { 
    chat_id: '@usdrubbotsupport', 
    text: text
  }
end
