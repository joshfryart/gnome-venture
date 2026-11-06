-- rosemary (lean E2_06)
local NAME = "rosemary"
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
local NEED = { "#1a3a2c", "#265a3c", "#347a44", "#4d9a4e", "#79b95e", "#aad87a" }
local WOOD = { "#3a2418", "#5e3c26", "#8a5c3a", "#b0804e", "#d2a468", "#ecc88a" }
local FLOW = { "#4a4a9a", "#6a78c8", "#90a4ec", "#b8caf8" }
c:groundShadow(32, 57, 18, 2)
local sprigs = { { { 30, 55 }, { 24, 40 }, { 18, 26 }, { 14, 10 } }, { { 32, 55 }, { 32, 38 }, { 33, 22 }, { 32, 7 } }, { { 34, 55 }, { 40, 40 }, { 46, 26 }, { 50, 11 } } }
local twig = HP.mask(); local nl = HP.mask()
local function bez(p, t) local u = 1 - t
  return u*u*u*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t*t*t*p[4][1], u*u*u*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t*t*t*p[4][2] end
local needles = {}
for si, p in ipairs(sprigs) do
  twig:add(c:line({ { R(p[1][1]), R(p[1][2]) }, { R(p[2][1]), R(p[2][2]) }, { R(p[3][1]), R(p[3][2]) } }, 2))
  for i = 0, 20 do
    local t = 0.18 + i * 0.04
    local x, y = bez(p, t); local x2, y2 = bez(p, t + 0.03)
    local a = math.atan(y2 - y, x2 - x)
    local L = 6.5 - 3 * (t - 0.18)
    for sd = -1, 1, 2 do
      local aa = a + sd * 0.95
      local ex, ey = x + cos(aa) * L, y + sin(aa) * L
      nl:add(c:line({ { R(x), R(y) }, { R(ex), R(ey) } }, 1))
      needles[#needles + 1] = { R(x), R(y), R(ex), R(ey), sd }
    end
  end
end
-- needles base (darker), then lit tops
nl:each(function(x, y) c:put(x, y, NEED[3], { r = { name = "needle" } }) end)
local nt = { r = { name = "needle" } }
for _, nd in ipairs(needles) do
  local ln = c:line({ { nd[1], nd[2] }, { nd[3], nd[4] } }, 1)
  ln:each(function(x, y) local f = (nd[5] < 0) and 0 or 1
    c:put(x, y, (y + x) % 5 == 0 and NEED[2] or (nd[5] < 0 and NEED[4] or NEED[3]), nt) end)
  c:put(nd[3], nd[4], nd[5] < 0 and NEED[6] or NEED[5], nt)
end
local wn, widx, wt = paint(twig, WOOD, 2, "wood", { wrap = 0.3 })
-- flowers (pale blue) along the sprigs
local fl = { { 17, 20 }, { 21, 30 }, { 29, 22 }, { 36, 17 }, { 43, 24 }, { 47, 14 }, { 33, 9 }, { 15, 14 } }
for i, f in ipairs(fl) do local ft = { r = { name = "fl" .. i } }
  c:put(f[1], f[2], FLOW[2], ft); c:put(f[1] + 1, f[2], FLOW[3], ft); c:put(f[1], f[2] - 1, FLOW[3], ft); c:put(f[1] + 1, f[2] - 1, FLOW[4], ft); c:put(f[1] - 1, f[2], FLOW[1], ft) end
-- quirk: tied with a little twine bow at the base
local tw = { r = { name = "twine" } }
for y = 49, 51 do for x = 28, 36 do c:put(x, y, ((x + y) % 2 == 0) and "#e4c070" or "#b28444", tw) end end
for _, p in ipairs{ {33,52},{32,53},{31,54},{35,52},{36,53},{37,54} } do c:put(p[1], p[2], "#e4c070", tw) end
c:put(34, 51, "#8a5a30", tw)
G.save(c, NAME)
