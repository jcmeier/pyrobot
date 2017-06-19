game_field = nil
ball_direction = nil
ball_position = {}
current_position_player_1 = 3 
current_position_player_2 = 3 

game_started = false
player_1_point = 0
player_2_point = 0

function start_pong_game()
	create_game_field()
	position_player_1(current_position_player_1)
	position_player_2(current_position_player_2)
	init_ball()
	show_game_on_display()
end

function position_player_1(y)
	position_player(y, 1)
end

function position_player_2(y)
	position_player(y, 8)
end

function position_player(y, x)	
	for i=1,8 do
		game_field[i][x] = 0
	end

	for i=0,3 do
		game_field[y+i][x] = 1
	end
end	

function create_game_field()
	game_field = {}
	for i=1,8 do
		game_field[i] = {}
		for j=1,8 do
			game_field[i][j] = 0
		end	 
	end
end	

function init_ball()
	game_field[4][2] = 1
	ball_position = {4, 2}
	ball_direction = node.random(3)
end

function clock_game()
	move_ball()
	check_score()
	show_game_on_display()
	if game_started == true then
		start_game_clock()
	end
end 

function move_ball()
	-- ball_position[1] == y
	-- ball_position[2] == x
	game_field[ball_position[1]][ball_position[2]] = 0

	print("Before collision")
	print(ball_direction)
	print(ball_position[1])
	print(ball_position[2])
	check_collision()
	print("After collision")
	print(ball_direction)
	print(ball_position[1])
	print(ball_position[2])

	if ball_direction == 1 then
		ball_position[1] = ball_position[1] - 1
		ball_position[2] = ball_position[2] + 1
	
	elseif ball_direction == 2 then
		ball_position[2] = ball_position[2] + 1
	
	elseif ball_direction == 3 then
		ball_position[1] = ball_position[1] + 1
		ball_position[2] = ball_position[2] + 1

	elseif ball_direction == 4 then
		ball_position[1] = ball_position[1] + 1
		ball_position[2] = ball_position[2] - 1

	elseif ball_direction == 5 then
		ball_position[2] = ball_position[2] - 1

	elseif ball_direction == 6 then
		ball_position[1] = ball_position[1] - 1
		ball_position[2] = ball_position[2] - 1

	end

	game_field[ball_position[1]][ball_position[2]] = 1

end

function check_collision()
	-- LEFT collision
	if ball_position[2] == 2 then

		bar_bottom = current_position_player_1 + 3
		if current_position_player_1 > ball_position[1] or bar_bottom < ball_position[1] then
			game_started = false
			player_1_point = player_1_point + 1

		elseif ball_position[1] == 1 then
			ball_position[1] = 1
			ball_direction = node.random(2, 3)
		
		elseif ball_position[1] == 8 then
			ball_position[1] = 8
			ball_direction = node.random(1, 2)
		
		else
			ball_direction = node.random(1, 3)
		end
		
	-- RIGHT collision
	elseif ball_position[2] == 7 then
		bar_bottom = current_position_player_2 + 3
		if current_position_player_2 > ball_position[1] or bar_bottom < ball_position[1] then
			game_started = false
			player_2_point = player_2_point + 1

		elseif ball_position[1] == 1 then
			ball_position[1] = 1
			ball_direction = node.random(4, 5)
		
		elseif ball_position[1] == 8 then
			ball_position[1] = 8
			ball_direction = node.random(5, 6)
		
		else
			ball_direction = node.random(4, 6) 
		end

		

    -- TOP and bottom collisions
	elseif ball_position[1] == 1 and ball_direction == 1 then
		ball_position[1] = 2
		ball_direction = 3

	elseif ball_position[1] == 1 and ball_direction == 6 then
		ball_position[1] = 2
		ball_direction = 6

	elseif ball_position[1] == 8 and ball_direction == 3 then
		ball_position[1] = 8
		ball_direction = 1
	
	elseif ball_position[1] == 8 and ball_direction == 4 then
		ball_position[1] = 8
		ball_direction = 6

	end	

end	

function player_down()
	print(current_position_player_1)
	
	if current_position_player_1 < 5 then
		current_position_player_1 = current_position_player_1 + 1
		position_player_1(current_position_player_1)
		show_game_on_display()
	end
end

function player_up()
	print(current_position_player_1)
	if current_position_player_1 > 1 then
		current_position_player_1 = current_position_player_1 - 1
		position_player_1(current_position_player_1)
		show_game_on_display()
	end
end

function check_score()
end

function show_game_on_display()
	for i = 1,8 do
		b = 0x0;
		for j=0,7 do
			if game_field[j+1][i] == 1 then
				b = bit.bor(b, bit.set(b, j))
			end	
		end
		
		sendByte(i, bit.band(b, 0xff))
	end
end

function start_game_clock()

	if not tmr.create():alarm(300, tmr.ALARM_SINGLE, function()
	  if game_started == true then
	  	clock_game()
	  end
	end)
	then
	  print("whoopsie")
	end
end

function start_game()
	if game_started == false then
		game_started = true
		start_pong_game()
		start_game_clock()
	end
end
