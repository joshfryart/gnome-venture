-- tide-bucket (lean D3o_2)
-- Tapered driftwood pail: pale salt-bleached staves, two rusty hoops, dark brine inside the oval rim, thin rope handle on knots. Quirk: a tiny crab claw waving over the rim.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tide-bucket" }
local floor, abs, sqrt = math.floor, math.abs, math.sqrt
local WOOD = { "#4a3640", "#6f5252", "#947466", "#b8977f", "#d6b99c", "#efdcc0" }
local IRON = { "#3a2b3a", "#5b4150", "#8a5a4e", "#b8745a", "#dc9a70", "#f5c79a" }
local ROPE = { "#6a5240", "#947a58", "#bba078", "#dcc596", "#f1e2b8", "#fff4d6" }
local BRINE= { "#1c2c44", "#2a4768", "#3d6a8a", "#62a0b0", "#a6dcdc", "#e6fbf4" }
local CRAB = { "#7a2a30", "#a8403a", "#d2614a", "#ee8a5c", "#fbb77e", "#ffe0b0" }
c:groundShadow(32, 57, 18, 2)
local Y0, Y1, CX = 24, 54, 32
local function hw(y) return 17 - 4 * (y - Y0) / (Y1 - Y0) end
local body = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do body:set(x, y) end end
-- body bottom is a gentle curve
local bot = HP.mask()
body:each(function(x, y) local u = (x - CX) / hw(y); if y > Y1 - 2 * (u * u) then bot:set(x, y) end end)
body:cut(bot)
local v, bias = {}, {}
body:each(function(x, y)
  local u = (x - CX) / hw(y)
  local s = 0.84 - 0.30 * (u + 1) / 2 * 1.9 + 0.08 * (1 - u * u)
  local stave = (x - (CX - 17)) % 6
  if stave == 0 then s = s - 0.18 end
  if stave == 1 then s = s + 0.05 end
  -- grain flecks
  if X.hash(x, y, 7) > 0.93 and stave > 1 then s = s - 0.12 end
  v[K(x, y)] = math.max(0, math.min(1, s))
end)
G.tone(c, body, v, WOOD)
-- hoops
local function hoop(y0, h)
  for y = y0, y0 + h - 1 do for x = floor(CX - hw(y) + 0.5), floor(CX + hw(y) - 0.5) do
    if body:has(x, y) then
      local u = (x - CX) / hw(y)
      local i = (u < -0.5) and 5 or (u < 0.1 and 4 or (u < 0.6 and 3 or 2))
      if y == y0 + h - 1 then i = math.max(1, i - 2) end
      c:px(x, y, IRON[i])
    end
  end end
  c:px(CX + 5, y0 + 1, IRON[1]) c:px(CX - 9, y0 + 1, IRON[1])
end
hoop(30, 3) hoop(46, 3)
-- ellipse rim, brine inside
local rim = c:ellipse(CX, Y0, 17, 4)
local inner = c:ellipse(CX, Y0 + 1, 15, 3)
local rv = {}
rim:each(function(x, y) local u = (x - CX) / 17; rv[K(x, y)] = math.max(0, math.min(1, 0.85 - 0.4 * (u + 1) / 2 + (y < Y0 and 0.06 or -0.1))) end)
G.tone(c, rim, rv, WOOD)
local bv = {}
inner:each(function(x, y) bv[K(x, y)] = math.max(0, math.min(1, 0.35 + 0.5 * (y - Y0 + 2) / 5 - 0.1 * (x - CX) / 15)) end)
G.tone(c, inner, bv, BRINE)
for _, p in ipairs{ {26,Y0+1},{27,Y0+1},{38,Y0+2} } do c:px(p[1], p[2], BRINE[6]) end
-- crab claw over rim (quirk): arm + pincer
for _, p in ipairs{ {44,Y0-1,3},{45,Y0-2,3},{45,Y0-3,2},{46,Y0-4,4},{47,Y0-4,3},{48,Y0-5,5},{48,Y0-6,4},{50,Y0-6,4},{49,Y0-7,5},{47,Y0-7,3},{50,Y0-5,3},{49,Y0-5,2},{47,Y0-6,2},{46,Y0-5,2},{45,Y0-1,2} } do
  c:px(p[1], p[2], CRAB[p[3]])
end
c:px(48, Y0 - 6, CRAB[6])
-- rope handle: thin arc, knots at rim holes
local rm, rn = G.tube({ {16, Y0}, {14, 5}, {50, 5}, {48, Y0} }, function(t) return 1.1 end)
local rv2 = X.light(rn, { amb = 0.1, wrap = 0.3 })
rm:cut(body)
G.tone(c, rm, rv2, ROPE)
rm:each(function(x, y) if (x + y) % 4 == 0 then c:px(x, y, ROPE[2]) end end)
for _, kx in ipairs{ 16, 48 } do
  c:fillMask(c:ellipse(kx, Y0 + 1, 2, 2), ROPE[3]) c:px(kx - 1, Y0, ROPE[5]) c:px(kx + 1, Y0 + 2, ROPE[1])
end
-- AO under rim on staves
for x = floor(CX - 16), floor(CX + 16) do if body:has(x, Y0 + 4) then c:px(x, Y0 + 4, WOOD[1]) end end
-- glint on lit stave
c:px(19, 36, WOOD[6]) c:px(19, 37, WOOD[6]) c:px(20, 35, WOOD[6])
G.fin(c, "tide-bucket")
