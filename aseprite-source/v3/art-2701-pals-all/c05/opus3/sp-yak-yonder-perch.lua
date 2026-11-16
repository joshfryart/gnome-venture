-- Yak Yonder (sp-yak-yonder), perch sprite 36x36. Opus richness pass (c05/opus3), hand-built at this size.
-- Richness pass: hue-shifted fur ramp, lit strand tips on the fringe, a gold diamond on the blanket, a horn ring,
-- a brass chin bell (3 px), a lit edge on the pole.
-- Bold and few: shaggy dark yak heading left, jagged fringe skirt over short legs, big head with cream
-- forelock, pale curved horns, pill eyes and a pale muzzle; a red/teal striped blanket and one burlap bundle.
-- quirk: the orange pennant on its pole, streaming forward (left), pointing yonder.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("sp-yak-yonder-perch", 36)

local FUR  = { "#20141e", "#3a2426", "#5c3a30", "#7e5440", "#a07250", "#c4946a" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local LOCK = { "#7a6450", "#ad9474", "#d4be98", "#ecdcba", "#f6ecd4" }
local HORN = { "#6a5a48", "#a8987a", "#d8ccb0", "#f2ead6" }
local MUZ  = { "#4a3430", "#6e5248", "#957264", "#b89282" }
local HOOF = { "#2a2228", "#4a3e44", "#6a5c62" }
local RED  = { "#4f1a26", "#8f2a33", "#c2463f", "#e8704e", "#f49a72" }
local TEAL = { "#1f4e56", "#2f7a7e", "#4aa8a0", "#7cd0c0" }
local SACK = { "#4a3622", "#6e5434", "#957448", "#b8965e", "#d8b880" }
local WOOD = { "#3d2620", "#64402c", "#8d6340", "#b48a58" }
local PEN  = { "#8a2a14", "#d0521e", "#f08a2e", "#fbbf5a" }
local BNC  = "#5a5a7a"

c:groundShadow(18, 32, 13, 1.5)
for i, lx in ipairs({ 12, 16, 24, 28 }) do
  O.flat(c, c:rect(lx, 28, lx + 1, 30), (i % 2 == 0) and FUR[2] or FUR[3], "leg")
  O.flat(c, c:rect(lx, 31, lx + 1, 31), HOOF[2], "hoof")
end
local body = c:ellipse(21, 22, 10, 5.5)
local hem = HP.mask()
for x = 11, 31 do for y = 22, 27 + (x % 3 == 0 and 1 or 0) do hem:set(x, y) end end
hem:clip(c:ellipse(21, 24, 11, 6))
body:add(hem)
local bI, bT = O.shade(c, body, FUR, { R = 3, amb = .22, wrap = .35, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, FUR, function(x, y, i)
  if y >= 24 and x % 3 == 0 and i >= 2 then return -1 end
  if y >= 25 and x % 3 == 1 and y % 2 == 0 and i <= 4 then return 1 end
end)
O.flat(c, c:line({ { 31, 20 }, { 33, 23 }, { 33, 25 } }, 1), FUR[3], "tail")

local bl = c:poly{ { 16, 18 }, { 20, 16 }, { 27, 16 }, { 29, 18 }, { 29, 23 }, { 16, 23 } }
local blI, blT = O.shade(c, bl, RED, { R = 1, amb = .35, wrap = .4, cuts = { .25, .45, .65, .85 }, sep = FUR[1] })
for k, p in pairs(blI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local pi = y * c.w + x
  if c.own[pi] == blT and (x - 16) % 5 == 2 then c.pix[pi] = TEAL[math.min(4, p)]:lower() end
end
O.mark(c, { { 25, 18 }, { 24, 19 }, { 26, 19 }, { 25, 20 } }, GOLD[3]) -- diamond motif
local sk = c:ellipse(25, 13.5, 3.5, 2.5)
O.shade(c, sk, SACK, { R = 1, amb = .35, wrap = .4, sep = SACK[1] })
-- pennant pole + flag forward
O.flat(c, c:rect(20, 3, 20, 16), WOOD[3], "pole") O.dot(c, 20, 8, WOOD[4]) O.dot(c, 20, 12, WOOD[4])
local flag = c:poly{ { 19, 3 }, { 13, 5 }, { 19, 7 } }
O.shade(c, flag, PEN, { R = 1, amb = .4, cuts = { .3, .55, .8 }, sep = WOOD[1] })

-- head
O.flat(c, c:line({ { 6, 15 }, { 4, 13 }, { 4, 10 } }, 1), HORN[3], "horn") O.dot(c, 4, 10, HORN[4])
O.flat(c, c:line({ { 14, 15 }, { 16, 13 }, { 16, 10 } }, 1), HORN[2], "horn") O.dot(c, 16, 10, HORN[3])
local head = c:ellipse(10, 20, 5.5, 5)
O.shade(c, head, FUR, { sphere = { 9, 18, 6 }, amb = .28, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
local lock = c:poly{ { 5, 17 }, { 7, 14 }, { 10, 14 }, { 13, 14 }, { 15, 17 }, { 13, 17 }, { 11, 18 }, { 9, 17 }, { 7, 18 } }
O.shade(c, lock, LOCK, { R = 1, amb = .4, cuts = { .25, .45, .65, .85 }, sep = FUR[1] })
local mz = c:ellipse(10, 23.5, 3, 1.5)
O.shade(c, mz, MUZ, { R = 1, amb = .45, cuts = { .3, .55, .8 }, sep = FUR[1] })
O.dots(c, { { 9, 23 }, { 11, 23 } }, MUZ[1])
-- pale eye patches so the pills read against the dark fur
for _, ex in ipairs({ 7, 12 }) do
  O.mark(c, { { ex - 1, 19 }, { ex - 1, 20 }, { ex - 1, 21 }, { ex + 2, 19 }, { ex + 2, 20 }, { ex + 2, 21 }, { ex, 22 }, { ex + 1, 22 } }, LOCK[2])
  c:eyeSmall(ex, 19)
end
O.dot(c, 5, 22, "#f5809f") O.dot(c, 15, 22, "#f5809f")
O.mark(c, { { 4, 12 }, { 16, 12 } }, HORN[1]) -- horn rings
-- chin bell
O.flat(c, c:rect(9, 26, 11, 27), GOLD[3], "bell") O.dot(c, 9, 26, GOLD[4]) O.dot(c, 11, 27, GOLD[2]) O.dot(c, 10, 28, HOOF[1])

O.shift(c, 0, 0)
O.done(c, "sp-yak-yonder-perch")
