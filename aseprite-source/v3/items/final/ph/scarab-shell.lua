-- scarab-shell (lean E2_06)
local NAME = "scarab-shell"
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
local GREEN = { "#0e3a2a", "#145a3a", "#1f8250", "#34a868", "#62cc88", "#a8eeb0" }
local TEAL = { "#0e3a4e", "#165a72", "#1f80a0", "#38a8c8", "#6acce4", "#b0f0f6" }
local BLUE = { "#1a1e5a", "#2a3a96", "#3e5ec8", "#5e86e8", "#92b0f8", "#d0e0ff" }
local GOLD = { "#6a4210", "#a06c18", "#d09a24", "#f0c444", "#ffe27c" }
c:groundShadow(32, 58, 17, 3)
local body = c:ellipse(32, 36, 17, 21)
local bn = X.pillow(body, 10)
local lv = X.light(bn, { amb = 0.08, wrap = 0.25 })
local function zone(fn, ramp, name) local m = sel(body, fn)
  X.tone(c, m, lv, ramp, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = { r = { name = name } } }) end
zone(function(x, y) return y < 33 end, GREEN, "g")
zone(function(x, y) return y >= 33 and y < 43 + ((x % 3 == 0) and 1 or 0) end, TEAL, "t")
zone(function(x, y) return y >= 43 + ((x % 3 == 0) and 1 or 0) end, BLUE, "b")
-- seam + striae
local sm = { r = { name = "seam" } }
for y = 20, 57 do c:put(32, y, GREEN[1], sm); if body:has(33, y) then c:put(33, y, GREEN[2], sm) end end
for _, x in ipairs{ 25, 39 } do for y = 26, 52 do if body:has(x, y) and y % 4 ~= 0 then c:put(x, y, (x < 32) and TEAL[2] or BLUE[2], sm) end end end
-- gold rim on the shell edge
body:edge():each(function(x, y) if y > 24 and (x < 20 or x > 44 or y > 52) and (x + y) % 2 == 0 then c:put(x, y, GOLD[3], { r = { name = "gold" } }) end end)
-- pronotum (head shield) with ridge and horns
local pro = c:ellipse(32, 14, 12, 6)
local pn, _, pt = paint(pro, GREEN, 5, "pro")
for x = 24, 40 do c:put(x, 12, GREEN[2], pt) end
local hd = c:poly{ { 26, 10 }, { 28, 4 }, { 31, 8 }, { 33, 8 }, { 36, 4 }, { 38, 10 } }
paint(hd, GOLD, 3, "horn")
c:put(32, 9, GOLD[1], { r = { name = "horn" } })
-- glints
local gt = { r = { name = "glint" } }
for _, p in ipairs{ {23,30},{24,29},{23,31},{24,38} } do c:put(p[1], p[2], "#f4fff0", gt) end
-- quirk: a small chip taken out of the shell edge, bare gold-brown beneath
for _, p in ipairs{ {47,44},{48,45},{47,45},{46,46},{47,46} } do c:put(p[1], p[2], GOLD[2], gt) end
c:put(46, 45, GOLD[4], gt)
G.save(c, NAME)
