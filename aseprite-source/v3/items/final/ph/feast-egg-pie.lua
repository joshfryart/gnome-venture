-- feast-egg-pie (lean W2_2)
-- Lattice-topped egg pie in a tin, one wedge cut out showing custard and a boiled-egg slice.
-- quirk: an egg-shaped steam vent in the middle of the crust.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "feast-egg-pie"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local CRUST = { "#6e3412", "#98521c", "#c27a2c", "#e0a043", "#f2c46a", "#fde39a" }
local CUST = { "#b07a14", "#d9a52a", "#f0c545", "#f9dc6a", "#fdeea0", "#fff4c0" }
local TIN = { "#4a5470", "#6f7b9a", "#97a3bd", "#bfc9dc", "#e0e7f2", "#f4f8ff" }
local EGGW = { "#9aa0b8", "#c4c8d8", "#e6e6ee", "#f6f4f2", "#fffaf0", "#fffdf6" }
local YOLK = { "#c0561a", "#e68a1e", "#f7b32a", "#ffd04a", "#ffe68a", "#fff2b8" }
local CUTS = { 0.22, 0.4, 0.58, 0.74, 0.88 }

c:groundShadow(32, 52, 25, 3)
local T = G.oval(32, 30, 23, 9, 0, 3)
local side = HP.mask() side:add(c:rect(9, 35, 55, 43)) side:add(c:ellipse(32, 43, 23, 8))
local band = T:shift(0, 5):add(T)
local W = c:poly{ { 32, 30 }, { 59, 22 }, { 59, 58 }, { 41, 58 } }
local function cylN(m, cx, rx)
  local n = {}
  m:each(function(x, y) local nx = max(-0.95, min(0.95, (x - cx) / rx)) n[K(x, y)] = { G.norm(nx, 0.3, sqrt(1 - nx * nx)) } end)
  return n
end
-- tin outer wall
local tinm = side:copy():cut(T:shift(0, 5))
G.toneN(c, tinm, cylN(tinm, 32, 23), TIN, { cuts = CUTS })
tinm:each(function(x, y) if (x % 5 == 0) and y > 44 and y < 49 then c:px(x, y, TIN[2]) end end)
-- tin rim lip
local lip = HP.mask()
for x = 9, 55 do local nx = (x - 32) / 23.5 local y = 35 + floor(8.5 * (1 - sqrt(max(0, 1 - nx * nx))) * 0 ) lip:set(x, 43) end
-- crust side band
local cb = band:copy():cut(T):cut(W)
G.toneN(c, cb, cylN(cb, 32, 23), CRUST, { cuts = CUTS })
-- notch interior: back wall (custard) + floor (tin)
local foot = HP.mask() foot:add(T):add(band):add(side)
local notch = W:copy():clip(foot)
local back = c:poly{ { 32, 30 }, { 59, 22 }, { 59, 31 }, { 32, 39 } }:clip(notch)
local floorm = notch:copy():cut(back):clip(c:rect(0, 0, 63, 42)):cut(T)
-- floor only where not the front tin wall
floorm = notch:copy():cut(back):clip(c:rect(0, 0, 63, 41))
local fv = {} floorm:each(function(x, y) fv[K(x, y)] = 0.35 + 0.012 * (x - 32) * -1 + 0.01 * (y - 36) end)
X.tone(c, floorm, fv, TIN, { cuts = CUTS })
local bv = {} back:each(function(x, y) bv[K(x, y)] = 0.82 - 0.012 * (x - 32) - 0.02 * (y - (30 - (x - 32) * 0.3)) end)
local bidx = X.tone(c, back, bv, CUST, { cuts = CUTS })
-- crust layer on the top of the cut face
back:each(function(x, y)
  local ty = 30 - (x - 32) * (8 / 27)
  if y <= ty + 1.2 then c:px(x, y, CRUST[5]) elseif y <= ty + 2.4 then c:px(x, y, CRUST[3]) end
end)
-- egg slice on cut face
local em, en = G.oval(43, 33, 5, 2.7, -0.28, 1)
G.toneN(c, em, en, EGGW, {})
local ym, yn = G.oval(43, 33, 2.4, 1.4, -0.28, 1)
G.toneN(c, ym, yn, YOLK, {})
c:px(42, 32, YOLK[6])
for _, p in ipairs{ { 36, 35 }, { 50, 28 }, { 47, 31 } } do c:px(p[1], p[2], "#6aa44a") end
-- top crust
local top = T:copy():cut(W)
local tn = X.pillow(T, 8)
local tv = X.light(tn, { amb = 0.15, wrap = 0.3 })
local idx = X.tone(c, top, tv, CRUST, { cuts = CUTS })
local ring = top:copy():cut(top:copy():shrink(2))
top:each(function(x, y)
  local k = K(x, y)
  local i = idx[k] or 3
  local a, b = (x + y) % 7, (x - y) % 7
  if ring:has(x, y) then
    c:px(x, y, CRUST[(x % 3 == 0) and max(1, i - 1) or min(6, i + 1)])
  elseif a < 2 or b < 2 then
    c:px(x, y, CRUST[min(6, i + 1)])
  elseif a == 2 or b == 2 then
    c:px(x, y, CRUST[max(1, i - 1)])
  elseif a == 4 and b == 4 then
    c:px(x, y, CUST[3])
  end
end)
-- egg vent
local vm, vn = G.oval(31, 29, 3, 2.1, 0, 1)
vm:clip(top)
vm:each(function(x, y) c:px(x, y, CRUST[1]) end)
c:px(30, 29, YOLK[3]) c:px(31, 29, YOLK[4]) c:px(30, 28, EGGW[5])
-- spec
c:px(21, 25, CRUST[6]) c:px(22, 25, CRUST[6]) c:px(20, 26, CRUST[6])
G.save(c, NAME)
