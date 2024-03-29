local filename='data/expire.lua'
local cronned = load_from_file(filename)

local function save_cron(msg, text,date)
  local origin = get_receiver(msg)
  if not cronned[date] then
    cronned[date] = {}
  end
  local arr = { origin,  text } ;
  table.insert(cronned[date], arr)
  serialize_to_file(cronned, filename)
  return 'Saved!'
end

local function delete_cron(date)
  for k,v in pairs(cronned) do
    if k == date then
	  cronned[k]=nil
    end
  end
  serialize_to_file(cronned, filename)
end

local function cron()
  for date, values in pairs(cronned) do
  	if date < os.time() then --time's up
    	chat_del_user("chat#id"..text, 'user#id'..bot_id, ok_cb, false)
	  	send_msg(values[1][1], "I left it - Group Id : "..text, ok_cb, false)
  		delete_cron(date) 
	end

  end
end

local function actually_run(msg, delay,text)
  if (not delay or not text) then
  	return "Usage: !remind [delay: 2h3m1s] text"
  end
  save_cron(msg, text,delay)
  return "OK I ll left It on " .. os.date("%x at %H:%M:%S",delay) .. " Chat ID : '" .. text .. "'"
end

local function run(msg, matches)
  local sum = 0
  for i = 1, #matches-1 do
    local b,_ = string.gsub(matches[i],"[a-zA-Z]","")
    if string.find(matches[i], "s") then
      sum=sum+b
    end
    if string.find(matches[i], "m") then
      sum=sum+b*60
    end
    if string.find(matches[i], "h") then
      sum=sum+b*3600
    end
  end

  local date=sum+os.time()
  local text = matches[#matches]

  local text = actually_run(msg, date, text)
  return text
end

return {

  patterns = {
    "^[!/](expire) ([0-9]+[hmsdHMSD]) (.+)$",   --- e.g : for a month enter : 720hms - then , in text enter gp id.
    "^[!/](expire) ([0-9]+[hmsdHMSD])([0-9]+[hmsdHMSD]) (.+)$",
    "^[!/](expire) ([0-9]+[hmsdHMSD])([0-9]+[hmsdHMSD])([0-9]+[hmsdHMSD]) (.+)$"
  }, 
  run = run,
  cron = cron
}
