local GameState = require "love-toys.third-party.hump.gamestate" 

local menu = {}

function menu:draw()
	love.graphics.print("Press enter to start", 10, 10)
end

function menu:keyreleased(key, code)
	if key == 'return' then
		GameState.switch(states.Game)
	end
end

return menu

