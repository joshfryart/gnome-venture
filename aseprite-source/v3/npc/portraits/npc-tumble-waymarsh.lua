-- npc-tumble-waymarsh portrait (npc2 P1_37) species: hare
-- Same hare as the sprite: tan fur, orange coat, striped green scarf, brass monocle on a chain; buck teeth.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-tumble-waymarsh"
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local FUR = { hi = "#e8c08a", base = "#c48a52", shade = "#8e5a5a", deep = "#5a3a4e" }
local MUZ = { hi = "#f6ead2", base = "#eedcb8", shade = "#c9b0a6", deep = "#8f7a86" }
local EAR = { hi = "#f6b8c4", base = "#e48ea6", shade = "#b46a8a", deep = "#7e4a6e" }
local COAT = { hi = "#f6c45a", base = "#e8962c", shade = "#b0603c", deep = "#6e3a48" }
local SCARF = { hi = "#a6d46a", base = "#5fa040", shade = "#3c6e48", deep = "#284a46" }
local BRASS = { hi = "#fff0a0", base = "#e8b838", shade = "#a8743a", deep = "#6e4a3a" }
local GLASS = { hi = "#eef6f0", base = "#bfe0e6", shade = "#8eb4c8", deep = "#6a86a8" }
local DISCR = { base = "#9cc47a", shade = "#6e9a62", deep = "#4c6e56" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- coat shoulders bleed off the bottom
local body = c:ellipse(39.5, 108, 36, 30):clip(c:rect(0, 76, 79, 99))
c:part(body, COAT, { pop = { x = 14, y = 86 } })
for y = 80, 99 do c:put(44, y, COAT.deep) end
for _, y in ipairs{ 86, 94 } do c:put(46, y, BRASS.base) c:put(47, y, BRASS.base) c:put(46, y + 1, BRASS.shade) c:put(47, y + 1, BRASS.deep) end
-- ears
local function ear(pts, w, r) local m = c:line(pts, w) m:add(c:ellipse(pts[#pts][1], pts[#pts][2], r, r)) return m end
local lp, rp = { { 31, 42 }, { 28, 24 }, { 27, 9 } }, { { 48, 42 }, { 51, 24 }, { 53, 9 } }
local eL, eR = ear(lp, 9, 4.5), ear(rp, 9, 4.5)
c:part(eL, FUR, { pop = { x = 25, y = 8 } }) c:part(eR, FUR, { nopop = true })
for _, q in ipairs{ { lp, eL }, { rp, eR } } do
  local inn = c:line(q[1], 4):clip(q[2]:shrink(2)):clip(c:rect(0, 0, 79, 38))
  c:part(inn, EAR, { nopop = true, band = 1 })
end
-- scarf
c:part(c:rrect(22, 69, 57, 77, 3), SCARF, { pop = { x = 26, y = 71 } })
local tail = c:poly{ { 45, 75 }, { 53, 75 }, { 55, 97 }, { 46, 96 } }
c:part(tail, SCARF, { nopop = true })
for x = 44, 56 do for _, y in ipairs{ 81, 82, 88, 89 } do if tail:has(x, y) then c:put(x, y, SCARF.hi) end end end
for x = 46, 55, 2 do if tail:has(x, 96) then c:put(x, 97, SCARF.shade) end end
-- head
local head = c:ellipse(39.5, 53, 20, 16)
for _, q in ipairs{ { 19.5, 57 }, { 20.5, 62 }, { 59.5, 57 }, { 58.5, 62 } } do head:add(c:ellipse(q[1], q[2], 2, 2)) end
c:part(head, FUR, { pop = { x = 28, y = 40 } })
c:part(c:ellipse(39.5, 62, 8, 5.5), MUZ, { nopop = true })
-- nose (pink wedge) + split lip + buck teeth
for x = 37, 42 do c:put(x, 57, EAR.base) end
for x = 38, 41 do c:put(x, 58, EAR.base) end
c:put(39, 59, EAR.shade) c:put(40, 59, EAR.shade) c:put(37, 57, EAR.hi) c:put(38, 57, EAR.hi) c:put(42, 57, EAR.shade)
c:put(39, 60, P.ink) c:put(40, 60, P.ink)
for _, q in ipairs{ { 36, 62 }, { 37, 62 }, { 38, 61 }, { 41, 61 }, { 42, 62 }, { 43, 62 } } do c:put(q[1], q[2], P.ink) end
for y = 62, 64 do c:put(38, y, MUZ.hi) c:put(39, y, MUZ.hi) c:put(40, y, MUZ.base) c:put(41, y, MUZ.base) end
c:put(37, 63, P.ink) c:put(37, 64, P.ink) c:put(42, 63, P.ink) c:put(42, 64, P.ink)
for x = 38, 41 do c:put(x, 65, P.ink) end
c:put(39, 62, MUZ.shade) c:put(40, 62, MUZ.shade)
-- eyes, monocle glass behind right eye
c:fillMask(c:ellipse(49.5, 49.5, 4.5, 4.5), GLASS.base)
c:put(46, 46, GLASS.hi) c:put(47, 46, GLASS.hi) c:put(52, 53, GLASS.shade) c:put(53, 52, GLASS.shade)
c:eyeLocked(28, 47) c:eyeLocked(47, 47)
local ring = c:ellipse(49.5, 49.5, 5.5, 5.5):cut(c:ellipse(49.5, 49.5, 4.5, 4.5))
ring:each(function(x, y) c:put(x, y, (x < 49 and y < 49) and BRASS.hi or ((x > 50 and y > 50) and BRASS.shade or BRASS.base)) end)
for i, q in ipairs{ { 55, 54 }, { 56, 55 }, { 57, 57 }, { 58, 59 }, { 58, 61 }, { 58, 63 }, { 57, 65 }, { 56, 67 }, { 55, 68 } } do
  c:put(q[1], q[2], i % 2 == 0 and BRASS.shade or BRASS.base) end
c:cheek(24, 58)
-- brows: kindly tufts
c:put(28, 44, FUR.deep) c:put(29, 43, FUR.deep) c:put(30, 43, FUR.deep) c:put(49, 43, FUR.deep) c:put(50, 43, FUR.deep) c:put(51, 44, FUR.deep)
c:finish{ outline = true }
backdrop(c, DISCR)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
