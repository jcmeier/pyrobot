MAXREG_DECODEMODE = 0x09
MAXREG_INTENSITY  = 0x0a
MAXREG_SCANLIMIT  = 0x0b
MAXREG_SHUTDOWN   = 0x0c
MAXREG_DISPTEST   = 0x0f 
DIN   = 7      -- 13 - data in pin
CS    = 8      -- 12 - load (CS) pin
CLK   = 5      -- 14 - clock pin
gpio.mode(DIN,gpio.OUTPUT)
gpio.mode(CS,gpio.OUTPUT)
gpio.mode(CLK,gpio.OUTPUT)

function wrByte(data)
   i=8
   while (i>0)  
   do
       mask = bit.lshift(0x01,i-1)
       --print(mask)
       gpio.write( CLK, 0)    -- tick
       dser = bit.band(data,mask)
       if (dser > 0) 
         then gpio.write(DIN, 1)   -- send 1
              --print("1")
         else gpio.write(DIN, 0)   -- send 0
              --print("0")
       end --endif
       --print(dser)
       gpio.write( CLK, 1)    -- tick
       i=i-1
    end --while
end

function setReg(reg, value)
  gpio.write(CS, 0)

  wrByte(reg)   -- specify register
  tmr.delay(10)
  wrByte(value) -- send data

  gpio.write(CS, 0)
  --tmr.delay(10)
  gpio.write(CS, 1)
end

 function print_led_int(c) 
   th = string.format("%d",c / 1000)
   h = string.format("%d",(c-th*1000) / 100)
   t = string.format("%d", (c-th*1000-h*100) / 10)
   u = string.format("%d", c-th*1000-h*100-t*10)
   --print(string.format("%d %d %d %d", th,h,t,u))
   setReg(4, th)
   setReg(3, h)
   setReg(2, t)
   setReg(1, u)
end

function zero_all()
   v=1
   while (v<9) do
       setReg(v,0)
    v=v+1
   end
end 

seg_numbers = {}
seg_numbers[0] = bit.set(0x00, 6,5,4,3,2,1)
seg_numbers[1] = bit.set(0x00, 5,4)
seg_numbers[2] = bit.set(0x00, 6,5,0,2,3)
seg_numbers[3] = bit.set(0x00, 6, 5,0,4,3)
seg_numbers[4] = bit.set(0x00, 1, 0, 5, 4)
seg_numbers[5] = bit.set(0x00, 6, 1, 0, 4,3)
seg_numbers[6] = bit.set(0x00, 6,1,0,4,3,2)
seg_numbers[7] = bit.set(0x00, 6,5,4)
seg_numbers[8] = bit.set(0x00, 6,5,4, 3, 2,1, 0)
seg_numbers[9] = bit.set(0x00, 6,5,4, 3,1, 0)

function show_temperature(celsius)
  setReg(MAXREG_DECODEMODE, 0x00)
  setReg(1, bit.set(0x00, 6, 5, 0, 1))

  celsius = string.format("%d", celsius)
  setReg(3, seg_numbers[tonumber(string.sub(celsius, 1, 1))])
  setReg(2, seg_numbers[tonumber(string.sub(celsius, 2, 2))])
end

function show_humidity(humidity)
   string.format("%d", humidity)
   setReg(7, seg_numbers[tonumber(string.sub(humidity, 1, 1))])
   setReg(8, seg_numbers[tonumber(string.sub(humidity, 2, 2))])
end

function start_dot_animation()
  zero_all()
  dot_animation(1, true)
end

function start_temperature_animation()
  pin = 1
  status, temp, humi, temp_dec, humi_dec = dht.read(pin)
  if status == dht.OK then
    show_temperature(math.floor(temp))
    show_humidity(math.floor(humi))
  end
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

setReg(MAXREG_SCANLIMIT, 0x07)
tmr.delay(100)
--setReg(MAXREG_DECODEMODE, 0xFF)    -- full decode mode BCD
setReg(MAXREG_DECODEMODE, 0x00)
tmr.delay(100)
setReg(MAXREG_SHUTDOWN, 0x01)          -- not in shutdown mode
tmr.delay(100)
setReg(MAXREG_DISPTEST, 0x00)              -- no display test
tmr.delay(100)
setReg(MAXREG_INTENSITY, 0xff)            -- set Brightness
zero_all()   
