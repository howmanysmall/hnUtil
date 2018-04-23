--@render functions
local function ToUDim2(self, guiobject)
	if not guiobject.Parent or not guiobject.Parent:IsA("GuiBase2d") then
		return UDim2.new()
	end
	local parentsize = guiobject.Parent.AbsoluteSize
	local X, Y, XX, XY, YX, YY = parentsize.X, parentsize.Y, self.XX, self.XY, self.YX, self.YY
	return UDim2.new(0, XX.Offset + XY.Offset + XX.Scale * X + XY.Scale * Y, 0, YY.Offset + YX.Offset + YY.Scale * Y + YX.Scale * X)
end

local function Render(self)
	local object = self._object.Parent
	object.Position = ToUDim2(self._position, object)
	object.Size = ToUDim2(self._size, object)
end

local function AttachToParent(self)
	local parent = self._object.Parent
	if self._parentconnection then
		self._parentconnection:Disconnect()
	end
	if parent then
		self._parentconnection = parent.Changed:Connect(function(property)
			if property == "AbsoluteSize" or property == "AbsolutePosition" then
				Render(self)
			end
		end)
	end
	return self
end
--@main
local hnUtil = { }
local hnGuiUtil = { Render = Render }
local HttpService = game:GetService("HttpService")
function hnUtil.HexToVec(Hex, Decimal)
	Hex = Hex:gsub("#", "")
	if Decimal then
		return Vector3.new(tonumber("0x" .. Hex:sub(1, 2) / 255), tonumber("0x" .. Hex:sub(3, 4) / 255), tonumber("0x" .. Hex:sub(5, 6) / 255))
	elseif not Decimal then
		return Vector3.new(tonumber("0x" .. Hex:sub(1, 2)), tonumber("0x" .. Hex:sub(3, 4)), tonumber("0x" .. Hex:sub(5, 6)))
	elseif Decimal == nil then
		return Vector3.new(tonumber("0x" .. Hex:sub(1, 2)), tonumber("0x" .. Hex:sub(3, 4)), tonumber("0x" .. Hex:sub(5, 6)))
	end
end

function hnUtil.HexToColor3(Hex, Decimal)
	Hex = Hex:gsub("#", "")
	if Decimal then
		return Color3.new(tonumber("0x" .. Hex:sub(1, 2) / 255), tonumber("0x" .. Hex:sub(3, 4) / 255), tonumber("0x" .. Hex:sub(5, 6) / 255))
	elseif not Decimal then
		return Color3.new(tonumber("0x" .. Hex:sub(1, 2)), tonumber("0x" .. Hex:sub(3, 4)), tonumber("0x" .. Hex:sub(5, 6)))
	elseif Decimal == nil then
		return Color3.new(tonumber("0x" .. Hex:sub(1, 2)), tonumber("0x" .. Hex:sub(3, 4)), tonumber("0x" .. Hex:sub(5, 6)))
	end
end

function hnUtil.Color3ToHex(color3)
	local hecks = "0X"
	if not color3.r == math.floor(color3.r) or not color3.g == math.floor(color3.g) or not color3.b == math.floor(color3.b) then
		rgb = { color3.r * 255, color3.g * 255, color3.b * 255 }
	else
		rgb = { color3.r, color3.g, color3.b }
	end
	for k, v in pairs(rgb) do
		local hex = ""
		while v > 0 do
			local i = math.fmod(v, 16) + 1
			v = math.floor(v / 16)
			hex = ("0123456789ABCDEF"):sub(i, i) .. hex
		end
		if #hex == 0 then
			hex = "00"
		elseif #hex == 1 then
			hex = "0" .. hex
		end
		hecks = hecks .. hex
	end
	return hecks
end

function hnUtil.Vector3ToHex(vector3)
	local hecks = "0X"
	if not vector3.x == math.floor(vector3.x) or not vector3.y == math.floor(vector3.y) or not vector3.z == math.floor(vector3.z) then
		rgb = { vector3.x * 255, vector3.y * 255, vector3.z * 255 }
	else
		rgb = { vector3.x, vector3.y, vector3.z }
	end
	for k, v in pairs(rgb) do
		local hex = ""
		while v > 0 do
			local i = math.fmod(v, 16) + 1
			v = math.floor(v / 16)
			hex = ("0123456789ABCDEF"):sub(i, i) .. hex
		end
		if #hex == 0 then
			hex = "00"
		elseif #hex == 1 then
			hex = "0" .. hex
		end
		hecks = hecks .. hex
	end
	return hecks
end

function hnUtil.rrandom()
	local numbers = { }
	local min, max, newvalues, term
	for i = 1, 255 do
		if min == nil or max == nil then
			newvalues = math.random(-100, 100)
		elseif max == nil and min ~= nil then
			newvalues = math.random(min, 100)
		elseif min == nil and max ~= nil then
			newvalues = math.random(-100, max)
		else
			newvalues = math.random(min, max)
		end
		numbers[#numbers + 1] = newvalues
	end
	term = math.random(1, 255)
	return numbers[term]
end

function hnGuiUtil:__index(i)
	if i == "Size" then
		return self._size
	elseif i == "Position" then
		return self._position
	else
		return hnGuiUtil[i]
	end
end

function hnGuiUtil:__newindex(i, v)
	if i == "Size" then
		self._size = v
		Render(self)
	elseif i == "Position" then
		self._position = v
		Render(self)
	end
end

function hnGuiUtil:Destroy()
	self._objectconnection:Disconnect()
	if self._parentconnection then
		self._parentconnection:Disconnect()
	end
	self._object, self._size, self._position, self._objectconnection, self._parentconnection = nil
end

local UDim4 = { ToUDim2 = ToUDim2 }
UDim4.__index = UDim4

function UDim4.new(x, y, ...)
	if ... then
		return setmetatable({ X = UDim2.new(x, y, ...), Y = UDim2.new(select(3, ...)) }, UDim4)
	else
		return setmetatable({ X = x or UDim2.new(), Y = y or UDim2.new() }, UDim4)
	end
end

local defaultsize = UDim4.new(UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0))
local defaultposition = UDim4.new(UDim2.new(1, 0, -1, 0), UDim2.new(0, 0, 1, 0))

function UDim4.MakeEnforcer(guiobject, position, size)
	self = {
		_object = guiobject,
		_size = size or defaultsize,
		_position = position or defaultposition,
		_parentconnection = false
	}
	self._objectconnection = guiobject.Changed:Connect(function(property)
		if property == "AbsoluteSize" or property == "AbsolutePosition" then
			Render(self)
		elseif property == "Parent" then
			AttachToParent(self)
		end
	end)
	return setmetatable(AttachToParent(self), hnGuiUtil)
end

return hnUtil, UDim4
