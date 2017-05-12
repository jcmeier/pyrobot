ds3231 = require("ds3231")
ds3231.init(3, 4)
--ds3231.setTime(30, 5, 20, 1, 7, 5, 17);

-- Get date and time
second, minute, hour, day, date, month, year = ds3231.getTime();

-- Print date and time
print(string.format("Time & Date: %s:%s:%s %s/%s/%s", 
    hour, minute, second, date, month, year))
