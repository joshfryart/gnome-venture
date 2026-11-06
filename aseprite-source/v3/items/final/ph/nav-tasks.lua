-- nav-tasks (lean E2_03)
local NAME = "nav-tasks"
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
c:groundShadow(30, 58, 16, 2)
local WD = { "#4a2a20", "#744028", "#9a5c34", "#bc7e46", "#d9a05c", "#f0c682" }
local board = c:rrect(10, 8, 44, 57, 3)
body(board, WD, 34, "board", 0.12)
-- wood grain
board:each(function(x, y) if (y + floor(x / 5)) % 6 == 0 and X.hash(x, y, 2) > 0.3 then c:put(x, y, WD[2], T) end end)
local paper = c:rect(14, 14, 40, 52)
body(paper, { "#b0a090", "#d0c4b0", "#e8dec8", "#f4ecd8", "#faf4e4", "#fffaee" }, 40, "paper", 0.3)
for y = 14, 52 do dot(40, y, "#c8bba4") end
for x = 14, 40 do dot(x, 52, "#c8bba4") end
-- rows: box + text bars
for i, ry in ipairs{ 20, 31, 42 } do
  for x = 17, 23 do for y = ry, ry + 6 do
    local edge = (x == 17 or x == 23 or y == ry or y == ry + 6)
    dot(x, y, edge and "#26448a" or "#fff6e0")
  end end
  dot(18, ry + 1, "#9cbcf0") dot(19, ry + 1, "#9cbcf0")
  for x = 26, (i == 3) and 36 or 37 do dot(x, ry + 2, "#6a6478") dot(x, ry + 3, "#8a8498") end
  if i == 3 then for x = 26, 33 do dot(x, ry + 6, "#8a8498") end end
  if i < 3 then
    -- green check mark, bold, escaping the box
    for _, p in ipairs{ {18,ry+3},{19,ry+4},{20,ry+5},{21,ry+3},{22,ry+1},{23,ry-1},{24,ry-2} } do
      dot(p[1], p[2], "#2a9a48") dot(p[1], p[2] + 1, "#1c6a34")
    end
    dot(23, ry - 2, "#8ee878") dot(24, ry - 3, "#8ee878")
  end
end
-- steel clip
local ST = { "#3a4258", "#5a6682", "#8794ae", "#b6c2d8", "#dde6f2", "#f6faff" }
local clip = c:rrect(20, 4, 34, 13, 2)
body(clip, ST, 8, "clip", 0.12)
dot(26, 7, "#2b1c26") dot(27, 7, "#2b1c26") dot(26, 8, "#2b1c26") dot(27, 8, "#2b1c26")
dot(22, 6, "#fff6e0")
-- quirk: yellow pencil laid diagonally with pink eraser
local pm = HP.mask()
local ax, ay, bx, by = 30, 59, 54, 35
local dx, dy = bx - ax, by - ay
local L = sqrt(dx * dx + dy * dy)
local px, py = -dy / L, dx / L
for y = 0, 63 do for x = 0, 63 do
  local t = ((x - ax) * dx + (y - ay) * dy) / (L * L)
  local d = ((x - ax) * px + (y - ay) * py)
  if t >= 0 and t <= 1 then
    local hw = 2.3
    if t > 0.84 then hw = 2.3 * (1 - t) / 0.16 + 0.4 end
    if abs(d) <= hw then
      local col
      if t < 0.1 then col = (d < 0) and "#f0a0a8" or "#c8607c"
      elseif t < 0.17 then col = (d < 0) and "#dde6f2" or "#8794ae"
      elseif t < 0.84 then col = (d < -0.8) and "#fcdc58" or (d > 0.9 and "#c8901c" or "#eeb830")
      elseif t < 0.94 then col = (d < 0) and "#f2d4a0" or "#d0aa74"
      else col = "#3a3040" end
      c:put(x, y, col, T)
    end
  end
end end
G.save(c, NAME)
