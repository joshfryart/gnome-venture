-- npc-lark-fernsway portrait (npc2 P1_19) species: rhinoceros beetle
-- Same design as the sprite: brown split shell + gold seam stitches, nub horn nose, fern scarf, fern frond tucked in. Moss disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
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
local function bz(a, b, cc, t) local u = 1 - t
  return u*u*a[1] + 2*u*t*b[1] + t*t*cc[1], u*u*a[2] + 2*u*t*b[2] + t*t*cc[2] end


local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local NAME = "npc-lark-fernsway"
local SHELL = R("#c98a52", "#9a5f36", "#6e3f45", "#4a2a3c")
local HORN  = R("#ecb878", "#c08048", "#86504a", "#4a2a3c")
local BELLY = R("#f2dba2", "#d9b378", "#a8806a", "#7a5560")
local FERN  = R("#c2dc6e", "#6fae48", "#3f7a4e", "#2f4f4a")
local MOSS  = R("#c8d88a", "#a3b862", "#7d924c", "#5b6c40")
local GOLD  = "#f0c050"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- shoulders: domed shell with seam
local sh = c:ellipse(39.5, 108, 34, 28):clip(c:rect(0, 80, 79, 99))
c:part(sh, SHELL, { band = 3, pop = { x = 14, y = 90 } })
for y = 84, 99 do c:put(39, y, SHELL.deep) end
for y = 86, 98, 4 do c:put(40, y, GOLD) end
-- fern frond tucked in the scarf (right)
local A, Bq, C = { 54, 84 }, { 60, 66 }, { 67, 50 }
local sp = {} for i = 0, 12 do local x, y = bz(A, Bq, C, i / 12) sp[#sp + 1] = { x, y } end
local leaves = HP.mask()
for i = 1, 8 do
  local t = 0.18 + i * 0.09
  local x, y = bz(A, Bq, C, t)
  local s = (i % 2 == 0) and 1 or -1
  local sz = 5 - i * 0.45
  leaves:add(oval(x + s * (sz + 0.4), y - 1, sz, 1.8, -s * 30))
end
leaves:add(oval(C[1], C[2] + 0.5, 1.5, 2.5, 20))
c:part(leaves, FERN, { band = 2, pop = { x = 56, y = 68 } })
c:fillMask(c:line(sp, 1), FERN.deep)
-- head: shell crown with seam, tan face plate
local head = c:ellipse(39.5, 52, 20.5, 18)
c:part(head, SHELL, { band = 3, pop = { x = 26, y = 41 } })
for x = 25, 30 do c:put(x, 40 - math.floor((x - 25) / 3), SHELL.hi) end
for y = 35, 49 do c:put(39, y, SHELL.deep) end
for y = 37, 47, 3 do c:put(40, y, GOLD) end
c:part(c:ellipse(39.5, 63, 13, 7.5), BELLY, { band = 2, nopop = true })
-- nub horn nose, curving up
c:part(c:poly{ { 36, 65 }, { 43, 65 }, { 43, 58 }, { 42, 54 }, { 40, 52 }, { 38, 54 }, { 37, 57 } }, HORN, { band = 2, pop = { x = 39, y = 55 } })
c:put(41, 63, HORN.deep) c:put(42, 62, HORN.deep)
c:eyeLocked(28, 52) c:eyeLocked(47, 52)
for _, q in ipairs{ { 34, 67 }, { 35, 68 }, { 36, 68 }, { 37, 68 }, { 38, 69 }, { 39, 69 }, { 40, 69 }, { 41, 69 }, { 42, 68 }, { 43, 68 }, { 44, 68 }, { 45, 67 } } do c:px(q[1], q[2], P.ink) end
c:cheek(25, 60) c:cheek(52, 60)
-- fern scarf + knot + tails
c:part(c:rrect(21, 74, 58, 81, 3), FERN, { band = 2, pop = { x = 24, y = 75 } })
for x = 23, 56, 3 do c:put(x, 77 + (x % 2), FERN.shade) end
c:part(c:poly{ { 25, 82 }, { 31, 82 }, { 30, 99 }, { 24, 97 } }, FERN, { band = 1, nopop = true })
c:part(c:poly{ { 30, 82 }, { 35, 82 }, { 37, 95 }, { 33, 96 } }, FERN, { band = 1, nopop = true })
c:part(c:ellipse(30, 81.5, 3.5, 3), FERN, { band = 1, pop = { x = 28, y = 80 } })
-- fan-club antennae tips
local tips = { { 25, 21 }, { 54, 21 } }
for _, t in ipairs(tips) do
  local m = c:ellipse(t[1], t[2], 2.5, 3)
  c:part(m, HORN, { band = 1, pop = { x = t[1] - 1, y = t[2] - 2 } })
  c:put(t[1], t[2] - 1, HORN.deep) c:put(t[1], t[2] + 1, HORN.deep) c:put(t[1] - 1, t[2], HORN.deep) c:put(t[1] + 1, t[2], HORN.deep)
end
c:finish{ outline = true }
c:fillMask(c:line({ { 32, 35 }, { 28, 29 }, { 26, 25 } }, 1), P.ink)
c:fillMask(c:line({ { 47, 35 }, { 51, 29 }, { 53, 25 } }, 1), P.ink)
backdrop(c, MOSS)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
