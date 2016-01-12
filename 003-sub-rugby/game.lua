local Camera = require "love-toys.third-party.hump.camera" 
local GameState = require "love-toys.third-party.hump.gamestate" 
local Timer = require "love-toys.third-party.hump.timer"
local Vector = require "love-toys.third-party.hump.vector"

local Entities = require "entities"
local Network = require "network"

local game = {
}

function game:init()
end

function game:drawBackground()
	local color_bkp = {love.graphics.getColor()}

	-- Background
	love.graphics.clear(Constants.Colors.Background)

	local CellWidth = Constants.Grid.DrawWidth / Constants.Grid.Width
	local CellHeight = Constants.Grid.DrawHeight / Constants.Grid.Height

	-- Team areas
	love.graphics.setColor(Constants.Colors.TeamRedArea)
	love.graphics.rectangle("fill", 
		Constants.Grid.DrawX,
		Constants.Grid.DrawY,
		Constants.Grid.DrawWidth,
		CellHeight * 2
	)
	love.graphics.setColor(Constants.Colors.TeamGreenArea)
	love.graphics.rectangle("fill", 
		Constants.Grid.DrawX,
		Constants.Grid.DrawY + Constants.Grid.DrawHeight - CellHeight * 2,
		Constants.Grid.DrawWidth,
		CellHeight * 2
	)

	-- Grid (with coordinate markers)
	love.graphics.setColor(Constants.Colors.GridMarkings)
	local coord_marker = 1
	for x = 0, Constants.Grid.DrawWidth, CellWidth do
		local draw_x = Constants.Grid.DrawX + x

		love.graphics.line(
			draw_x,
			Constants.Grid.DrawY,
			draw_x,
			Constants.Grid.DrawY + Constants.Grid.DrawHeight
		)

		if coord_marker <= Constants.Grid.Width then
			love.graphics.print(
				coord_marker,
				draw_x + Constants.Grid.HorMarkerOffsetX,
				Constants.Grid.DrawY - Constants.Grid.HorMarkerOffsetY
			)
			coord_marker = coord_marker + 1
		end
	end

	coord_marker = 1
	for y = 0, Constants.Grid.DrawHeight, CellHeight do
		local draw_y = Constants.Grid.DrawY + y

		love.graphics.line(
			Constants.Grid.DrawX,
			draw_y,
			Constants.Grid.DrawX + Constants.Grid.DrawWidth,
			draw_y
		)

		if coord_marker <= Constants.Grid.Height then
			local A = "A"
			local letter = string.char(A:byte() + (coord_marker - 1))
			love.graphics.print(
				letter,
				Constants.Grid.DrawX - Constants.Grid.VerMarkerOffsetX,
				draw_y + Constants.Grid.VerMarkerOffsetY
			)
			coord_marker = coord_marker + 1
		end
	end

	love.graphics.setColor(color_bkp)
end

function game:draw()
	self:drawBackground()
	love.graphics.print("Press escape to return to menu", 10, 10)
end

function game:update(dt)
	Network:update(dt)
end

function game:keypressed(key, code, isrepeat)
--	if key == 'left' then
--		self.player.direction = PlayerEntity.LeftDirection
--	end
--
--	if key == 'right' then
--		self.player.direction = PlayerEntity.RightDirection
--	end
end

function game:keyreleased(key, code)
	if key == 'escape' then
		Network:abort()
		GameState.switch(states.Menu)
	end
end

return game

