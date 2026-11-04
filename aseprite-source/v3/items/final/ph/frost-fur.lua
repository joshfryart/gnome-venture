-- frost-fur (lean W2_4)
-- Hanging tuft of icy fur: curved locks fanning down from a twine-tied knot, icicle tips, hook loop on top.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local function shade(c, m, R, r, amb, bias) local n = X.pillow(m, r) local v = X.light(n, { amb = amb or 0.1, wrap = 0.25 }) G.tone(c, m, v, R, CUTS, bias) return v, n end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "frost-fur" }
local FU = { "#566a98", "#7e93bd", "#a7bbd8", "#cfdcec", "#ebf2f8", "#fcffff" }
local TW = { "#4a3320", "#6e4a2c", "#97693b", "#c4955a" }
local IC = { "#6fb4d8", "#a6dcf0", "#e0f7ff" }
local locks = {
  { {32,22},{22,28},{16,40},{15,50} }, { {32,22},{26,32},{23,44},{24,55} },
  { {32,22},{32,34},{32,46},{32,58} }, { {32,22},{38,32},{41,44},{40,53} },
  { {32,22},{42,28},{48,40},{49,49} } }
local order = { 1, 5, 2, 4, 3 }
for _, i in ipairs(order) do
  local m, n = G.tube(locks[i], function(t) return 3.2 * sin(min(1, 0.25 + t) * pi * 0.5) * (1 - t * 0.85) + 0.6 end)
  local v = X.light(n, { amb = 0.12, wrap = 0.3 })
  G.tone(c, m, v, FU, CUTS)
  -- fur strands
  m:each(function(x, y) if (x + y * 2) % 5 == 0 and X.hash(x, y, 3) > 0.4 then c:put(x, y, FU[2]) end end)
end
-- icicle tips
for _, p in ipairs{ {15,51},{24,56},{32,59},{40,54},{49,50} } do c:put(p[1], p[2], IC[2]) c:put(p[1], p[2] + 1, IC[1]) c:put(p[1], p[2] - 1, IC[3]) end
c:put(32, 60, IC[1])
-- twine knot and hook loop
local knot = c:rrect(27, 18, 37, 25, 2)
shade(c, knot, TW, 4, 0.1)
for x = 28, 36, 2 do c:put(x, 20, TW[1]) c:put(x + 1, 22, TW[1]) end
G.line(c, { {30,18},{29,13},{31,9},{34,9},{36,13},{35,18} }, TW[3])
c:put(30, 11, TW[4]) c:put(31, 9, TW[4])
-- frost sparkle quirk
c:sparkle(21, 33) c:put(20, 45, FU[6]) c:put(36, 38, FU[6])
G.fin(c, "frost-fur")
