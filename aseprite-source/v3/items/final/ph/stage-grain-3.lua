-- stage-grain-3 (lean W2_23)
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

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-grain-3" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local EAR  = { "#2f5a34", "#47763a", "#6b9a3f", "#90b94a", "#b6d460", "#dcea8c" }
local AWN  = { "#6a8a3a", "#8fb04a", "#b9d46c", "#e0eea0" }
c:groundShadow(32, 56, 24, 3)
soil(c)
blade(c, { {20,48}, {14,42}, {10,36}, {6,34} }, 2.6, LEAF)
blade(c, { {44,48}, {50,42}, {54,37}, {58,36} }, 2.6, LEAF)
local ears = { {21, 21, 3.4, 7.5}, {32, 15, 3.8, 8.5}, {43, 20, 3.4, 7.5} }
for i, e in ipairs(ears) do
  local cx, cy = e[1], e[2]
  stalk(c, { {cx + (i - 2) * -1, 50}, {cx, 40}, {cx, 30}, {cx, cy + 4} }, 1.2, LEAF)
  -- awns spray above the ear
  for k = -2, 2 do
    G.line(c, { {cx + k, cy - e[4] + 2}, {cx + k * 2, cy - e[4] - 4} }, AWN[2 + (k % 2)])
  end
  local m = c:ellipse(cx, cy, e[3], e[4])
  local n = part(c, m, EAR, 3.6)
  -- grain pairs: chevron rows
  m:each(function(x, y)
    local ry = (y - cy + e[4])
    if ry % 3 == 1 and abs(x - cx) < e[3] - 0.5 then
      local d = abs(x - cx)
      if floor(ry / 3) % 2 == 0 and d >= 1 then c:px(x, y, EAR[2]) else c:px(x, y, EAR[1]) end
    end
  end)
  c:px(cx - 1, cy - 3, EAR[6]) c:px(cx - 1, cy - 2, EAR[5])
  -- leaf sheath wrapped at the base of the ear
  blade(c, { {cx, cy + e[4] + 6}, {cx - 2, cy + e[4] + 2}, {cx - 1, cy + e[4] - 2}, {cx, cy + e[4] - 4} }, 2.0, LEAF)
end
-- quirk: a dewdrop on the middle awn tip, and a little ladybird on a blade
c:px(33, 3, "#e8f6ff") c:px(33, 4, "#8cc4e8")
c:fillMask(c:ellipse(12, 37, 1.5, 1), "#c4342e") c:px(11, 37, "#2b1c26") c:px(12, 36, "#f0807a")
G.fin(c, "stage-grain-3")
