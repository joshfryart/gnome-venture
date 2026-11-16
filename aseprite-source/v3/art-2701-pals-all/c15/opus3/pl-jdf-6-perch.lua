-- Lotus Perch (pl-jdf-6), perch sprite 36x36. Opus richness pass (c15/opus3), hand-built at this size.
-- Pointed pink lotus in three layers (deeper back petals, two side petals, a broad front petal with 2x3 pill
-- eyes), deeper pink tips, a gold stamen hint, on a notched lily pad.
-- richness: rim light and lilac bounce on the petals, paler petal bases, pad rim light and cool bounce, a dewdrop
-- on the pad.
-- opus2 weakness fixed: the napping dragonfly was a few pixels; now a clear 17-px dragonfly lies across the head
-- (round jade head with a shut eye, gold-ringed tail, two glassy wings folded up), with a bigger "z".
-- quirk: the jade dragonfly naps on its head.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-6-perch", 36)

local PET  = { "#7d2c5e", "#b8477a", "#e06e98", "#f59ab8", "#ffc4d8", "#ffe8ee" }
local PAD  = { "#1d4a3c", "#2c6c46", "#3f9150", "#64b45c", "#9cd477", "#d0ec9e" }
local JADE = { "#16403a", "#1f6650", "#2f9460", "#55bf6a", "#9ae07c", "#d8f6aa" }

local pad = c:ellipse(18, 29, 14, 3.5)
pad:cut(c:poly{ { 25, 29 }, { 34, 26 }, { 34, 28 } })
O.shade(c, pad, PAD, { R = 3, amb = .3, wrap = .4, rim = true, bounce = "#4f8eaa", bmax = 2 })

local function petal(base, tip, W, back)
  local bx, by, tx, ty = base[1], base[2], tip[1], tip[2]
  local pts = { { bx, by }, { bx + (tx - bx) * .35, by + (ty - by) * .35 }, { bx + (tx - bx) * .75, by + (ty - by) * .75 }, { tx, ty } }
  local m, n, T = O.tube(pts, function(t) return math.max(.4, W * (math.sin(math.pi * math.min(1, .12 + .88 * t)) ^ .75)) end)
  local I, Tk = O.shadeN(c, m, n, PET, { amb = .4, wrap = .5, rim = true, sep = PET[2], bounce = "#9a7ac8", bmax = 2 })
  O.tex(c, I, Tk, PET, function(x, y, i)
    local t = T[K(x, y)] or 0
    if t > .75 then return -1 + (back or 0) end
    if t < .2 and i <= 4 then return 1 + (back or 0) end
    return back
  end)
end
petal({ 16, 24 }, { 6, 12 }, 3, -2)
petal({ 20, 24 }, { 30, 12 }, 3, -2)
petal({ 17, 23 }, { 12, 6 }, 3, -2)
petal({ 19, 23 }, { 24, 6 }, 3, -2)
O.flat(c, c:rect(14, 12, 22, 13), "#f5b82e", "stamen") O.dots(c, { { 15, 12 }, { 17, 12 }, { 19, 12 }, { 21, 12 } }, "#ffe38a")
petal({ 16, 27 }, { 4, 18 }, 3.5)
petal({ 20, 27 }, { 32, 18 }, 3.5)
petal({ 18, 29 }, { 18, 10 }, 6.5)

c:eyeSmall(14, 17)
c:eyeSmall(20, 17)
O.dot(c, 12, 21, P.petal.base) O.dot(c, 24, 21, P.petal.base)
O.mark(c, { { 17, 22 }, { 18, 22 } }, P.ink)

-- napping dragonfly lying across the head: wings folded up behind, gold-ringed tail, round head, shut eye
local WG = { "#4a80a6", "#74b2c8", "#a2d8d8", "#cbefe6", "#eefcf2" }
for _, w in ipairs({ { { 15, 8 }, { 18, 6 }, { 22, 5 }, { 26, 5 } }, { { 15, 8 }, { 19, 7 }, { 23, 7 }, { 28, 7 } } }) do
  local wm, wn = O.tube(w, function(t) return .4 + .7 * math.sin(math.pi * math.min(1, .1 + t)) end)
  O.shadeN(c, wm, wn, WG, { amb = .55, wrap = .5, cuts = { .2, .4, .6, .8 }, sep = WG[1], rim = true })
end
O.dots(c, { { 25, 5 }, { 27, 7 } }, "#f5b82e")
local bm, bn = O.tube({ { 13, 9 }, { 18, 9 }, { 23, 9 }, { 29, 10 } }, function(t) return 1.1 - t * .5 end)
O.shadeN(c, bm, bn, JADE, { amb = .6, wrap = .5, cuts = { .1, .3, .5, .7, .9 }, rim = true })
O.dots(c, { { 18, 9 }, { 21, 9 }, { 24, 9 }, { 27, 10 } }, "#f5b82e")
O.shade(c, c:ellipse(12, 8, 2, 2), JADE, { sphere = { 11, 7, 3 }, amb = .35, cuts = { .2, .4, .6, .8, .95 }, sep = JADE[1], rim = true })
O.dots(c, { { 11, 8 }, { 12, 8 } }, P.ink)
-- dewdrop on the pad
O.flat(c, c:rect(28, 29, 29, 30), "#b9e2f5", "dew") O.dot(c, 28, 29, "#e4f6ff") O.dot(c, 29, 30, "#7ab8c8")

O.done(c, "pl-jdf-6-perch", function(c)
  for _, p in ipairs({ { 6, 1 }, { 7, 1 }, { 8, 1 }, { 9, 1 }, { 8, 2 }, { 7, 3 }, { 6, 4 }, { 7, 4 }, { 8, 4 }, { 9, 4 },
    { 1, 6 }, { 2, 6 }, { 3, 6 }, { 4, 6 }, { 3, 7 }, { 2, 8 }, { 1, 9 }, { 2, 9 }, { 3, 9 }, { 4, 9 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], P.ink) end end
end)
