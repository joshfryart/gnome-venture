-- mossy-shell (lean P1b_O4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "mossy-shell" }
local SH = { "#4a3a68", "#7a6a98", "#a898b8", "#d0c4d4", "#ece4e0", "#fffaf0" }
local MS = { "#14401e", "#1e6a2a", "#34943a", "#58bc48", "#8ede5a", "#caf58e" }
local AP = { "#6a1e46", "#a0346a", "#d4588a", "#f48eb0", "#ffc8d8" }
c:groundShadow(32, 52, 22, 3)
local m = c:ellipse(30, 31, 20, 19)
local lip = c:ellipse(43, 42, 11, 9) m:add(lip)
local n = X.pillow(m, 15)
G.toneN(c, m, n, SH, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- whorl grooves: spiral from centre (24,26)
m:each(function(x, y)
  local dx, dy = x - 24, y - 26
  local d = sqrt(dx * dx + dy * dy)
  local a = math.atan(dy, dx)
  local k = (d - a * 1.6) % 6
  if d > 2 and k < 1.2 and not lip:has(x, y) then c:px(x, y, SH[1 + floor(k)]) end
end)
-- aperture: pink opening on lower right
local ap = c:ellipse(44, 43, 8, 6) 
G.toneN(c, ap, X.pillow(ap, 6), AP, { cuts = { 0.2, 0.4, 0.6, 0.8, 0.9 } })
for x = 37, 51 do for y = 36, 50 do if ap:has(x, y) and not ap:copy():shrink(1):has(x, y) then c:px(x, y, SH[5]) end end end
c:px(41, 41, AP[5]) c:px(42, 40, AP[5]) c:px(47, 46, AP[1]) c:px(46, 47, AP[1])
-- moss cap on upper left, ragged
local mo = HP.mask()
m:each(function(x, y)
  local e = 24 + 6 * sin(x * 0.55) + 4 * (X.hash(x, y, 5) - 0.5) * 3
  if y < e - 0.55 * (x - 14) + 8 and x < 44 and y < 34 then mo:set(x, y) end
end)
mo:clip(m)
G.toneN(c, mo, X.pillow(mo, 5), MS, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.12 })
mo:each(function(x, y) if X.hash(x, y, 9) > 0.9 then c:px(x, y, MS[6]) end end)
-- quirk: tiny mushroom sprouting from the moss
for y = 14, 17 do c:px(36, y, "#e8dcc0") end
c:fillMask(c:ellipse(36, 13, 3, 2), "#d03a3a") c:px(35, 12, "#fff0e0") c:px(37, 13, "#fff0e0") c:px(34, 14, "#8a1e2a") c:px(38, 14, "#8a1e2a")
-- spec
c:px(15, 22, SH[6]) c:px(16, 21, SH[6])
G.save(c, "mossy-shell")
