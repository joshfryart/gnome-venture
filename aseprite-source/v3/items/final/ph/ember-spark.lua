-- ember-spark (lean P1pilot)
local NAME = "ember-spark"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = { r = { name = nm } } if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local COAL = { "#120d16", "#241a2c", "#3a2c42", "#54425a", "#725c72", "#968096" }
local HOT = { "#8c1a10", "#d03a12", "#f2701a", "#ffb02a", "#ffe066", "#fffbd0" }
c:groundShadow(32, 56, 17, 3)
-- angular faceted coal chunk
local ch = c:poly{ {14,50},{12,38},{19,29},{29,26},{39,28},{48,34},{52,44},{46,53},{30,56},{20,55} }
local n = X.pillow(ch, 10)
G.toneN(c, ch, n, COAL, { tok = { r = { name = "coal" } }, cuts = {0.2,0.4,0.58,0.76,0.9}, amb = 0.06, wrap = 0.15 })
-- hard facet planes: lit top-left face, dark lower-right
ch:each(function(x, y) local f = (x - 32) * 0.7 + (y - 40) * 0.5
  if f > 6 then c:put(x, y, COAL[1], { r = { name = "coal" } }) end
  if (x - 14) + (y - 29) * 1.2 < 12 and (x + y) % 2 == 0 and y < 38 then c:put(x, y, COAL[5], { r = { name = "coal" } }) end end)
-- glowing cracks (jagged, white-hot cores)
local cr = { { {30,28},{29,33},{33,36},{31,42},{35,46},{33,53} }, { {33,36},{40,35},{46,40} }, { {31,42},{23,43},{19,48} }, { {35,46},{43,48} } }
for _, p in ipairs(cr) do
  local m = c:line(p, 1)
  m:each(function(x, y) c:put(x, y, HOT[3], { r = { name = "crack" } }) end)
  m:shrink(0)
  for i = 1, #p do c:put(p[i][1], p[i][2], HOT[5], { r = { name = "crack" } }) end
  m:grow(1):cut(m):clip(ch):each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, HOT[1], { r = { name = "glow" } }) end end)
end
c:put(33,36,HOT[6]) c:put(31,42,HOT[6]) c:put(35,46,HOT[6])
-- flame tongue licking up from the top crack (quirk)
local fl = c:poly{ {28,28},{27,22},{30,16},{29,11},{33,17},{34,12},{37,20},{36,27} }
local fn = X.pillow(fl, 5)
G.toneN(c, fl, fn, { HOT[1], HOT[2], HOT[3], HOT[4], HOT[5], HOT[6] }, { tok = { r = { name = "flame" } }, cuts = {0.15,0.3,0.5,0.7,0.88}, amb = 0.2, wrap = 0.1, bias = nil })
-- flying sparks
for _, p in ipairs{ {18,16},{45,14},{50,24},{12,26},{40,6},{22,8} } do c:put(p[1], p[2], HOT[5], { r = { name = "sp" } }) end
c:sparkle(46, 12) 
c:put(18,17,HOT[3]) c:put(50,25,HOT[3])
G.save(c, NAME)
