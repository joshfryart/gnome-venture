-- npc-ivy-brambleby portrait (npc2 P1_15) species: grasshopper
-- Same design as the sprite: lime grasshopper, long muzzle with nostrils, side eye domes, ivy-leaf cap, plum vest, blackberry basket.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function R(v) return math.floor(v + 0.5) end
local NAME = "npc-ivy-brambleby"
local GR = { hi = "#c7e06e", base = "#8cc04a", shade = "#5a8a4a", deep = "#35574a" }
local PL = { hi = "#f0f2b0", base = "#d6e08a", shade = "#9fb46a", deep = "#5a8a4a" }
local VE = { hi = "#b8689a", base = "#8a3f6e", shade = "#612b5a", deep = "#3f1f45" }
local BK = { hi = "#e8b870", base = "#c48a48", shade = "#8f5a3a", deep = "#5a3838" }
local BE = { hi = "#8a6ab0", base = "#4f3a7a", shade = "#33264f", deep = "#33264f" }
local IV = { hi = "#7fc06a", base = "#3f8a4f", shade = "#2a6048", deep = "#1f3f3a" }
local BG = "#d9c8ee"
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local BGR = { base = "#f2c25a", shade = "#d89a3a", deep = "#a86a34" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local body = c:ellipse(39.5, 106, 30, 30):clip(c:rect(0, 70, 79, 99))
c:part(body, VE, { band = 3, pop = { x = 16, y = 88 } })
c:part(c:rect(33, 62, 46, 74), GR, { band = 1, nopop = true })
local bel = c:poly{ { 31, 71 }, { 48, 71 }, { 39.5, 95 } }:clip(body)
c:part(bel, PL, { band = 1, nopop = true })
for _, y in ipairs{ 75, 79, 83, 87 } do for x = 30, 49 do if bel:has(x, y) then c:px(x, y, PL.shade) end end end
for _, y in ipairs{ 80, 88 } do c:px(30, y, BK.hi) c:px(49, y, BK.hi) end
-- basket of blackberries, lower left
c:part(c:line({ { 8, 86 }, { 17, 73 }, { 26, 86 } }, 2), BK, { band = 1, nopop = true, inner = false })
for _, q in ipairs{ {10,84},{15,83},{20,83},{25,84},{12,87},{18,86},{23,87} } do
  c:part(c:ellipse(q[1], q[2], 2.5, 2.5), BE, { band = 1, nopop = true, inner = false })
  c:px(q[1] - 1, q[2] - 1, BE.hi)
end
local bk = c:rrect(5, 87, 29, 99, 3)
c:part(bk, BK, { band = 2, pop = { x = 7, y = 88 } })
for _, y in ipairs{ 90, 93, 96 } do for x = 6, 28 do if (x + y) % 3 == 0 and bk:has(x, y) then c:px(x, y, BK.shade) end end end
c:part(c:ellipse(24, 80, 3.5, 3), GR, { band = 1, pop = { x = 23, y = 79 } })
-- antennae
c:fillMask(c:line({ { 34, 28 }, { 27, 15 }, { 18, 5 } }, 1), GR.shade)
c:fillMask(c:line({ { 45, 28 }, { 52, 15 }, { 61, 5 } }, 1), GR.shade)
-- head
local head = c:ellipse(39.5, 41, 18, 14) head:add(c:ellipse(39.5, 55, 12, 10))
c:part(head, GR, { band = 3, pop = { x = 28, y = 33 } })
for _, ex in ipairs{ 23, 56 } do c:part(c:ellipse(ex, 43, 6, 7), GR, { band = 2, nopop = true }) end
c:part(c:ellipse(39.5, 59, 8.5, 5.5), PL, { band = 1, pop = { x = 34, y = 56 } })
for _, q in ipairs{ {35,55},{36,55},{43,55},{44,55} } do c:px(q[1], q[2], GR.deep) end
for _, q in ipairs{ {33,60},{34,61},{35,61},{36,61},{37,61},{38,61},{39,61},{40,61},{41,61},{42,61},{43,61},{44,61},{45,61},{46,60} } do c:px(q[1], q[2], INK) end
c:px(39, 62, PL.shade) c:px(40, 62, PL.shade) c:px(39, 63, PL.shade) c:px(40, 63, PL.shade)
c:eyeLocked(21, 41) c:eyeLocked(54, 41)
for _, x in ipairs{ 27, 50 } do c:fillMask(c:rect(x, 51, x + 2, 52), "#eaa0a8") c:px(x, 51, "#f6c4c4") end
-- ivy-leaf cap
local leaf = c:ellipse(39.5, 27, 7, 5.5) leaf:add(c:ellipse(31.5, 30, 5, 4)) leaf:add(c:ellipse(47.5, 30, 5, 4))
leaf:add(c:poly{ { 35, 24 }, { 44, 24 }, { 39.5, 15 } })
c:part(leaf, IV, { band = 2, pop = { x = 34, y = 22 } })
c:fillMask(c:line({ { 39, 17 }, { 39, 32 } }, 1), IV.hi)
c:fillMask(c:line({ { 39, 27 }, { 32, 30 } }, 1), IV.hi) c:fillMask(c:line({ { 40, 27 }, { 47, 30 } }, 1), IV.hi)
c:finish{ outline = true }
backdrop(c, BGR)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
