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

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function animate_all_on(position, first, second, third, fourth)
	if position <= 8 then
		first[position] = bit.set(first[position], 0, 1, 2, 3, 4, 5, 6, 7)
	
	elseif position <= 16 then
		second[position-8] = bit.set(second[position-8], 0, 1, 2, 3, 4, 5, 6, 7)
	
	elseif position <= 24 then
		third[position-16] = bit.set(third[position-16], 0, 1, 2, 3, 4, 5, 6, 7)

	elseif position <= 32 then
		fourth[position-24] = bit.set(fourth[position-24], 0, 1, 2, 3, 4, 5, 6, 7)	
	end
	
	max7219.write({first, second, third, fourth})
	if position <= 32 then
		position = position + 1
		tmr.create():alarm(1, tmr.ALARM_SINGLE, function() 
			show_clockturn_animation(position, first, second, third, fourth)
		end)
	end
	
end

function show_time(blink) 
	second, minute, hour, day, date, month, year = ds3231.getTime();

	if hour > 9 then
		hour_string = string.format("%s", hour)
		hour_first = shallowcopy(letters[string.sub(hour_string, 1, 1)])
		hour_second = shallowcopy(letters[string.sub(hour_string, 2, 2)])
	else
	    hour_string = string.format("%s", hour)
	    hour_first = shallowcopy(letters["0"])
		hour_second = shallowcopy(letters[string.sub(hour_string, 1, 1)])
	end


	if minute > 9 then
		minute_string = string.format("%s", minute)
		minute_first = shallowcopy(letters[string.sub(minute_string, 1, 1)])
		minute_second = shallowcopy(letters[string.sub(minute_string, 2, 2)])
	else
	    minute_string = string.format("%s", minute)
	    minute_first = shallowcopy(letters["0"])
		minute_second = shallowcopy(letters[string.sub(minute_string, 1, 1)])
	end

	if blink == true then
		hour_second[8] = bit.set(hour_second[8], 3, 4)
		blink = false
	else 
		hour_second[8] = bit.clear(hour_second[8], 3, 4)
		blink = true
	end

	seconds_iterate = second / 2
	for i=1,seconds_iterate do
		if i <= 8 then
			hour_first[i] = bit.set(hour_first[i], 7)
		elseif i <= 16 then
			hour_second[i-8] = bit.set(hour_second[i-8], 7)
		elseif i <= 24 then
			minute_first[i-16] = bit.set(minute_first[i-16], 7)
		elseif i <= 30 then
			minute_second[i-24] = bit.set(minute_second[i-24], 7)	
		end
	end
	if second > 57 then
		all_on= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff}
		max7219.write({all_on, all_on, all_on, all_on})
		timer_time = 1
	else
		max7219.write({hour_first, hour_second, minute_first, minute_second})
		timer_time = 500
	end

	tmr.create():alarm(timer_time, tmr.ALARM_SINGLE, function() 
		show_time(blink)
	end)
	
end
