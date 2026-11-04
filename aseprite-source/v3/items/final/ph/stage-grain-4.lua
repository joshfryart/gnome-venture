-- stage-grain-4 (lean W2_23)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUT = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local SOIL = { "#2a1a1e", "#4a2e2a", "#6b4232", "#8d5c3e", "#b07a4e", "#cf9a66" }
local function part(c, m, ramp, R, amb)
  local n = X.pillow(m, R)
  G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUT)
  return n
end
local function soil(c)
  local m = c:ellipse(32, 50, 23, 8)
  part(c, m, SOIL, 8, 0.05)
  m:each(function(x, y) local h = X.hash(x, y, 3)
    if h > 0.93 then c:px(x, y, SOIL[5]) elseif h < 0.05 then c:px(x, y, SOIL[1]) end end)
  return m
end
local function stalk(c, pts, w, ramp)
  local m, n = G.tube(pts, function(t) return w end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), ramp, CUT)
  return m
end
local function blade(c, pts, wmax, ramp)
  local m, n = G.tube(pts, function(t) return max(0.5, wmax * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.7) end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), ramp, CUT)
  return m
end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-grain-4" }
local GOLD = { "#6a3a14", "#9a5c1c", "#c88426", "#e4a834", "#f4c852", "#fde48a" }
local STRAW = { "#7a5a24", "#a8802e", "#d0a844", "#ecd070" }
local LEAF = { "#2a3a2a", "#3c5a32", "#587a3a", "#7a9a48", "#9cb85a", "#c0d27a" }
c:groundShadow(32, 56, 24, 3)
soil(c)
blade(c, { {38,48}, {40,42}, {44,38}, {50,38} }, 2.4, LEAF)
-- ears hang off arched stalks (different heights/droop)
local function droopy(pts, ex, ey, ang)
  stalk(c, pts, 1.1, STRAW)
  local m = HP.mask()
  for t = -7, 7 do
    local w = 3.3 * (1 - (t / 8) ^ 2) ^ 0.6
    local px, py = ex + sin(ang) * t, ey + cos(ang) * t
    for dx = -floor(w), floor(w) do
      for dy = -floor(w), floor(w) do
        if dx * dx + dy * dy <= w * w + 0.5 then m:set(floor(px + dx + 0.5), floor(py + dy + 0.5)) end
      end
    end
  end
  part(c, m, GOLD, 3.4)
  m:each(function(x, y) if (x + y * 2) % 4 == 0 and X.hash(x, y, 6) > 0.35 then c:px(x, y, GOLD[2]) end end)
  -- tail awns at the ear tip
  local tx, ty = ex + sin(ang) * 8, ey + cos(ang) * 8
  G.line(c, { {floor(tx), floor(ty)}, {floor(tx + sin(ang) * 4), floor(ty + cos(ang) * 4)} }, STRAW[3])
  G.line(c, { {floor(tx) + 1, floor(ty)}, {floor(tx + sin(ang) * 4) + 2, floor(ty + cos(ang) * 4)} }, STRAW[2])
  return m
end
stalk(c, { {32,50}, {28,36}, {24,26}, {26,20} }, 0.9, STRAW)
droopy({ {26,48}, {24,24}, {26,12}, {34,13} }, 38, 20, -0.4)
droopy({ {44,50}, {46,34}, {48,26}, {52,24} }, 51, 33, -0.2)
droopy({ {18,50}, {10,40}, {9,34}, {12,34} }, 12, 40, 0.15)
blade(c, { {32,50}, {28,44}, {24,40}, {20,40} }, 2.4, LEAF)
-- quirk: loose grains spilled on the soil
for _, g in ipairs{ {19, 50}, {47, 52}, {40, 54} } do
  c:fillMask(c:ellipse(g[1], g[2], 1.5, 1), GOLD[4]) c:px(g[1] - 1, g[2] - 1, GOLD[6])
end
G.fin(c, "stage-grain-4")
