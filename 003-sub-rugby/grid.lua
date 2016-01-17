local Class = require "love-toys.third-party.hump.class"

require "constants"

local GridClass = Class {}

-- precompute some values
local CellWidth = Constants.Grid.DrawWidth / Constants.Grid.Width
local CellHeight = Constants.Grid.DrawHeight / Constants.Grid.Height

function GridClass:init()
	self.hovering_enabled = false
	self.hovering_condition_hook = nil
	self.hovered_cell = nil
	self.flashing_tile_color = {192, 192, 192, 192}
end

function GridClass:enableHovering(condition_hook)
	self.hovering_enabled = true
	self.hovering_condition_hook = condition_hook
	self.hovered_cell = nil
end

function GridClass:disableHovering()
	self.hovering_enabled = false
end

function GridClass:isPlayerTeamArea(cell_x, cell_y)
	local x_in_area = cell_x >= 0 and cell_x < Constants.Grid.TeamAreaDepth
	local y_in_area = cell_y >= 0 and cell_y < Constants.Grid.Height
	return x_in_area and y_in_area
end

function GridClass:isRemoteTeamArea(cell_x, cell_y)
	local x_in_area = cell_x >= Constants.Grid.Width - Constants.Grid.TeamAreaDepth and cell_x < Constants.Grid.Width
	local y_in_area = cell_y >= 0 and cell_y < Constants.Grid.Height
	return x_in_area and y_in_area
end

function GridClass:cellCoord(cell_x, cell_y)
	local pix_x = Constants.Grid.DrawX + cell_x * CellWidth
	local pix_y = Constants.Grid.DrawY + cell_y * CellHeight
	return pix_x, pix_y
end

function GridClass:cellAtCoord(pix_x, pix_y)
	local cell_x = math.floor((pix_x - Constants.Grid.DrawX) / CellWidth)
	local cell_y = math.floor((pix_y - Constants.Grid.DrawY) / CellHeight)
	if cell_x < 0
	or cell_x >= Constants.Grid.Width
	or cell_y < 0
	or cell_y >= Constants.Grid.Height then
		return -1, -1
	end
	return cell_x, cell_y
end

function GridClass:draw()
	local color_bkp = {love.graphics.getColor()}

	-- Team areas
	love.graphics.setColor(Constants.Colors.TeamGreenArea)
	local team_area_width = CellWidth * Constants.Grid.TeamAreaDepth
	love.graphics.rectangle("fill", 
		Constants.Grid.DrawX,
		Constants.Grid.DrawY,
		team_area_width,
		Constants.Grid.DrawHeight
	)
	love.graphics.setColor(Constants.Colors.TeamRedArea)
	love.graphics.rectangle("fill", 
		Constants.Grid.DrawX + Constants.Grid.DrawWidth - team_area_width,
		Constants.Grid.DrawY,
		team_area_width,
		Constants.Grid.DrawHeight
	)

	-- Hovered cell
	if self.hovered_cell ~= nil then
		self.flashing_tile_color[4] = 192 * global_blinker
		love.graphics.setColor(self.flashing_tile_color)
		love.graphics.rectangle("fill", 
			Constants.Grid.DrawX + self.hovered_cell[1] * CellWidth,
			Constants.Grid.DrawY + self.hovered_cell[2] * CellHeight,
			CellWidth,
			CellHeight
		)
	end

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

function GridClass:mousemoved(x, y, dx, dt)
	if self.hovering_enabled then
		local cell_x, cell_y = self:cellAtCoord(x, y)
		local cell_correct = cell_x >= 0 and cell_y >= 0  -- cellAtcoord will return -1, -1 on incorrect coords
		local hook_correct = self.hovering_condition_hook == nil or self.hovering_condition_hook(cell_x, cell_y)

		if cell_correct and hook_correct then
			self.hovered_cell = {cell_x, cell_y}
		else
			self.hovered_cell = nil
		end
	end
end

return GridClass

