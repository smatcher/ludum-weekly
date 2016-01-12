local GameState = require "love-toys.third-party.hump.gamestate" 
local Network = require "network"

local connecting = {
}

function connecting:init()
end

function connecting:draw()
	if Network.server ~= nil then
		love.graphics.print("Awaiting client", 10, 10)
	else
		love.graphics.print("Connecting", 10, 10)
	end
	love.graphics.print("Press F10 to abort", 10, 30)
end

function connecting:update(dt)
	Network:update(dt)
end

function connecting:keyreleased(key, code)
	if key == 'f10' then
		Network:abort()
		GameState.switch(states.Menu)
	end
end

return connecting

