-- pickled-lotus-root (lean W2_13)
-- Two overlapping marinated slices (nine-hole pattern) leaning on a short whole root link whose cut end shows the holes.
-- quirk: a single lotus fibre thread hangs from one hole.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sqrt = math.floor, math.abs, math.sqrt
local WOOD  = { "#3d2418", "#5e3a22", "#8a5a32", "#b0804a", "#d3a766" }
local WHITE = { "#5d5a84", "#8d8aae", "#bdbcd2", "#e4e1e6", "#fbf6ea" }
local BLUE  = { "#223a6e", "#31569a", "#4c7cc4", "#7aaae0", "#b4d6f5" }
local function shade(x, y, x0, y0, x1, y1, R, base)
  local i = base or 3
  if x == x0 then i = i + 1 elseif x == x1 then i = i - 1 end
  if y == y0 then i = i + 1 elseif y == y1 then i = i - 1 end
  return R[math.max(1, math.min(#R, i))]
end
local function box(c, x0, y0, x1, y1, R, base, grain)
  for y = y0, y1 do for x = x0, x1 do
    local col = shade(x, y, x0, y0, x1, y1, R, base)
    if grain and X.hash(x, y, grain) > 0.82 and x > x0 and x < x1 then col = R[math.max(1, (base or 3) - 1)] end
    c:put(x, y, col)
  end end
end
local NAME = "pickled-lotus-root"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local PINK = { "#7a3b58", "#a65876", "#d08a9c", "#ecb7b4", "#f8dccb", "#fff3e2" }
local SKIN = { "#5a3a3a", "#7d5448", "#a37a5a", "#c9a478" }
c:fillMask(c:ellipse(30, 55, 22, 3), "#9a94a8") c:fillMask(c:ellipse(30, 55, 13, 2), "#7c7690")
-- whole root link (horizontal capsule, lower-left)
local link = c:rrect(7, 41, 33, 53, 5)
link:each(function(x, y)
  local t = (y - 41) / 12
  local i = t < 0.2 and 4 or t < 0.45 and 3 or t < 0.75 and 2 or 1
  if X.hash(x, y, 3) > 0.9 then i = math.max(1, i - 1) end
  c:put(x, y, SKIN[i])
end)
for _, x in ipairs{ 18 } do for y = 41, 53 do c:put(x, y, SKIN[1]) end c:px(x + 1, 43, SKIN[4]) end
-- slice painter
local function slice(cx, cy, r, holes)
  local m = c:ellipse(cx, cy, r, r)
  m:each(function(x, y)
    local dx, dy = (x - cx) / r, (y - cy) / r
    local d = sqrt(dx * dx + dy * dy)
    local lit = 0.55 - 0.3 * (dx + dy) + 0.1 * (X.hash(x, y, 5) - 0.5)
    local i = lit > 0.78 and 5 or lit > 0.6 and 4 or lit > 0.42 and 3 or 2
    if d > 0.84 then i = (dx + dy < -0.2) and 3 or 2 end
    if d > 0.93 then i = 2 end
    if dx + dy > 1.0 and d > 0.7 then i = 1 end
    c:put(x, y, PINK[i])
  end)
  for _, h in ipairs(holes) do
    local hx, hy, hr = cx + h[1] * r, cy + h[2] * r, h[3] * r
    c:ellipse(hx, hy, hr, hr):each(function(x, y)
      local dx, dy = x - hx, y - hy
      c:put(x, y, (dx + dy > hr * 0.6) and PINK[4] or (dx + dy < -hr * 0.4) and PINK[1] or "#4a2236")
    end)
  end
  return m
end
local function pat(a)
  local H = { { 0, 0, 0.17 } }
  for k = 0, 7 do local ang = a + k * math.pi / 4 H[#H + 1] = { math.cos(ang) * 0.55, math.sin(ang) * 0.55, 0.13 } end
  return H
end
slice(23, 22, 14, pat(0.2))
slice(43, 31, 13, pat(0.5))
-- link cut face
c:ellipse(33, 47, 4, 6):each(function(x, y) c:put(x, y, PINK[(x + y) % 5 == 0 and 5 or 4]) end)
for _, p in ipairs{ {33,47}, {32,44}, {34,44}, {32,50}, {34,50} } do c:px(p[1], p[2], "#4a2236") end
-- highlights (marinade gloss)
c:px(15, 14, PINK[6]) c:px(16, 14, PINK[6]) c:px(36, 24, PINK[6]) c:px(37, 24, PINK[6])
-- quirk: fibre thread
for i, p in ipairs{ {47,35}, {48,38}, {47,41}, {48,44}, {49,47} } do c:px(p[1], p[2], i % 2 == 0 and "#f4e6c8" or "#d9c49c") end
G.save(c, NAME)
