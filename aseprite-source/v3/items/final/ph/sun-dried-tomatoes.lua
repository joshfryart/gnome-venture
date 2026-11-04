-- sun-dried-tomatoes (lean W2_31)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sun-dried-tomatoes" }
local RED = { "#3a0e1c", "#5c1426", "#7e1c2a", "#a42a30", "#c9453a", "#e8704f" }
local TWN = { "#7a5a38", "#a88050", "#c9a066", "#e2c488" }
G.line(c, { {5,10},{14,13},{22,15},{32,16},{42,15},{50,13},{59,10} }, TWN[3])
for _, p in ipairs{ {10,12},{18,14},{27,16},{37,16},{46,14},{54,12} } do c:px(p[1], p[2], TWN[1]) end
for _, p in ipairs{ {13,12},{23,14},{33,15},{43,14},{51,12} } do c:px(p[1], p[2], TWN[4]) end
local function tom(cx, top, len, wd, seed, bite)
  local m = HP.mask()
  for y = top, top + len do
    local t = (y - top) / len
    local h = wd * sin(pi * min(1, t * 0.92 + 0.07)) ^ 0.65 + 1.3 * sin(y * 0.9 + seed) * min(1, t * 3)
    local sh = floor(2.2 * sin(t * 3 + seed))
    for x = floor(cx + sh - h + 0.5), floor(cx + sh + h - 0.5 + 1) - 1 do m:set(x, y) end
  end
  if bite then m:cut(c:ellipse(cx + wd - 1, top + len - 9, 4, 4)) end
  local n = X.pillow(m, wd + 1)
  local v = X.light(n, { amb = 0.08, wrap = 0.18 })
  local bias = {}
  m:each(function(x, y)
    local w = (y + 1.6 * sin(x * 0.7 + seed)) % 5
    if w < 0.9 and y > top + 5 then bias[K(x, y)] = -1 end
    if w > 2.4 and w < 3.1 and X.hash(x, y, seed) > 0.5 and y > top + 5 then bias[K(x, y)] = 1 end
  end)
  G.tone(c, m, v, RED, { 0.18, 0.36, 0.54, 0.7, 0.86 }, bias)
  -- curled lighter rim along left edge
  m:edge():each(function(x, y) if x < cx - 1 and y > top + 3 and y < top + len - 3 then c:px(x, y, RED[5]) end end)
  -- oil sheen
  c:px(cx - 3, top + 8, "#ffc4a8") c:px(cx - 3, top + 9, "#ffc4a8") c:px(cx - 2, top + 8, "#ff9a78")
  c:px(cx + 2, top + 16, "#f08a68") c:px(cx + 2, top + 17, "#f08a68")
  -- loop and knot
  G.line(c, { {cx,top - 1},{cx - 1,top - 3},{cx,top - 5},{cx + 1,top - 3},{cx,top - 1} }, TWN[2])
  c:px(cx, top - 1, TWN[1]) c:px(cx, top - 6, TWN[3])
  return m
end
tom(17, 20, 28, 7, 1, false)
tom(32, 22, 32, 8, 2.3, false)
tom(47, 20, 24, 7, 4.1, true)
-- wisp of dried oregano at the foot (quirk)
G.line(c, { {24,56},{28,55},{33,56},{38,55} }, "#6f8a4e")
for _, p in ipairs{ {26,55},{29,56},{31,55},{35,55},{37,56} } do c:px(p[1], p[2], "#9ab868") end
G.fin(c, "sun-dried-tomatoes")
