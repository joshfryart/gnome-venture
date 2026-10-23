-- drum-skin: a torn wedge of old drumhead, the curved hoop edge rolled into a laced hem
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local CX, CY = 32, 12                                     -- centre of the old round drumhead
local parch = GV.ramp("#e2c48c", { shade = "#c4945c", deep = "#8a5a34", bounce = "#cfa064" })

-- the scrap: bottom of a big circle, torn ragged across the top
local circ = c:ellipse(CX, CY, 41, 41)
local torn = c:poly({ { 7, 27 }, { 11, 21 }, { 15, 24 }, { 20, 15 }, { 25, 19 }, { 30, 11 }, { 35, 16 },
  { 40, 10 }, { 44, 15 }, { 49, 12 }, { 53, 18 }, { 58, 23 }, { 58, 63 }, { 7, 63 } })
local skin = circ:copy():clip(torn):clip(c:rect(8, 0, 55, 63))
-- rolled hem along the hoop edge
local hem = skin:copy():cut(c:ellipse(CX, CY, 36.5, 36.5))
-- upper-right corner peeling back, showing the darker underside
local flap = c:poly({ { 49, 12 }, { 55, 20 }, { 46, 22 } }):clip(skin:shrink(1))

c:build{
  { "skin", skin, parch, { gloss = { 16, 27 }, cres = 5 } },
  { "hem",  hem,  "wood", { gloss = false } },
  { "flap", flap, GV.ramp("#c4945c", { shade = "#a87a48", deep = "#8a5a34" }), { gloss = false, contact = false } },
}

-- faded painted ring and a diamond mark from the old drum face
local ring = c:mask()
skin:each(function(x, y)
  local d = math.sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  if d >= 29.5 and d < 31.5 then ring:set(x, y) end
end)
c:fill(ring:clip(skin:shrink(3)):cut(hem:grow(1)):cut(flap:grow(1)), "#b8452f")
c:fill(c:ascii({
  "..r..",
  ".rrr.",
  "rrrrr",
  ".rrr.",
  "..r..",
}, 30, 28), "#b8452f")
c:px(32, 28, "#dd3a2a"); c:px(31, 29, "#dd3a2a")

-- laced seam along the hem join, with lacing holes punched below it
local pts, holes = {}, {}
for x = 12, 52 do
  local dx = x - CX
  pts[#pts + 1] = { x, math.floor(CY + math.sqrt(36.5 ^ 2 - dx ^ 2) + 0.5) }
end
c:seam(pts)
for x = 16, 48, 6 do
  local dx = x - CX
  local y = math.floor(CY + math.sqrt(39 ^ 2 - dx ^ 2) + 0.5)
  if hem:has(x, y) and hem:has(x + 1, y) then c:px(x, y, "#5e2f1e"); c:px(x + 1, y, "#5e2f1e") end
end
c:button(10, 39)

local t = c:save(D .. "final/aseprite/ph/drum-skin.aseprite", PNG .. "drum-skin.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
