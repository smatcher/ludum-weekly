local Class = require "love-toys.third-party.hump.class"

local GridClass = Class {}

function GridClass:init()
end

function GridClass:draw()
	local color_bkp = {love.graphics.getColor()}

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

function GridClass:update(dt)
end

return GridClass

