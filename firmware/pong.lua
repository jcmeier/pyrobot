game_field = nil
ball_direction = nil
ball_position = {}

function start_pong_game()
	create_game_field()
	position_player_1(3)
	position_player_2(3)
	init_ball()

	print_game()
	clock_game()
	print_game()
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
	math.randomseed(os.time())
	ball_direction = math.random(3)
end

function clock_game()
	move_ball()
	check_score()
end 

function move_ball()
	game_field[ball_position[0][ball_position[1]] = 0
	if ball_direction == 1:
	end	
end

function check_score()
end

function print_game()
	for i=1,8 do
		for j=1,8 do
			io.write(game_field[i][j])
		end	 
		print()
	end
end
start_pong_game()