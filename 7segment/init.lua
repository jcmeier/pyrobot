if not tmr.create():alarm(5000, tmr.ALARM_AUTO, function()
  pin = 1
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
        -- Integer firmware using this example
        show_temperature(math.floor(temp))
        show_humidity(math.floor(humi))
    
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
end)
then
  print("whoopsie")
end


function dot_animation(reg, toggle)
    setReg(MAXREG_DECODEMODE, 0x00)
    abort = false
    if reg == 8 then
        reg = 0
        if toggle then
            toggle = false
        else 
            abort = true
        end
    end 
    if toggle then
        setReg(reg, bit.set(0x00, 7))
    else
        setReg(reg, 0x0)
    end
    
    if not abort then
        if not tmr.create():alarm(100, tmr.ALARM_SINGLE, function()
          dot_animation(reg + 1, toggle)
        end)
        then
          print("whoopsie")
        end
    end
end