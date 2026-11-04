-- tamarind-drink (lean W2_33)
-- Slim tapered tumbler of dark tamarind juice: pale glass tint, cream foam line, one ice cube, striped straw,
-- and a bumpy tamarind pod propped on the rim (quirk: pod end cracked open showing orange pulp).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tamarind-drink" }
local floor, abs, sin, max, min, sqrt = math.floor, math.abs, math.sin, math.max, math.min, math.sqrt
local function cl(v) return max(0, min(1, v)) end
local BROWN = { "#2a130f", "#4a2216", "#6e3418", "#97501f", "#c07a32", "#e3a655" }
local GLASS = { "#7a93b0", "#a3bcd0", "#c9dfe6", "#e4f2f0", "#f4fbf6", "#fffaf0" }
local POD   = { "#3a2218", "#5a3826", "#7e5236", "#a2754a", "#c79b68", "#e2bf8c" }
local PULP  = { "#7a2e12", "#a8481a", "#d06c26", "#ee9440" }
local CX, Y0, Y1 = 30, 22, 54
local function hw(y) return 10.5 - (y - Y0) / (Y1 - Y0) * 2.5 end
c:groundShadow(31, 57, 14, 2)
local glass, liq = HP.mask(), HP.mask()
for y = Y0, Y1 do local h = hw(y)
  for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do glass:set(x, y) end end
local top = 29
for y = top, Y1 - 3 do local h = hw(y) - 1.5
  for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do if not (y == top and (x * 3) % 5 == 0) then liq:set(x, y) end end end
-- glass body
local gv = {}
glass:each(function(x, y) local u = (x - (CX - hw(y))) / (2 * hw(y)); gv[K(x, y)] = cl(0.92 - u * 0.95) end)
G.tone(c, glass, gv, GLASS, { 0.2, 0.38, 0.55, 0.7, 0.88 })
-- liquid
local lv = {}
liq:each(function(x, y) local u = (x - (CX - hw(y))) / (2 * hw(y)); lv[K(x, y)] = cl(0.8 - u * 0.95 - (y - top) * 0.012 + (X.hash(x, y, 3) - 0.5) * 0.08) end)
G.tone(c, liq, lv, BROWN, { 0.18, 0.36, 0.54, 0.72, 0.88 })
-- foam line
for x = floor(CX - hw(top) + 1.5), floor(CX + hw(top) - 1.5) do
  c:px(x, top - 1, "#f4e6c8") if (x * 7) % 4 ~= 0 then c:px(x, top, "#e8cf9f") end end
c:px(CX - 7, top - 2, "#fff4de") c:px(CX - 6, top - 2, "#f4e6c8")
-- glass base (thick) and rim
for x = CX - 6, CX + 6 do c:px(x, Y1 - 2, GLASS[4]) c:px(x, Y1 - 1, GLASS[2]) end
c:px(CX + 6, Y1 - 2, GLASS[2]) c:px(CX + 5, Y1 - 1, GLASS[1])
for x = floor(CX - hw(Y0) + 0.5), floor(CX + hw(Y0) - 0.5) do c:px(x, Y0, GLASS[6]) end
c:px(CX + 9, Y0, GLASS[3])
-- left edge highlight streak + right shade edge
for y = Y0 + 2, Y1 - 5 do c:px(floor(CX - hw(y) + 1), y, GLASS[6]) end
for y = top + 2, Y1 - 4 do c:px(floor(CX + hw(y) - 1.5), y, BROWN[1]) end
-- ice cube
local ice = c:rrect(33, top - 1, 38, top + 4, 1)
G.tone(c, ice, (function() local v = {} ice:each(function(x, y) v[K(x, y)] = cl(0.95 - (x - 33) * 0.1 - (y - top) * 0.06) end) return v end)(),
  { "#6a8fb0", "#8fb4cc", "#b7d6e2", "#d8eef2", "#eefafa", "#fffaf0" }, { 0.2, 0.38, 0.55, 0.7, 0.88 })
-- condensation drip
c:px(CX - 7, 40, GLASS[6]) c:px(CX - 7, 41, GLASS[6]) c:px(CX - 7, 42, GLASS[4])
-- straw: red/white stripes, from in the drink up past the rim
local sx0, sy0, sx1, sy1 = 33, 42, 46, 6
local sl = sqrt((sx1 - sx0)^2 + (sy1 - sy0)^2)
local ux, uy = (sx1 - sx0) / sl, (sy1 - sy0) / sl
c:line({ { sx0, sy0 }, { sx1, sy1 } }, 2):each(function(x, y)
  local a = (x - sx0) * ux + (y - sy0) * uy
  local red = floor(a / 3.2) % 2 == 0
  local right = ((x - sx0) * -uy + (y - sy0) * ux) > 0
  if red then c:px(x, y, right and "#a8232e" or "#e24650") else c:px(x, y, right and "#c9bfc2" or "#fbf3f0") end
end)
c:px(sx1, sy1, "#fbf3f0")
-- tamarind pod propped on the rim: bumpy bean
local pm, pn, pT, pS = G.tube({ { 10, 10 }, { 14, 15 }, { 20, 21 }, { 27, 26 } },
  function(t) return 2.5 + 0.8 * sin(t * 20) - 0.6 * t end)
G.tone(c, pm, X.light(pn, { amb = 0.15, wrap = 0.3 }), POD, { 0.2, 0.38, 0.55, 0.7, 0.88 })
pm:each(function(x, y) local k = K(x, y)
  if pT[k] < 0.14 then c:px(x, y, PULP[(x + y) % 3 + 1]) end
  if abs(pS[k]) < 0.15 and pT[k] > 0.2 and pT[k] < 0.93 then c:px(x, y, POD[2]) end end)
c:px(13, 11, POD[6]) c:px(14, 12, POD[6])
G.fin(c, "tamarind-drink")
