-- Lofty Kite (sp-lofty-kite), perch sprite 36x36. Opus richness pass (c06/opus3), hand-built at this size.
-- Same design as the yard, fewer and bolder parts: tilted diamond kite, sea-blue top panels over a saffron
-- lower half (where the face sits), bamboo cross spar, ribbon tail in an S with two bows.
-- Richness: a darker hem band with gold stitches, bamboo node marks, a twisted ribbon, snow on the ridge.
-- Face: c:eyeSmall pills under heavy flat lids, smug smile.
-- quirk: it looks down on everything: a tiny snowy ridge far below, peered at down its nose.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sp-lofty-kite-perch", 36)

local SEA  = { "#1a2c58", "#24448a", "#2e64b4", "#4a8ad6", "#7cb2ea", "#b8daf8" }
local SAF  = { "#7a3a1a", "#b4601e", "#e48e26", "#f6b442", "#ffd47a", "#fff0bc" }
local RIB  = { "#6e1a3a", "#b0305a", "#e05a7e", "#fa9ab0" }
local ROCK = { "#3e3654", "#5e5878", "#8682a0", "#b4b2c6" }
local BNC  = "#3a6a7a"

local ridge = c:poly{ { 23, 34 }, { 27, 28 }, { 29, 30 }, { 31, 26 }, { 35, 34 } }
O.shade(c, ridge, ROCK, { R = 1, amb = .3, cuts = { .3, .55, .8 } })
O.mark(c, { { 27, 28 }, { 26, 29 }, { 27, 29 }, { 31, 26 }, { 30, 27 }, { 31, 27 }, { 32, 27 } }, "#f8f8f4")

local tail = { { 20, 24 }, { 12, 27 }, { 22, 30 }, { 14, 35 } }
for i = 0, 60 do local x, y = O.bez(tail, i / 60) O.dot(c, math.floor(x + .5), math.floor(y + .5), ((i // 8) % 2 == 0) and RIB[3] or RIB[2]) end
for n, t in ipairs({ .35, .8 }) do
  local x, y = O.bez(tail, t) x, y = math.floor(x + .5), math.floor(y + .5)
  local R = n == 1 and RIB or { "#7a3a1a", "#e48e26", "#f6b442", "#ffd47a" }
  O.flat(c, c:poly{ { x, y }, { x - 2, y - 1 }, { x - 2, y + 1 } }, R[3], "bow")
  O.flat(c, c:poly{ { x, y }, { x + 2, y - 1 }, { x + 2, y + 1 } }, R[2], "bow")
  O.dot(c, x - 2, y - 1, R[4]) O.dot(c, x, y, R[1])
end

local T, R, B, L = { 16, 2 }, { 32, 7 }, { 20, 24 }, { 3, 10 }
local kite = c:poly{ T, R, B, L }
local top, bot = HP.mask(), HP.mask()
kite:each(function(x, y)
  local s2 = (x - L[1]) * (R[2] - L[2]) - (y - L[2]) * (R[1] - L[1])
  if s2 > 0 then top:set(x, y) else bot:set(x, y) end
end)
local n = X.pillow(kite, 4)
O.shadeN(c, top, n, SEA, { amb = .3, wrap = .4, rim = true })
O.shadeN(c, bot, n, SAF, { amb = .26, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
local hem = kite:edge()
kite:each(function(x, y) if not hem:has(x, y) then
  for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do if hem:has(x + d[1], y + d[2]) then
    local q = y * c.w + x c.pix[q] = ((x + y) % 3 == 0) and "#ffd866" or (top:has(x, y) and SEA[2] or SAF[2]) break end end end end)
for i = 0, 28 do
  local x, y = math.floor(4 + i + .5), math.floor(10 - 3 * i / 28 + .5)
  if c:get(x, y) then c.pix[y * c.w + x] = (i % 6 == 3) and "#5a4228" or "#8a6a3e" end
end

c:eyeSmall(11, 13) c:eyeSmall(19, 12)
O.dots(c, { { 10, 12 }, { 11, 12 }, { 12, 12 }, { 13, 12 }, { 18, 11 }, { 19, 11 }, { 20, 11 }, { 21, 11 } }, SAF[1])
O.dots(c, { { 14, 18 }, { 15, 18 }, { 16, 17 }, { 17, 17 } }, P.ink)
c:cheek(8, 16) c:cheek(22, 15)

O.done(c, "sp-lofty-kite-perch")
