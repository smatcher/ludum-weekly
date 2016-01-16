local Class = require "love-toys.third-party.hump.class"

local SubmarineClass = require "submarine"

local OrdersMenuClass = Class {}

local OrderButton = Class {
	init = function(self, code, label, info, width)
		self.code = code
		self.label = label
		self.hovered = false
		self.enabled = true
		self.width = width
		self.info = info
	end,

	setPosition = function(self, x, y)
		self.x = x
		self.y = y
	end,

	draw = function(self)
		local x = self.x
		local y = self.y
		if self.enabled then
			if self.hovered then
				love.graphics.setColor({64, 128, 255, 192})
				love.graphics.rectangle("fill", x-2, y-2, self.width, Constants.OrdersMenu.LineHeight)
				love.graphics.setColor(Constants.Colors.TextHovered)
			else
				love.graphics.setColor(Constants.Colors.TextNormal)
			end
		else
			love.graphics.setColor(Constants.Colors.TextDisabled)
		end
		love.graphics.print(self.label, x, y)
		love.graphics.rectangle("line", x-2, y-2, self.width, Constants.OrdersMenu.LineHeight)
	end,

	hit = function(self, x, y)
		if x < self.x
		or x > self.x + self.width
		or y < self.y
		or y > self.y + Constants.OrdersMenu.LineHeight then
			return false
		end
		return true
	end,
}

function OrdersMenuClass:init()
	self.visible = false
	self.selected_sub = nil
	self.info_text = ""

	self.move_orders = {
		OrderButton(Move_1, "Move 1", "Move forward 1 cell", 60),
		OrderButton(Move_2, "Move 2", "Move forward 2 cells", 60),
		OrderButton(Move_3, "Move 3", "Move forward 3 cells *NON STEALTHY*", 60),
		OrderButton(Move_4, "Move 4", "Move forward 4 cells *NON STEALTHY*", 60),
		OrderButton(Move_5, "Move 5", "Move forward 5 cells *NON STEALTHY* *TAKES 2 ACTIONS*", 60),
		OrderButton(Move_6, "Move 6", "Move forward 6 cells *NON STEALTHY* *TAKES 2 ACTIONS*", 60),
	}

	self.turn_orders = {
		OrderButton(Turn_NW, "NW", "Turn the submarine to face north-west", 30),
		OrderButton(Turn_N , "N" , "Turn the submarine to face north", 30),
		OrderButton(Turn_NE, "NE", "Turn the submarine to face north-east", 30),
		OrderButton(Turn_W , "W" , "Turn the submarine to face west", 30),
		nil,
		OrderButton(Turn_E , "E" , "Turn the submarine to face east", 30),
		OrderButton(Turn_SW, "SW", "Turn the submarine to face south-west", 30),
		OrderButton(Turn_S , "S" , "Turn the submarine to face south", 30),
		OrderButton(Turn_SE, "SE", "Turn the submarine to face south-east", 30),
	}

	self.interact_orders = {
		OrderButton(Fire,    "Fire"   , "Fire a torpedo *NON STEALTHY*", 60),
		OrderButton(Special, "Special", "NOT IMPLEMENTED", 60),
		OrderButton(Grab,    "Grab"   , "Grab the bomb", 60),
	}

	self.other_orders = {
		OrderButton(Wait, "Wait", "Do nothing", 60),
	}

	self:computeOrdersPositions()
end

function OrdersMenuClass:computeOrdersPositions()
	local column_padding = 10
	local header_height = 30

	local header_y = Constants.OrdersMenu.DrawY + Constants.OrdersMenu.TextOffsetY
	local start_x = Constants.OrdersMenu.DrawX + Constants.OrdersMenu.TextOffsetX
	local start_y = header_y + header_height

	for k,v in pairs(self.move_orders) do
		local x = start_x + ((k-1)%2) * v.width
		local y = start_y + math.floor((k-1)/2) * Constants.OrdersMenu.LineHeight
		v:setPosition(x, y)
	end

	start_x = start_x + 2*self.move_orders[1].width + column_padding
	for k,v in pairs(self.turn_orders) do
		local x = start_x + ((k-1)%3) * v.width
		local y = start_y + math.floor((k-1)/3) * Constants.OrdersMenu.LineHeight
		v:setPosition(x, y)
	end

	start_x = start_x + 3*self.turn_orders[1].width + column_padding
	for k,v in pairs(self.interact_orders) do
		v:setPosition(start_x, start_y + (k-1) * Constants.OrdersMenu.LineHeight)
	end

	start_x = start_x + self.interact_orders[1].width + column_padding
	for k,v in pairs(self.other_orders) do
		v:setPosition(start_x, start_y + (k-1) * Constants.OrdersMenu.LineHeight)
	end
end

function OrdersMenuClass:draw()
	if self.visible == false then
		return
	end

	love.graphics.setColor(Constants.Colors.OrdersMenuBackground)
	love.graphics.rectangle("fill",
		Constants.OrdersMenu.DrawX,
		Constants.OrdersMenu.DrawY,
		Constants.OrdersMenu.DrawWidth,
		Constants.OrdersMenu.DrawHeight,
		Constants.OrdersMenu.DrawRadius
	)

	local column_padding = 10
	local header_height = 20

	love.graphics.setColor(Constants.Colors.TextInfo)
	love.graphics.print(self.info_text,
		Constants.OrdersMenu.DrawX + Constants.OrdersMenu.TextOffsetX,
		Constants.OrdersMenu.DrawY + Constants.OrdersMenu.TextOffsetY + 5*Constants.OrdersMenu.LineHeight
	)

	local header_y = Constants.OrdersMenu.DrawY + Constants.OrdersMenu.TextOffsetY
	local start_x = Constants.OrdersMenu.DrawX + Constants.OrdersMenu.TextOffsetX
	local start_y = header_y + header_height
	love.graphics.setColor(Constants.Colors.TextInfo)
	love.graphics.print("Move:", start_x, header_y)
	for k,v in pairs(self.move_orders) do
		v:draw()
	end

	start_x = start_x + 2*self.move_orders[1].width + column_padding
	love.graphics.setColor(Constants.Colors.TextInfo)
	love.graphics.print("Turn:", start_x, header_y)
	for k,v in pairs(self.turn_orders) do
		v:draw()
	end

	start_x = start_x + 3*self.turn_orders[1].width + column_padding
	love.graphics.setColor(Constants.Colors.TextInfo)
	love.graphics.print("Interact:", start_x, header_y)
	for k,v in pairs(self.interact_orders) do
		v:draw()
	end

	start_x = start_x + self.interact_orders[1].width + column_padding
	for k,v in pairs(self.other_orders) do
		v:draw()
	end

end

function OrdersMenuClass:updateAvailableOrders()
	for _,o in pairs(self.turn_orders) do
		o.enabled = true
	end
	self.interact_orders[2].enabled = false
	self.interact_orders[3].enabled = false

	local d = self.selected_sub.direction
	local ds = SubmarineClass.Directions
	if d == ds.North then
		self.turn_orders[2].enabled = false
	elseif d == ds.NorthEast then
		self.turn_orders[3].enabled = false
	elseif d == ds.East then
		self.turn_orders[6].enabled = false
	elseif d == ds.SouthEast then
		self.turn_orders[9].enabled = false
	elseif d == ds.South then
		self.turn_orders[8].enabled = false
	elseif d == ds.SouthWest then
		self.turn_orders[7].enabled = false
	elseif d == ds.West then
		self.turn_orders[4].enabled = false
	elseif d == ds.NorthWest then
		self.turn_orders[1].enabled = false
	end
end

function OrdersMenuClass:selectSub(sub)
	self:unselectSub()
	self.selected_sub = sub
	self.selected_sub.selected = true
	self.visible = true
	self:updateAvailableOrders()
end

function OrdersMenuClass:unselectSub()
	if self.selected_sub ~= nil then
		self.selected_sub.selected = false
	end
	self.selected_sub = nil
	self.visible = false
end

function OrdersMenuClass:mousemoved(x, y, dx, dy)
	self.info_text = ""
	local function updateHovered(t)
		for _,o in pairs(t) do
			o.hovered = o:hit(x,y)
			if o.hovered then
				self.info_text = o.info
			end
		end
	end
	updateHovered(self.move_orders)
	updateHovered(self.turn_orders)
	updateHovered(self.interact_orders)
	updateHovered(self.other_orders)
end

return OrdersMenuClass

