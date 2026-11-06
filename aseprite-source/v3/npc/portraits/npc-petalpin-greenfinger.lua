-- npc-petalpin-greenfinger portrait (npc2 P1_29) species: bear cub
-- 80x100 head+shoulders: honey bear cub, puffy pink beret with a big flower pin, green apron, holds a tin watering can.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-petalpin-greenfinger"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FUR = { hi = "#f2c27a", base = "#d8954a", shade = "#a8623a", deep = "#6e3a45" }
local CRM = { hi = "#fbefd2", base = "#f0d7a8", shade = "#cfa77e", deep = "#9a6e6e" }
local BER = { hi = "#f79ac0", base = "#e0559a", shade = "#ab3480", deep = "#6e2263" }
local EAR = { hi = "#f7b6c8", base = "#e98aa6", shade = "#c0607f", deep = "#8a3f66" }
local APR = { hi = "#a8d672", base = "#6aa84f", shade = "#3f7a4a", deep = "#284d45" }
local SHI = { hi = "#7fc4e0", base = "#3f8fc0", shade = "#2e5f96", deep = "#283f6e" }
local TIN = { hi = "#e6eef0", base = "#a9bccb", shade = "#6f7f9c", deep = "#454a6e" }
local NOS = { hi = "#e98aa0", base = "#b9506e", shade = "#7e3456", deep = "#56243f" }
local PET = { hi = "#fbe9a0", base = "#f6d35a", shade = "#e0a33a", deep = "#a8623a" }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function pts(list, hex) for _, p in ipairs(list) do c:put(p[1], p[2], hex) end end
-- body: blue shirt shoulders + green apron bib
local body = c:ellipse(39.5, 106, 31, 31):clip(c:rect(0, 70, 79, 99))
c:part(body, SHI, { band = 3, pop = { x = 15, y = 84 } })
c:part(c:line({ { 30, 79 }, { 27, 71 } }, 3), APR, { band = 1, nopop = true })
c:part(c:line({ { 49, 79 }, { 52, 71 } }, 3), APR, { band = 1, nopop = true })
local bib = c:rrect(28, 78, 51, 99, 3)
c:part(bib, APR, { band = 2, nopop = true })
c:part(c:rrect(33, 87, 46, 95, 2), APR, { band = 1, nopop = true })
c:stitch{ { 34, 88 }, { 45, 88 } }
-- trowel tip peeking from the pocket
c:part(c:poly{ { 42, 82 }, { 45, 82 }, { 44, 87 }, { 43, 87 } }, TIN, { band = 1, nopop = true })
-- ears behind
for _, ex in ipairs{ 21, 58 } do
  c:part(c:ellipse(ex, 33, 7, 7), FUR, { band = 2, nopop = true })
  c:part(c:ellipse(ex, 33.5, 3.5, 3.5), EAR, { band = 1, nopop = true })
end
-- head
c:part(c:ellipse(39.5, 50, 20, 17), FUR, { band = 3, pop = { x = 25, y = 44 } })
for _, q in ipairs{ {22,58},{24,62},{56,58},{54,62},{30,65},{49,65} } do c:put(q[1], q[2], FUR.shade) end
c:part(c:ellipse(39.5, 58.5, 9.5, 7), CRM, { band = 2, pop = { x = 33, y = 54 } })
-- nose: wide bear button, glint
c:part(c:ellipse(39.5, 54.5, 3.5, 2.5), NOS, { band = 1, nopop = true })
c:put(37, 53, NOS.hi) c:put(38, 53, NOS.hi)
for _, q in ipairs{ {39,57},{40,57},{39,58},{40,58},{36,59},{37,60},{38,60},{41,60},{42,60},{43,59} } do c:put(q[1], q[2], FUR.deep) end
c:put(39, 61, EAR.base) c:put(40, 61, EAR.base)
c:eyeLocked(29, 45) c:eyeLocked(46, 45)
for _, cx in ipairs{ 24, 53 } do for dx = 0, 2 do for dy = 0, 1 do c:put(cx + dx, 54 + dy, EAR.base) end end c:put(cx, 54, EAR.hi) end
-- beret: puffy, tilted, stalk nub, ribbed band
c:part(c:ellipse(41.5, 24, 2, 2.5), BER, { band = 1, nopop = true })
local bm = c:ellipse(41, 33, 20.5, 7.5)
c:part(bm, BER, { band = 3, pop = { x = 28, y = 29 } })
for x = 20, 62 do for y = 38, 40 do if bm:has(x, y) and not bm:has(x, y + 2) then c:put(x, y, BER.shade) end end end
for x = 22, 60, 3 do if bm:has(x, 37) then c:put(x, 37, BER.hi) end end
-- flower pin
for i = 0, 4 do
  local a = math.rad(-90 + i * 72)
  c:part(c:ellipse(55 + math.cos(a) * 3, 32 + math.sin(a) * 3, 2, 2), PET, { band = 1, nopop = true })
end
c:part(c:ellipse(55, 32, 1.5, 1.5), { hi = "#f6a35a", base = "#e8792f", shade = "#b8503a", deep = "#7e3446" }, { band = 1, nopop = true })
c:put(52, 28, PET.hi) c:put(54, 31, "#f6a35a")
-- watering can held at the lower right
c:part(c:line({ { 66, 86 }, { 73, 76 } }, 2), TIN, { band = 1, nopop = true })
c:part(c:ellipse(74.5, 74.5, 2, 2), TIN, { band = 1, pop = { x = 73, y = 73 } })
c:part(c:line({ { 56, 81 }, { 61, 75 }, { 66, 81 } }, 2), TIN, { band = 1, nopop = true })
c:part(c:rrect(54, 80, 67, 96, 3), TIN, { band = 2, pop = { x = 56, y = 83 } })
for x = 55, 66 do c:put(x, 85, TIN.shade) c:put(x, 92, TIN.shade) end
c:part(c:ellipse(55, 88, 4, 3.5), FUR, { band = 1, nopop = true })
c:finish{ outline = true }
backdrop({ base = "#b7dc8f", shade = "#8cbf6e", deep = "#5f9558" })
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
