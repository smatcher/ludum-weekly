require "love-toys.third-party.randomlua"

local rng = mwc(0)

paddle_width = 6
paddle_height = 120
paddle_start_x = 60
paddle_start_y = 300

paddle_1_x = paddle_start_x
paddle_1_y = paddle_start_y
paddle_1_speed = 0
paddle_2_x = love.window.getWidth() - paddle_start_x
paddle_2_y = paddle_start_y
paddle_2_speed = 0

max_paddle_speed = 100
max_paddle_acceleration = 200

ball_width = 10
ball_x = love.window.getWidth() / 2
ball_y = love.window.getHeight() / 2
ball_speed_x = 100
ball_speed_y = 20

separation_width = 2
separation_spacing = 4
separation_length = 6
separation_margin = 40
separation_x = love.window.getWidth() / 2

score_margin = 40
score_height = 60
score_width  = 30
score_thickness = 4
score_spacing = 10

streaker_speed = 100
streaker_x = love.window.getWidth() / 2
streaker_y = love.window.getHeight() - separation_margin
streaker_width = 30

streaker_map_1 = {1, 2, 3, 4, 5, 6, 7, 8, 9}
streaker_map_2 = {6, 3, 8, 1, 7, 4, 2, 9, 5}
streaker_blend = 0
streaker_colors = {
	{255, 128, 128, 255},
	{200, 140, 128, 255},
	{255, 160, 140, 255},
	{255, 080, 140, 255},
	{200, 120, 128, 255},
	{200, 140, 100, 255},
	{230, 080, 080, 255},
	{200, 100, 100, 255},
	{255, 140, 080, 255},
	{200, 160, 140, 255},
}

p1_score = 0
p2_score = 0

-- first index: number
-- second index: top top-left top-right middle lower-left lower-right bottom quadrants of a LED display
score_font = {
	{true,  true,  true,  false, true,  true, true}, -- 0
	{false, false, true,  false, false, true, false}, -- 1
	{true,  false, true,  true,  true, false, true}, -- 2
	{true,  false, true,  true,  false, true, true}, -- 3
	{false, true,  true,  true,  false, true, false}, -- 4
	{true,  true,  false, true,  false, true, true}, -- 5
	{true,  true,  false, true,  true,  true, true}, -- 6
	{true,  false, true,  false, false, true, false}, -- 7
	{true,  true,  true,  true,  true,  true, true}, -- 8
	{true,  true,  true,  true,  false,  true, false}, -- 9
}

function love.load()
	UI = require "love-toys.third-party.LoveFrames"

	resetBall(1)
end

function resetBall(serving_player)
	ball_x = love.window.getWidth() / 2
	ball_y = love.window.getHeight() / 2

	if serving_player == 1 then
		ball_speed_x = 200
	else
		ball_speed_x = -200
	end

	-- TODO : add some randomness
	ball_speed_y = 20
end

function resetStreaker()
	streaker_x = love.window.getWidth()/2
	streaker_y = love.window.getHeight() - separation_margin
end

function love.update(dt)
	UI.update(dt)

	local new_ball_x = ball_x + ball_speed_x * dt
	local new_ball_y = ball_y + ball_speed_y * dt
	local new_ball_speed_x = ball_speed_x
	local new_ball_speed_y = ball_speed_y
	local reset_ball = false
	local serving_player = 1

	-- hit left wall
	if new_ball_x < 0 then
		p2_score = (p2_score + 1) % 100
		serving_player = 2
		reset_ball = true
	end

	-- hit right wall
	if new_ball_x > love.window.getWidth() then
		p1_score = (p1_score + 1) % 100
		serving_player = 1
		reset_ball = true
	end

	-- hit p1 paddle
	if new_ball_x - ball_width/2 < paddle_1_x + paddle_width/2 and
	   ball_x - ball_width/2 > paddle_1_x + paddle_width/2 and
	   new_ball_y > paddle_1_y - paddle_height/2 and
	   new_ball_y < paddle_1_y + paddle_height/2 then
		new_ball_x = ball_x
		new_ball_speed_x = -ball_speed_x
		-- TODO : increase speed (add some spin effect)
	end

	-- hit p2 paddle
	if new_ball_x + ball_width/2 > paddle_2_x - paddle_width/2 and
	   ball_x + ball_width/2 < paddle_2_x - paddle_width/2 and
	   new_ball_y > paddle_2_y - paddle_height/2 and
	   new_ball_y < paddle_2_y + paddle_height/2 then
		new_ball_x = ball_x
		new_ball_speed_x = -ball_speed_x
		-- TODO : increase speed (add some spin effect)
	end

	-- hit screen top
	if new_ball_y < 0 then
		new_ball_y = ball_y
		new_ball_speed_y = -ball_speed_y
	end

	-- hit screen bottom
	if new_ball_y > love.window.getHeight() then
		new_ball_y = ball_y
		new_ball_speed_y = -ball_speed_y
	end

	-- apply new ball coord
	if reset_ball then
		resetBall(serving_player)
	else
		ball_x = new_ball_x
		ball_y = new_ball_y
		ball_speed_x = new_ball_speed_x
		ball_speed_y = new_ball_speed_y
	end

	-- paddles track the ball
	-- TODO : add some prediction and some delay to make it more life-like
	local paddle_acceleration = max_paddle_acceleration * dt
	local paddle_1_target = ball_y
	if ball_speed_x > 0 then
		paddle_1_target = love.window.getHeight()/2
	end
	if paddle_1_y > paddle_1_target then
		paddle_1_speed = math.max(paddle_1_speed - paddle_acceleration, -max_paddle_speed)
	elseif paddle_1_y < paddle_1_target then
		paddle_1_speed = math.min(paddle_1_speed + paddle_acceleration, max_paddle_speed)
	end
	paddle_1_y = paddle_1_y + paddle_1_speed * dt

	local paddle_2_target = ball_y
	if ball_speed_x < 0 then
		paddle_2_target = love.window.getHeight()/2
	end
	if paddle_2_y > paddle_2_target then
		paddle_2_speed = math.max(paddle_2_speed - paddle_acceleration, -max_paddle_speed)
	elseif paddle_2_y < paddle_2_target then
		paddle_2_speed = math.min(paddle_2_speed + paddle_acceleration, max_paddle_speed)
	end
	paddle_2_y = paddle_2_y + paddle_2_speed * dt

	-- move streaker
	local dx = 0
	local dy = 0
	if love.keyboard.isDown("left")  then dx = dx - 1 end
	if love.keyboard.isDown("right") then dx = dx + 1 end
	if love.keyboard.isDown("up")    then dy = dy - 1 end
	if love.keyboard.isDown("down")  then dy = dy + 1 end
	if dx ~= 0 or dy ~= 0 then
		local div = math.sqrt(dx*dx + dy*dy)
		dx = dt * streaker_speed * dx / div
		dy = dt * streaker_speed * dy / div
		streaker_x = streaker_x + dx
		streaker_y = streaker_y + dy

		-- hit screen boundaries
		if streaker_x < 0                       then streaker_x = 0 end
		if streaker_x > love.window.getWidth()  then streaker_x = love.window.getWidth() end
		if streaker_y < 0                       then streaker_y = 0 end
		if streaker_y > love.window.getHeight() then streaker_y = love.window.getHeight() end

		-- catch ball
		local dist_x = ball_x - streaker_x
		local dist_y = ball_y - streaker_y
		if math.sqrt(dist_x*dist_x + dist_y*dist_y) < streaker_width then
			local default_serving_player = 1
			if ball_x > love.graphics.getWidth()/2 then default_serving_player = 2 end
			resetBall(default_serving_player)
			resetStreaker()
		end
	end

	-- streaker color blending 
	streaker_blend = streaker_blend + dt
	if streaker_blend > 1 then
		streaker_blend = streaker_blend - 1
		-- swap streaker maps
		streaker_map_1, streaker_map_2 = streaker_map_2, streaker_map_1
		-- randomize the second map
		for i = 1,8,1 do
			local swap = streaker_map_2[i]
			local swap_index = rng:random(i, 9)
			streaker_map_2[i] = streaker_map_2[swap_index]
			streaker_map_2[swap_index] = swap
		end
	end
end

function drawDigit(x, y, digit)
	-- top quadrant
	local quad_x = x - score_width/2
	local quad_y = y - score_height/2
	if score_font[digit + 1][1] then
		love.graphics.rectangle("fill", quad_x, quad_y, score_width, score_thickness)
	end

	-- top-left quadrant
	quad_x = x - score_width/2
	quad_y = y - score_height/2
	if score_font[digit + 1][2] then
		love.graphics.rectangle("fill", quad_x, quad_y, score_thickness, score_height/2)
	end

	-- top-right quadrant
	quad_x = x + score_width/2 - score_thickness
	quad_y = y - score_height/2
	if score_font[digit + 1][3] then
		love.graphics.rectangle("fill", quad_x, quad_y, score_thickness, score_height/2)
	end

	-- middle quadrant
	quad_x = x - score_width/2
	quad_y = y - score_thickness/2
	if score_font[digit + 1][4] then
		love.graphics.rectangle("fill", quad_x, quad_y, score_width, score_thickness)
	end

	-- lower-left quadrant
	quad_x = x - score_width/2
	quad_y = y
	if score_font[digit + 1][5] then
		love.graphics.rectangle("fill", quad_x, quad_y, score_thickness, score_height/2)
	end

	-- lower-right quadrant
	quad_x = x + score_width/2 - score_thickness
	quad_y = y
	if score_font[digit + 1][6] then
		love.graphics.rectangle("fill", quad_x, quad_y, score_thickness, score_height/2)
	end

	-- bottom quadrant
	quad_x = x - score_width/2
	quad_y = y + score_height/2 - score_thickness
	if score_font[digit + 1][7] then
		love.graphics.rectangle("fill", quad_x, quad_y, score_width, score_thickness)
	end

end

function drawScore()
	-- P1 score
	local digit = math.floor(p1_score /10) % 10
	if digit ~= 0 then
		drawDigit(love.window.getWidth()/2 - 4*score_spacing - score_width/2 - score_width, score_margin + score_height/2, digit)
	end
	digit = p1_score % 10
	drawDigit(love.window.getWidth()/2 - 3*score_spacing - score_width/2, score_margin + score_height/2, digit)

	-- P2 score
	digit = math.floor(p2_score /10) % 10
	if digit ~= 0 then
		drawDigit(love.window.getWidth()/2 + 3*score_spacing + score_width/2, score_margin + score_height/2, digit)
		drawDigit(love.window.getWidth()/2 + 4*score_spacing + score_width/2 + score_width, score_margin + score_height/2, p2_score % 10)
	else
		drawDigit(love.window.getWidth()/2 + 3*score_spacing + score_width/2, score_margin + score_height/2, p2_score)
	end
end

function drawStreaker()
	local beg_x = streaker_x - streaker_width/2
	local beg_y = streaker_y - streaker_width/2
	local incr = streaker_width/3

	for x = 0, 2, 1 do
		for y = 0, 2, 1 do
			local col_1 = streaker_colors[streaker_map_1[1 + x + 3*y]]
			local col_2 = streaker_colors[streaker_map_2[1 + x + 3*y]]
			local col = {}
			for i = 1,4,1 do
				col[i] = col_1[i] * (1-streaker_blend) + col_2[i] * streaker_blend
			end
			love.graphics.setColor(col)
			love.graphics.rectangle("fill", beg_x + x*incr, beg_y + y*incr, incr, incr)
		end
	end
	-- restore white
	love.graphics.setColor(255, 255, 255)
end

function love.draw()
	-- Draw ball
	love.graphics.rectangle("fill", ball_x - ball_width/2, ball_y - ball_width/2, ball_width, ball_width)

	-- Draw paddles
	love.graphics.rectangle("fill", paddle_1_x - paddle_width/2, paddle_1_y - paddle_height/2, paddle_width, paddle_height)
	love.graphics.rectangle("fill", paddle_2_x - paddle_width/2, paddle_2_y - paddle_height/2, paddle_width, paddle_height)

	-- Draw separation line
	local min_y = separation_margin
	local max_y = love.window.getHeight() - separation_margin - separation_length
	local incr_y = separation_spacing + separation_length
	for y = min_y, max_y, incr_y do
		love.graphics.rectangle("fill", separation_x - separation_width/2, y, separation_width, separation_length)
	end

	-- Draw score
	drawScore()

	-- Draw streaker --
	drawStreaker()

	UI.draw()
end

function love.mousepressed(x, y, button)
	UI.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	UI.mousereleased(x, y, button)
end

function love.keypressed(key, isrepeat)
	UI.keypressed(key, isrepeat)

	if key == "escape" then
		love.event.quit()
	end
end

function love.keyreleased(key)
	UI.keyreleased(key)
end

function love.textinput(text)
	UI.textinput(text)
end

