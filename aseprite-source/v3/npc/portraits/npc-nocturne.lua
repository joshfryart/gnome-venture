-- npc-nocturne portrait (npc2 P1_24) species: fruit bat
-- Same design as the sprite: plum fur, tall pink-lined ears, tan pug muzzle + fang, folded plum wing-cloak,
-- orange knit scarf with hanging tail. Prop: wooden flute in paw. Night-blue backdrop.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-nocturne"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local R = {
  fur   = { hi = "#a3829a", base = "#765a74", shade = "#523e5c", deep = "#382a44" },
  muz   = { hi = "#f6d2a6", base = "#dca282", shade = "#ab7072", deep = "#764c5c" },
  mem   = { hi = "#cf94b0", base = "#a0628c", shade = "#70426e", deep = "#4a2d52" },
  scarf = { hi = "#ffc674", base = "#f28c3c", shade = "#c25a30", deep = "#883c36" },
  wood  = { hi = "#ecbb7a", base = "#bb8452", shade = "#8b5739", deep = "#5c3b31" },
  ear   = { hi = "#f4b4bc", base = "#d9838f", shade = "#a45a78", deep = "#6e3e5c" },
  bg    = { base = "#7486c8", shade = "#5565a6", deep = "#3c4884" },
}
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function mir(t) local o = {} for i, q in ipairs(t) do o[i] = { 79 - q[1], q[2] } end return o end
-- wing-cloak shoulders with finger ribs + thumb claws
local body = c:ellipse(39.5, 112, 34, 36):clip(c:rect(0, 74, 79, 99))
c:part(body, R.mem, { band = 3, pop = { x = 14, y = 86 } })
local inn = body:shrink(1)
for _, l in ipairs{ { { 22, 78 }, { 9, 99 } }, { { 28, 77 }, { 22, 99 } }, { { 51, 77 }, { 57, 99 } }, { { 57, 78 }, { 70, 99 } } } do
  c:fillMask(c:line(l, 1):clip(inn), R.mem.shade)
end
for _, s in ipairs{ -1, 1 } do
  local cl = { { 17, 82 }, { 15, 78 }, { 20, 80 } }
  if s > 0 then cl = mir(cl) end
  c:part(c:poly(cl), R.muz, { band = 1, nopop = true, inner = false })
end
-- ears
local L = { { 24, 44 }, { 12, 8 }, { 17, 5 }, { 37, 34 } }
local Li = { { 25, 39 }, { 15, 12 }, { 17.5, 10 }, { 33, 33 } }
c:part(c:poly(L), R.fur, { band = 2, pop = { x = 15, y = 9 } })
c:part(c:poly(mir(L)), R.fur, { band = 2, nopop = true })
c:part(c:poly(Li), R.ear, { band = 1, pop = { x = 17, y = 13 }, inner = false })
c:part(c:poly(mir(Li)), R.ear, { band = 1, nopop = true, inner = false })
-- tuft + head
c:part(c:poly{ { 34, 37 }, { 36, 29 }, { 39, 33 }, { 42, 28 }, { 45, 37 } }, R.fur, { band = 1, nopop = true })
local head = c:ellipse(39.5, 51, 20, 16)
c:part(head, R.fur, { band = 3, pop = { x = 27, y = 41 } })
for _, q in ipairs{ { 25, 47 }, { 30, 39 }, { 52, 42 }, { 23, 55 } } do c:put(q[1], q[2], R.fur.hi) end
-- muzzle, pug nose, fangs
c:part(c:ellipse(39.5, 58, 9.5, 6), R.muz, { band = 2, pop = { x = 33, y = 54 } })
c:eyeLocked(28, 44) c:eyeLocked(47, 44)
c:part(c:ellipse(39.5, 55, 3, 2), R.ear, { band = 1, nopop = true, inner = false })
c:put(38, 54, R.ear.hi) c:put(38, 55, P.ink) c:put(41, 55, P.ink)
for _, q in ipairs{ { 35, 59 }, { 36, 60 }, { 37, 60 }, { 38, 60 }, { 39, 60 }, { 40, 60 }, { 41, 60 }, { 42, 60 }, { 43, 60 }, { 44, 59 } } do c:put(q[1], q[2], P.ink) end
c:put(37, 61, P.cream) c:put(42, 61, P.cream)
for _, x0 in ipairs{ 23, 54 } do for x = x0, x0 + 2 do c:put(x, 56, R.ear.base) c:put(x, 57, R.ear.base) end end
-- scarf + tail
local sc = c:rrect(22, 63, 57, 72, 3)
c:part(sc, R.scarf, { band = 2, pop = { x = 25, y = 65 } })
for x = 26, 55, 3 do for y = 65, 70 do if c:get(x, y) == R.scarf.base:lower() then c:put(x, y, R.scarf.shade) end end end
local tail = c:poly{ { 24, 68 }, { 33, 70 }, { 31, 93 }, { 22, 91 } }
c:part(tail, R.scarf, { band = 1, nopop = true })
for _, y in ipairs{ 78, 85 } do c:rect(0, y, 79, y + 1):clip(tail):each(function(x, yy) c:put(x, yy, R.scarf.hi) end) end
for x = 22, 31, 2 do if tail:has(x, 91) then c:put(x, 91, R.scarf.deep) end end
-- flute + paws
local fl = c:line({ { 42, 98 }, { 73, 77 } }, 3)
c:part(fl, R.wood, { band = 1, pop = { x = 70, y = 78 } })
for _, x in ipairs{ 58, 62, 66 } do local y = math.floor(98 - (x - 42) * 21 / 31 + 0.5) c:put(x, y - 1, R.wood.deep) end
c:part(c:ellipse(52, 91, 3, 3), R.fur, { band = 1, nopop = true })
c:part(c:ellipse(67, 81, 3, 3), R.fur, { band = 1, nopop = true })
c:finish{ outline = true }
backdrop(R.bg)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
