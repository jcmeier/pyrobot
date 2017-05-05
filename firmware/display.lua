
MAX7219_REG_NOOP        = 0x00
MAX7219_REG_DECODEMODE  = 0x09
MAX7219_REG_INTENSITY   = 0x0A
MAX7219_REG_SCANLIMIT   = 0x0B
MAX7219_REG_SHUTDOWN    = 0x0C
MAX7219_REG_DISPLAYTEST = 0x0F
 

function sendByte(reg, data)
  spi.send(1,reg * 256 + data)
  tmr.delay(50)
end

function show_animation_from_file(position, size)
    fd = file.open("animation.bytes", "r")
    if fd then
       
        if size == position then
             position = 0
        end    
        
        for i=0,7 do
            fd:seek("set", position)
            position = position + 1
            data = fd:read(1) 
            sendByte(i+1, string.byte(data))   
        end    
        
        fd:close()
        local mytmr = tmr.create()
        mytmr:alarm(500, tmr.ALARM_SINGLE, function() 
            show_animation_from_file(position, size)
        end)
    end
end        

function start_animation()
    s = file.stat("animation.bytes")
    show_animation_from_file(0, s.size)
end

function setup_display()
    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 16, 8)

    sendByte (MAX7219_REG_SHUTDOWN, 1)
    sendByte (MAX7219_REG_SCANLIMIT, 7)
    sendByte (MAX7219_REG_DECODEMODE, 0x00)
    sendByte (MAX7219_REG_DISPLAYTEST, 0)
    sendByte (MAX7219_REG_INTENSITY, 12)
    sendByte (MAX7219_REG_SHUTDOWN, 1)
    
    tmr.stop(0)
end

setup_display()

