Constants = {
	Game = {
		SubCountPerTeam = 4,
		RespawnCooldown = 3,
		TorpedoSpeed = 6,
	},

	Bomb = {
		StartX = 12,
		StartY = 8,
	},

	Grid = {
		-- Number of cells
		Width = 25,
		Height = 17,
		TeamAreaDepth = 3,

		-- Pixel dimensions
		DrawWidth = 600,
		DrawHeight = 408,
		DrawX = 100,
		DrawY = 25,
		HorMarkerOffsetX = 6, -- Horizontal marker offset
		HorMarkerOffsetY = 14,
		VerMarkerOffsetX = 14, -- Vertical marker offset
		VerMarkerOffsetY = 6,
	},

	Tooltips = {
		DrawX = (800 - 32 - 4),
		DrawY = 4,
		DrawInfoX = 270,
		DrawInfoY = 0,
		DrawInfoWidth = 530,
		DrawInfoHeight = 600,
		TextOffsetX = 15,
		TextOffsetY = 5,
	},

	OrdersMenu = {
		DrawWidth = 650,
		DrawHeight = 125,
		DrawX = 75,
		DrawY = 450,
		DrawRadius = 2,
		TextOffsetX = 15,
		TextOffsetY = 5,
		ActionDescriptionOffsetX = 400,
		LineHeight = 20,
		ColumnWidth = 150,
	},

	Console = {
		DrawWidth = 650,
		DrawHeight = 125,
		DrawX = 75,
		DrawY = 450,
		DrawRadius = 2,
		TextOffsetX = 15,
		TextOffsetY = 5,
		LineHeight = 20,
		MaxLines = 6
	},

	Submit = {
		DrawWidth = 125,
		DrawHeight = 32,
		DrawX = 600,
		DrawY = 575 - 32, 
		DrawRadius = 2,
		TextOffsetX = 22,
		TextOffsetY = 8,
	},

	Colors = {
		Background = {105, 140, 160, 255},
		ConsoleBackground = {27, 33, 37, 255},
		OrdersMenuBackground = {27, 33, 37, 255},
		TooltipBackground = {10, 10, 10, 240},
		Submit = {46, 75, 67, 255},
		SubmitHovered = {59, 145, 83, 255},
		TeamRedArea = {160, 105, 140, 255},
		TeamGreenArea = {140, 160, 107, 255},
		GridMarkings = {255, 255, 255, 255},
		TooltipDim = {192, 192, 192, 64},
		TooltipNew = {255, 190, 85, 255},
		TooltipHovered = {192, 192, 192, 128},
		TextAlert = {230, 130, 55, 255},
		TextInfo = {110, 160, 105, 255},
		TextNormal = {192, 192, 192, 255},
		TextHovered = {255, 255, 192, 255},
		TextHoveredAlert = {255, 128, 64, 255},
		TextDisabled = {92, 92, 92},
		Default = {255, 255, 255, 255},
	},
	
}

