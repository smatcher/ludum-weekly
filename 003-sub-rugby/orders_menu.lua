local Class = require "love-toys.third-party.hump.class"

local SubmarineClass = require "submarine"

local OrdersMenuClass = Class {}

local OrderButton = Class {
	init = function(self, code, label)
		self.code = code
		self.label = label
		self.hovered = false
	end,

	draw = function(self, x, y)
		love.graphics.setColor(Constants.Colors.TextInfo)
		love.graphics.print(self.label, x, y)
	end,
}

function OrdersMenuClass:init()
	self.visible = false
	self.selected_sub = nil

	self.move_orders = {
		OrderButton(Move_1, "Move 1"),
		OrderButton(Move_2, "Move 2"),
		OrderButton(Move_3, "Move 3"),
		OrderButton(Move_4, "Move 4"),
		OrderButton(Move_5, "Move 5"),
		OrderButton(Move_6, "Move 6"),
	}

	self.turn_orders = {
		OrderButton(Turn_NW, "NW"),
		OrderButton(Turn_N, "N"),
		OrderButton(Turn_NE, "NE"),
		OrderButton(Turn_W, "W"),
		nil,
		OrderButton(Turn_E, "E"),
		OrderButton(Turn_SW, "SW"),
		OrderButton(Turn_S, "S"),
		OrderButton(Turn_SE, "SE"),
	}

	self.interact_orders = {
		OrderButton(Fire, "Fire"),
		OrderButton(Special, "Special"),
		OrderButton(Grab, "Grab"),
	}

	self.other_orders = {
		OrderButton(Wait, "Wait"),
	}
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

	local start_x = Constants.OrdersMenu.DrawX + Constants.OrdersMenu.TextOffsetX
	local start_y = Constants.OrdersMenu.DrawY + Constants.OrdersMenu.TextOffsetY
	for k,v in pairs(self.move_orders) do
		v:draw(start_x, start_y + (k-1) * Constants.OrdersMenu.LineHeight)
	end

	start_x = start_x + Constants.OrdersMenu.ColumnWidth
	for k,v in pairs(self.turn_orders) do
		v:draw(start_x, start_y + (k-1) * Constants.OrdersMenu.LineHeight)
	end

	start_x = start_x + Constants.OrdersMenu.ColumnWidth
	for k,v in pairs(self.interact_orders) do
		v:draw(start_x, start_y + (k-1) * Constants.OrdersMenu.LineHeight)
	end

	start_x = start_x + Constants.OrdersMenu.ColumnWidth
	for k,v in pairs(self.other_orders) do
		v:draw(start_x, start_y + (k-1) * Constants.OrdersMenu.LineHeight)
	end

end

function OrdersMenuClass:selectSub(sub)
	self:unselectSub()
	self.selected_sub = sub
	self.selected_sub.selected = true
	self.visible = true
end

function OrdersMenuClass:unselectSub()
	if self.selected_sub ~= nil then
		self.selected_sub.selected = false
	end
	self.selected_sub = nil
	self.visible = false
end

function OrdersMenuClass:mousemoved(x, y, dx, dy)
	-- TODO test hit order and HL them
end

return OrdersMenuClass

