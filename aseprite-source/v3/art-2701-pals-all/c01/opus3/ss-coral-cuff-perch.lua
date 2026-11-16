-- Coral Cuff (ss-coral-cuff), perch sprite 36x36. Opus third pass (c01/opus3), richness pass over opus2.
-- Richness kept bold for 36 px: hue-shifted 6-tone coral, light from the upper-left with the core shadow kept off
-- the face, 2 px polyp cups, a twisted gold braid with a sea-glass clasp, pink anemone tips (no starfish at 36 px).
-- The cuff is lower and wider than on the yard so the pill eyes and smile get the middle of the band;
-- open top, gold band, porous skin cut to a few pores; four reefs kept but simplified to bold 2-3 px shapes
-- (red staghorn fork, orange fan, yellow tubes, teal anemone).
-- quirk: the clownfish, here a 3x2 orange-and-white dash beside the fan.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("ss-coral-cuff-perch", 36)

local COR  = { "#55203f", "#8a3155", "#c24a6a", "#e8717f", "#f69c96", "#fcd2be" }
local GOLD = { "#5e3a1c", "#9a5d1e", "#d08a2a", "#f0b440", "#f8d670", "#fdf0b0" }
local RED  = { "#5a1630", "#9a2238", "#d23a3a", "#f06a4a", "#fba070" }
local ORG  = { "#6a2e24", "#b0522a", "#e8803a", "#f8b05a", "#fcd890" }
local YEL  = { "#6a4a1c", "#b88a28", "#ecc23a", "#f8e47a" }
local TEAL = { "#173f4a", "#1f6a6a", "#2f9a8a", "#5cc8a8", "#a8ecc8" }

c:groundShadow(18, 32, 13, 1.5)
for _, fx in ipairs({ 13, 23 }) do O.shade(c, c:ellipse(fx, 30, 2.5, 1.5), COR, { R = 1, amb = .25, sep = COR[1] }) end

local body = c:rect(5, 15, 30, 26)
body:add(c:ellipse(17.5, 15, 12.5, 3.5)):add(c:ellipse(17.5, 26, 12.5, 3.5))
local bn = O.cylN(body, 20, 15, -.1)
local pn = X.pillow(body, 3)
for k, v in pairs(bn) do
  local q = pn[k]
  if q then
    local a, b, z = v[1] * .7 + q[1] * .5, v[2] * .7 + q[2] * .5, v[3] * .7 + q[3] * .5
    local l = math.sqrt(a * a + b * b + z * z) bn[k] = { a / l, b / l, z / l }
  end
end
local bI, bT = O.shadeN(c, body, bn, COR, { amb = .1, wrap = .3, sep = COR[1], rim = true, bounce = "#4a7690", bmax = 1 })
O.pits(c, bI, bT, COR, { sx = 5, sy = 4, seed = 2, skip = function(x, y) return (x > 9 and x < 26 and y < 25) or y < 18 end })
local hole = c:ellipse(17.5, 15, 10, 2)
hole:each(function(x, y)
  local col = COR[2]
  if y <= 14 then col = (x > 16) and COR[4] or COR[3] end
  if y >= 16 then col = COR[1] end
  c:put(x, y, col, bT)
end)
for x = 9, 26 do c:put(x, 18, x < 20 and COR[6] or COR[5], bT) end -- front lip
for x = 6, 29 do -- gold band
  local dy = 3.5 * math.sqrt(math.max(0, 1 - ((x + .5 - 18) / 13) ^ 2))
  local y = math.floor(24 + dy + .5)
  local g = (x < 14) and 5 or (x < 24 and 4 or 3)
  if x <= 6 or x >= 29 then g = 2 end
  c:put(x, y, x % 3 == 0 and GOLD[math.min(6, g + 1)] or (x % 3 == 2 and GOLD[g - 1] or GOLD[g]), bT)
  if c:get(x, y + 1) then c:put(x, y + 1, COR[2], bT) end
end
O.shade(c, c:ellipse(18, 27.5, 1.5, 1.5), GOLD, { R = 1, amb = .3, sep = GOLD[1] })
O.dot(c, 17, 27, TEAL[5]) O.dot(c, 18, 27, TEAL[4]) O.dot(c, 17, 28, TEAL[4]) O.dot(c, 18, 28, TEAL[2])


-- knobs + reefs
for _, k in ipairs({ { 7, 13 }, { 14, 12 }, { 22, 12 }, { 28, 13 } }) do
  O.shade(c, c:ellipse(k[1], k[2], 1.5, 1.5), COR, { R = 1, amb = .3, sep = COR[2] })
end
local st = HP.mask()
st:add(c:line({ { 7, 11 }, { 7, 8 }, { 5, 6 } }, 1)):add(c:line({ { 7, 9 }, { 9, 6 } }, 1))
O.shade(c, st, RED, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 5, 6 }, { 9, 6 } }, RED[5])
local fan = c:ellipse(13.5, 7.5, 3, 3)
fan:cut(c:rect(8, 10, 20, 14)):add(c:rect(13, 9, 14, 10))
O.shade(c, fan, ORG, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 }, sep = ORG[1] })
O.dots(c, { { 13, 6 }, { 12, 7 }, { 15, 7 } }, ORG[2]) O.dot(c, 12, 5, ORG[5])
-- clownfish
O.flat(c, c:rect(18, 6, 19, 7), ORG[4], "fish") O.dot(c, 20, 7, "#fcecd8") O.dot(c, 20, 6, P.ink)
for _, t in ipairs({ { 21, 9 }, { 23, 7 } }) do
  O.shade(c, c:rect(t[1], t[2], t[1] + 1, 11), YEL, { R = 1, amb = .3, cuts = { .3, .6, .85 }, sep = YEL[1] })
  O.dot(c, t[1], t[2], YEL[1]) O.dot(c, t[1] + 1, t[2], YEL[2])
end
local an = c:ellipse(28, 11, 2, 1)
an:add(c:line({ { 27, 10 }, { 26, 7 } }, 1)):add(c:line({ { 29, 10 }, { 30, 7 } }, 1)):add(c:line({ { 28, 10 }, { 28, 7 } }, 1))
O.shade(c, an, TEAL, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 26, 7 }, { 28, 7 }, { 30, 7 } }, "#f79ab8")
O.dot(c, 31, 4, "#bfe8f0")


-- face
c:eyeSmall(12, 19)
c:eyeSmall(22, 19)
O.dot(c, 9, 22, P.petal.base) O.dot(c, 26, 22, P.petal.base)
O.dots(c, { { 15, 22 }, { 16, 23 }, { 17, 23 }, { 18, 23 }, { 19, 23 }, { 20, 22 } }, P.ink)

O.done(c, "ss-coral-cuff-perch")
