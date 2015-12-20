
paddle_width = 6
paddle_height = 120
paddle_start_x = 60
paddle_start_y = 300

paddle_1_x = paddle_start_x
paddle_1_y = paddle_start_y
paddle_2_x = love.window.getWidth() - paddle_start_x
paddle_2_y = paddle_start_y

ball_width = 10
ball_x = love.window.getWidth() / 2
ball_y = love.window.getHeight() / 2

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
end

global_timer = 0
function love.update(dt)
	UI.update(dt)
	local prev = global_timer
	global_timer = global_timer + dt
	if math.floor(prev) ~= math.floor(global_timer) then
		p1_score = p1_score + 1
		p2_score = p2_score + 2
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
	-- TODO --

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

