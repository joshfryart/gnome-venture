-- npc-indigo-fennelwick portrait (npc2 P1_15) species: hedgehog
-- Same design as the sprite: chestnut spines, cream face + snout with plum nose, indigo tam + smock, mustard scarf, fennel sprig.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function R(v) return math.floor(v + 0.5) end
local NAME = "npc-indigo-fennelwick"
local SP = { hi = "#b07a4f", base = "#8a5636", shade = "#5e3a48", deep = "#3e2735" }
local TIP = "#ecd4a4"
local FC = { hi = "#f8ecd4", base = "#ead2b0", shade = "#c9a6a0", deep = "#8f6f86" }
local SM = { hi = "#8582d8", base = "#5553a8", shade = "#3b357a", deep = "#2a2556" }
local SCF = { hi = "#f5d36a", base = "#e0a83a", shade = "#b06a3a", deep = "#74404a" }
local ST = { hi = "#b6d86a", base = "#7fae45", shade = "#4d7a48", deep = "#2f4f45" }
local UM = { hi = "#fbe77a", base = "#e9c63e", shade = "#b88c38", deep = "#7a5a3a" }
local NO, NOG = "#4a2a40", "#9a6a8a"
local function spikes(c, m, cx, cy, rx, ry, a0, a1, n, len, w)
  local tips = {}
  for i = 0, n - 1 do
    local a, wa = math.rad(a0 + (a1 - a0) * i / (n - 1)), math.rad(w)
    local p1 = { R(cx + math.cos(a - wa) * rx * 0.85), R(cy + math.sin(a - wa) * ry * 0.85) }
    local p2 = { R(cx + math.cos(a + wa) * rx * 0.85), R(cy + math.sin(a + wa) * ry * 0.85) }
    local t = { R(cx + math.cos(a) * (rx + len)), R(cy + math.sin(a) * (ry + len)) }
    m:add(c:poly{ p1, t, p2 }) tips[#tips + 1] = { t[1], t[2], a }
  end
  return tips
end
local function tipsPaint(c, m, tips)
  for _, t in ipairs(tips) do
    local dx, dy = math.cos(t[3]), math.sin(t[3])
    for k = 2, 4 do local x, y = R(t[1] - dx * k), R(t[2] - dy * k) if m:has(x, y) then c:px(x, y, SP.deep) end end
    for k = 0, 1 do local x, y = R(t[1] - dx * k), R(t[2] - dy * k) if m:has(x, y) then c:px(x, y, TIP) end end
  end
end
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local BGR = { base = "#a7a2e6", shade = "#7d76c8", deep = "#5a52a0" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local body = c:ellipse(39.5, 104, 31, 31):clip(c:rect(0, 68, 79, 99))
c:part(body, SM, { band = 3, pop = { x = 15, y = 86 } })
for y = 76, 99 do if body:has(39, y) then c:px(39, y, SM.shade) end end
for _, y in ipairs{ 80, 88, 96 } do c:px(41, y, SCF.base) c:px(42, y, SCF.base) end
-- scarf
c:part(c:rrect(20, 64, 59, 71, 3), SCF, { band = 2, pop = { x = 23, y = 65 } })
for x = 23, 56, 3 do c:px(x, 68, SCF.shade) end
c:part(c:poly{ { 25, 68 }, { 33, 68 }, { 32, 90 }, { 24, 88 } }, SCF, { band = 1, nopop = true })
for i = 0, 8, 2 do c:px(24 + i, 89, SCF.shade) end
-- head
local hx, hy = 39.5, 44
local mass = c:ellipse(hx, hy, 19, 18)
local ht = spikes(c, mass, hx, hy, 19, 18, 160, 380, 14, 5, 7)
c:part(mass, SP, { band = 3, pop = { x = 26, y = 33 } })
for _, s in ipairs{ {27,36,24,31},{33,33,32,28},{40,32,40,27},{47,33,48,28},{53,37,56,32},{22,44,19,41},{57,44,60,41} } do
  c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1):clip(mass):each(function(x, y) c:px(x, y, SP.hi) end)
end
tipsPaint(c, mass, ht)
for _, x in ipairs{ 22, 57 } do c:part(c:ellipse(x, 41, 3.5, 3.5), FC, { band = 1, nopop = true }) c:fillMask(c:ellipse(x, 41.5, 1.5, 1.5), "#d9909e") end
local face = c:ellipse(39.5, 52, 15.5, 12)
c:part(face, FC, { band = 2, pop = { x = 29, y = 44 } })
c:fillMask(c:poly{ { 32, 40 }, { 47, 40 }, { 39.5, 46 } }:clip(face), SP.base)
c:eyeLocked(29, 46) c:eyeLocked(46, 46)
local sn = c:ellipse(39.5, 58.5, 6.5, 5)
c:part(sn, FC, { band = 1, pop = { x = 36, y = 56 } })
c:fillMask(c:ellipse(39.5, 55.5, 3, 2), NO) c:px(37, 54, NOG) c:px(38, 54, NOG)
for _, q in ipairs{ {39,58},{40,58},{39,59},{40,59},{35,61},{36,62},{37,62},{38,62},{39,61},{40,61},{41,62},{42,62},{43,62},{44,61} } do c:px(q[1], q[2], FC.deep) end
for _, x in ipairs{ 25, 52 } do c:fillMask(c:rect(x, 56, x + 2, 57), "#eaa0a8") c:px(x, 56, "#f6c4c4") end
-- tam
local hat = c:ellipse(35, 25, 15, 4.5) hat:add(c:ellipse(35, 22, 12, 4.5))
c:part(hat, SM, { band = 2, pop = { x = 26, y = 20 } })
for x = 21, 49, 2 do if hat:has(x, 28) then c:px(x, 28, SCF.base) end end
c:part(c:line({ { 35, 17 }, { 37, 13 } }, 2), SM, { band = 1, nopop = true, inner = false })
-- fennel
c:part(c:line({ { 62, 99 }, { 64, 70 }, { 67, 41 } }, 2), ST, { band = 1, nopop = true, inner = false })
for _, f in ipairs{ { 64, 64, 71, 58 }, { 65, 58, 59, 52 }, { 66, 52, 72, 47 }, { 66, 48, 61, 44 } } do
  c:fillMask(c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1), ST.hi)
end
for _, x in ipairs{ 62, 67, 72 } do c:fillMask(c:line({ { 67, 41 }, { x, 38 } }, 1), ST.base) end
c:part(c:ellipse(67, 36, 7, 3), UM, { band = 1, pop = { x = 63, y = 35 } })
for _, q in ipairs{ {62,36},{65,35},{68,35},{71,36},{64,37},{70,37} } do c:px(q[1], q[2], UM.hi) end
c:part(c:ellipse(62, 80, 4, 3.5), FC, { band = 1, pop = { x = 60, y = 78 } })
c:finish{ outline = true }
backdrop(c, BGR)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
