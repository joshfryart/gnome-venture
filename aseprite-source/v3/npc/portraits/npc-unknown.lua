-- npc-unknown portrait (npc2 P1_37) species: moth
-- Same moth stranger: brim shadow over the eyes, feathery antennae, fuzzy ruff, eyespot wing cloak, lantern in frame.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-unknown"
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local FUZZ = { hi = "#f2e6cc", base = "#d4c4a8", shade = "#9a8a9a", deep = "#655a76" }
local HAT = { hi = "#a8785a", base = "#7e5040", shade = "#5a3a4a", deep = "#3e2a3c" }
local WING = { hi = "#a690c2", base = "#76609a", shade = "#53437a", deep = "#3a2d58" }
local GLOW = { hi = "#fff2b0", base = "#ffd468", shade = "#f0a040", deep = "#b8683c" }
local GOLD = P.gold
local DISCR = { base = "#c79bb0", shade = "#a07892", deep = "#7a5a78" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- wing cloak shoulders (tent), eyespots
local cloak = c:poly{ { 6, 99 }, { 14, 76 }, { 30, 72 }, { 49, 72 }, { 65, 76 }, { 73, 99 } }
c:part(cloak, WING, { pop = { x = 16, y = 80 } })
for y = 76, 99 do c:put(39, y, WING.deep) end
for _, x in ipairs{ 23, 56 } do
  c:fillMask(c:ellipse(x, 89, 4, 4), GOLD.base) c:fillMask(c:ellipse(x, 89, 2.5, 2.5), WING.deep)
  c:put(x - 2, 87, GOLD.hi) c:put(x - 1, 86, GOLD.hi) c:put(x, 90, WING.shade)
end
for i = 0, 5 do c:put(18 + i * 2, 81 - (i % 2), WING.hi) c:put(61 - i * 2, 81 - (i % 2), WING.hi) end
-- lantern (lower-left) held by a fuzzy paw
local lan = c:rrect(7, 80, 16, 95, 2)
c:part(lan, GOLD, { nopop = true })
c:fillMask(c:rect(9, 83, 14, 93), GLOW.base)
c:fillMask(c:ellipse(11.5, 89, 1.5, 2.5), GLOW.hi)
c:put(11, 86, GLOW.shade) c:put(12, 85, GLOW.shade) c:put(14, 93, GLOW.shade) c:put(13, 93, GLOW.shade)
c:fillMask(c:rect(8, 78, 15, 79), GOLD.shade)
c:part(c:ellipse(17, 79, 3, 2.5), FUZZ, { nopop = true })
-- feathery antennae (behind hat)
for _, sg in ipairs{ -1, 1 } do
  local m = HP.mask()
  for i = 0, 10 do local t = i / 10
    local x, y = 39.5 + sg * (8 + 16 * t), 40 - 24 * t
    local r = 0.7 + 1.8 * math.sin(math.pi * math.min(1, t * 1.1))
    m:add(c:ellipse(x, y, r, r)) end
  c:part(m, FUZZ, { nopop = true, inner = false })
  for i = 1, 9 do local t = i / 10
    local x, y = math.floor(39.5 + sg * (8 + 16 * t) + .5), math.floor(40 - 24 * t + .5)
    c:put(x, y, FUZZ.deep) if i % 2 == 0 then c:put(x + sg, y + 1, FUZZ.shade) c:put(x - sg, y - 1, FUZZ.shade) end end
end
-- ruff
local ruff = c:ellipse(39.5, 72, 17, 4.5)
for _, x in ipairs{ 24, 29, 34, 39.5, 45, 50, 55 } do ruff:add(c:ellipse(x, 76, 2, 2)) end
c:part(ruff, FUZZ, { pop = { x = 26, y = 70 } })
-- head
local head = c:ellipse(39.5, 56, 20, 15)
for _, q in ipairs{ { 19.5, 59 }, { 20.5, 63 }, { 59.5, 59 }, { 58.5, 63 } } do head:add(c:ellipse(q[1], q[2], 1.5, 1.5)) end
c:part(head, FUZZ, { nopop = true })
head:each(function(x, y) if y >= 48 and y <= 50 then c:put(x, y, (y == 48) and FUZZ.deep or FUZZ.shade) end end)
for _, q in ipairs{ { 24, 60 }, { 27, 64 }, { 52, 64 }, { 55, 60 }, { 33, 66 }, { 46, 66 } } do c:put(q[1], q[2], FUZZ.shade) c:put(q[1], q[2] + 1, FUZZ.shade) end
c:eyeLocked(29, 52) c:eyeLocked(46, 52)
-- fuzzy button nose + curled proboscis
c:part(c:ellipse(39.5, 60, 2.5, 2), FUZZ, { pop = { x = 38, y = 59 } })
for _, q in ipairs{ { 39, 63 }, { 40, 63 }, { 41, 64 }, { 40, 65 }, { 39, 65 }, { 38, 64 } } do c:put(q[1], q[2], HAT.deep) end
c:put(40, 64, HAT.shade)
c:cheek(24, 59) c:cheek(53, 59)
-- hat: very wide brim, squat cone, crooked tip, gold band + bead
local hat = c:ellipse(39.5, 44, 30, 5)
hat:add(c:poly{ { 27, 44 }, { 52, 44 }, { 48, 26 }, { 32, 26 } })
hat:add(c:line({ { 40, 27 }, { 42, 18 }, { 47, 12 }, { 53, 10 } }, 5))
c:part(hat, HAT, { pop = { x = 34, y = 29 } })
local band = c:rect(0, 38, 79, 41):clip(hat):cut(c:ellipse(39.5, 44, 30, 5))
band:add(c:rect(26, 40, 53, 41):clip(c:poly{ { 27, 44 }, { 52, 44 }, { 48, 26 }, { 32, 26 } }))
c:part(band, GOLD, { nopop = true, band = 1 })
for x = 12, 67, 2 do if hat:has(x, 46) then c:put(x, 46, GOLD.base) end end
for _, q in ipairs{ { 44, 18 }, { 45, 17 }, { 49, 13 }, { 50, 13 } } do c:put(q[1], q[2], HAT.deep) end
c:part(c:ellipse(56, 9.5, 2.5, 2.5), GOLD, { pop = { x = 55, y = 8 } })
c:finish{ outline = true }
backdrop(c, DISCR)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
