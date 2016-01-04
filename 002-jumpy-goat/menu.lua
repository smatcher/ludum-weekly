local GameState = require "love-toys.third-party.hump.gamestate" 

local menu = {}

function menu:draw()
	love.graphics.print("Press enter to start", 10, 10)
	love.graphics.print("Press escape to quit", 10, 30)
end

function menu:keyreleased(key, code)
	if key == 'return' then
		GameState.switch(states.Game)
	end
	if key == 'escape' then
		love.event.quit()
	end
end

return menu

