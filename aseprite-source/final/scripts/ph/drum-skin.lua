-- drum-skin: a scrap torn from an old round drumhead; the hoop edge is a rolled hem with zigzag lacing
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local CX, CY, R = 36, 8, 44                                -- the old drumhead, centre above the scrap
local parch = GV.ramp("#e2c48c", { shade = "#c4945c", deep = "#8a5a34", bounce = "#cfa064" })
local hemR  = GV.ramp("#b07a45", { gloss = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a", deep = "#5e2f1e", bounce = "#a8582f" })

-- torn on a slant across the top and ragged at both ends; the rest is the round hoop edge
local torn = c:poly({ { 4, 31 }, { 8, 27 }, { 12, 29 }, { 16, 23 }, { 21, 25 }, { 25, 19 }, { 30, 21 },
  { 34, 15 }, { 39, 17 }, { 43, 11 }, { 48, 14 }, { 52, 9 }, { 58, 12 }, { 58, 63 }, { 4, 63 } })
torn:cut(c:poly({ { 0, 28 }, { 9, 28 }, { 8, 33 }, { 11, 37 }, { 8, 41 }, { 10, 45 }, { 0, 45 } }))   -- left end
torn:cut(c:poly({ { 63, 8 }, { 54, 8 }, { 56, 15 }, { 53, 20 }, { 56, 27 }, { 54, 33 }, { 57, 40 }, { 63, 40 } })) -- right end
local skin = c:ellipse(CX, CY, R, R):clip(torn):clip(c:rect(6, 6, 56, 56))
local hem = skin:copy():cut(c:ellipse(CX, CY, R - 6, R - 6))
-- the torn corner curling back, showing the darker underside
local flap = c:poly({ { 43, 12 }, { 48, 15 }, { 52, 10 }, { 54, 19 }, { 45, 21 } }):clip(skin:shrink(1))

c:build{
  { "skin", skin, parch, { gloss = { 16, 32 }, cres = 5 } },
  { "hem",  hem,  hemR, { gloss = false, light = skin } },
  { "flap", flap, GV.ramp("#c4945c", { shade = "#a8754a", deep = "#8a5a34", rim = "#d9b47a" }), { gloss = false, contact = false, light = skin } },
}

-- hide flecks on the drum face (small beans, evenly spread)
for _, p in ipairs({ { 24, 31 }, { 36, 26 }, { 31, 38 }, { 44, 33 }, { 19, 39 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2]), "#c4945c")
end

-- zigzag drum lacing over the hem (thread gold, 2 on / 1 off), button at its head
local function at(a, r)
  local q = math.rad(a)
  return { math.floor(CX + r * math.cos(q) + 0.5), math.floor(CY + r * math.sin(q) + 0.5) }
end
local pts, flip = {}, false
for a = 150, 34, -8 do
  pts[#pts + 1] = at(a, flip and R - 2 or R - 6)
  flip = not flip
end
c:seam(pts)
local b = at(156, R - 4)
c:button(b[1] - 1, b[2] - 2)

local t = c:save(D .. "final/aseprite/ph/drum-skin.aseprite", PNG .. "drum-skin.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
