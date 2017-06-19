require("pong")

function start_wlan()
    wifi.setmode(wifi.SOFTAP)
    cfg={}
    cfg.ssid="Come to daddy!"
    cfg.pwd="mypassword"
    wifi.ap.config(cfg)

    cfg =
    {
        ip="192.168.42.1",
        netmask="255.255.255.0",
        gateway="192.168.42.1"
    }
    wifi.ap.setip(cfg)
end



function handle_udp_packet(srv, command)
       print("Command Reveived:")
       print("***" .. command .. "****")
       if command == "btn_start" then
           print("Starting")
           start_game()
       
       elseif command == "forward" then
            print("player_up")
            player_up()

       elseif command == "backward" then
            print("player_down")
            player_down()
       end
end

function start_udpserver()
    srv=net.createServer(net.UDP)
    srv:on("receive", handle_udp_packet)
    srv:listen(4242)
end

start_wlan()
start_udpserver()
start_pong_game()


