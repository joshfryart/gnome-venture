-- Flamingo Flick (th-flamingo-flick), yard sprite 64x64. Opus second pass (art-2701-pals-all/c05/opus2) over the Haiku pass.
-- Bloomcaller, common, Thornacre. "Stands on one leg in the waterhole and dares you to try."
-- A petal-pink flamingo standing on ONE thin leg in a round savanna waterhole (ripple rings round the shin),
-- the other leg folded up under the belly with its knee poking forward. S-curve neck up to a round head turned
-- to face you: locked eyes, a chunky bent flamingo beak (pale base, dark plum tip) hanging under them.
-- Fixes vs Haiku: real S-neck and bent beak, body is a feathered teardrop with a tail point, the second
-- leg shows it is standing on one on purpose, water is a waterhole with ripples, not a bar.
-- quirk (the dare): the near wing is flung up and open, dark-tipped primaries fanned like beckoning fingers.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("th-flamingo-flick-yard", 64)

local FLM  = { "#5e1f3a", "#8f2f55", "#c44a73", "#e8789a", "#f7a3b8", "#fdd3d8" }
local LEG  = { "#6e2440", "#a83a5e", "#d9607f", "#f08ea6" }
local BEAK = { "#3a2233", "#5b3047", "#d68e9e", "#f3c4c2" }
local PRIM = { "#2f1f33", "#4a2f4c", "#6e4668" }
local WAT  = { "#1d4866", "#2c6f8f", "#4598b0", "#6fc2c8", "#a8e2d8", "#d4f4e8" }
local BNC  = "#7a5a8a"

-- waterhole
local pool = c:ellipse(32, 56, 22, 3.5)
local wb = {}
pool:each(function(x, y) if y <= 54 then wb[K(x, y)] = 2 end end)
local wI, wT = O.shade(c, pool, WAT, { R = 2, bias = wb, amb = .3, wrap = .4, cuts = O.CUTS })
-- ripple rings round the standing leg
for x = 22, 39 do
  local dx = (x - 30.5) / 8.5
  if math.abs(dx) <= 1 then
    local y = 56 + math.floor(math.sqrt(1 - dx * dx) * 1.6 + .5)
    if (x + y) % 4 ~= 0 then O.mark(c, { { x, y } }, WAT[6]) end
  end
end
O.mark(c, { { 26, 55 }, { 27, 55 }, { 34, 55 }, { 35, 55 } }, WAT[5])
O.mark(c, { { 15, 57 }, { 16, 57 }, { 47, 56 }, { 48, 56 }, { 49, 56 } }, WAT[5])

-- standing leg: backward knee joint halfway
local l1, n1 = O.tube({ { 30, 40 }, { 30, 44 }, { 31, 47 }, { 31, 48 } }, function() return 1 end)
O.shadeN(c, l1, n1, LEG, { amb = .3, cuts = { .3, .55, .8 }, sep = FLM[1] })
local l2, n2 = O.tube({ { 31, 48 }, { 31, 51 }, { 30, 54 }, { 30, 56 } }, function() return .9 end)
O.shadeN(c, l2, n2, LEG, { amb = .3, cuts = { .3, .55, .8 } })
O.shade(c, c:ellipse(31, 48, 1.5, 1), LEG, { R = 1, amb = .4, cuts = { .3, .55, .8 } }) -- knee
-- folded leg: thigh down, shin tucked forward under the belly
local f1, fn1 = O.tube({ { 34, 39 }, { 36, 42 }, { 38, 44 }, { 39, 45 } }, function() return 1 end)
O.shadeN(c, f1, fn1, LEG, { amb = .3, cuts = { .3, .55, .8 }, sep = FLM[1] })
local f2, fn2 = O.tube({ { 39, 45 }, { 37, 46 }, { 35, 46 }, { 33, 45 } }, function() return .8 end)
O.shadeN(c, f2, fn2, LEG, { amb = .3, cuts = { .3, .55, .8 } })
O.shade(c, c:ellipse(39.5, 45, 1.5, 1.5), LEG, { R = 1, amb = .4, cuts = { .3, .55, .8 } })

-- body: feathered teardrop with a tail point on the left
local body = c:ellipse(28, 34, 11.5, 7)
body:add(c:poly{ { 18, 30 }, { 11, 31 }, { 13, 34 }, { 19, 37 } })
local bI, bT = O.shade(c, body, FLM, { R = 5, amb = .22, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
-- scalloped feather rows (one tone down crescents)
O.tex(c, bI, bT, FLM, function(x, y, i)
  if i >= 3 and y >= 34 and ((x + (y // 3) * 3) % 6 == 0) and y % 3 == 1 then return -1 end
end)
O.mark(c, { { 12, 31 }, { 13, 32 }, { 14, 32 } }, FLM[2]) -- tail split

-- neck: S curve up to the head
local nk, nkn = O.tube({ { 36, 31 }, { 45, 26 }, { 34, 20 }, { 40, 14 } }, function(t) return 2.2 - t * .6 end)
O.shadeN(c, nk, nkn, FLM, { amb = .25, wrap = .4, sep = FLM[2], rim = true, bounce = BNC, bmax = 2 })

-- head turned to face you
local head = c:ellipse(40.5, 11, 8, 6.5)
O.shade(c, head, FLM, { sphere = { 38, 9, 8 }, amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
c:eyeLocked(34, 7) c:eyeLocked(42, 7)
O.dots(c, { { 34, 6 }, { 35, 5 }, { 36, 5 }, { 37, 5 }, { 43, 5 }, { 44, 5 }, { 45, 5 }, { 46, 6 } }, FLM[2]) -- cocky brows
c:cheek(34, 13) c:cheek(45, 13)
-- bent beak: pale base, kinks down, dark plum tip
local bk = c:poly{ { 37, 12 }, { 42, 12 }, { 43, 14 }, { 44, 17 }, { 45, 20 }, { 44, 22 }, { 42, 20 }, { 39, 16 }, { 37, 14 } }
local kb = {}
bk:each(function(x, y) if y >= 18 or (y >= 17 and x >= 44) then kb[K(x, y)] = -9 end end)
O.shade(c, bk, BEAK, { R = 1, bias = kb, amb = .45, wrap = .5, cuts = { .25, .5, .75 }, sep = FLM[1] })
O.mark(c, { { 38, 13 }, { 39, 13 }, { 39, 14 } }, BEAK[4])
O.mark(c, { { 40, 15 }, { 41, 16 } }, BEAK[2]) -- nostril slit
O.mark(c, { { 43, 18 }, { 44, 18 } }, BEAK[2]) -- the bend line
-- quirk: near wing flung up and open, dark primaries fanned like beckoning fingers
local wing = c:poly{ { 21, 33 }, { 30, 31 }, { 25, 22 }, { 19, 17 }, { 16, 19 } }
local wI2, wT2 = O.shade(c, wing, FLM, { R = 2, amb = .3, wrap = .45, sep = FLM[2], rim = true })
O.tex(c, wI2, wT2, FLM, function(x, y, i) if (x - y) % 4 == 0 and i >= 3 then return -1 end end) -- covert rows
for _, f in ipairs({ { { 19, 18 }, { 15, 13 } }, { { 21, 19 }, { 19, 12 } }, { { 23, 21 }, { 23, 13 } }, { { 25, 23 }, { 27, 15 } } }) do
  local m, n = O.tube({ f[1], { (f[1][1] * 2 + f[2][1]) / 3, (f[1][2] * 2 + f[2][2]) / 3 },
                         { (f[1][1] + f[2][1] * 2) / 3, (f[1][2] + f[2][2] * 2) / 3 }, f[2] }, function(t) return 1.1 - t * .4 end)
  local fb = {} m:each(function(x, y) if y > f[1][2] - 3 then fb[K(x, y)] = 9 end end)
  O.shadeN(c, m, n, PRIM, { amb = .35, cuts = { .45, .75 }, sep = P.ink })
  O.mark(c, { { f[1][1], f[1][2] - 1 }, { f[1][1], f[1][2] - 2 } }, FLM[3])
end

O.shift(c, 0, 1)
O.done(c, "th-flamingo-flick-yard")
