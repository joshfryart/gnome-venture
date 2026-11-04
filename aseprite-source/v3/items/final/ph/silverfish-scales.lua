-- silverfish-scales (lean D2o_0)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c
local function shade(m, ramp, R, o) local n = X.pillow(m, R) return G.toneN(c, m, n, ramp, o), n end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "silverfish-scales" }
local SIL = { "#3e4a6e", "#5f7096", "#8499b8", "#aebfd6", "#d3deea", "#f4f8fc" }
local IRI = { "#4e3d6e", "#6e5a92", "#9580b8", "#bba6d6", "#dccaea", "#f6eefa" }
local function scale(cx, cy, rx, ry, ang, ramp)
  local m, n = G.oval(cx, cy, rx, ry, ang, 0.7)
  G.toneN(c, m, n, ramp)
  local l = X.light(n, { amb = 0.08, wrap = 0.25 })
  local rx0, ry0 = cx + sin(ang) * ry * 0.95, cy - cos(ang) * ry * 0.95
  m:each(function(x, y)
    local d = sqrt((x - rx0)^2 + (y - ry0)^2)
    local a = atan(y - ry0, x - rx0)
    local lit = (l[K(x, y)] or 0) > 0.5
    if d > 3 and floor(d) % 3 == 0 then c:px(x, y, lit and ramp[4] or ramp[2])
    elseif d > 3 and (a * 7 / pi) % 1 < 0.13 then c:px(x, y, lit and ramp[6] or ramp[3]) end
  end)
  m:edge():each(function(x, y) c:px(x, y, (x + y) < (cx + cy) and ramp[5] or ramp[1]) end)
  return m, n
end
scale(48, 22, 5, 9, 1.1, IRI)
scale(24, 41, 13, 10, 0.4, SIL)
scale(42, 43, 12, 9, -0.3, SIL)
local cm, cn = scale(33, 26, 12, 10, 0.1, SIL)
local sx, sy = G.specAt(cm, cn, 30)
c:sparkle(sx + 1, sy + 1)
-- quirk: a bead of water on the pile
c:fillMask(c:poly{ {50, 50}, {52, 53}, {52, 55}, {50, 56}, {48, 55}, {48, 53} }, "#6fa8dc")
c:px(49, 53, "#e4f2ff") c:px(51, 55, "#3b6ea5")
G.save(c, "silverfish-scales")
