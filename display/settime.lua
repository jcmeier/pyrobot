ds3231 = require("ds3231")
ds3231.init(3, 1)

function sync_time()

    sntp.sync(nil,
      function(sec, usec, server, info)
        tm = rtctime.epoch2cal(sec)
        sec = tonumber(tm["sec"])
        min = tonumber(tm["min"])
        hour = tonumber(tm["hour"]) + 2
        day = tonumber(tm["day"])
        month = tonumber(tm["mon"])
        year = tonumber(tm["year"])
        
     -- (second, minute, hour, day, date, month, year, disOsc
        ds3231.setTime(sec, min, hour, 2, day, month, 17);
        
        print(string.format("%04d/%02d/%02d %02d:%02d:%02d", 
        tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
    
      end,
      function()
       print('failed!')
      end
    )
end


function wifi_connect()
    station_cfg={}
    station_cfg.ssid="WIFI"
    station_cfg.pwd="PASSWORD"
    wifi.setmode(wifi.STATION)
    wifi.sta.config(station_cfg)
    --wifi.sta.sethostname("Gamepad of death")
    wifi.sta.connect()
    
end

wifi_connect()
