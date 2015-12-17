
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

function love.load()
	UI = require "love-toys.third-party.loveframes"
end

function love.update(dt)
	UI.update(dt)
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
	-- TODO --

	-- Draw stryker --
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

