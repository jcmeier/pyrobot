game_field = nil
ball_direction = nil
ball_position = {}

function start_pong_game()
	create_game_field()
	position_player_1(3)
	position_player_2(3)
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
end 

function move_ball()
	game_field[ball_position[1]][ball_position[2]] = 0
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
	check_collision()
	game_field[ball_position[1]][ball_position[2]] = 1

end

function check_collision()
	if ball_position[1] < 1 then
		ball_position[1] = 2
		ball_position[2] = ball_position[2]
		ball_direction = 3

	elseif ball_position[2] > 7 then
		ball_position[2] = 7
		ball_direction = node.random(4, 6)
		print(ball_direction)

	elseif ball_position[1] > 8 then
		ball_position[1] = 7
		ball_position[2] = ball_position[2]
		ball_direction = 1
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

--start_pong_game()
