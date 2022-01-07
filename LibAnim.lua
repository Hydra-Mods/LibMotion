--[[
	local LibAnim = LibStub:GetLibrary("LibAnim")
	
	if (not LibAnim) then return end
	
	LibAnim:CreateAnimation(object, type) --> Create an animation for the given object (frame/texture/fontstring)
		
		type:
			"Move"     - Move the position of the object
			"Fade"     - Animate the opacity of the object
			"Height"   - Animate the height of the object
			"Width"    - Animate the width of the object
			"Scale"    - Animate the scale of the object
			"Color"    - Animate a color change (border/backdrop/texture/statusbar/font)
			"Progress" - Animate the statusbar position (statusbar only)
			"Number"   - Animate number updates (fontstring only)
			"Sleep"    - Used to create pauses, no animation
			"Frames"   - WIP. animate textures akin to the minimap LFG eye
			
		returns:
			animation object
	
	LibAnim:CreateAnimationGroup(object) --> Create an animation group to control individual animations
--]]

local LibAnim = LibStub:NewLibrary("LibAnim", 1)

if (not LibAnim) then
	return
end

local pi = math.pi
local cos = math.cos
local sin = math.sin
local mod = math.fmod
local sqrt = math.sqrt
local ceil = math.ceil
local floor = math.floor
local tremove = table.remove
local rawget = rawget

local Updater = CreateFrame("StatusBar")
local Texture = Updater:CreateTexture()
local FontString = Updater:CreateFontString()
local Initialize = {}
local Update = {}
local Easing = {}
local Callbacks = {} -- OnPlay, OnPause, OnResume, OnStop, OnReset, OnFinished, OnLoop

local Index = {
	__index = function(t, k)
		if rawget(t, k) then
			return rawget(t, k)
		end
	end
}

local OnUpdate = function(self, elapsed)
	for i = 1, #self do
		if self[i] then
			self[i]:Update(elapsed, i)
		end
	end
	
	if (#self == 0) then
		self:SetScript("OnUpdate", nil)
	end
end

local TweenColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

local Set = {
	backdrop = Updater.SetBackdropColor,
	border = Updater.SetBackdropBorderColor,
	statusbar = Updater.SetStatusBarColor,
	text = FontString.SetTextColor,
	texture = Texture.SetTexture,
	vertex = Texture.SetVertexColor,
}

local Get = {
	backdrop = Updater.GetBackdropColor,
	border = Updater.GetBackdropBorderColor,
	statusbar = Updater.GetStatusBarColor,
	text = FontString.GetTextColor,
	texture = Texture.GetVertexColor,
	vertex = Texture.GetVertexColor,
}

local Prototype = {
	-- Default attributes
	Paused = false,
	Playing = false,
	Stopped = false,
	Looping = false,
	Duration = 0.3,
	Easing = "linear",
	
	Play = function(self) -- animation:Play() --> Play the animation
		if (not self.Paused) then
			if Initialize[self.Type] then
				Initialize[self.Type](self)
				self:Callback("OnPlay")
			end
		else
			self:StartUpdating()
			self:Callback("OnResume")
		end
		
		self.Playing = true
		self.Paused = false
		self.Stopped = false
	end,
	
	IsPlaying = function(self) -- animation:IsPlaying() --> Return playing state of the animation
		return self.Playing
	end,
	
	Pause = function(self) -- animation:Pause() --> Pause the animation
		for i = 1, #Updater do
			if (Updater[i] == self) then
				tremove(Updater, i)
				
				break
			end
		end
		
		self.Playing = false
		self.Paused = true
		self.Stopped = false
		self:Callback("OnPause")
	end,
	
	IsPaused = function(self) -- animation:IsPaused() --> Return paused state of the animation
		return self.Paused
	end,
	
	Stop = function(self, reset) -- animation:Stop(reset) --> Stop the animation. Optional argument resets the animation to its pre-played state
		for i = 1, #Updater do
			if (Updater[i] == self) then
				tremove(Updater, i)
				
				break
			end
		end
		
		self.Playing = false
		self.Paused = false
		self.Stopped = true
		self.Timer = 0
		
		if reset then
			self:Reset()
			self:Callback("OnReset")
		else
			self:Callback("OnStop")
		end
	end,
	
	IsStopped = function(self) -- animation:IsStopped() --> Return stopped state of the animation
		return self.Stopped
	end,
	
	SetEasing = function(self, easing) -- animation:SetEasing(easing) --> Set the easing of the animation
		easing = easing:lower()
		
		self.Easing = Easing[easing] and easing or "linear"
	end,
	
	GetEasing = function(self) -- animation:GetEasing() --> Get the easing of the animation
		return self.Easing
	end,
	
	SetDuration = function(self, duration) -- animation:SetDuration(seconds) --> Set the duration of the animation
		self.Duration = duration or 0
	end,
	
	GetDuration = function(self) -- animation:GetDuration() --> Get the duration of the animation in seconds
		return self.Duration
	end,
	
	GetProgressByTimer = function(self) -- animation:GetProgressByTimer() --> Get the progress of the animation in seconds
		return self.Timer
	end,
	
	SetOrder = function(self, order) -- animation:SetOrder(num) --> Set the play order of the animation, if it belongs to a group
		if (not self.Group) then
			return
		end
		
		self.Order = order or 1
		
		if (order > self.Group.MaxOrder) then
			self.Group.MaxOrder = order
		end
	end,
	
	GetOrder = function(self) -- animation:GetOrder() --> Get the play order of the animation
		return self.Order
	end,
	
	SetParent = function(self, parent) -- animation:SetParent(object) --> Set the object that the animation controls
		self.Parent = parent
	end,
	
	GetParent = function(self) -- animation:GetParent() --> Get the object that the animation controls
		return self.Parent
	end,
	
	SetGroup = function(self, group) -- animation:SetGroup(group) --> Add the animation to a group
		if (not group.Animations) then
			group.Animations = {}
		end
		
		self.Order = 1
		self.Group = group
		
		group.Animations[#group.Animations + 1] = self
		
		return self.Group
	end,
	
	GetGroup = function(self) -- animation:GetGroup() --> Get the animation group
		return self.Group
	end,
	
	Ungroup = function(self) -- animation:Ungroup() --> Remove the animation from its group
		if (not self.Group) then
			return
		end
		
		for i = 1, #self.Group.Animations do
			if (self.Group.Animations[i] == self) then
				tremove(self.Group, i)
			end
		end
	end,
	
	SetScript = function(self, handler, func) -- animation:SetScript(handler, func) --> Set a callback to be fired on an event
		handler = handler:lower()
		
		if Callbacks[handler] then
			Callbacks[handler][self] = func
		end
	end,
	
	GetScript = function(self, handler) -- animation:GetScript(handler) --> Get the callback to be fired on an event
		handler = handler:lower()
		
		if (Callbacks[handler] and Callbacks[handler][self]) then
			return Callbacks[handler][self]
		end
	end,
	
	Callback = function(self, handler) -- animation:Callback(handler) --> Fire a callback on an event
		handler = handler:lower()
		
		if (Callbacks[handler] and Callbacks[handler][self]) then
			Callbacks[handler][self](self)
		end
	end,
	
	StartUpdating = function(self) -- animation:StartUpdating() --> Start updating the animation. This is called by :Play()
		Updater[#Updater + 1] = self
		
		if (not Updater:GetScript("OnUpdate")) then
			Updater:SetScript("OnUpdate", OnUpdate)
		end
	end,
	
	Update = function(self, elapsed, index) -- animation:Update() --> The update function of the animation. Called while the animation is playing
		Update[self.Type](self, elapsed, index)
	end,
}

local AnimMethods = {
	move = {
		SetOffset = function(self, x, y) -- animation:SetOffset(x, y) --> Set the x and y offset of a movement animation
			self.XSetting = x or 0
			self.YSetting = y or 0
		end,
		
		GetOffset = function(self) -- animation:GetOffset() --> Get the x and y offset of a movement animation
			return self.XSetting, self.YSetting
		end,
		
		SetRounded = function(self, flag) -- animation:SetRounded() --> Set a movement animation to use a rounded path rather than linear
			self.IsRounded = flag
		end,
		
		GetRounded = function(self) -- animation:GetRounded() --> Get whether a movement animation will use a rounded path rather than linear
			return self.IsRounded
		end,
		
		GetProgress = function(self) -- animation:GetProgress() --> Get the progress of the animation position
			return self.XOffset, self.YOffset
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
			self.Parent:ClearAllPoints()
			self.Parent:SetPoint(self.A1, self.P, self.A2, self.StartX, self.StartY)
			
			if self.IsRounded then
				self.ModTimer = 0
			end
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
			
			if self.IsRounded then
				self.ModTimer = 0
			end
			
			self.Parent:ClearAllPoints()
			self.Parent:SetPoint(self.A1, self.P, self.A2, self.EndX, self.EndY)
		end,
	},
	
	fade = {
		SetChange = function(self, alpha) -- animation:SetChange(alpha) --> Set the alpha change of a fade animation
			self.EndAlphaSetting = alpha or 0
		end,
		
		GetChange = function(self) -- animation:GetChange() --> Get the alpha change of a fade animation
			return self.EndAlphaSetting
		end,
		
		GetProgress = function(self) -- animation:GetProgress() --> Get the alpha progress of a fade animation
			return self.CurrentValue
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
			self.Parent:SetAlpha(self.StartAlpha)
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
			self.Parent:SetAlpha(self.EndAlpha)
		end,
	},
	
	height = {
		SetChange = function(self, height) -- animation:SetChange(height) --> Set the change of a height animation
			self.EndHeightSetting = height or 0
		end,
		
		GetChange = function(self) -- animation:GetChange() --> Get the change of a height animation
			return self.EndHeightSetting
		end,
		
		GetProgress = function(self) -- animation:GetProgress() --> Get the progress of a height animation
			return self.CurrentValue
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
			self.Parent:SetHeight(self.StartHeight)
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
			self.Parent:SetHeight(self.EndHeight)
		end,
	},
	
	width = {
		SetChange = function(self, width) -- animation:SetChange(width) --> Set the change of a width animation
			self.EndWidthSetting = width or 0
		end,
		
		GetChange = function(self) -- animation:GetChange() --> Get the change of a width animation
			return self.EndWidthSetting
		end,
		
		GetProgress = function(self) -- animation:GetProgress() --> Get the progress of a width animation
			return self.CurrentValue
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
			self.Parent:SetWidth(self.StartWidth)
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
			self.Parent:SetWidth(self.EndWidth)
		end,
	},
	
	color = {
		SetChange = function(self, r, g, b) -- animation:SetChange(r, g, b) --> Set the rgb change of a color animation
			self.EndRSetting = r or 1
			self.EndGSetting = g or 1
			self.EndBSetting = b or 1
		end,
		
		GetChange = function(self) -- animation:GetChange() --> Get the rgb change of a color animation
			return self.EndRSetting, self.EndGSetting, self.EndBSetting
		end,
		
		SetColorType = function(self, region) -- animation:SetColorType() --> Define what a color animation will colorize
			region = region:lower()
			
			self.ColorType = Set[region] and region or "border"
		end,
		
		GetColorType = function(self) -- animation:GetColorType() --> Get what a color animation will colorize
			return self.ColorType
		end,
		
		GetProgress = function(self) -- animation:GetProgress() --> Get the progress of a color animation
			return self.CurrentValue
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
			Set[self.ColorType](self.Parent, self.StartR, self.StartG, self.StartB)
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
			Set[self.ColorType](self.Parent, self.EndR, self.EndG, self.EndB)
		end,
	},
	
	progress = {
		SetChange = function(self, value) -- animation:SetChange(seconds) --> Set the change of a progress animation
			self.EndValueSetting = value or 0
		end,
		
		GetChange = function(self) -- animation:GetChange() --> Get the change of a progress animation
			return self.EndValueSetting
		end,
		
		GetProgress = function(self) -- animation:GetProgress() --> Get the progress of a progress animation
			return self.CurrentValue
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
			self.Parent:SetValue(self.StartValue)
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
			self.Parent:SetValue(self.EndValue)
		end,
	},
	
	number = {
		SetChange = function(self, value) -- animation:SetChange(num) --> Set the change of a number animation
			self.EndNumberSetting = value or 0
		end,
		
		GetChange = function(self) -- animation:GetChange() --> Get the change of a number animation
			return self.EndNumberSetting
		end,
		
		SetStart = function(self, value) -- animation:SetStart(num) --> Set the start value of a number animation
			self.StartNumber = value
		end,
		
		GetStart = function(self) -- animation:GetStart() --> Set the start value of a number animation
			return self.StartNumber
		end,
		
		SetPrefix = function(self, text) -- animation:SetPrefix(text) --> Set the prefix text of a number animation
			self.Prefix = text or ""
		end,
		
		GetPrefix = function(self) -- animation:GetPrefix() --> Get the prefix text of a number animation
			return self.Prefix
		end,
		
		SetPostfix = function(self, text) -- animation:SetPostfix() --> Set the postfix text of a number animation
			self.Postfix = text or ""
		end,
		
		GetPostfix = function(self) -- animation:GetPostfix() --> Get the postfix text of a number animation
			return self.Postfix
		end,
		
		GetProgress = function(self) -- animation:GetProgress() --> Get the progress of a number animation
			return self.CurrentValue
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
			self.Parent:SetText(self.StartNumber)
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
			self.Parent:SetText(self.EndNumber)
		end,
	},
	
	sleep = {
		GetProgress = function(self) -- animation:GetProgress() --> Get the progress of a sleep animation
			return self.Timer
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
		end,
	},
	
	scale = {
		SetChange = function(self, scale) -- animation:SetChange(scale) --> Set the change of a scale animation
			self.EndScaleSetting = scale or 0
		end,
		
		GetChange = function(self) -- animation:GetChange() --> Get the change of a scale animation
			return self.EndScaleSetting
		end,
		
		GetProgress = function(self) -- animation:GetProgress() --> Get the progress of a scale animation
			return self.CurrentValue
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
			self.Parent:SetScale(self.EndScale)
		end,
	},
	
	frames = {
		SetTextureSize = function(self, width, height)
			self.TextureWidthSetting = width or 0
			self.TextureHeightSetting = height or width or 0
		end,
		
		GetTextureSize = function(self)
			return self.TextureWidthSetting, self.TextureHeightSetting
		end,
	
		SetFrameSize = function(self, size)
			self.FrameSizeSetting = size or 0
		end,
		
		GetFrameSize = function(self)
			return self.FrameSizeSetting
		end,
		
		SetNumFrames = function(self, frames)
			self.NumFramesSetting = frames or 0
		end,
		
		GetNumFrames = function(self)
			return self.NumFramesSetting
		end,
		
		SetFrameDelay = function(self, delay)
			self.DelaySetting = delay or 0
		end,
		
		GetFrameDelay = function(self)
			return self.DelaySetting
		end,
		
		GetProgress = function(self)
			return self.Frame
		end,
		
		Reset = function(self) -- animation:Reset() --> Reset the animation to its pre-played state
			self.Timer = 0
		end,
		
		Finish = function(self) -- animation:Finish() --> Set the animation to its finished state
			self:Stop()
		end,
	},
}

local GroupMethods = {
	Playing = false,
	Paused = false,
	Stopped = false,
	Order = 1,
	MaxOrder = 1,
	Animations = {},
	
	Play = function(self)
		for i = 1, #self.Animations do
			if (self.Animations[i].Order == self.Order) then
				self.Animations[i]:Play()
			end
		end
		
		self.Playing = true
		self.Paused = false
		self.Stopped = false
		
		self:Callback("OnPlay")
	end,
	
	IsPlaying = function(self)
		return self.Playing
	end,
	
	Pause = function(self)
		for i = 1, #self.Animations do
			if (self.Animations[i].Order == self.Order) then
				self.Animations[i]:Pause()
			end
		end
		
		self.Playing = false
		self.Paused = true
		self.Stopped = false
		
		self:Callback("OnPause")
	end,
	
	IsPaused = function(self)
		return self.Paused
	end,
	
	Stop = function(self)
		for i = 1, #self.Animations do
			self.Animations[i]:Stop()
		end
		
		self.Playing = false
		self.Paused = false
		self.Stopped = true
		self.Order = 1
		
		self:Callback("OnStop")
	end,
	
	IsStopped = function(self)
		return self.Stopped
	end,
	
	SetLooping = function(self, shouldLoop)
		self.Looping = shouldLoop
	end,
	
	GetLooping = function(self)
		return self.Looping
	end,
	
	SetParent = function(self, parent)
		self.Parent = parent
	end,
	
	GetParent = function(self)
		return self.Parent
	end,
	
	SetScript = function(self, handler, func)
		handler = handler:lower()
		
		if (not Callbacks[handler]) then
			Callbacks[handler] = {}
		end
		
		Callbacks[handler][self] = func
	end,
	
	GetScript = function(self, handler)
		handler = handler:lower()
		
		if (Callbacks[handler] and Callbacks[handler][self]) then
			return Callbacks[handler][self]
		end
	end,
	
	Callback = function(self, handler)
		handler = handler:lower()
		
		if (Callbacks[handler] and Callbacks[handler][self]) then
			Callbacks[handler][self](self)
		end
	end,
	
	CheckOrder = function(self)
		if (not self.Animations) then
			return
		end
	
		-- Check if we're done all animations at the current order, then proceed to the next order.
		local NumAtOrder = 0
		local NumDoneAtOrder = 0
		
		for i = 1, #self.Animations do
			if (self.Animations[i].Order == self.Order) then
				NumAtOrder = NumAtOrder + 1
				
				if (not self.Animations[i].Playing) then
					NumDoneAtOrder = NumDoneAtOrder + 1
				end
			end
		end
		
		-- All the animations at x order finished, go to next order
		if (NumAtOrder == NumDoneAtOrder) then
			self.Order = self.Order + 1
			
			-- We exceeded max order, reset to 1 and bail the function, or restart if we're looping
			if (self.Order > self.MaxOrder) then
				self.Order = 1
				
				self:Callback("OnFinished")
				
				if (self.Stopped or not self.Looping) then
					self.Playing = false
					
					return
				end
			end
			
			self:Callback("OnLoop")
			
			-- Play!
			for i = 1, #self.Animations do
				if (self.Animations[i].Order == self.Order) then
					self.Animations[i]:Play()
				end
			end
		end
	end,
	
	--[[
		These need reworking. I want animations to be independant objects now, that can be grouped if desired and run off the group rather than individually.
		Previously groups were needed to run animations. I've gotten rid of that, but now I need to make sure that my existing functions accomodate this change.
	--]]
	
	StartUpdating = function(self)
		Updater[#Updater + 1] = self
		
		if (not Updater:GetScript("OnUpdate")) then
			Updater:SetScript("OnUpdate", OnUpdate)
		end
	end,
	
	Update = function(self, elapsed, index)
		for i = 1, #self.Animations do
			self.Animations[i]:Update(elapsed, index)
		end
	end,
}

-- Library functions

function LibAnim:CreateAnimationGroup(parent) -- LibAnim:CreateAnimationGroup(object) --> Create an animation group to control individual animations
	local Group = setmetatable(GroupMethods, Index)
	
	Group.Parent = parent
	
	return Group
end

function LibAnim:CreateAnimation(parent, animtype) -- LibAnim:CreateAnimation(object, type) --> Create an animation
	if (not AnimMethods[animtype:lower()]) then
		return
	end
	
	local Animation = setmetatable(Prototype, {__index = setmetatable(AnimMethods[animtype:lower()], Index)})
	
	Animation.Type = animtype:lower()
	Animation.Parent = parent
	
	return Animation
end

-- Easing types

-- Linear easing
Easing.linear = function(t, b, c, d)
	return c * t / d + b
end

-- Quadratic easing
Easing.inquadratic = function(t, b, c, d)
	t = t / d
	
	return c * (t ^ 2) + b
end

Easing.outquadratic = function(t, b, c, d)
	t = t / d
	
	return -c * t * (t - 2) + b
end

Easing.inoutquadratic = function(t, b, c, d)
	t = t / d * 2
	
	if (t < 1) then
		return c / 2 * (t ^ 2) + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

-- Cubic easing
Easing.incubic = function(t, b, c, d)
	t = t / d
	
	return c * (t ^ 3) + b
end

Easing.outcubic = function(t, b, c, d)
	t = t / d - 1
	
	return c * (t ^ 3 + 1) + b
end

Easing.inoutcubic = function(t, b, c, d)
	t = t / d * 2
	
	if (t < 1) then
		return c / 2 * (t ^ 3) + b
	else
		t = t - 2
		
		return c / 2 * (t ^ 3 + 2) + b
	end
end

-- Quartic easing
Easing.inquartic = function(t, b, c, d)
	t = t / d
	
	return c * (t ^ 4) + b
end

Easing.outquartic = function(t, b, c, d)
	t = t / d - 1
	
	return -c * (t ^ 4 - 1) + b
end

Easing.inoutquartic = function(t, b, c, d)
	t = t / d * 2
	
	if (t < 1) then
		return c / 2 * t ^ 4 + b
	else
		t = t - 2
		
		return -c / 2 * (t ^ 4 - 2) + b
	end
end

-- Quintic easing
Easing.inquintic = function(t, b, c, d)
	t = t / d
	
	return c * (t ^ 5) + b
end

Easing.outquintic = function(t, b, c, d)
	t = t / d - 1
	
	return c * (t ^ 5 + 1) + b
end

Easing.inoutquintic = function(t, b, c, d)
	t = t / d * 2
	
	if (t < 1) then
		return c / 2 * t ^ 5 + b
	else
		t = t - 2
		
		return c / 2 * (t ^ 5 + 2) + b
	end
end

-- Sinusoidal easing
Easing.insinusoidal = function(t, b, c, d)
	return -c * cos(t / d * (pi / 2)) + c + b
end

Easing.outsinusoidal = function(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

Easing.inoutsinusoidal = function(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

-- Exponential easing
Easing.inexponential = function(t, b, c, d)
	if (t == 0) then
		return b
	else
		return c * (2 ^ (10 * (t / d - 1))) + b - c * 0.001
	end
end

Easing.outexponential = function(t, b, c, d)
	if (t == d) then
		return b + c
	else
		return c * 1.001 * (-(2 ^ (-10 * t / d)) + 1) + b
	end
end

Easing.inoutexponential = function(t, b, c, d)
	if (t == 0) then
		return b
	end
	
	if (t == d) then
		return b + c
	end
	
	t = t / d * 2
	
	if (t < 1) then
		return c / 2 * (2 ^ (10 * (t - 1))) + b - c * 0.0005
	else
		t = t - 1
		
		return c / 2 * 1.0005 * (-(2 ^ (-10 * t)) + 2) + b
	end
end

-- Circular easing
Easing.incircular = function(t, b, c, d)
	t = t / d
	
	return (-c * (sqrt(1 - t * t) - 1) + b)
end

Easing.outcircular = function(t, b, c, d)
	t = t / d - 1
	
	return (c * sqrt(1 - t * t) + b)
end

Easing.inoutcircular = function(t, b, c, d)
	t = t / d * 2
	
	if (t < 1) then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	else
		t = t - 2
		
		return c / 2 * (sqrt(1 - t * t) + 1) + b
	end
end

-- Bounce easing
Easing.outbounce = function(t, b, c, d)
	t = t / d
	
	if (t < (1 / 2.75)) then
		return c * (7.5625 * t * t) + b
	elseif (t < (2 / 2.75)) then
		t = t - (1.5 / 2.75)
		
		return c * (7.5625 * t * t + 0.75) + b
	elseif (t < (2.5 / 2.75)) then
		t = t - (2.25 / 2.75)
		
		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)
		
		return c * (7.5625 * t * t + 0.984375) + b
	end
end

Easing.inbounce = function(t, b, c, d)
	return c - Easing.outbounce(d - t, 0, c, d) + b
end

Easing.inoutbounce = function(t, b, c, d)
	if (t < d / 2) then
		return Easing.inbounce(t * 2, 0, c, d) * 0.5 + b
	else
		return Easing.outbounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
	end
end

-- Elastic easing
Easing.inelastic = function(t, b, c, d)
	if (t == 0) then
		return b
	end
	
	t = t / d
	
	if (t == 1) then
		return b + c
	end
	
	local a = c
	local p = d * 0.3
	local s = p / 4
	
	t = t - 1
	
	return -(a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

Easing.outelastic = function(t, b, c, d)
	if (t == 0) then
		return b
	end
	
	t = t / d
	
	if (t == 1) then
		return b + c
	end
	
	local a = c
	local p = d * 0.3
	local s = p / 4
	
	return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

Easing.inoutelastic = function(t, b, c, d)
	if (t == 0) then
		return b
	end
	
	t = t / d * 2
	
	if (t == 2) then
		return b + c
	end
	
	local a = c
	local p = d * (0.3 * 1.5)
	local s = p / 4
	
	if (t < 1) then
		t = t - 1
		
		return -0.5 * (a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	else
		t = t - 1
		
		return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
	end
end

-- Simple options
Easing['in'] = Easing.inquadratic
Easing.out = Easing.outquadratic
Easing.inout = Easing.inoutquadratic

-- Animation types

-- Movement
Initialize.move = function(self)
	if self.Playing then
		return
	end
	
	local A1, P, A2, X, Y = self.Parent:GetPoint()
	
	self.Timer = 0
	self.A1 = A1
	self.P = P
	self.A2 = A2
	self.StartX = X
	self.EndX = X + self.XSetting or 0
	self.StartY = Y
	self.EndY = Y + self.YSetting or 0
	self.XChange = self.EndX - self.StartX
	self.YChange = self.EndY - self.StartY
	
	if self.IsRounded then
		if (self.XChange == 0 or self.YChange == 0) then -- check if we're valid to be rounded
			self.IsRounded = false
		else
			self.ModTimer = 0
		end
	end
	
	self:StartUpdating()
end

Update.move = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetPoint(self.A1, self.P, self.A2, self.EndX, self.EndY)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	else
		if self.IsRounded then
			self.ModTimer = Easing[self.Easing](self.Timer, 0, self.Duration, self.Duration)
			self.XOffset = self.StartX - (-1) * (self.XChange * (1 - cos(90 * self.ModTimer / self.Duration)))
			self.YOffset = self.StartY + self.YChange * sin(90 * self.ModTimer / self.Duration)
		else
			self.XOffset = Easing[self.Easing](self.Timer, self.StartX, self.XChange, self.Duration)
			self.YOffset = Easing[self.Easing](self.Timer, self.StartY, self.YChange, self.Duration)
		end
		
		self.Parent:SetPoint(self.A1, self.P, self.A2, (self.EndX ~= 0 and self.XOffset or self.StartX), (self.EndY ~= 0 and self.YOffset or self.StartY))
	end
end

-- Fade
Initialize.fade = function(self)
	if self.Playing then
		return
	end
	
	self.Timer = 0
	self.StartAlpha = self.Parent:GetAlpha() or 1
	self.EndAlpha = self.EndAlphaSetting or 0
	self.Change = self.EndAlpha - self.StartAlpha
	
	self:StartUpdating()
end

Update.fade = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetAlpha(self.EndAlpha)
		self.Playing = false
		self:Callback("OnFinished")
		
		if self.Group then
			self.Group:CheckOrder()
		end
	else
		self.CurrentValue = Easing[self.Easing](self.Timer, self.StartAlpha, self.Change, self.Duration)
		self.Parent:SetAlpha(self.CurrentValue)
	end
end

-- Height
Initialize.height = function(self)
	if self.Playing then
		return
	end
	
	self.Timer = 0
	self.StartHeight = self.Parent:GetHeight() or 0
	self.EndHeight = self.EndHeightSetting or 0
	self.HeightChange = self.EndHeight - self.StartHeight
	
	self:StartUpdating()
end

Update.height = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetHeight(self.EndHeight)
		self.Playing = false
		self:Callback("OnFinished")
		
		if self.Group then
			self.Group:CheckOrder()
		end
	else
		self.CurrentValue = Easing[self.Easing](self.Timer, self.StartHeight, self.HeightChange, self.Duration)
		self.Parent:SetHeight(self.CurrentValue)
	end
end

-- Width
Initialize.width = function(self)
	if self.Playing then
		return
	end
	
	self.Timer = 0
	self.StartWidth = self.Parent:GetWidth() or 0
	self.EndWidth = self.EndWidthSetting or 0
	self.WidthChange = self.EndWidth - self.StartWidth
	
	self:StartUpdating()
end

Update.width = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetWidth(self.EndWidth)
		self.Playing = false
		self:Callback("OnFinished")
		
		if self.Group then
			self.Group:CheckOrder()
		end
	else
		self.CurrentValue = Easing[self.Easing](self.Timer, self.StartWidth, self.WidthChange, self.Duration)
		self.Parent:SetWidth(self.CurrentValue)
	end
end

-- Color
Initialize.color = function(self)
	self.Timer = 0
	self.ColorType = self.ColorType or "backdrop"
	self.StartR, self.StartG, self.StartB = Get[self.ColorType](self.Parent)
	self.EndR = self.EndRSetting or 1
	self.EndG = self.EndGSetting or 1
	self.EndB = self.EndBSetting or 1
	
	self:StartUpdating()
end

Update.color = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		Set[self.ColorType](self.Parent, self.EndR, self.EndG, self.EndB)
		self.Playing = false
		self:Callback("OnFinished")
		
		if self.Group then
			self.Group:CheckOrder()
		end
	else
		self.CurrentValue = Easing[self.Easing](self.Timer, 0, self.Duration, self.Duration)
		Set[self.ColorType](self.Parent, TweenColor(self.Timer / self.Duration, self.StartR, self.StartG, self.StartB, self.EndR, self.EndG, self.EndB))
	end
end

-- Progress
Initialize.progress = function(self)
	self.Timer = 0
	self.StartValue = self.Parent:GetValue() or 0
	self.EndValue = self.EndValueSetting or 0
	self.ProgressChange = self.EndValue - self.StartValue
	
	self:StartUpdating()
end

Update.progress = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetValue(self.EndValue)
		self.Playing = false
		self:Callback("OnFinished")
		
		if self.Group then
			self.Group:CheckOrder()
		end
	else
		self.CurrentValue = Easing[self.Easing](self.Timer, self.StartValue, self.ProgressChange, self.Duration)
		self.Parent:SetValue(self.CurrentValue)
	end
end

-- Sleep
Initialize.sleep = function(self)
	self.Timer = 0
	
	self:StartUpdating()
end

Update.sleep = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Playing = false
		self:Callback("OnFinished")
		
		if self.Group then
			self.Group:CheckOrder()
		end
	end
end

-- Number
Initialize.number = function(self)
	self.Timer = 0
	
	if (not self.StartNumber) then
		self.StartNumber = tonumber(self.Parent:GetText()) or 0
	end
	
	self.EndNumber = self.EndNumberSetting or 0
	self.NumberChange = self.EndNumberSetting - self.StartNumber
	self.Prefix = self.Prefix or ""
	self.Postfix = self.Postfix or ""
	
	self:StartUpdating()
end

Update.number = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetText(self.Prefix..floor(self.EndNumber)..self.Postfix)
		self.Playing = false
		self:Callback("OnFinished")
		
		if self.Group then
			self.Group:CheckOrder()
		end
	else
		self.CurrentValue = Easing[self.Easing](self.Timer, self.StartNumber, self.NumberChange, self.Duration)
		self.Parent:SetText(self.Prefix..floor(self.CurrentValue)..self.Postfix)
	end
end

-- Scale
Initialize.scale = function(self)
	if self.Playing then
		return
	end
	
	self.Timer = 0
	self.StartScale = self.Parent:GetScale() or 1
	self.EndScale = self.EndScaleSetting or 1
	self.ScaleChange = self.EndScale - self.StartScale
	
	self:StartUpdating()
end

Update.scale = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetScale(self.EndScale)
		self.Playing = false
		self:Callback("OnFinished")
		
		if self.Group then
			self.Group:CheckOrder()
		end
	else
		self.CurrentValue = Easing[self.Easing](self.Timer, self.StartScale, self.ScaleChange, self.Duration)
		self.Parent:SetScale(self.CurrentValue)
	end
end

-- Frames
Initialize.frames = function(self)
	if self.Playing then
		return
	end
	
	self.Timer = 0
	self.Frame = 1
	self.Delay = self.DelaySetting or 0
	self.Throttle = self.Delay
	self.NumFrames = self.NumFramesSetting or 0
	self.TextureWidth = self.TextureWidthSetting or self.Parent:GetWidth()
	self.TextureHeight = self.TextureHeightSetting or self.Parent:GetHeight()
	self.FrameSize = self.FrameSizeSetting or 0
	self.NumColumns = floor(self.TextureWidth / self.FrameSize)
	self.ColumnWidth = self.FrameSize / self.TextureWidth
	self.NumRows = floor(self.TextureHeight / self.FrameSize)
	self.RowHeight = self.FrameSize / self.TextureHeight
	
	self:StartUpdating()
end

Update.frames = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	
	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Playing = false
		self:Callback("OnFinished")
		
		if self.Group then
			self.Group:CheckOrder()
		end
	else
		if (self.Throttle > self.Delay) then
			local Advance = floor(self.Throttle / self.Delay)
			
			while (self.Frame + Advance > self.NumFrames) do
				self.Frame = self.Frame - self.NumFrames
			end
			
			self.Frame = self.Frame + Advance
			
			local Left = mod(self.Frame - 1, self.NumColumns) * self.ColumnWidth
			local Bottom = ceil(self.Frame / self.NumColumns) * self.RowHeight
			
			self.Parent:SetTexCoord(Left, Left + self.ColumnWidth, Bottom - self.RowHeight, Bottom)
			self.Throttle = 0
		end
		
		self.Throttle = self.Throttle + elapsed
	end
end