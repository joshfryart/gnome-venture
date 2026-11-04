-- npc-captain-pipi-shellback (sprite N0_0)
-- Captain Pipi Shellback: turtle; wide domed shell flaring past the shoulders; captain cap; navy coat; brass spyglass (prop).
local NAME = "npc-captain-pipi-shellback"
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

local NAVY = { hi = "#6f8fd0", base = "#3d5aa8", shade = "#2c3f80", deep = "#1f2a55" }
local SHELL = { hi = "#c99a58", base = "#9a6a3a", shade = "#6e4a2c", deep = "#45301f" }
c:groundShadow(32, 89.5, 16, 2.5)
-- shell behind the body: wide dome (species silhouette), gold rim, scute seams
local sh = c:ellipse(32, 66, 18, 16)
form(sh, SHELL, { frac = 0.3, off = 2, pop = { { 20, 56 }, { 21, 55 }, { 22, 54 } } })
local rim = sh:copy():cut(sh:shrink(2))
rim:each(function(x, y) c:put(x, y, (y > 70) and P.gold.shade or P.gold.base) end)
for _, l in ipairs({ { { 18, 62 }, { 24, 64 } }, { { 17, 72 }, { 24, 72 } }, { { 46, 62 }, { 40, 64 } }, { { 47, 72 }, { 40, 72 } }, { { 24, 52 }, { 26, 57 } }, { { 40, 52 }, { 38, 57 } } }) do
  c:line(l, 1):each(function(x, y) if sh:has(x, y) and not rim:has(x, y) then c:put(x, y, SHELL.deep) end end)
end
-- stubby flipper feet
form(c:ellipse(26, 87.5, 4, 2), P.moss, { off = 1 }) form(c:ellipse(38, 87.5, 4, 2), P.moss, { off = 1, frac = 0.5 })
-- navy coat: short barrel, cream lapels, two gold buttons
local coat = c:rrect(23, 56, 41, 85, 5)
form(coat, NAVY, { frac = 0.3, off = 2, pop = { { 25, 59 }, { 25, 60 } } })
local lap = c:poly{ { 27, 56 }, { 37, 56 }, { 32, 65 } }
form(lap, { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }, { off = 1, frac = 0.4 })
for y = 57, 64 do c:put(32, y, NAVY.deep) end
for _, y in ipairs({ 69, 76 }) do c:button(29, y) c:button(35, y) c:put(28, y - 1, P.gold.hi) c:put(34, y - 1, P.gold.hi) end
for x = 24, 40 do c:put(x, 84, NAVY.deep) end
-- sleeves + green flipper hands
form(c:ellipse(21, 64, 3.5, 6), NAVY, { frac = 0.3, off = 1 })
form(c:ellipse(43, 64, 3.5, 6), NAVY, { frac = 0.6, off = 1 })
c:hem(69, 18, 24) c:hem(69, 40, 46)
form(c:ellipse(21, 71.5, 2.5, 2), P.moss, { off = 1 })
-- brass spyglass held up in the right flipper (prop)
local sg = c:line({ { 44, 72 }, { 53, 56 } }, 3)
form(sg, P.gold, { frac = 0.4, off = 1, pop = { { 50, 59 }, { 51, 58 } } })
local lens = c:ellipse(53.5, 55, 2.5, 2.5)
form(lens, NAVY, { off = 1, pop = { { 53, 54 } } })
for _, q in ipairs({ { 47, 66 }, { 48, 66 }, { 49, 64 }, { 50, 64 } }) do c:put(q[1], q[2], P.gold.deep) end
form(c:ellipse(44, 71.5, 2.5, 2), P.moss, { off = 1, frac = 0.5 })
-- neck + wide turtle head, beak-line grin, high-set eyes
form(c:rect(28, 50, 36, 56), P.moss, { off = 1, frac = 0.4 })
for x = 29, 35, 3 do c:put(x, 53, P.moss.shade) end
local hd = c:ellipse(32, 44, 12, 8)
form(hd, P.moss, { frac = 0.28, off = 2, pop = { { 25, 40 }, { 26, 40 } } })
for _, q in ipairs({ { 23, 44 }, { 40, 46 }, { 29, 49 } }) do c:put(q[1], q[2], P.moss.hi) end
eye(24, 40) eye(37, 40)
for x = 26, 38 do c:put(x, 47 + ((x == 26 or x == 38) and -1 or 0), P.moss.deep) end
for x = 29, 35 do c:put(x, 48, P.ember.base) end
c:put(31, 45, P.moss.deep) c:put(33, 45, P.moss.deep)
-- captain cap: big white crown seen from above, navy band, gold badge, dark visor
local cr = c:ellipse(32, 31, 15, 7)
cr:add(c:rect(19, 31, 45, 35))
form(cr, { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }, { frac = 0.3, off = 2, pop = { { 24, 27 }, { 25, 26 }, { 26, 26 } } })
form(c:rect(19, 35, 45, 37), NAVY, { off = 1, frac = 0.3, inner = false })
c:stitch{ { 20, 35 }, { 44, 35 } }
local vz = c:ellipse(32, 38.5, 11, 2)
form(vz, { hi = NAVY.shade, base = NAVY.deep, shade = P.dusk.deep, deep = P.ink }, { off = 1, frac = 0.4 })
local bd = c:ellipse(32, 31, 2.5, 2)
form(bd, P.gold, { off = 1, pop = { { 31, 30 } } })
save()
