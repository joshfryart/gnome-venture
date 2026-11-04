-- Auntie Mossbead villager sprite: 64x96, feet baseline y=90, single standing pose, basket-cat quirk.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local function cp(r) return { hi = r.hi, base = r.base, shade = r.shade, deep = r.deep } end
local function form(c, m, r, o)
  o = o or {}
  r = type(r) == "string" and P[r] or r
  c:part(m, r, { noshade = true, nopop = true, inner = o.inner })
  local rows = {}
  m:each(function(x, y) local t = rows[y]
    if not t then rows[y] = { x, x } else t[1] = math.min(t[1], x) t[2] = math.max(t[2], x) end end)
  local frac, off = o.frac or 0.3, o.off or 2
  local list = {}
  m:each(function(x, y)
    if c:get(x, y) ~= r.base:lower() then return end
    local t = rows[y]
    local s = (x - t[1] + 0.5) / (t[2] - t[1] + 1) > 1 - frac
    if not m:has(x + off, y + off) then s = true end
    if s then list[#list + 1] = { x, y } end
  end)
  for _, p in ipairs(list) do c:put(p[1], p[2], r.shade, r) end
  if o.pop then c:put(o.pop[1], o.pop[2], r.hi, r) c:put(o.pop[1] + 1, o.pop[2], r.hi, r) end
  return m
end
local function under(c, m, hex, x0, x1)
  m:each(function(x, y) if not m:has(x, y + 1) and (not x0 or (x >= x0 and x <= x1)) then c:put(x, y, hex) end end)
end

local c = HP.canvas{ w = 64, h = 96, name = "auntie" }
local CAT = { hi = "#d8d6e0", base = "#aaa9b8", shade = "#74758c", deep = "#444663" }
c:groundShadow(32, 89, 15, 3.5)
-- boots
for _, x in ipairs({ 27, 37 }) do
  local m = c:ellipse(x, 88, 4, 2.5)
  form(c, m, cp(P.wood), { frac = 0.35, off = 1 })
  under(c, m, P.wood.deep)
end
-- dress: bell skirt, gold apron panel
local dress = c:poly{ { 23, 52 }, { 41, 52 }, { 48, 80 }, { 16, 80 } }
dress:add(c:ellipse(32, 81, 16.5, 5))
form(c, dress, "ember", { frac = 0.3, off = 2 })
under(c, dress, P.ember.deep)
local ap = c:poly{ { 27, 56 }, { 37, 56 }, { 40, 82 }, { 24, 82 } }
form(c, ap, "gold", { frac = 0.3, off = 1 })
for x = 25, 39, 3 do c:put(x, 82, P.ember.deep) end
-- left arm (viewer's left) hanging, mitten hand
local la = c:poly{ { 18, 53 }, { 23, 53 }, { 23, 66 }, { 18, 66 } }
form(c, la, cp(P.ember), { frac = 0.4, off = 1 })
form(c, c:ellipse(20.5, 68, 2.5, 2), cp(P.skinC), { off = 1, frac = 0.35 })
-- shawl collar of moss beads
form(c, c:rrect(20, 49, 44, 55, 3), "moss", { frac = 0.3, off = 1 })
for x = 22, 42, 4 do c:put(x, 54, P.gold.base) end
-- basket on right arm with cat
local arm = c:poly{ { 41, 53 }, { 46, 55 }, { 48, 66 }, { 44, 67 } }
form(c, arm, cp(P.ember), { frac = 0.5, off = 1 })
local cat = c:ellipse(49, 66, 4.5, 4.5)
cat:add(c:poly{ { 45, 64 }, { 46, 59 }, { 49, 63 } }) cat:add(c:poly{ { 53, 64 }, { 52, 59 }, { 49, 63 } })
form(c, cat, cp(CAT), { frac = 0.3, off = 1 })
c:put(47, 66, P.stone.deep) c:put(51, 66, P.stone.deep) c:put(49, 68, P.petal.base)
c:put(46, 61, P.petal.base) c:put(52, 61, P.petal.base)
local bk = c:rrect(42, 69, 57, 80, 3)
form(c, bk, "wood", { frac = 0.3, off = 1 })
for x = 44, 56, 3 do c:line({ { x, 70 }, { x, 79 } }, 1):each(function(px, py) c:put(px, py, P.wood.shade) end) end
for y = 72, 78, 3 do for x = 43, 56 do if (x + y) % 2 == 0 then c:put(x, y, P.wood.hi) end end end
form(c, c:ellipse(44, 68, 2, 2), cp(P.skinC), { off = 1, frac = 0.35 })
-- face + ears
form(c, c:ellipse(32, 43, 12.5, 8), "skinC", { frac = 0.25, off = 1 })
form(c, c:ellipse(19.5, 43, 2, 3), cp(P.skinC), { off = 1, frac = 0.2 })
form(c, c:ellipse(44.5, 43, 2, 3), cp(P.skinC), { off = 1, frac = 0.6 })
c:put(19, 46, P.gold.base) c:put(45, 46, P.gold.base)
local nose = c:ellipse(32.5, 43.5, 2, 1.5)
form(c, nose, cp(P.skinC), { off = 1, frac = 0.4, inner = false })
c:eyeSmall(26, 39) c:eyeSmall(37, 39)
c:cheek(23, 44) c:cheek(41, 44)
for x = 29, 35 do c:put(x, 47, P.skinC.deep) end
c:put(28, 46, P.skinC.deep) c:put(36, 46, P.skinC.deep)
-- hat: wrapped turban dome with brim roll and pom
local hm = c:ellipse(32, 29, 15, 11)
hm:add(c:ellipse(32, 36, 16.5, 3.5))
form(c, hm, "sea", { frac = 0.36, off = 2, pop = { 25, 22 } })
under(c, hm, P.sea.deep, 18, 46)
for _, q in ipairs({ { 22, 27 }, { 27, 22 }, { 33, 20 } }) do
  c:line({ { q[1], q[2] + 7 }, { q[1] + 7, q[2] + 1 }, { q[1] + 12, q[2] + 2 } }, 1):each(function(px, py) if hm:has(px, py) then c:put(px, py, P.sea.shade) end end)
end
local pom = c:ellipse(32, 15, 3, 3)
form(c, pom, "gold", { frac = 0.3, off = 1 })
c:line({ { 32, 17 }, { 32, 19 } }, 1):each(function(px, py) c:put(px, py, P.sea.deep) end)
-- bead band along the brim
for x = 18, 46, 3 do
  local y = math.floor(36 + 3.5 * math.sqrt(math.max(0, 1 - ((x - 32) / 16.5) ^ 2)) - 0.5)
  c:put(x, y, P.moss.hi)
end
c:finish{ outline = true }
HP.assertClean(c)
local s = HP.sheet{ cellw = 64, cellh = 96, frames = { c }, tags = { { name = "stand", from = 1, to = 1 } } }
s:save{ aseprite = out .. "npc-auntie-mossbead.aseprite", png = out .. "npc-auntie-mossbead.png", scale = 1 }
