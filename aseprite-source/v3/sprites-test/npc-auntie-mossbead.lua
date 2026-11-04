-- npc-auntie-mossbead (sprite N0_0)
-- Auntie Mossbead: towering moss head-wrap with a lopsided bun knot + gold beads; kente bell dress; woven bowl with a cat peeking (quirk).
local NAME = "npc-auntie-mossbead"
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/sprites-test/"
local c = HP.canvas{ w = 64, h = 96, name = NAME }
local function form(m, r, o)
  o = o or {}
  c:part(m, r, { noshade = true, nopop = true, inner = o.inner })
  local rows = {}
  m:each(function(x, y) local t = rows[y]
    if not t then rows[y] = { x, x } else t[1] = math.min(t[1], x) t[2] = math.max(t[2], x) end end)
  local frac, off, list = o.frac or 0.3, o.off or 2, {}
  m:each(function(x, y)
    if c:get(x, y) ~= r.base:lower() then return end
    local t = rows[y]
    if (x - t[1] + 0.5) / (t[2] - t[1] + 1) > 1 - frac or not m:has(x + off, y + off) then list[#list + 1] = { x, y } end
  end)
  for _, p in ipairs(list) do c:put(p[1], p[2], r.shade, r) end
  if o.pop then for _, q in ipairs(o.pop) do c:put(q[1], q[2], r.hi, r) end end
  m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, r.deep, r) end end)
  return m
end
local function eye(x, y)
  for _, q in ipairs({ {1,0},{2,0},{0,1},{3,1},{0,2},{3,2},{1,3},{2,3},{1,1} }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function save()
  c:finish{ outline = true }
  HP.assertClean(c)
  c:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite" }
  print(NAME .. " ok")
end

local SKIN = { hi = "#a8664a", base = "#7a4632", shade = "#573024", deep = "#3a1f1e" }
c:groundShadow(32, 89.5, 13, 2.5)
-- sandals
form(c:ellipse(27, 88, 3, 1.5), P.wood, { off = 1 }) form(c:ellipse(37, 88, 3, 1.5), P.wood, { off = 1 })
-- bell dress with kente bands
local dr = c:poly{ { 24, 51 }, { 40, 51 }, { 47, 85 }, { 17, 85 } }
dr:add(c:ellipse(32, 85, 15, 2.5))
form(dr, P.gold, { frac = 0.33, off = 2, pop = { { 25, 54 }, { 24, 57 } } })
for _, y in ipairs({ 74, 81 }) do for x = 15, 49 do
  if dr:has(x, y) and dr:has(x, y + 1) then
    local k = x % 6
    if k < 2 then c:put(x, y, P.ember.base) elseif k < 4 then c:put(x, y, P.moss.shade) end
    c:put(x, y + 1, P.gold.deep)
  end end end
-- puffy sleeves
form(c:ellipse(20, 59, 3.5, 5), P.gold, { frac = 0.3, off = 1 })
form(c:ellipse(44, 59, 3.5, 5), P.gold, { frac = 0.6, off = 1 })
-- woven bowl (prop) held at the waist, seen from above
local bowl = c:ellipse(32, 66, 10, 5)
form(bowl, P.wood, { frac = 0.3, off = 2 })
for x = 23, 41 do for y = 64, 70 do if bowl:has(x, y) and (x + y) % 3 == 0 then c:put(x, y, P.wood.shade) end end end
local inside = c:ellipse(32, 63, 8, 2)
c:fillMask(inside, P.wood.deep)
-- cat peeking out (quirk)
local cat = c:ellipse(32, 61, 4, 2.5)
cat:add(c:poly{ { 28, 61 }, { 29, 57 }, { 31, 60 } }) cat:add(c:poly{ { 33, 60 }, { 35, 57 }, { 36, 61 } })
form(cat, P.stone, { frac = 0.3, off = 1, pop = { { 29, 59 } } })
c:put(30, 61, P.ink) c:put(34, 61, P.ink) c:put(32, 62, P.petal.base)
-- hands gripping bowl rim
form(c:ellipse(22, 65, 2.5, 2), SKIN, { off = 1 }) form(c:ellipse(42, 65, 2.5, 2), SKIN, { off = 1, frac = 0.5 })
-- neck + bead collar
form(c:rect(29, 48, 35, 52), SKIN, { off = 1 })
for x = 25, 39, 2 do c:put(x, 52 + ((x == 25 or x == 39) and 0 or 1), (x // 2) % 2 == 0 and P.moss.base or P.gold.hi) end
-- face + ears with gold drops
form(c:ellipse(21.5, 42, 2, 2.5), SKIN, { off = 1 }) form(c:ellipse(42.5, 42, 2, 2.5), SKIN, { off = 1, frac = 0.6 })
c:put(21, 45, P.gold.base) c:put(43, 45, P.gold.base)
form(c:ellipse(32, 41, 10, 8), SKIN, { frac = 0.28, off = 2, pop = { { 26, 37 }, { 27, 37 } } })
eye(25, 39) eye(36, 39)
for x = 30, 34 do c:put(x, 46, P.ember.shade) end c:put(29, 45, P.ember.shade) c:put(35, 45, P.ember.shade)
c:put(32, 43, SKIN.shade) c:put(33, 43, SKIN.shade)
c:cheek(24, 44) c:cheek(38, 44)
-- head wrap: wide band, tall dome, bun knot leaning right (silhouette)
local wr = c:ellipse(32, 33, 14, 4)
wr:add(c:ellipse(31, 25, 12, 9))
wr:add(c:ellipse(40, 13, 6, 6))
form(wr, P.moss, { frac = 0.34, off = 2, pop = { { 24, 20 }, { 25, 19 }, { 26, 19 }, { 36, 10 }, { 37, 9 } } })
-- folds
for _, q in ipairs({ { 27, 27 }, { 28, 26 }, { 29, 25 }, { 33, 28 }, { 34, 27 }, { 35, 26 }, { 37, 17 }, { 38, 16 }, { 42, 15 } }) do c:put(q[1], q[2], P.moss.deep) end
for x = 19, 45 do if wr:has(x, 34) then c:put(x, 34, P.moss.shade) end end
-- gold beads sprinkled on the wrap
for _, q in ipairs({ { 23, 30 }, { 28, 22 }, { 33, 19 }, { 38, 23 }, { 41, 30 }, { 30, 31 }, { 36, 31 }, { 25, 25 }, { 43, 11 }, { 39, 14 } }) do c:put(q[1], q[2], P.gold.hi) end
save()
