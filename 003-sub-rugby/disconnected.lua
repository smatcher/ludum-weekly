local GameState = require "love-toys.third-party.hump.gamestate" 
local Network = require "network"

local disconnected = {
}

function disconnected:init()
end

function disconnected:draw()
	love.graphics.print("Disconnected", 10, 10)
	love.graphics.print("Press enter to return to menu", 10, 30)
end

function disconnected:update(dt)
	Network:update(dt)
end

function disconnected:keyreleased(key, code)
	if key == 'return' then
		Network:abort()
		GameState.switch(states.Menu)
	end
end

return disconnected

