-- folk-cricket-3 sprite (folk F1_6) variant: 3
-- cricket cook
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME, V = "folk-cricket-3", 3
local BODY = { hi = "#f2d59e", base = "#cfa565", shade = "#96704f", deep = "#5c4250" }
local WING = { hi = "#e2bf86", base = "#b38b5c", shade = "#7f5e50", deep = "#4f3a48" }
local FACE = { hi = "#fff0c8", base = "#f0d6a0", shade = "#c49a70", deep = "#7e5a58" }
local EYE  = { hi = "#a593b8", base = "#5c4250", shade = "#3a2840", deep = "#3a2840" }
local CL   = { hi = "#fbf1d8", base = "#eadcb8", shade = "#bba79e", deep = "#807189" } -- cream apron
local HAT  = { hi = "#ff9a7a", base = "#df4e45", shade = "#9c3048", deep = "#5e2240" } -- red kerchief
local PR   = { hi = "#e6e2ee", base = "#a9a8be", shade = "#706f90", deep = "#48475f" } -- ladle
local SOUP = { hi = "#ffd27a", base = "#f0a040", shade = "#c06a3a", deep = "#7e4038" }
local BG   = { base = "#f4ab8c", shade = "#cf7f72", deep = "#9a5862" }
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

-- 3/4 top-down cricket villager: round glossy head, pronotum saddle, folded veined tegmina,
-- big herringbone jumping femurs with spurred tibiae, tiny middle legs, whip antennae.
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3},{1,1} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, st, tw = p.bob or 0, p.settle or 0, p.tw or 0
  c:groundShadow(32, 89.5, 13, 2.5)
  for _, s in ipairs{ -1, 1 } do
    local w = c:poly{ { 32 + s * 5, 58 + b }, { 32 + s * 15, 73 + b }, { 32 + s * 14, 83 + b }, { 32 + s * 6, 78 + b } }
    c:part(w, WING, { band = 1, nopop = true })
    local inner = w:copy():shrink(1)
    c:line({ { 32 + s * 8, 63 + b }, { 32 + s * 12, 80 + b } }, 1):clip(inner):each(function(x, y) keep(c, x, y, WING.deep) end)
    c:line({ { 32 + s * 10, 70 + b }, { 32 + s * 14, 75 + b } }, 1):clip(inner):each(function(x, y) keep(c, x, y, WING.shade) end)
  end
  if V == 2 then -- big travel pack + bedroll
    c:part(c:rrect(15, 49 + b, 49, 73 + b, 6), PR2, { band = 2, pop = { x = 17, y = 56 + b } })
    c:part(c:ellipse(32, 48 + b, 18, 3.5), ROLL, { band = 1, sep = true })
    for _, x in ipairs{ 15, 49 } do keep(c, x, 48 + b, ROLL.deep) end
  end
  for _, s in ipairs{ -1, 1 } do
    c:part(c:line({ { 32 + s * 5, 81 + b }, { 32 + s * 5, 88 } }, 2), BODY, { band = 1, nopop = true, sep = true })
    local tib = c:line({ { 32 + s * 17, 61 + b }, { 32 + s * 18.5, 75 }, { 32 + s * 11, 87 } }, 2)
    tib:add(c:line({ { 32 + s * 19, 66 + b }, { 32 + s * 21, 65 + b } }, 1))
    tib:add(c:line({ { 32 + s * 19.5, 71 }, { 32 + s * 21.5, 70 } }, 1))
    tib:add(c:line({ { 32 + s * 17, 81 }, { 32 + s * 19, 80 } }, 1))
    c:part(tib, BODY, { band = 1, nopop = true, sep = true })
    local fem = oval(32 + s * 13, 71 + b, 9.5, 4, s < 0 and 66 or 114)
    fem:add(c:ellipse(32 + s * 15, 65 + b, 4, 4))
    c:part(fem, BODY, { band = 2, sep = true })
    fem:each(function(x, y) if (x * s + y) % 4 == 0 and c:get(x, y) == BODY.base then keep(c, x, y, BODY.shade) end end)
    c:part(c:ellipse(32 + s * 10, 88, 3.5, 1.8), BODY, { band = 1, nopop = true, sep = true })
  end
  local body = c:ellipse(32, 72 + b, 10.5, 12)
  c:part(body, BODY, { band = 2, sep = true })
  for _, y in ipairs{ 74, 78, 82 } do for x = 20, 44 do
    if body:has(x, y + b) and x % 5 ~= 0 and body:has(x, y + b + 1) then keep(c, x, y + b, c:get(x, y + b) == BODY.shade and BODY.deep or BODY.shade) end
  end end
  if V == 1 then -- dungarees
    local ov = c:rect(0, 72 + b, 63, 95) ov:add(c:rrect(26, 63 + b, 38, 73 + b, 1)) ov:clip(body)
    c:part(ov, CL, { band = 2, pop = { x = 27, y = 66 + b } })
    c:part(c:line({ { 27, 64 + b }, { 25, 57 + b } }, 2), CL, { band = 1, nopop = true })
    c:part(c:line({ { 37, 64 + b }, { 39, 57 + b } }, 2), CL, { band = 1, nopop = true })
    keep(c, 27, 64 + b, P.gold.hi) keep(c, 37, 64 + b, P.gold.hi)
    c:stitch{ { 29, 68 + b }, { 35, 68 + b } }
  elseif V == 2 then
    c:part(c:line({ { 25, 58 + b }, { 24, 73 + b } }, 2), PR2, { band = 1, nopop = true, sep = true })
    c:part(c:line({ { 39, 58 + b }, { 40, 73 + b } }, 2), PR2, { band = 1, nopop = true, sep = true })
    keep(c, 24, 68 + b, PR.hi) keep(c, 40, 68 + b, PR.base)
  else -- apron with red hem
    local ap = c:rrect(24, 62 + b, 40, 85 + b, 3) ap:clip(body:copy():grow(1))
    c:part(ap, CL, { band = 2, pop = { x = 26, y = 64 + b } })
    ap:each(function(x, y) if not ap:has(x, y + 1) then keep(c, x, y, HAT.base) end end)
    c:part(c:rrect(28, 72 + b, 36, 77 + b, 1), CL, { band = 1, nopop = true, sep = true })
    keep(c, 32, 74 + b, HAT.base)
  end
  -- props held low (before the arms so the hands grip over them)
  if V == 1 then
    c:part(c:rect(44, 61 + b, 46, 69 + b), PR2, { band = 1, pop = { x = 44, y = 62 + b, horizontal = false } })
    local bl = c:poly{ { 42, 70 + b }, { 49, 70 + b }, { 45.5, 81 + b } }
    c:part(bl, PR, { band = 1, sep = true, pop = { x = 43, y = 71 + b } })
    for y = 72, 77 do keep(c, 45, y + b, PR.shade) end
    keep(c, 45, 80 + b, SOIL) keep(c, 44, 79 + b, SOIL) keep(c, 46, 78 + b, SOIL)
  elseif V == 2 then
    local lx = 18 + tw
    c:fillMask(c:line({ { 21, 72 + b }, { lx, 73 + b } }, 1), PR.deep)
    c:part(c:rrect(lx - 4, 73 + b, lx + 4, 75 + b, 1), PR, { band = 1, pop = { x = lx - 3, y = 73 + b } })
    c:part(c:rect(lx - 3, 76 + b, lx + 3, 81 + b), GLOW, { band = 1, nopop = true, sep = true })
    for y = 76, 81 do keep(c, lx, y + b, PR.shade) end
    keep(c, lx - 2, 77 + b, GLOW.hi) keep(c, lx - 2, 78 + b, GLOW.hi)
    c:part(c:rect(lx - 4, 82 + b, lx + 4, 83 + b), PR, { band = 1, nopop = true, sep = true })
  end
  c:part(c:ellipse(21.5, (V == 2 and 70 or 68) + b, 2.5, 3.5), BODY, { band = 1, nopop = true, sep = true })
  if V ~= 3 then c:part(c:ellipse(43.5, 67 + b, 2.5, 3.5), BODY, { band = 1, nopop = true, sep = true }) end
  -- head
  local pro = c:rrect(20, 51 + b, 44, 59 + b, 4)
  c:part(pro, BODY, { band = 1, sep = true, pop = { x = 23, y = 53 + b } })
  local head = c:ellipse(32, 42 + b, 15.5, 12.5)
  c:part(head, BODY, { band = 3, sep = true, pop = { x = 24, y = 34 + b } })
  for _, q in ipairs{ {19,41},{19,40},{20,38},{21,37} } do keep(c, q[1], q[2] + b, BODY.hi) end
  for _, ex in ipairs{ 23, 41 } do c:part(c:ellipse(ex, 45 + b, 4.5, 5), EYE, { band = 1, nopop = true, inner = false }) end
  eye(c, 21, 43 + b, p.blink) eye(c, 39, 43 + b, p.blink)
  c:part(c:ellipse(32, 50 + b, 5, 3), FACE, { band = 1, sep = true, pop = { x = 30, y = 48 + b } })
  c:put(29, 51 + b, P.ink) for x = 30, 34 do c:put(x, 52 + b, P.ink) end c:put(35, 51 + b, P.ink)
  for _, s in ipairs{ -1, 1 } do
    c:part(c:line({ { 32 + s * 5, 52 + b }, { 32 + s * 6, 56 + b + st } }, 1), FACE, { band = 1, nopop = true, sep = true })
    keep(c, 32 + s * 6, 56 + b + st, FACE.hi)
  end
  c:cheek(19, 51 + b) c:cheek(43, 51 + b)
  if V == 1 then -- wide straw hat, antennae poke through holes
    local brim = c:ellipse(32, 33 + b, 19.5, 4.5)
    c:part(brim, HAT, { band = 2 })
    for x = 14, 50, 3 do local y = 33 + b + (x % 2) if brim:has(x, y) then keep(c, x, y, HAT.shade) end end
    local crown = c:rrect(24, 23 + b, 40, 33 + b, 4)
    c:part(crown, HAT, { band = 2, sep = true, pop = { x = 26, y = 25 + b } })
    for x = 24, 40 do if crown:has(x, 30 + b) then keep(c, x, 30 + b, CL.base) keep(c, x, 31 + b, CL.shade) end end
    c:put(13, 34 + b, HAT.hi) c:put(51, 35 + b, HAT.shade)
  elseif V == 2 then -- tilted flat cap + scarf with tail
    local sc = c:rrect(19, 53 + b, 45, 58 + b, 2)
    c:part(sc, CL, { band = 1, sep = true, pop = { x = 21, y = 54 + b } })
    local tail = c:poly{ { 37, 56 + b }, { 42, 56 + b }, { 44, 66 + b + st }, { 39, 67 + b + st } }
    c:part(tail, CL, { band = 1, nopop = true, sep = true })
    for x = 39, 44, 2 do keep(c, x, 66 + b + st, CL.deep) end
    local cap = c:ellipse(31, 34 + b, 12.5, 6) cap:clip(c:rect(0, 0, 63, 35 + b))
    c:part(cap, HAT, { band = 2, pop = { x = 23, y = 30 + b } })
    c:part(c:poly{ { 17, 34 + b }, { 31, 34 + b }, { 29, 38 + b }, { 15, 37 + b } }, HAT, { band = 1, sep = true, nopop = true })
    c:put(31, 28 + b, HAT.deep)
  else -- kerchief + knot, ladle raised
    local k = head:copy() k:clip(c:rect(0, 0, 63, 36 + b))
    for x = 17, 47, 4 do k:add(c:ellipse(x, 36.5 + b, 1.5, 1.5)) end
    k:clip(head:copy():grow(1))
    c:part(k, HAT, { band = 2, pop = { x = 21, y = 33 + b } })
    k:each(function(x, y) if (x * 3 + y * 5) % 11 == 0 and c:get(x, y) == HAT.base then keep(c, x, y, CL.hi) end end)
    c:part(c:ellipse(47, 33 + b, 2.5, 2), HAT, { band = 1, sep = true, nopop = true })
    c:part(c:poly{ { 48, 32 + b }, { 53, 29 + b + st }, { 52, 33 + b + st } }, HAT, { band = 1, nopop = true, sep = true })
    c:part(c:line({ { 44, 68 + b }, { 48, 59 + b }, { 50, 53 + b } }, 2), PR, { band = 1, nopop = true })
    c:part(c:ellipse(51, 50 + b, 4.5, 3), PR, { band = 1, sep = true, pop = { x = 48, y = 48 + b } })
    c:part(c:ellipse(51, 50 + b, 3, 1.5), SOUP, { band = 1, sep = true, pop = { x = 49, y = 50 + b } })
    c:part(c:rect(55, 52 + b + tw, 55, 53 + b + tw), SOUP, { band = 1, nopop = true })
    c:part(c:ellipse(44, 66 + b, 2.5, 3), BODY, { band = 1, nopop = true, sep = true })
  end
  c:finish{ outline = true }
  local A = ({ { 29, 23, 35, 23 }, { 27, 29, 36, 29 }, { 28, 31, 36, 31 } })[V]
  local lx, ly, rx, ry = A[1], A[2] + b, A[3], A[4] + b
  c:fillMask(c:line({ { lx, ly }, { lx - 3, ly - 6 }, { lx - 9, ly - 12 }, { lx - 18, ly - 13 + st } }, 1), P.ink)
  c:fillMask(c:line({ { rx, ry }, { rx + 3, ry - 6 }, { rx + 9, ry - 12 }, { rx + 18 - tw * 2, ry - 13 + st + tw } }, 1), P.ink)
  HP.assertClean(c)
  return c
end
local F = { {}, { bob = 1, settle = 1 }, {}, { blink = true, tw = 1 } }
local frames = {}
for i, p in ipairs(F) do frames[i] = frame(p) end
HP.report(frames[1])
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
