-- tide-bucket (lean W2_33)
-- Tall tapered wooden bucket, brimming with seawater, twisted rope bail, two verdigris hoops, wet-dark base.
-- Quirk: an orange starfish clinging to the staves.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tide-bucket" }
local floor, abs, sin, max, min = math.floor, math.abs, math.sin, math.max, math.min
local function cl(v) return max(0, min(1, v)) end
local WOOD = { "#3a2630", "#5e4040", "#86604a", "#ab8460", "#cba87a", "#e6cc9c" }
local WATER = { "#1c4f7c", "#2a76a6", "#3ea0c4", "#6cc6d8", "#a6e6e8", "#e6fbf8" }
local HOOP = { "#1f4a4a", "#2f6e68", "#4a9488", "#7cc4aa" }
local STAR = { "#8c2e1c", "#bf4a22", "#e8742e", "#f6a64e" }
local CX, Y0, Y1 = 32, 24, 54
local function hw(y) return 14 - (y - Y0) / (Y1 - Y0) * 4 end
c:groundShadow(33, 57, 16, 2)
-- rope bail (behind): arcs over the top
local rm, rn, rT = G.tube({ { 19, 25 }, { 19, -2 }, { 45, -2 }, { 45, 25 } }, function() return 1.6 end)
G.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), { "#6e5230", "#94733f", "#b8975a", "#d8bc80", "#f0dca8", "#fff2c8" }, { 0.2, 0.4, 0.58, 0.75, 0.9 })
rm:each(function(x, y) if floor(rT[K(x, y)] * 38 + (y > 0 and 0 or 0)) % 2 == 0 then c:px(x, y, "#6e5230") end end)
-- body
local body = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do body:set(x, y) end end
body:add(c:ellipse(CX, Y1, 10, 2.5))
local v = {}
body:each(function(x, y) local u = (x - (CX - hw(math.min(y, Y1)))) / (2 * hw(math.min(y, Y1)))
  local g = X.hash(x // 1, floor(y / 6), 5) * 0.06
  v[K(x, y)] = cl(0.95 - u * 0.95 + g - (y - Y0) * 0.006) end)
local bias = {}
body:each(function(x, y) if y > 48 then bias[K(x, y)] = -1 end end)
G.tone(c, body, v, WOOD, { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias)
-- stave seams (follow taper)
for i = -2, 2 do
  for y = Y0 + 3, Y1 - 1 do
    local h = hw(y)
    local x = floor(CX + i * (h / 2.5) + 0.5)
    if i ~= 0 or true then c:px(x, y, WOOD[2]) if i < 0 then c:px(x - 1, y, WOOD[5]) end end
  end
end
-- hoops
for _, hy in ipairs{ 30, 47 } do
  for dy = 0, 2 do local y = hy + dy
    for x = floor(CX - hw(y) + 0.5), floor(CX + hw(y) - 0.5) do
      local u = (x - (CX - hw(y))) / (2 * hw(y))
      c:px(x, y, dy == 0 and HOOP[u < 0.55 and 4 or 3] or (dy == 1 and HOOP[u < 0.6 and 3 or 2] or HOOP[u < 0.5 and 2 or 1]))
    end end
  c:px(CX - 5, hy + 1, HOOP[4]) c:px(CX + 4, hy + 1, HOOP[1])
end
-- top rim ring + water
local rim = c:ellipse(CX, Y0, 14, 4)
G.tone(c, rim, (function() local t = {} rim:each(function(x, y) t[K(x, y)] = cl(0.95 - (x - 18) / 28 * 0.8) end) return t end)(), WOOD, { 0.2, 0.38, 0.55, 0.72, 0.88 })
local wat = c:ellipse(CX, Y0 + 0.5, 12, 2.7)
wat:each(function(x, y) local w = (y - (Y0 - 2)) / 5
  local t = 3 + ((x + 2 * y) % 7 == 0 and 1 or 0) - (w > 0.7 and 1 or 0) - (w > 0.9 and 1 or 0)
  c:px(x, y, WATER[max(1, t)]) end)
for x = 24, 28 do c:px(x, Y0 - 1, WATER[5]) end c:px(25, Y0 - 1, WATER[6]) c:px(37, Y0 + 1, WATER[5])
-- spill drip on right side
c:px(CX + 12, Y0 + 2, WATER[4]) c:px(CX + 12, Y0 + 3, WATER[3]) c:px(CX + 12, Y0 + 4, WATER[4])
-- starfish
local pts = {}
for i = 0, 9 do local a = -math.pi / 2 + i * math.pi / 5; local r = (i % 2 == 0) and 5.2 or 2.1
  pts[#pts + 1] = { 38 + r * math.cos(a), 39 + r * math.sin(a) } end
local star = c:poly(pts)
star:each(function(x, y) local t = 3 - ((x - 36) * 0.3 + (y - 37) * 0.25)
  c:px(x, y, STAR[cl((t - 1) / 3) * 3 // 1 + 1 > 4 and 4 or cl((t - 1) / 3) * 3 // 1 + 1]) end)
c:px(38, 39, STAR[1]) c:px(37, 37, STAR[4]) c:px(39, 40, STAR[2])
G.fin(c, "tide-bucket")
