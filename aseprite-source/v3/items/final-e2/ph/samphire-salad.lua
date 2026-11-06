-- samphire-salad (lean E2_06)
local NAME = "samphire-salad"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function R(v) return floor(v + 0.5) end
local function paint(m, ramp, rad, name, opt) opt = opt or {}
  local n = X.pillow(m, rad or 4); local tok = { r = { name = name } }
  local idx = X.tone(c, m, X.light(n, { amb = opt.amb or 0.08, wrap = opt.wrap or 0.25 }), ramp, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  return n, idx, tok end
local function sel(m, fn) local o = HP.mask() m:each(function(x, y) if fn(x, y) then o:set(x, y) end end) return o end
local function spec(m, n, col, tok) local x, y = G.specAt(m, n, 30) if x then c:put(x, y, col, tok) end end
local BOWL = { "#3a4a6a", "#56709a", "#7a9ac4", "#a2bede", "#cddcf0", "#f0f6fc" }
local SAM = { "#1c4a2a", "#2a6e38", "#3e9244", "#5cb450", "#88d068", "#bcea8c" }
local LEM = { "#c8860c", "#e8aa14", "#f8cc2c", "#fce458", "#fff2a0" }
local PITH = { "#e8d890", "#f6ecb0", "#fffadc" }
c:groundShadow(32, 58, 22, 3)
local bowl = sel(c:ellipse(32, 42, 23, 16), function(x, y) return y >= 41 end)
local bn, bidx, bt = paint(bowl, BOWL, 8, "bowl")
c:rect(9, 40, 55, 42):each(function(x, y) c:put(x, y, y == 40 and BOWL[6] or (y == 41 and BOWL[5] or BOWL[3]), bt) end)
for x = 14, 50 do c:put(x, 49, BOWL[2], bt) end
c:rect(22, 55, 42, 57):each(function(x, y) c:put(x, y, BOWL[2], bt) end)
-- samphire strands fanning out of the bowl
local strands = {
  { { 28, 42 }, { 20, 34 }, { 12, 24 }, { 10, 12 } }, { { 30, 42 }, { 26, 32 }, { 22, 20 }, { 22, 8 } },
  { { 32, 42 }, { 32, 30 }, { 31, 18 }, { 32, 6 } }, { { 34, 42 }, { 38, 30 }, { 42, 18 }, { 43, 8 } },
  { { 36, 42 }, { 44, 34 }, { 52, 26 }, { 54, 14 } }, { { 33, 42 }, { 28, 36 }, { 18, 34 }, { 10, 34 } },
}
local order = { 1, 5, 2, 4, 3, 6 }
for k, si in ipairs(order) do
  local m, n, T = G.tube(strands[si], function(t) return 2.3 - 1.0 * t end)
  local tok = { r = { name = "sam" .. si } }
  G.toneN(c, m, n, SAM, { tok = tok, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, amb = 0.1, wrap = 0.3 })
  -- jointed segments: dark nodes + tiny scale-leaf nubs
  m:each(function(x, y) local t = T[K(x, y)]
    local seg = floor(t * 24)
    if t * 24 - seg < 0.14 and t > 0.08 and t < 0.94 then c:put(x, y, SAM[1], tok) end end)
  m:each(function(x, y) local t = T[K(x, y)] if t > 0.9 then c:put(x, y, SAM[6], tok) end end)
end
-- lemon wedge on the rim (front, quirk: perched with a tiny bite of zest curl)
local lem = c:poly{ { 38, 38 }, { 56, 34 }, { 60, 40 }, { 52, 47 }, { 42, 46 } }
local ln, _, lt = paint(lem, LEM, 5, "lemon")
local pith = c:line({ { 41, 40 }, { 49, 38 }, { 57, 36 } }, 1)
pith:each(function(x, y) c:put(x, y, PITH[2], lt) end)
for _, p in ipairs{ {44,41},{48,42},{52,41},{46,44},{51,44} } do c:put(p[1], p[2], LEM[5], lt) end
for _, p in ipairs{ {42,38},{43,38},{44,38} } do c:put(p[1], p[2], PITH[3], lt) end
c:put(41, 38, PITH[2], lt)
G.save(c, NAME)
