-- reindeer-lichen (lean E2_06)
local NAME = "reindeer-lichen"
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
local ROCK = { "#2e2833", "#4a4150", "#6a5f68", "#8a7d80", "#aa9d96", "#c8bbae" }
local MOSS = { "#1f3a2c", "#2f5a38", "#437a42", "#5e9a4c", "#86b960", "#b3d680" }
local LICH = { "#4a6a62", "#6c8f80", "#93b39c", "#b6d0b4", "#d4e6cc", "#f0f7e2" }
c:groundShadow(32, 56, 22, 3)
local rock = c:ellipse(32, 52, 19, 6)
paint(rock, ROCK, 6, "rock")
local mt = sel(rock, function(x, y) return y < 50 + 2 * sin(x * 0.9) end)
paint(mt, MOSS, 3, "moss")
local m = HP.mask(); local tips = {}
local function br(x, y, a, l, w, d)
  local x2, y2 = x + cos(a) * l, y + sin(a) * l
  m:add(c:line({ { R(x), R(y) }, { R((x + x2) / 2 - sin(a)), R((y + y2) / 2 + cos(a)) }, { R(x2), R(y2) } }, w))
  if d == 0 then tips[#tips + 1] = { R(x2), R(y2) } return end
  br(x2, y2, a - 0.55, l * 0.7, max(2, w - 1), d - 1)
  br(x2, y2, a + 0.55, l * 0.7, max(2, w - 1), d - 1)
  if d == 2 then br(x2, y2, a + 0.05, l * 0.7, max(2, w - 1), d - 1) end
end
br(24, 49, -1.85, 8, 4, 3); br(32, 50, -1.57, 10, 4, 3); br(40, 49, -1.3, 8, 4, 3)
local n, idx, tok = paint(m, LICH, 3, "lichen", { amb = 0.15, wrap = 0.35 })
-- dark gaps / deep fork shadow
m:each(function(x, y) if idx[K(x, y)] == 1 and X.hash(x, y, 4) > 0.5 then c:put(x, y, LICH[1], tok) end end)
-- quirk: red-capped tips (little soldiers)
table.sort(tips, function(a, b) return a[2] < b[2] end)
for i = 1, 4 do local t = tips[i]
  if t then local rt = { r = { name = "cap" .. i } }
    c:put(t[1], t[2] - 1, "#c8322e", rt); c:put(t[1] + 1, t[2] - 1, "#e8584a", rt); c:put(t[1], t[2] - 2, "#e8584a", rt); c:put(t[1] + 1, t[2] - 2, "#ff9a78", rt) end end
G.save(c, NAME)
