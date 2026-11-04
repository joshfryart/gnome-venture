-- toad-slime (lean D3o_5)
-- A glossy green slime mound with a scalloped skirt, three drips and a falling drop; bubbles inside.
-- quirk: a tiny yellow toad eye floats in the goo.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "toad-slime" }
local sin, sqrt, abs, floor = math.sin, math.sqrt, math.abs, math.floor
local function sh(m, ramp, R, amb, wrap, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = amb or 0.1, wrap = wrap or 0.25 })
  G.tone(c, m, v, ramp, nil, bias, tok)
  return n, v
end
local SL = { "#26443a", "#35693c", "#559a42", "#80c050", "#b0e06c", "#e4f8a4" }
local body = HP.mask()
for y = 15, 48 do for x = 12, 52 do
  local hw
  if y < 30 then local u = (30 - y) / 15 hw = 19 * sqrt(max and 1 or 1) * sqrt(math.max(0, 1 - u * u))
  else hw = 19 - (y - 30) * 0.08 end
  local bot = 40 + 5 * sin(x * 0.62) + 2 * sin(x * 0.25 + 1)
  if abs(x - 32) <= hw and y <= bot then body:set(x, y) end
end end
-- drips
local drips = { {21, 41, 52, 2.3}, {34, 42, 49, 2.0}, {44, 40, 52, 2.1} }
for _, d in ipairs(drips) do
  local m = G.tube({ {d[1], d[2]}, {d[1], d[2] + 3}, {d[1] + 0.5, d[3] - 4}, {d[1], d[3]} }, function(t) return d[4] * (1 - 0.45 * t) end)
  body:add(m)
  body:add(G.rell(d[1], d[3], 0, 1, d[4] * 1.15, d[4] * 1.2))
end
body:add(G.rell(51, 54, 0, 1, 2.2, 1.5))
local bias = {}
local n, v = sh(body, SL, 11, 0.08, 0.3, bias)
-- darker lower band
body:each(function(x, y) if y > 41 and v[K(x, y)] < 0.5 then c:px(x, y, SL[2]) end end)
-- bubbles
local function bub(x, y, r)
  c:fillMask(c:ellipse(x, y, r, r), SL[5])
  c:fillMask(c:ellipse(x, y, r - 1, r - 1), SL[3])
  c:px(x - 1, y - 1, SL[6])
end
bub(37, 24, 3) bub(26, 38, 2) bub(44, 35, 2) bub(21, 28, 1)
-- toad eye (quirk)
c:fillMask(c:ellipse(31, 32, 3, 3), "#d9b030")
c:fillMask(c:ellipse(31, 32, 2, 2), "#f4d84c")
c:px(30, 32, "#2b1c26") c:px(31, 32, "#2b1c26") c:px(32, 32, "#2b1c26")
c:px(30, 31, "#fff6c0")
-- gloss
c:px(23, 21, "#ffffe8") c:px(24, 21, "#ffffe8") c:px(22, 22, "#f2fcc0") c:px(22, 23, "#f2fcc0") c:px(23, 20, SL[6])
c:px(28, 17, SL[6]) c:px(29, 17, SL[6])
G.fin(c, "toad-slime")
