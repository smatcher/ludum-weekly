local Class = require "love-toys.third-party.hump.class"

local SubmarineClass = Class {
	Teams = {
		Player = 0,
		Remote = 1,
	},

	Directions = {
		North = 0,
		NorthEast = 1,
		East = 2,
		SouthEast = 3,
		South = 4,
		SouthWest = 5,
		West = 6,
		NorthWest = 7,
	},

	Actions = {
		-- Move actions
		Move_1  = 00,
		Move_2  = 01,
		Move_3  = 02,
		Move_4  = 03,
		Move_5  = 04,
		Move_6  = 05,
		-- Turn actions
		Turn_N  = 10,
		Turn_NE = 11,
		Turn_E  = 12,
		Turn_SE = 13,
		Turn_S  = 14,
		Turn_SW = 15,
		Turn_W  = 16,
		Turn_NW = 17,
		-- Interact actions
		Fire    = 20,
		Special = 21, -- Reserved for later use
		Grab    = 22,
		-- Other
		Wait    = 30,
	},
}

local function deltaCellsForDirection(d)
	local ds = SubmarineClass.Directions
	if d == ds.North then
		return 0,-1
	elseif d == ds.NorthEast then
		return 1,-1
	elseif d == ds.East then
		return 1,0
	elseif d == ds.SouthEast then
		return 1,1
	elseif d == ds.South then
		return 0,1
	elseif d == ds.SouthWest then
		return -1,1
	elseif d == ds.West then
		return -1,0
	elseif d == ds.NorthWest then
		return -1,-1
	end
end

local function isNonStealthyAction(action)
	if action ~= nil then
		if action  >= SubmarineClass.Actions.Move_3
		and action <= SubmarineClass.Actions.Move_6 then
			return true
		end
		if action == SubmarineClass.Actions.Fire then
			return true
		end
	end
	return false
end

function SubmarineClass:init()
	self.sonar_bleep = false
	self.team = SubmarineClass.Teams.Player
	self.x = -1
	self.y = -1
	self.in_game = false
	self.respawn_cooldown = 0
	self.direction = SubmarineClass.Directions.North
	self.action_1 = nil
	self.action_2 = nil
	self.selected = false
end

function SubmarineClass:drawActionMarker(action, draw_x, draw_y, override)
	if action ~= nil or override then
		love.graphics.setColor(0, 255, 0, 255)
	else
		love.graphics.setColor(96, 96, 96, 255)
	end
	love.graphics.rectangle("fill",
		draw_x,
		draw_y,
		4, -- Hardcoded while not definitive draw function
		4
	)
end

function SubmarineClass:draw(grid, draw_action_markers)
	if self.in_game == false then
		return
	end

	if self.team == SubmarineClass.Teams.Player then
		love.graphics.setColor(0, 128, 0, 255)
	else
		love.graphics.setColor(128, 0, 0, 255) -- TODO : skip displaying Remote Subs
	end

	-- Actual submarine drawing
	local draw_x, draw_y = grid:cellCoord(self.x, self.y)
	love.graphics.rectangle("fill",
		draw_x + 2,
		draw_y + 2,
		20, -- Hardcoded while not definitive draw function
		20,
		10
	)

	-- Action taken markers
	if draw_action_markers then
		self:drawActionMarker(self.action_1, draw_x + 12, draw_y + 18, false)
		local override = (self.action_1 == SubmarineClass.Actions.Move_5 
			or self.action_1 == SubmarineClass.Actions.Move_6)
		self:drawActionMarker(self.action_2, draw_x + 18, draw_y + 18, override)
	end

	-- Selection marker
	if self.selected then
		love.graphics.setColor(255,0,0,255)
		love.graphics.rectangle("line",
			draw_x,
			draw_y,
			24, -- Hardcoded while not definitive draw function
			24
		)
	end

	love.graphics.setColor(0,0,0,255)
	local markers = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
	local marker = markers[self.direction+1]
	love.graphics.print(marker, draw_x + 2, draw_y + 2)

	if self.sonar_bleep then
		love.graphics.print("b", draw_x + 14, draw_y + 10)
	end
	love.graphics.setColor(Constants.Colors.Default)
end

function SubmarineClass:ordersGiven()
	if self.action_1 == SubmarineClass.Actions.Move_5
	or self.action_1 == SubmarineClass.Actions.Move_6 then
		return true
	end
	return self.action_1 ~= nil and self.action_2 ~= nil
end

function SubmarineClass:resetOrders()
	self.action_1 = nil
	self.action_2 = nil
end

function SubmarineClass:directionAfterAction(a)
	if a ~= nil and a >= SubmarineClass.Actions.Turn_N and a <= SubmarineClass.Actions.Turn_NW then
		return a - SubmarineClass.Actions.Turn_N
	end
	return self.direction
end

function SubmarineClass:positionAfterAction(a)
	if a ~= nil and a >= SubmarineClass.Actions.Move_1 and a <= SubmarineClass.Actions.Move_6 then
		local length = a + 1
		local dx, dy = deltaCellsForDirection(self.direction)
		return self.x + length * dx, self.y + length * dy
	end
	return self.x, self.y
end

function SubmarineClass:resolveAction(action, torpedoes)
	self.x, self.y = self:positionAfterAction(action)
	self.direction = self:directionAfterAction(action)

	-- TODO : spawn torpedo

	if isNonStealthyAction(action) then
		self.sonar_bleep = true
	end
end

return SubmarineClass

