-- Lotus Perch (pl-jdf-6), yard sprite 64x64. Opus second pass (c15/opus2), built on the Haiku idea.
-- Bloomcaller, rare, Lair of the Jade Dragon-fly. "A pink lotus where the jade dragon-fly naps, humming with
-- its wingbeat."
-- A true lotus: pointed petals in three layers (four back petals fanned up, two side petals, one broad front
-- petal that holds the face), pale at the base and deeper pink at the tips, fine lengthwise veins, a gold stamen
-- fringe in the cup, sitting on a notched lily pad on a ring of ripples.
-- Haiku weakness fixed: round paw-like blobs read as a pink paw print; now pointed, veined, layered petals.
-- quirk: a little jade dragonfly naps on the tip of a back petal, wings folded, eyes shut, "z" floating up.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-jdf-6-yard", 64)

local PET  = { "#7d2c5e", "#b8477a", "#e06e98", "#f59ab8", "#ffc4d8", "#ffe8ee" }
local PAD  = { "#1d4a3c", "#2c6c46", "#3f9150", "#64b45c", "#9cd477", "#d0ec9e" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local JADE = { "#16403a", "#1f6650", "#2f9460", "#55bf6a", "#9ae07c", "#d8f6aa" }

-- lily pad with a notch
local pad = c:ellipse(32, 50, 24, 6)
pad:cut(c:poly{ { 44, 50 }, { 60, 45 }, { 60, 48 } })
local pI, pT = O.shade(c, pad, PAD, { R = 4, amb = .3, wrap = .4, rim = true, bounce = "#3a6a8a", bmax = 2 })
O.tex(c, pI, pT, PAD, function(x, y, i) -- radial veins from the centre
  local a = math.atan((y - 50) * 4, x - 32)
  if math.abs(((a / math.pi) * 9) % 1 - .5) < .06 and i >= 3 then return -1 end
end)

local function petal(base, tip, W, o)
  o = o or {}
  local bx, by, tx, ty = base[1], base[2], tip[1], tip[2]
  local bend = o.bend or 0
  local pts = { { bx, by }, { bx + (tx - bx) * .35 + bend, by + (ty - by) * .35 }, { bx + (tx - bx) * .75 + bend, by + (ty - by) * .75 }, { tx, ty } }
  local m, n, T, S = O.tube(pts, function(t)
    local s = math.sin(math.pi * math.min(1, .12 + .88 * t))
    return math.max(.4, W * (s ^ .75) * (t < .1 and .7 + 3 * t or 1))
  end)
  local I, Tk = O.shadeN(c, m, n, PET, { amb = o.amb or .38, wrap = .5, rim = true, sep = PET[2], bounce = "#9a7ac8", bmax = 2 })
  O.tex(c, I, Tk, PET, function(x, y, i)
    local t, s = T[K(x, y)] or 0, S[K(x, y)] or 0
    if t > .78 then return -1 end                                    -- deeper pink tip
    if t > .2 and t < .7 and math.abs(math.abs(s) - .45) < .1 then return -1 end -- veins
    if t < .25 and i <= 4 then return 1 + (o.back or 0) end                          -- paler at the base
    if o.back then return o.back end
  end)
  return m
end

-- back petals
petal({ 29, 42 }, { 12, 19 }, 5, { back = -2 })
petal({ 35, 42 }, { 52, 19 }, 5, { back = -2 })
petal({ 30, 40 }, { 20, 10 }, 5, { back = -2 })
petal({ 34, 40 }, { 44, 10 }, 5, { back = -2 })
-- stamen fringe in the cup
local st = c:ellipse(32, 26, 9, 4)
local sI, sT = O.shade(c, st, GOLD, { R = 2, amb = .35, wrap = .4, cuts = { .3, .55, .8 }, sep = GOLD[1] })
O.tex(c, sI, sT, GOLD, function(x, y, i) if y <= 24 and x % 2 == 0 then return 1 end end)
-- side petals
petal({ 30, 46 }, { 9, 32 }, 6, { bend = -2 })
petal({ 34, 46 }, { 55, 32 }, 6, { bend = 2 })
-- front petal with the face
petal({ 32, 49 }, { 32, 20 }, 10.5, { amb = .45 })

c:eyeLocked(25, 31)
c:eyeLocked(34, 31)
c:cheek(23, 37) c:cheek(39, 37)
O.mark(c, { { 30, 38 }, { 31, 39 }, { 32, 39 }, { 33, 38 } }, P.ink)

-- napping jade dragonfly on the front petal tip (the pal's head): long body, folded wings swept back, eyes shut
local db, dn = O.tube({ { 27, 18 }, { 31, 18 }, { 36, 19 }, { 42, 20 } }, function(t) return 1.4 - t * .6 end)
local dI, dT = O.shadeN(c, db, dn, JADE, { amb = .3, wrap = .4, sep = JADE[1], rim = true })
O.dots(c, { { 34, 19 }, { 37, 19 }, { 40, 20 } }, "#f5b82e") -- gold tail rings
O.shade(c, c:ellipse(26, 17, 2.5, 2.5), JADE, { sphere = { 25, 16, 3.5 }, amb = .35, sep = JADE[1], rim = true })
O.dots(c, { { 24, 17 }, { 25, 17 } }, P.ink)  -- shut eye line
for _, w in ipairs({ { { 29, 16 }, { 32, 14 }, { 35, 13 }, { 39, 12 } }, { { 29, 16 }, { 33, 15 }, { 37, 15 }, { 41, 15 } } }) do
  local wm, wn = O.tube(w, function(t) return .7 * math.sin(math.pi * math.min(1, .15 + t)) + .3 end)
  O.shadeN(c, wm, wn, { "#4c8aa6", "#7ab8c8", "#a6dcd8", "#cdf0e6", "#eefcf2" }, { amb = .5, wrap = .5, cuts = { .2, .4, .6, .8 }, sep = "#4c8aa6" })
end
O.dots(c, { { 38, 12 }, { 40, 15 } }, "#f5b82e") -- pterostigma

O.done(c, "pl-jdf-6-yard", function(c)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  -- z z floating up from the napper
  for _, p in ipairs({ { 27, 6 }, { 28, 6 }, { 29, 6 }, { 28, 7 }, { 27, 8 }, { 28, 8 }, { 29, 8 } }) do put(p[1], p[2], P.ink) end
  for _, p in ipairs({ { 25, 11 }, { 26, 11 }, { 25, 12 }, { 26, 12 } }) do put(p[1], p[2], P.ink) end
  -- ripples around the pad
  for _, r in ipairs({ { 6, 52, 3 }, { 55, 54, 3 }, { 10, 57, 3 }, { 50, 58, 4 } }) do
    for x = r[1], r[1] + r[3] - 1 do put(x, r[2], "#8bc4ea") end
    put(r[1], r[2], "#e4f6ff")
  end
end)
