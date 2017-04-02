require("displayfont")
MAX7219_REG_NOOP        = 0x00
MAX7219_REG_DECODEMODE  = 0x09
MAX7219_REG_INTENSITY   = 0x0A
MAX7219_REG_SCANLIMIT   = 0x0B
MAX7219_REG_SHUTDOWN    = 0x0C
MAX7219_REG_DISPLAYTEST = 0x0F

all =   {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}
happy = {0x3C, 0x42, 0xA5, 0x81, 0xA5, 0x99, 0x42, 0x3C}
frown = {0x3C, 0x42, 0xA5, 0x81, 0xBD, 0x81, 0x42, 0x3C}
sad = {0x3C, 0x42, 0xA5, 0x81, 0x99, 0xA5, 0x42, 0x3C }

faces = {all, happy, frown, sad}

function sendByte(reg, data)
  spi.send(1,reg * 256 + data)
  tmr.delay(50)
end

function displayFace(faceIndex)
  local face = faces[faceIndex]
  -- iterates over all 8 columns and sets their values
  for i=1,8 do
    sendByte(i,face[i])
  end
end

function display_letter(letter)
    for i=1,8 do
        if letters[letter] then
            sendByte(i,letters[letter][i])
        end
    end
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

stop_moody = false

function moody(i)
    if not stop_moody then
        faceIndex = (i % 4) + 1
        displayFace(faceIndex)
        tmr.alarm(0, 2000, 0, function()
            moody(faceIndex)
        end);
    end
end

function display_message(message, index)
    index = (index % string.len(message)) + 1
    stop_moody = true
    char = string.sub(message, index, index)
    display_letter(string.upper(char))
    tmr.alarm(0, 2000, 0, function()
        display_message(message, index)
    end);
end
