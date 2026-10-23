-- drum-skin: a curved wedge torn from an old round drumhead; the hoop edge is a rolled, laced hem
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local CX, CY, R = 50, 12, 42                               -- the old drumhead: centre off to the upper right
local parch = GV.ramp("#e2c48c", { shade = "#c4945c", deep = "#8a5a34", bounce = "#cfa064" })

-- torn across the middle of the head (ragged diagonal), and ragged at both ends
local torn = c:poly({ { 0, 0 }, { 16, 3 }, { 19, 9 }, { 24, 8 }, { 27, 14 }, { 32, 14 }, { 34, 20 }, { 39, 21 },
  { 40, 27 }, { 46, 28 }, { 46, 34 }, { 52, 36 }, { 51, 41 }, { 58, 44 }, { 58, 63 }, { 0, 63 } })
torn:cut(c:poly({ { 0, 0 }, { 30, 0 }, { 10, 12 }, { 13, 15 }, { 5, 21 }, { 0, 21 } }))       -- top end
torn:cut(c:poly({ { 63, 40 }, { 63, 63 }, { 40, 63 }, { 45, 55 }, { 49, 56 }, { 51, 49 }, { 56, 48 } })) -- bottom end
local skin = c:ellipse(CX, CY, R, R):clip(torn):clip(c:rect(7, 7, 56, 56))
-- rolled hem along the hoop edge, then the peeled corner of the tear
local hem = skin:copy():cut(c:ellipse(CX, CY, R - 5, R - 5))

c:build{
  { "skin", skin, parch, { gloss = { 20, 22 }, cres = 5 } },
  { "hem",  hem,  "wood", { gloss = false } },
}

-- faded painted band on the drum face, following the hoop
local band = c:mask()
skin:each(function(x, y)
  local d = math.sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  if d >= R - 11 and d < R - 9 then band:set(x, y) end
end)
c:fill(band:clip(skin:shrink(3)), "#b8452f")

-- laced seam along the hem join, lacing holes punched through the hem
local pts = {}
for a = 92, 182, 2 do
  local r = math.rad(a)
  pts[#pts + 1] = { math.floor(CX + (R - 5) * math.cos(r) + 0.5), math.floor(CY + (R - 5) * math.sin(r) + 0.5) }
end
c:seam(pts)
for a = 100, 175, 12 do
  local r = math.rad(a)
  local x, y = math.floor(CX + (R - 2.5) * math.cos(r) + 0.5), math.floor(CY + (R - 2.5) * math.sin(r) + 0.5)
  if hem:has(x, y) then c:px(x, y, "#8a4a1c") end
end

local t = c:save(D .. "final/aseprite/ph/drum-skin.aseprite", PNG .. "drum-skin.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
