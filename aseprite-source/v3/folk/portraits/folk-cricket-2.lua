-- folk-cricket-2 portrait (folk F1_6) variant: 2
-- cricket traveller
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME, V = "folk-cricket-2", 2
local BODY = { hi = "#9c8aa0", base = "#5e4a5c", shade = "#40324a", deep = "#30243a" }
local WING = { hi = "#8a7a90", base = "#5a4a60", shade = "#3e3048", deep = "#2f2238" }
local FACE = { hi = "#d6c0b6", base = "#a3878a", shade = "#6c5568", deep = "#483848" }
local EYE  = { hi = "#a596c0", base = "#30243a", shade = "#3a2840", deep = "#3a2840" }
local CL   = { hi = "#86e2d2", base = "#2fa3a0", shade = "#276a78", deep = "#22445a" } -- teal scarf
local HAT  = { hi = "#f08a6a", base = "#c4503e", shade = "#8a3440", deep = "#55223a" } -- rust cap
local PR   = { hi = "#ffe08a", base = "#d9a440", shade = "#9a6a3c", deep = "#5e3f3a" } -- brass
local PR2  = { hi = "#e0b07a", base = "#b07a4a", shade = "#7a4c3c", deep = "#4a2e36" } -- pack leather
local ROLL = { hi = "#f4e6c4", base = "#d6c39c", shade = "#a0908e", deep = "#6a5c6e" }
local GLOW = { hi = "#fff3c4", base = "#ffd56e", shade = "#f2a24a", deep = "#b06a3a" }
local BG   = { base = "#86c9bf", shade = "#5f9f9e", deep = "#44727c" }
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local R = math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do for x = math.floor(cx - R), math.ceil(cx + R) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function keep(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end

-- head-and-shoulders cricket portrait: glossy round head, compound-eye patches, clypeus snout with
-- lip and segmented palps, pronotum shield, folded veined tegmina behind the shoulders, whip antennae.
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:copy():grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
for _, s in ipairs{ -1, 1 } do
  local w = c:poly{ { 39.5 + s * 8, 70 }, { 39.5 + s * 29, 82 }, { 39.5 + s * 29, 99 }, { 39.5 + s * 12, 99 } }
  c:part(w, WING, { band = 2, nopop = true })
  local inner = w:copy():shrink(1)
  c:line({ { 39.5 + s * 12, 76 }, { 39.5 + s * 25, 98 } }, 1):clip(inner):each(function(x, y) keep(c, x, y, WING.deep) end)
  c:line({ { 39.5 + s * 18, 80 }, { 39.5 + s * 28, 88 } }, 1):clip(inner):each(function(x, y) keep(c, x, y, WING.shade) end)
end
if V == 2 then
  c:part(c:rrect(12, 62, 67, 99, 8), PR2, { band = 3, pop = { x = 14, y = 70 } })
  c:part(c:ellipse(39.5, 61, 27, 5), ROLL, { band = 1, sep = true })
  for _, x in ipairs{ 13, 66 } do keep(c, x, 61, ROLL.deep) keep(c, x, 60, ROLL.shade) end
end
local body = c:ellipse(39.5, 104, 27, 27) body:clip(c:rect(0, 0, 79, 99))
c:part(body, BODY, { band = 3, sep = true })
for _, y in ipairs{ 88, 94 } do for x = 12, 68 do if body:has(x, y) and x % 6 ~= 0 then keep(c, x, y, BODY.shade) end end end
c:part(c:rrect(20, 61, 59, 80, 7), BODY, { band = 2, sep = true, pop = { x = 24, y = 64 } })
if V == 1 then
  c:part(c:rrect(27, 84, 52, 99, 2), CL, { band = 2, sep = true, pop = { x = 29, y = 86 } })
  c:part(c:line({ { 30, 85 }, { 27, 73 } }, 3), CL, { band = 1, nopop = true })
  c:part(c:line({ { 49, 85 }, { 52, 73 } }, 3), CL, { band = 1, nopop = true })
  for _, x in ipairs{ 29, 49 } do c:part(c:rect(x, 85, x + 1, 86), "gold", { band = 1, nopop = true }) end
  c:stitch{ { 33, 91 }, { 46, 91 } }
elseif V == 2 then
  c:part(c:line({ { 21, 76 }, { 19, 99 } }, 3), PR2, { band = 1, nopop = true, sep = true })
  c:part(c:line({ { 58, 76 }, { 60, 99 } }, 3), PR2, { band = 1, nopop = true, sep = true })
  c:part(c:rect(57, 88, 61, 90), PR, { band = 1, sep = true })
  c:part(c:rrect(18, 66, 61, 77, 5), CL, { band = 2, sep = true, pop = { x = 22, y = 68 } })
  for x = 22, 58, 4 do keep(c, x, 72, CL.shade) keep(c, x + 1, 73, CL.shade) end
  c:part(c:poly{ { 23, 73 }, { 31, 73 }, { 30, 93 }, { 22, 91 } }, CL, { band = 1, nopop = true, sep = true })
  for x = 22, 30, 2 do keep(c, x, 92, CL.deep) end
else
  c:part(c:rrect(27, 80, 52, 99, 3), CL, { band = 2, sep = true, pop = { x = 29, y = 82 } })
  c:part(c:line({ { 29, 81 }, { 27, 70 } }, 2), CL, { band = 1, nopop = true })
  c:part(c:line({ { 50, 81 }, { 52, 70 } }, 2), CL, { band = 1, nopop = true })
  for x = 28, 51 do keep(c, x, 81, HAT.base) end
  c:part(c:rrect(33, 88, 46, 95, 2), CL, { band = 1, nopop = true, sep = true })
  for x = 34, 45, 2 do keep(c, x, 89, HAT.base) end
end
-- head
local head = c:ellipse(39.5, 48, 20.5, 17)
c:part(head, BODY, { band = 3, sep = true, pop = { x = 26, y = 37 } })
for _, q in ipairs{ {21,46},{21,45},{22,43},{22,42},{23,41},{24,40} } do keep(c, q[1], q[2], BODY.hi) end
for _, ex in ipairs{ 29.5, 49.5 } do c:part(c:ellipse(ex, 47, 6, 6.5), EYE, { band = 1, nopop = true, inner = false }) end
keep(c, 26, 43, EYE.hi) keep(c, 46, 43, EYE.hi) keep(c, 25, 44, EYE.hi) keep(c, 45, 44, EYE.hi)
c:eyeLocked(27, 45) c:eyeLocked(47, 45)
for y = 44, 51 do keep(c, 39, y, BODY.hi) keep(c, 40, y, BODY.shade) end
c:part(c:ellipse(39.5, 57, 6.5, 4.5), FACE, { band = 2, sep = true, pop = { x = 36, y = 54 } })
keep(c, 37, 57, FACE.deep) keep(c, 42, 57, FACE.deep)
c:part(c:rrect(35, 60, 44, 64, 2), FACE, { band = 1, sep = true, nopop = true })
for _, q in ipairs{ {36,61},{37,62},{38,62},{39,62},{40,62},{41,62},{42,62},{43,61} } do c:put(q[1], q[2], P.ink) end
for _, s in ipairs{ -1, 1 } do
  local x0 = math.floor(39.5 + s * 9)
  c:part(c:line({ { 39.5 + s * 6.5, 61 }, { x0, 65 }, { x0, 69 } }, 2), FACE, { band = 1, nopop = true, sep = true })
  keep(c, x0, 65, FACE.deep) keep(c, x0, 69, FACE.hi)
end
c:paint({ "PPP", "PPP" }, 21, 55, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 56, 55, { P = "petal.base" })
c:put(21, 55, P.petal.hi) c:put(56, 55, P.petal.hi)
if V == 1 then
  local brim = c:ellipse(39.5, 33, 27, 5.5)
  c:part(brim, HAT, { band = 2 })
  for x = 14, 66, 3 do local y = 34 + (x % 2) if brim:has(x, y) then keep(c, x, y, HAT.shade) end end
  local crown = c:rrect(27, 18, 52, 33, 6)
  c:part(crown, HAT, { band = 2, sep = true, pop = { x = 30, y = 21 } })
  for x = 27, 52 do if crown:has(x, 29) then keep(c, x, 28, CL.hi) keep(c, x, 29, CL.base) keep(c, x, 30, CL.shade) end end
  for y = 20, 27, 2 do for x = 29, 50, 4 do if crown:has(x + (y % 4) // 2 * 2, y) and c:get(x + (y % 4) // 2 * 2, y) == HAT.base then keep(c, x + (y % 4) // 2 * 2, y, HAT.shade) end end end
  c:put(12, 34, HAT.hi) c:put(67, 35, HAT.shade)
  -- trowel in the right hand, a crumb of soil on the tip
  c:part(c:line({ { 64, 99 }, { 64, 88 }, { 61, 82 } }, 4), BODY, { band = 1, nopop = true, sep = true })
  c:part(c:rrect(59, 70, 63, 80, 1), PR2, { band = 1, pop = { x = 60, y = 71, horizontal = false } })
  for y = 72, 79, 3 do keep(c, 61, y, PR2.shade) end
  c:part(c:rect(58, 68, 64, 69), PR, { band = 1, sep = true })
  local bl = c:poly{ { 56, 67 }, { 66, 67 }, { 61, 51 } }
  c:part(bl, PR, { band = 2, sep = true, pop = { x = 58, y = 64 } })
  for y = 55, 65 do keep(c, 61, y, PR.shade) end
  for _, q in ipairs{ {60,53},{61,52},{62,54},{61,54} } do keep(c, q[1], q[2], SOIL) end
  c:part(c:ellipse(61, 80, 3, 3), BODY, { band = 1, nopop = true, sep = true })
elseif V == 2 then
  local cap = c:ellipse(40, 35, 19, 9) cap:clip(c:rect(0, 0, 79, 36))
  c:part(cap, HAT, { band = 2, pop = { x = 27, y = 29 } })
  c:part(c:poly{ { 17, 35 }, { 41, 35 }, { 38, 40 }, { 14, 39 } }, HAT, { band = 1, sep = true, nopop = true })
  c:part(c:ellipse(40, 27, 2, 1.5), HAT, { band = 1, sep = true, nopop = true })
  for x = 23, 57, 3 do if cap:has(x, 33) then keep(c, x, 33, HAT.shade) end end
  -- lantern held up on the left
  c:part(c:line({ { 18, 99 }, { 12, 86 }, { 14, 74 } }, 4), BODY, { band = 1, nopop = true, sep = true })
  c:fillMask(c:line({ { 15, 72 }, { 15, 75 } }, 1), PR.deep)
  c:part(c:rrect(10, 75, 20, 77, 1), PR, { band = 1, pop = { x = 11, y = 75 } })
  c:part(c:rrect(11, 78, 19, 87, 1), GLOW, { band = 2, nopop = true, sep = true })
  for y = 78, 87 do keep(c, 15, y, PR.shade) end
  keep(c, 12, 79, GLOW.hi) keep(c, 12, 80, GLOW.hi) keep(c, 13, 79, GLOW.hi)
  c:part(c:rect(10, 88, 20, 89), PR, { band = 1, nopop = true, sep = true })
  c:part(c:ellipse(15, 72, 3, 2.5), BODY, { band = 1, nopop = true, sep = true })
else
  local k = head:copy() k:clip(c:rect(0, 0, 79, 39))
  for x = 21, 58, 5 do k:add(c:ellipse(x, 39.5, 2, 2)) end
  k:clip(head:copy():grow(1))
  c:part(k, HAT, { band = 2, pop = { x = 27, y = 35 } })
  k:each(function(x, y) if (x * 3 + y * 5) % 13 == 0 and c:get(x, y) == HAT.base then keep(c, x, y, CL.hi) end end)
  c:part(c:poly{ { 61, 36 }, { 71, 30 }, { 69, 38 } }, HAT, { band = 1, nopop = true, sep = true })
  c:part(c:poly{ { 61, 38 }, { 70, 43 }, { 64, 42 } }, HAT, { band = 1, nopop = true, sep = true })
  c:part(c:ellipse(61, 37, 3, 2.5), HAT, { band = 1, sep = true, nopop = true })
  -- ladle raised on the right, soup drip
  c:part(c:line({ { 63, 99 }, { 64, 88 }, { 62, 80 } }, 4), BODY, { band = 1, nopop = true, sep = true })
  c:part(c:line({ { 62, 86 }, { 64, 70 }, { 65, 59 } }, 2), PR, { band = 1, nopop = true })
  c:part(c:ellipse(65, 55, 6, 3.5), PR, { band = 1, sep = true, pop = { x = 61, y = 53 } })
  c:part(c:ellipse(65, 55, 4, 2), SOUP, { band = 1, sep = true, pop = { x = 63, y = 54 } })
  c:part(c:rect(70, 58, 70, 60), SOUP, { band = 1, nopop = true })
  c:part(c:ellipse(62, 79, 3, 3), BODY, { band = 1, nopop = true, sep = true })
end
c:finish{ outline = true }
local A = ({ { 35, 19, 45, 19 }, { 34, 28, 46, 28 }, { 33, 32, 46, 32 } })[V]
local lx, ly, rx, ry = A[1], A[2], A[3], A[4]
c:fillMask(c:line({ { lx, ly }, { lx - 4, ly - 8 }, { lx - 11, ly - 14 }, { lx - 22, ly - 16 } }, 1), P.ink)
c:fillMask(c:line({ { rx, ry }, { rx + 4, ry - 8 }, { rx + 11, ry - 14 }, { rx + 22, ry - 16 } }, 1), P.ink)
backdrop(BG)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
