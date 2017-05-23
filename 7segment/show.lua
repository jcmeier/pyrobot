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
