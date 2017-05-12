max7219 = require("max7219")
ds3231 = require("ds3231")

letters = {}
letters["0"] = { 0x3E, 0x7F, 0x71, 0x59, 0x4D, 0x7F, 0x3E, 0x00 } -- '0'
letters["1"] = { 0x40, 0x42, 0x7F, 0x7F, 0x40, 0x40, 0x00, 0x00 } -- '1'
letters["2"] = { 0x62, 0x73, 0x59, 0x49, 0x6F, 0x66, 0x00, 0x00 } -- '2'
letters["3"] = { 0x22, 0x63, 0x49, 0x49, 0x7F, 0x36, 0x00, 0x00 } -- '3'
letters["4"] = { 0x18, 0x1C, 0x16, 0x53, 0x7F, 0x7F, 0x50, 0x00 } -- '4'
letters["5"] = { 0x27, 0x67, 0x45, 0x45, 0x7D, 0x39, 0x00, 0x00 } -- '5'
letters["6"] = { 0x3C, 0x7E, 0x4B, 0x49, 0x79, 0x30, 0x00, 0x00 } -- '6'
letters["7"] = { 0x03, 0x03, 0x71, 0x79, 0x0F, 0x07, 0x00, 0x00 } -- '7'
letters["8"] = { 0x36, 0x7F, 0x49, 0x49, 0x7F, 0x36, 0x00, 0x00 } -- '8'
letters["9"] = { 0x06, 0x4F, 0x49, 0x69, 0x3F, 0x1E, 0x00, 0x00 } -- '9'


ds3231.init(3, 1)
max7219.setup({ debug = true, numberOfModules = 4, slaveSelectPin = 8, intensity = 6 })

brightness = 0
multiply = 1

function show_time() 
	second, minute, hour, day, date, month, year = ds3231.getTime();

	if hour > 9 then
		hour_string = string.format("%s", hour)
		first = letters[string.sub(hour_string, 1, 1)]
		second = letters[string.sub(hour_string, 2, 2)]
	else
	    hour_string = string.format("%s", hour)
	    first = letters["0"]
		second = letters[string.sub(hour_string, 1, 1)]
	end


	if minute > 9 then
		minute_string = string.format("%s", minute)
		minute_first = letters[string.sub(minute_string, 1, 1)]
		minute_second = letters[string.sub(minute_string, 2, 2)]
	else
	    hour_string = string.format("%s", hour)
	    first = letters["0"]
		second = letters[string.sub(hour_string, 1, 1)]
	end

	max7219.write({first, second, minute_first, minute_second})
	tmr.create():alarm(1000, tmr.ALARM_SINGLE, show_time)
end
