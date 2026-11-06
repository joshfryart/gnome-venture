-- strawberry-jam (lean D2o_15)
-- Squat wide jar of deep red jam, topped by a gingham cloth cover with scalloped hem tied with twine.
-- quirk: a fat blob of jam has dribbled down the glass from under the cloth.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "strawberry-jam" }
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local function inter(a, b) local m = HP.mask() a:each(function(x, y) if b:has(x, y) then m:set(x, y) end end) return m end
local GLASS = { "#4a6a7a", "#6f98a8", "#9fc4d0", "#c9e4ea", "#e8f6f6", "#f4fffe" }
local JAM = { "#3a0a1a", "#6a1226", "#9c1c32", "#c42c3c", "#e0505a", "#ff8a84" }
local CRM = { "#a89a8c", "#cfc2b0", "#e8dcc6", "#f6ecd8", "#fff8ea" }
local PNK = { "#8a3a48", "#b45a66", "#d8808a", "#eaa4a8", "#f8c8c4" }
local RD  = { "#5a1420", "#8a2030", "#b8303c", "#d6504e", "#ee7a68" }
c:groundShadow(32, 55, 18, 2)
local g = c:rrect(15, 28, 49, 53, 6)
shade(g, 8, GLASS)
local jam = g:copy():shrink(2)
local n, v = shade(jam, 9, JAM, { amb = 0.05 })
jam:each(function(x, y) local h = X.hash(x, y, 9)
  if h > 0.93 and v[K(x, y)] > 0.35 then c:px(x, y, JAM[5]) end
  if h < 0.05 then c:px(x, y, JAM[1]) end end)
-- strawberry chunks
for _, p in ipairs{ {24, 40}, {38, 45}, {30, 48}, {41, 36} } do c:px(p[1], p[2], JAM[6]) c:px(p[1] + 1, p[2], JAM[5]) c:px(p[1], p[2] + 1, JAM[3]) end
for y = 33, 46 do c:px(18, y, GLASS[5]) end c:px(18, 32, GLASS[6])
for x = 20, 24 do c:px(x, 50, GLASS[3]) end
-- cloth cover (scalloped hem)
local cl = c:rrect(13, 17, 51, 30, 4)
for x = 13, 51, 5 do cl:add(c:ellipse(x + 2, 30, 3, 2.4)) end
cl:cut(c:rect(0, 0, 63, 16))
local cn = X.pillow(cl, 6)
local cv = X.light(cn, { amb = 0.15, wrap = 0.35 })
local cuts = { 0.25, 0.5, 0.75, 0.9 }
local function ti(val) local i = 1 for _, q in ipairs(cuts) do if val > q then i = i + 1 end end return i end
cl:each(function(x, y)
  local code = floor(x / 3) % 2 + floor(y / 3) % 2
  local ramp = code == 0 and CRM or (code == 1 and PNK or RD)
  c:px(x, y, ramp[ti(cv[K(x, y)])]) end)
-- twine tie
for x = 16, 48 do c:px(x, 29, "#e0bf86") c:px(x, 30, "#a2733f") end
G.line(c, { {40, 30}, {43, 35}, {42, 38} }, "#c79a5c")
G.line(c, { {41, 30}, {47, 33}, {48, 37} }, "#a2733f")
c:fillMask(c:ellipse(41, 30, 2, 1.5), "#e0bf86")
-- dribble (quirk)
local dr = HP.mask() dr:add(c:rect(24, 31, 26, 40)) dr:add(c:ellipse(25, 41, 2.6, 2.6))
shade(dr, 2, JAM, { amb = 0.1 })
c:px(24, 34, JAM[6]) c:px(24, 41, JAM[6])
G.fin(c, "strawberry-jam")
