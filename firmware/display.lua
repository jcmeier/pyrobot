MAX7219_REG_NOOP        = 0x00
MAX7219_REG_DECODEMODE  = 0x09
MAX7219_REG_INTENSITY   = 0x0A
MAX7219_REG_SCANLIMIT   = 0x0B
MAX7219_REG_SHUTDOWN    = 0x0C
MAX7219_REG_DISPLAYTEST = 0x0F

all =   {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}
happy = {0x3C, 0x42, 0xA5, 0x81, 0xA5, 0x99, 0x42, 0x3C}
frown = {0x3C, 0x42, 0xA5, 0x81, 0xBD, 0x81, 0x42, 0x3C}
sad = {0x3C, 0x42, 0xA5, 0x81, 0x99, 0xA5, 0x42, 0x3C}
N = { 0x7F, 0x7F, 0x06, 0x0C, 0x18, 0x7F, 0x7F, 0x00 }
O = { 0x1C, 0x3E, 0x63, 0x41, 0x63, 0x3E, 0x1C, 0x00 }
R = { 0x41, 0x7F, 0x7F, 0x09, 0x19, 0x7F, 0x66, 0x00 }
A = { 0x7C, 0x7E, 0x13, 0x13, 0x7E, 0x7C, 0x00, 0x00 }
faces = {all, happy, frown, sad, N, O, R, A}

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

-- changes the face every two seconds cycling through the array of faces
function moody(i)
  faceIndex = (i % 8) + 1
  displayFace(faceIndex)
  tmr.alarm(0, 2000, 0, function()
    moody(faceIndex)
  end);
end

