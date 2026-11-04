-- stage-herb-3 (lean W2_23)
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

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-herb-3" }
local LEAF = { "#27403f", "#36605a", "#4f8068", "#76a082", "#9cbc98", "#c4d8b4" }
local PETAL = { "#3a2a6a", "#5a3e92", "#7c5cb8", "#9c80d4", "#bea4ea", "#e2d4fa" }
c:groundShadow(32, 56, 24, 3)
soil(c)
-- silver-green grey leaves in a rosette
blade(c, { {30,48}, {22,44}, {14,42}, {7,44} }, 2.2, LEAF)
blade(c, { {34,48}, {42,44}, {50,42}, {57,44} }, 2.2, LEAF)
blade(c, { {32,48}, {27,42}, {24,38}, {23,34} }, 1.8, LEAF)
blade(c, { {33,48}, {38,42}, {42,38}, {44,34} }, 1.8, LEAF)
-- spikes: slender stems, florets as whorled blobs
local spikes = { {16, 24, 20}, {25, 15, 22}, {32, 9, 26}, {40, 14, 22}, {49, 21, 20} }
for i, s in ipairs(spikes) do
  local x, ytop = s[1], s[2]
  stalk(c, { {32 + (x - 32) * 0.15, 48}, {32 + (x - 32) * 0.5, 40}, {x, 34}, {x, ytop + 8} }, 0.9, LEAF)
  local len = 12
  for k = 0, 4 do
    local y = ytop + k * 3
    local w = (k == 0) and 1.3 or 2.2 - (k == 4 and 0.4 or 0)
    local m = c:ellipse(x, y + 1, w + 0.8, 2)
    part(c, m, PETAL, 2, 0.12)
    c:px(x - 1, y, PETAL[6])
  end
  c:px(x, ytop - 2, PETAL[4]) c:px(x, ytop - 1, PETAL[3])
end
-- quirk: a little bee on the right spike
c:fillMask(c:ellipse(52, 17, 2.2, 1.5), "#f2c230") c:px(51, 17, "#2b1c26") c:px(53, 17, "#2b1c26") c:px(52, 15, "#e8f4ff") c:px(51, 15, "#e8f4ff")
G.fin(c, "stage-herb-3")
