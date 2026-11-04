-- loach-scale (lean W2_8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="loach-scale" }
local abs, sqrt, atan2, pi = math.abs, math.sqrt, math.atan2 or function(y,x) return math.atan(y,x) end, math.pi
local ICE = { "#5a6c98", "#8498c0", "#aebfdc", "#cbd9ee", "#e4eefa", "#f4faff" }
local OLV = { "#3e3a20", "#665e2c", "#8e8440", "#b4a858", "#d6ca78", "#f0e6a0" }
local tok = { r = { name = "scale" } }
-- fan-shaped scale: wide round front (top), narrow embedded root bottom-left
local sc = HP.mask() sc:add(c:ellipse(32, 29, 17, 20))
local n = X.pillow(sc, 10)
G.toneN(c, sc, n, ICE, { tok = tok })
-- concentric circuli rings (centred low in the scale) + radial grooves from focus
local fx, fy = 30, 40
sc:each(function(x, y)
  local dx, dy = x - fx, y - fy
  local r = sqrt(dx*dx + dy*dy)
  if r % 3.2 < 0.8 and r > 3 and y < 46 then c:put(x, y, (dx + dy < 0) and ICE[5] or ICE[2], tok) end
  local ang = atan2(dy, dx)
  for _, a in ipairs{ -2.35, -1.95, -1.57, -1.2, -0.8 } do
    if abs(ang - a) * r < 0.55 and r > 5 and r < 24 then c:put(x, y, ICE[1], tok) end
  end
end)
-- olive-gold skin patch where the scale was seated (lower-right), with pores
local patch = HP.mask() patch:add(c:ellipse(40, 46, 11, 8)) patch:clip(sc:copy():grow(0))
local pm = c:ellipse(33, 40, 17, 20) pm = HP.mask() pm:add(c:ellipse(32, 29, 17, 20))
patch:each(function(x, y) if (x - 40)*0.7 + (y - 46) > 2 then end end)
local seat = HP.mask()
sc:each(function(x, y) if (x - 32) * 0.6 + (y - 29) * 0.8 > 15 and (x - 32) > -6 then seat:set(x, y) end end)
G.toneN(c, seat, X.pillow(seat, 6), OLV, { tok = tok })
for _, p in ipairs{ {37,47},{41,44},{44,48},{39,51},{43,52} } do if seat:has(p[1], p[2]) then c:put(p[1], p[2], OLV[1], tok) end end
-- spec glint + quirk: a tiny pink-blue iridescent streak
c:put(23, 17, "#fff6f2", tok) c:put(24, 17, "#fff6f2", tok) c:put(23, 18, "#fff6f2", tok)
for i = 0, 8 do c:put(34 + i // 2, 13 + i, (i % 2 == 0) and "#f4b4e0" or "#a0e0f0", tok) end
G.save(c, "loach-scale")
