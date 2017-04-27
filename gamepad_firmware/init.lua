DATA = 1
CLOCK = 2
LATCH = 0

function wifi_connect()
    station_cfg={}
    station_cfg.ssid="Come to daddy!"
    station_cfg.pwd="password"
    wifi.setmode(wifi.STATION)
    wifi.sta.config(station_cfg)
    --wifi.sta.sethostname("Gamepad of death")
    wifi.sta.connect()
    
end

function clock()
    gpio.write(CLOCK, gpio.HIGH)
    gpio.write(CLOCK, gpio.LOW)
end

function init()
    gpio.mode(DATA, gpio.INPUT)
    gpio.mode(CLOCK, gpio.OUTPUT)
    gpio.mode(LATCH, gpio.OUTPUT)
    
    gpio.write(CLOCK, gpio.LOW)
    gpio.write(LATCH, gpio.LOW)
end

function latch()
    gpio.write(LATCH, gpio.HIGH)
    gpio.write(LATCH, gpio.LOW)
end

function send_command(command)
   cu = net.createUDPSocket()
   cu:send(4242,'192.168.178.111', command)
end

function main_loop()  
    latch()
    A_BUTTON = gpio.read(DATA)
    if A_BUTTON == 0 then
        send_command('stop')
    end    
    
    clock()
    B_BUTTON = gpio.read(DATA)
    if B_BUTTON == 0 then 
        send_command('btn_b')
    end
    
    clock()
    SELECT_BUTTON = gpio.read(DATA)
    if SELECT_BUTTON == 0 then
        send_command('btn_select')
    end    
    
    clock()
    START_BUTTON = gpio.read(DATA)
    if START_BUTTON == 0 then
        send_command('btn_start')
    end
    
    clock()
    UP_BUTTON = gpio.read(DATA)
    if UP_BUTTON == 0 then
        send_command('forward')
    end    
    
    clock()
    DOWN_BUTTON = gpio.read(DATA)
    if DOWN_BUTTON == 0 then
        send_command('backward')
    end
    
    clock()
    LEFT_BUTTON = gpio.read(DATA)
    if LEFT_BUTTON == 0 then
        send_command('turn_left')
    end
    
    clock()
    RIGHT_BUTTON = gpio.read(DATA)
    if RIGHT_BUTTON == 0 then
        send_command('turn_right')
    end    

    tmr.alarm(0, 75, 0, main_loop)
end


function start()
    if wifi.sta.getip() then
        init()
        main_loop() 
    else 
        tmr.alarm(0, 500, 0, start)
    end 
end

wifi_connect()
start()
