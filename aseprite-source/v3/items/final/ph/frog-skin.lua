-- frog-skin (lean E2_01)
local NAME = "frog-skin"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, ceil = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.ceil
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function inter(a, b) local r = HP.mask() a:each(function(x, y) if b:has(x, y) then r:set(x, y) end end) return r end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local SKIN = { "#1b3a2a", "#2a5c34", "#3f8a3c", "#63b348", "#92d466", "#c4ec8c" }
local SPOT = { "#12281f", "#1f4a2b" }
local m = HP.mask()
m:add(c:ellipse(32, 31, 9, 14))
m:add(c:ellipse(32, 17, 7, 6))
local feet = {}
local limbs = {
  { {26,23}, {17,19}, {13,25} }, { {38,23}, {47,19}, {51,25} },
  { {26,42}, {16,47}, {14,53} }, { {38,42}, {48,47}, {50,53} },
}
for _, l in ipairs(limbs) do
  m:add(c:line(l, 3))
  local fx, fy = l[3][1], l[3][2]
  m:add(c:ellipse(fx, fy, 4, 3.4))
  local dx, dy = fx - 32, fy - 31
  local d = sqrt(dx * dx + dy * dy) dx, dy = dx / d, dy / d
  local base = math.atan(dy, dx)
  feet[#feet + 1] = { fx, fy, base }
  for _, da in ipairs{ -0.7, 0, 0.7 } do
    m:add(c:ellipse(fx + cos(base + da) * 5, fy + sin(base + da) * 5, 1.4, 1.4))
  end
end
local tok = { r = { name = "hide" } }
local idx = X.tone(c, m, X.light(X.pillow(m, 6), { amb = 0.1, wrap = 0.25 }), SKIN, { cuts = CUTS, tok = tok })
-- pale dorsal stripe
for y = 13, 45 do if m:has(32, y) then c:put(32, y, SKIN[5], tok) end end
-- toe webbing lines
for _, f in ipairs(feet) do for _, da in ipairs{ -0.7, 0, 0.7 } do
  for r = 2, 5 do
    local x, y = floor(f[1] + cos(f[3] + da) * r + 0.5), floor(f[2] + sin(f[3] + da) * r + 0.5)
    if m:has(x, y) then c:put(x, y, SKIN[2], tok) end
  end end end
-- dark blotches
for _, p in ipairs{ {27,26}, {37,28}, {29,36}, {36,40}, {27,31}, {35,22}, {30,44}, {17,19}, {47,19}, {17,49}, {47,49}, {37,34}, {28,21} } do
  c:ellipse(p[1], p[2], 1.8, 1.3):each(function(x, y) if m:has(x, y) then c:put(x, y, SPOT[1 + (x + y) % 2], tok) end end)
end
-- hide thickness rim on lower-right edges
m:each(function(x, y) if not m:has(x + 1, y + 1) and not m:has(x + 1, y) then c:put(x, y, "#dcd890", tok) end end)
-- empty eye holes
for _, ex in ipairs{ 28, 36 } do
  c:ellipse(ex, 15, 1.6, 1.6):each(function(x, y) c:put(x, y, "#12281f", tok) end)
  c:put(ex, 17, "#b5b266", tok)
end
-- tacks through the toes and shoulders
for i, f in ipairs(feet) do
  local x, y = floor(f[1]), floor(f[2])
  local t = { r = { name = "pin" .. i } }
  c:put(x + 1, y + 2, SPOT[1], t)
  c:put(x, y, "#ff9a8a", t) c:put(x + 1, y, "#c8383c", t) c:put(x, y + 1, "#c8383c", t) c:put(x + 1, y + 1, "#7a1c2c", t)
end
G.save(c, NAME)
