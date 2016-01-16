local Class = require "love-toys.third-party.hump.class"
local Timer = require "love-toys.third-party.hump.timer"

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

	bleep_alpha = 255,
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

	local draw_x, draw_y = grid:cellCoord(self.x, self.y)

	-- Sonar bleep
	if self.sonar_bleep then
		love.graphics.setColor(255,0,0,SubmarineClass.bleep_alpha)
		love.graphics.draw(
			SubmarineClass.Bleep,
			draw_x,
			draw_y
		)
	end

--	if self.team ~= SubmarineClass.Teams.Player then
--		return
--	end

	local before_draw_x, before_draw_y = draw_x, draw_y
	local x_after, y_after, direction_after = self:positionAndDirectionAfterTurn()
	local draw_x, draw_y = grid:cellCoord(x_after, y_after)

	-- Actual submarine drawing
	local sub_alpha = 255

	if draw_action_markers and not self:ordersGiven() then
		sub_alpha = (SubmarineClass.bleep_alpha / 2) + 128 -- not a full bleep
	end

	if self.team == SubmarineClass.Teams.Player then
		love.graphics.setColor(0, 128, 0, sub_alpha)
	else
		love.graphics.setColor(128, 0, 0, sub_alpha) -- TODO : skip displaying Remote Subs
	end
	love.graphics.draw(
		SubmarineClass.Sub,
		draw_x + 12,
		draw_y + 12,
		math.pi*(direction_after - 2)/4.0,
		1, 1, 12, 12
	)

	if x_after ~= self.x or y_after ~= self.y then
		love.graphics.setColor(0, 128, 0, 128)
		love.graphics.draw(
			SubmarineClass.Sub,
			before_draw_x + 12,
			before_draw_y + 12,
			math.pi*(self.direction - 2)/4.0,
			1, 1, 12, 12
		)
		love.graphics.setColor(128, 255, 128, 255)
		love.graphics.line(before_draw_x + 12, before_draw_y+ 12, draw_x + 12, draw_y + 12)
	end

	-- Action taken markers
	if draw_action_markers then
		love.graphics.setColor({0,0,0,192})
		love.graphics.rectangle("fill", draw_x + 11, draw_y + 17, 12, 6)
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

--	love.graphics.setColor(0,0,0,255)
--	local markers = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
--	local marker = markers[self.direction+1]
--	love.graphics.print(marker, draw_x + 2, draw_y + 2)
--
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

local function modDirection(a, start_direction)
		if a ~= nil and a >= SubmarineClass.Actions.Turn_N and a <= SubmarineClass.Actions.Turn_NW then
		return a - SubmarineClass.Actions.Turn_N
	end
	return start_direction
end

local function modPosition(a, x, y, direction)
	if a ~= nil and a >= SubmarineClass.Actions.Move_1 and a <= SubmarineClass.Actions.Move_6 then
		local length = a + 1
		local dx, dy = deltaCellsForDirection(direction)
		return x + length * dx, y + length * dy
	end
	return x, y
end

function SubmarineClass:positionAndDirectionAfterTurn()
	local x,y,direction = self.x, self.y, self.direction
	x, y = modPosition(self.action_1, x, y, direction)
	direction = modDirection(self.action_1, direction)
	x, y = modPosition(self.action_2, x, y, direction)
	direction = modDirection(self.action_2, direction)
	return x, y, direction
end

function SubmarineClass:resolveAction(action, torpedoes)
	self.x, self.y = modPosition(action, self.x, self.y, self.direction)
	self.direction = modDirection(action, self.direction)

	-- TODO : spawn torpedo

	if isNonStealthyAction(action) then
		self.sonar_bleep = true
	end
end

function SubmarineClass.loadAssets()
	SubmarineClass.Sub = love.graphics.newImage("sub.png")
	SubmarineClass.Bleep = love.graphics.newImage("bleep.png")

	local easeIn, easeOut
	easeIn = function()
		Timer.tween(0.5, SubmarineClass, {bleep_alpha = 255}, 'in-out-quad', easeOut)
	end
	easeOut = function()
		Timer.tween(0.5, SubmarineClass, {bleep_alpha = 0}, 'in-out-quad', easeIn)
	end
	easeOut()
end

return SubmarineClass

