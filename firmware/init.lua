require("display")

function start_wlan()
    station_cfg={}
    station_cfg.ssid="Blubberblah"
    station_cfg.pwd="*****"
    wifi.setmode(wifi.STATION)
    wifi.sta.config(station_cfg)
    wifi.sta.sethostname("Catch-me-if-you-can")
    wifi.sta.connect()
    print(wifi.sta.getip())
end

function init_ports()
    gpio.mode(0, gpio.OUTPUT)
    gpio.mode(1, gpio.OUTPUT)
    gpio.mode(2, gpio.OUTPUT)
    gpio.mode(3, gpio.OUTPUT)
end

function left_stop()
    gpio.write(0, gpio.LOW)
    gpio.write(1, gpio.LOW)
end

function right_stop()
    gpio.write(2, gpio.LOW)
    gpio.write(3, gpio.LOW)
end

function left_backward()
    gpio.write(0, gpio.HIGH)
    gpio.write(1, gpio.LOW)
end

function left_forward()
    gpio.write(0, gpio.LOW)
    gpio.write(1, gpio.HIGH)
end

function right_backward()
    gpio.write(2, gpio.LOW)
    gpio.write(3, gpio.HIGH)
end

function right_forward()
    gpio.write(2, gpio.HIGH)
    gpio.write(3, gpio.LOW)
end

function backward()
    left_backward()
    right_backward()
end

function forward()
    left_forward()
    right_forward()
end    


function stop()
    left_stop()
    right_stop()
end

function handle_udp_packet(srv, command)
       print("Command Reveived:")
       print("***" .. command .. "****")
       if command == "stop" then
            stop()
       
       elseif command == "forward" then
            forward()

       elseif command == "backward" then
            backward()

       elseif command == "left_forward" then
            right_stop()
            left_forward()

        elseif command == "right_forward" then
            left_stop()
            right_forward()
       
       elseif command == "left_backward" then
            right_stop()
            left_backward()
       
       elseif command == "right_backward" then
             left_stop()
             right_backward()

       elseif command == "turn_left" then
             left_backward()
             right_forward()

       elseif command == "turn_right" then
             left_forward()
             right_backward()

       elseif string.sub(command, 1, 8) == "message " then
           display_message(string.sub(command, 9, string.len(command)), 0)

       end
end

function start_udpserver()
    srv=net.createServer(net.UDP)
    srv:on("receive", handle_udp_packet)
    srv:listen(4242)
end

init_ports()
stop()
start_wlan()
start_udpserver()

setup_display()
moody(0)
