-- npc-pip-burrowell portrait (npc2 P1_29) species: field mouse
-- 80x100 head+shoulders: grey field mouse, huge round ears, crooked floppy brown cone hat, ochre vest, buck teeth, spade over the shoulder.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pip-burrowell"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FUR = { hi = "#cfc3c6", base = "#a0939c", shade = "#71667e", deep = "#4a3f5c" }
local BEL = { hi = "#f4e6d4", base = "#e2cdb8", shade = "#b8a0a0", deep = "#7e6a80" }
local PNK = { hi = "#f9c6d2", base = "#ec98b2", shade = "#c46c96", deep = "#8a4a78" }
local HAT = { hi = "#b98656", base = "#8e5a3a", shade = "#653d36", deep = "#452a35" }
local VST = { hi = "#f2d06c", base = "#d49c3c", shade = "#a26535", deep = "#6b3e3c" }
local WOD = { hi = "#e9c38a", base = "#c4925a", shade = "#8f6046", deep = "#5c3b3e" }
local MET = { hi = "#e4ecee", base = "#a6b6c6", shade = "#6e7c9a", deep = "#46496c" }
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
-- spade over the right shoulder (behind)
c:part(c:line({ { 54, 99 }, { 66, 60 } }, 3), WOD, { band = 1, nopop = true })
local blade = oval(68.5, 50, 5, 8, 15)
c:part(blade, MET, { band = 2, pop = { x = 66, y = 45 } })
c:fillMask(c:line({ { 68, 44 }, { 67, 55 } }, 1):clip(blade:shrink(1)), MET.shade)
-- body: ochre vest, cream belly V, buttons
local body = c:ellipse(39.5, 106, 30, 30):clip(c:rect(0, 72, 79, 99))
c:part(body, VST, { band = 3, pop = { x = 16, y = 85 } })
c:part(c:poly{ { 32, 72 }, { 47, 72 }, { 39.5, 88 } }, BEL, { band = 1, nopop = true })
for _, y in ipairs{ 90, 96 } do c:part(c:rect(38, y, 40, y + 1), HAT, { band = 1, nopop = true }) end
-- ears
for i, ex in ipairs{ 17, 62 } do
  c:part(c:ellipse(ex, 41, 10, 10), FUR, { band = 2, nopop = true })
  c:part(c:ellipse(ex, 42, 6, 6), PNK, { band = 2, pop = (i == 1) and { x = 14, y = 38 } or nil, nopop = (i ~= 1) })
end
-- head
c:part(c:ellipse(39.5, 54, 19.5, 16), FUR, { band = 3, pop = { x = 25, y = 47 } })
for _, q in ipairs{ {21,60},{23,64},{58,60},{56,64} } do c:put(q[1], q[2], FUR.shade) end
-- pointed snout + pink nose tip + buck teeth
c:part(c:ellipse(39.5, 62.5, 8.5, 6), BEL, { band = 2, pop = { x = 34, y = 59 } })
c:part(c:ellipse(39.5, 60.5, 3, 2.2), PNK, { band = 1, nopop = true })
c:put(38, 59, PNK.hi)
for _, q in ipairs{ {39,63},{40,63},{37,64},{38,65},{41,65},{42,64} } do c:put(q[1], q[2], FUR.deep) end
c:part(c:rect(39, 65, 40, 67), { hi = "#fbf3e2", base = "#f4e6d4", shade = "#cfc0b8", deep = "#9a8a98" }, { band = 1, nopop = true })
c:eyeLocked(29, 49) c:eyeLocked(46, 49)
for _, cx in ipairs{ 23, 54 } do for dx = 0, 2 do c:put(cx + dx, 58, PNK.base) end end
-- crooked cone hat with flopped tip and a pom
local hm = c:ellipse(39.5, 40, 21, 5)
hm:add(c:poly{ { 25, 40 }, { 54, 40 }, { 44, 13 }, { 37, 13 } })
hm:add(c:line({ { 40, 15 }, { 35, 8 }, { 27, 7 } }, 4))
c:part(hm, HAT, { band = 3, pop = { x = 33, y = 24 } })
for x = 20, 60 do if hm:has(x, 37) and hm:has(x, 35) then c:put(x, 36, VST.shade) c:put(x, 37, (x % 3 == 0) and VST.hi or VST.base) end end
for y = 25, 29 do for x = 41, 45 do if hm:has(x, y) then c:put(x, y, HAT.shade) end end end
for _, q in ipairs{ {41,25},{45,25},{41,29},{45,29} } do c:put(q[1], q[2], VST.base) end
c:part(c:ellipse(25, 8, 2.5, 2.5), VST, { band = 1, pop = { x = 24, y = 7 } })
c:finish{ outline = true }
for _, w in ipairs{ { {30,62},{20,60} }, { {30,64},{20,66} }, { {49,62},{59,60} }, { {49,64},{59,66} } } do
  c:fillMask(c:line(w, 1), FUR.deep)
end
backdrop({ base = "#e8c690", shade = "#cf9f6a", deep = "#a0704f" })
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
