-- sun-dried-tomatoes (lean D2o_16)
local NAME = "sun-dried-tomatoes"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function blob(m, ramp, R, o, cuts, bias)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, cuts, bias)
  return v, n
end
local function lines(pts, hex) G.line(c, pts, hex) end
local function hits(m, fn) m:each(fn) end

-- sun-dried tomatoes: two strings of wrinkled red halves hung from a wooden rail; quirk: a basil leaf tucked on the end of the left string
local WOOD = { "#3a2218", "#5e3a28", "#855636", "#ab7a48", "#cf9f66", "#e8c488" }
local RED = { "#3c0f1c", "#641a28", "#8e2630", "#b53a34", "#d4573e", "#ef8058" }
local TW = { "#6a5030", "#a8884e", "#d8bc78" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local rail = c:rrect(8, 6, 55, 11, 2)
blob(rail, WOOD, 3, { amb = 0.15, wrap = 0.25 })
for x = 12, 52, 3 do c:px(x, 8 + (x % 2), WOOD[2]) end
c:fillMask(c:rect(8, 11, 55, 11), WOOD[1])
-- hanging loop pegs
c:px(22, 12, TW[3]) c:px(42, 12, TW[3])
local function tomato(cx, cy, rx, ry, seed)
  local m = c:ellipse(cx, cy, rx, ry)
  local n = X.pillow(m, rx)
  local v = X.light(n, { amb = 0.06, wrap = 0.2 })
  local bias = {}
  m:each(function(x, y)
    local k = K(x, y)
    local w = sin((x - cx) * 1.4 + (y - cy) * 0.9 + seed) + X.hash(x, y, seed) * 0.8
    if w > 1.0 then bias[k] = -1 elseif w < -0.9 then bias[k] = 1 end
  end)
  G.tone(c, m, v, RED, { 0.18, 0.34, 0.5, 0.68, 0.84 }, bias)
  c:px(cx - rx * 0.4, cy - ry * 0.5, RED[6])
end
local function string(x, y0, ts)
  lines({ { x, 12 }, { x, 52 } }, TW[2])
  for y = 13, 51, 2 do c:px(x, y, TW[1]) end
  for _, t in ipairs(ts) do
    tomato(x + t[3], t[1], t[2] + 1, t[2] + 2, t[1])
    c:px(x, t[1] - 1, TW[3]) c:px(x, t[1], TW[2]) c:px(x, t[1] + 1, TW[3])
  end
end
string(22, 12, { { 20, 5, -1 }, { 32, 6, 1 }, { 44, 5, -1 } })
string(42, 12, { { 18, 5, 1 }, { 29, 5, -1 }, { 40, 6, 1 }, { 51, 4, 0 } })
c:fillMask(c:rect(21, 51, 23, 52), TW[1])
local lf = G.rell(21, 55, 0.3, 0.95, 4, 2.2)
blob(lf, LEAF, 1.5)
lines({ { 21, 52 }, { 21, 58 } }, LEAF[6])

G.fin(c, NAME)
