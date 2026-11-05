-- lizard-scale (lean E2_03)
local NAME = "lizard-scale"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local T = { r = { name = "d" } }
local function body(m, ramp, R, name, amb)
  local n = X.pillow(m, R)
  local idx = X.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, { cuts = { .22, .4, .56, .72, .86 }, tok = { r = { name = name } } })
  return n, idx
end
local function draw(lm, hex, within) lm:each(function(x, y) if (not within) or within:has(x, y) then c:put(x, y, hex, T) end end) end
local function dot(x, y, hex, within) if (not within) or within:has(x, y) then c:put(x, y, hex, T) end end
c:groundShadow(32, 58, 12, 2)
local m = c:poly{ {32,6},{44,16},{50,32},{40,48},{32,57},{24,48},{14,32},{20,16} }
local R = { "#12302a", "#1d5638", "#2e7f42", "#52a94a", "#88cf5c", "#c4ec88" }
body(m, R, 17, "scale")
-- keel ridge down the middle: lit left, dark right
for y = 10, 52 do
  local w = (y < 30) and 1 or 1
  dot(31, y, R[6], m) dot(32, y, R[4], m) dot(33, y, R[2], m)
end
-- side ridges parallel to the keel, bowing out
for side = -1, 1, 2 do
  local pts = {}
  for i = 0, 8 do local y = 14 + i * 4.5; local bow = 9 - ((y - 32) / 20) ^ 2 * 5; pts[#pts+1] = { 32 + side * bow, y } end
  draw(c:line(pts, 1), side < 0 and R[5] or R[2], m)
  local p2 = {}
  for i = 0, 8 do local y = 18 + i * 4; local bow = 15 - ((y - 32) / 20) ^ 2 * 9; p2[#p2+1] = { 32 + side * bow, y } end
  draw(c:line(p2, 1), side < 0 and R[4] or R[1], m)
end
-- soft pale skin where the scale was plucked from the lizard (bottom tip), with a nick on the right edge
local skin = HP.mask() m:each(function(x, y) if y >= 50 then skin:set(x, y) end end)
skin:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and "#f0d6b0" or "#e0b892", T) end)
dot(32, 56, "#c98f7a", m) dot(31, 55, "#fbe8c8", m)
for _, p in ipairs{ {47,24},{48,25},{47,26} } do end
c:put(46, 23, "#12302a", T) c:put(46, 24, "#12302a", T)
-- gleam
dot(24, 22, "#f4ffd0", m) dot(25, 22, "#f4ffd0", m) dot(24, 23, "#f4ffd0", m)
G.save(c, NAME)
