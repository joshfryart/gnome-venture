-- Stitch Crow (mh-stitch-crow), yard sprite 64x64. Opus richness pass (c00/opus3), built on c00/opus2.
-- Richness pass: a stronger two-part beak (lit upper mandible, darker lower, nostril), violet-teal sheen on the
-- crown and nape, layered breast and wing feathers, bolder tape ticks (every 3 px, alternate long), the locked eyes
-- left whole (opus2 painted lids over them; now the eyes sit tight under the brim, which shades the brow), and a stitched
-- patch on the wing: an ember cloth square sewn on with gold cross-stitches, like a scarecrow's mended sleeve.
-- Thornblade, uncommon, Maizehollow. "A scarecrow's apprentice, very serious about hats."
-- A small crow in proper crow-black (cool slate ramp with a violet sheen, not purple) wearing a far too big
-- woven straw hat set dead level, ember hat band. Gold beak, half-lidded serious eyes, folded wing with primary
-- lines, straw poking out of its wing cuff like a scarecrow's sleeve, orange feet.
-- quirk: a cream tailor's measuring tape hung round its neck (it measures hats).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mh-stitch-crow-yard", 64)

local CROW = { "#17121f", "#241d32", "#342c48", "#4a4566", "#686a8e", "#9399bc" }
local STRW = { "#7a4a1f", "#a8702a", "#d49a3a", "#ecc05a", "#f8dc86", "#fff0b4" }
local BAND = { "#5a1a30", "#8a2438", "#c43a3e", "#ee6248" }
local BEAK = { "#7a3a1a", "#c27022", "#f5b82e", "#ffe38a" }
local TAPE = { "#a89070", "#d8c8a0", "#f4ead0" }
local FEET = { "#8f4a1f", "#d98322", "#f5a83a" }

c:groundShadow(31, 57, 15, 2.5)

-- tail feathers fanned down-left behind the body
for _, f in ipairs({ { 20, 46, 9, 55, 2.6 }, { 22, 47, 12, 57, 2.6 }, { 24, 48, 16, 58, 2.4 } }) do
  local m, n = O.tube({ { f[1], f[2] }, { (2 * f[1] + f[3]) / 3, (2 * f[2] + f[4]) / 3 }, { (f[1] + 2 * f[3]) / 3, (f[2] + 2 * f[4]) / 3 }, { f[3], f[4] } },
    function(t) return f[5] * (1 - .4 * t) end)
  O.shadeN(c, m, n, CROW, { amb = .25, wrap = .4, sep = CROW[1], rim = true })
end
-- feet
for _, fx in ipairs({ 27, 35 }) do
  O.flat(c, c:rect(fx, 51, fx + 1, 54), FEET[2], "leg")
  O.flat(c, c:rect(fx - 2, 55, fx + 3, 55), FEET[2], "toes")
  O.dots(c, { { fx, 51 }, { fx - 2, 55 } }, FEET[3]) O.dot(c, fx + 1, 54, FEET[1])
end
-- body
local body = c:ellipse(31, 41, 13, 11)
local bI, bT = O.shade(c, body, CROW, { sphere = { 26, 34, 17 }, amb = .2, wrap = .35, rim = true, bounce = "#4a5a7a", bmax = 2 })
-- breast feather scallops
O.tex(c, bI, bT, CROW, function(x, y, i)
  local row = y // 3
  local u = (x + row * 2) % 4
  if x < 26 or y <= 37 then return 0 end
  if y % 3 == 0 and (u == 1 or u == 2) and i >= 3 then return -1 end   -- scallop edges, lit side only
  if y % 3 == 1 and u == 1 and i == 3 then return 1 end              -- feather tips catching light
end)
-- head
local head = c:ellipse(32, 27, 10, 8.5)
local hI, hT = O.shade(c, head, CROW, { sphere = { 28, 23, 12 }, amb = .25, wrap = .35, rim = true })
-- brim cast shadow over the brow, iridescent sheen on the nape
O.tex(c, hI, hT, CROW, function(x, y, i) if y <= 22 then return -1 end end)
O.mark(c, { { 23, 27 }, { 23, 28 }, { 24, 29 }, { 24, 30 }, { 25, 31 } }, "#6a74a8")
O.mark(c, { { 23, 26 }, { 24, 28 } }, "#8a7ab8")

-- quirk: measuring tape round the neck, one end hanging down the chest
local tape = HP.mask()
for x = 23, 42 do local y = 34 + math.floor(((x - 32.5) / 9.5)^2 * -2 + 2.5) tape:add(c:rect(x, y, x, y + 1)) end
tape:add(c:rect(38, 35, 39, 46))
local tI, tT = O.shade(c, tape, TAPE, { R = 1, amb = .6, wrap = .6, cuts = { .2, .5 } })
tape:each(function(x, y)
  local q = y * c.w + x
  if c.own[q] ~= tT then return end
  if x >= 38 and y >= 37 then -- hanging end: ticks across, long every other
    if y % 3 == 0 and (x == 39 or y % 6 == 0) then c.pix[q] = P.ink end
  elseif x % 3 == 0 and (not tape:has(x, y - 1) or x % 6 == 0) then c.pix[q] = P.ink end
end)
O.flat(c, c:rect(38, 47, 39, 48), BEAK[2], "tab") O.dot(c, 38, 47, BEAK[4])

-- folded wing with primaries, straw sticking out of the cuff
local wing, wn = O.tube({ { 22, 34 }, { 18, 39 }, { 18, 46 }, { 22, 50 } }, function(t) return 5 * (1 - .5 * t) end)
local wI, wT = O.shadeN(c, wing, wn, CROW, { amb = .25, wrap = .4, sep = CROW[1] })
O.tex(c, wI, wT, CROW, function(x, y, i) if y > 40 and (x + y) % 3 == 0 and i >= 2 then return -1 end end)
-- stitched patch on the wing (quirk detail)
local patch = c:rect(17, 39, 21, 43)
O.shade(c, patch, BAND, { R = 1, amb = .35, wrap = .4, cuts = { .3, .6, .82 }, sep = CROW[1] })
O.mark(c, { { 18, 41 }, { 20, 41 }, { 19, 40 }, { 19, 42 } }, BAND[2])
O.dots(c, { { 16, 39 }, { 16, 41 }, { 16, 43 }, { 22, 40 }, { 22, 42 }, { 18, 38 }, { 20, 38 }, { 19, 44 }, { 21, 44 } }, "#f2c04a")
for _, s in ipairs({ { { 21, 49 }, { 20, 52 }, { 19, 53 }, { 17, 54 } }, { { 23, 50 }, { 23, 52 }, { 24, 54 }, { 24, 55 } }, { { 22, 50 }, { 21, 52 }, { 21, 54 }, { 21, 56 } } }) do
  local m, n = O.tube(s, function(t) return .7 end)
  O.shadeN(c, m, n, STRW, { amb = .4, wrap = .5 })
end

-- beak
local upper = c:poly{ { 38, 25 }, { 47, 27 }, { 51, 30 }, { 38, 30 } }
O.shade(c, upper, BEAK, { R = 1, amb = .4, wrap = .45, cuts = { .25, .5, .75 }, sep = CROW[1] })
local lower = c:poly{ { 38, 31 }, { 48, 31 }, { 38, 34 } }
local lI2, lT2 = O.shade(c, lower, BEAK, { R = 1, amb = .2, wrap = .3, cuts = { .35, .7, .95 }, sep = CROW[1] })
O.dots(c, { { 39, 31 }, { 40, 31 }, { 41, 31 }, { 42, 31 }, { 43, 31 }, { 44, 31 }, { 45, 31 }, { 46, 31 }, { 47, 31 } }, BEAK[1])
O.dots(c, { { 39, 26 }, { 40, 26 }, { 41, 27 } }, BEAK[4])
O.dot(c, 41, 28, BEAK[1])

-- the too-big straw hat, perfectly level
local crown = c:rrect(21, 5, 43, 17, 4)
local cI2, cT2 = O.shade(c, crown, STRW, { R = 4, amb = .25, wrap = .4, rim = true })
O.tex(c, cI2, cT2, STRW, function(x, y, i) if (x + y) % 4 == 0 or (x - y) % 4 == 0 then return -1 end end) -- weave
O.mark(c, { { 27, 5 }, { 28, 5 }, { 29, 5 }, { 30, 5 }, { 31, 5 }, { 32, 5 }, { 33, 5 }, { 34, 5 }, { 35, 5 }, { 36, 5 }, { 37, 5 } }, STRW[3]) -- pinched top
local band = c:rect(21, 14, 43, 17)
O.shade(c, band, BAND, { R = 1, amb = .35, wrap = .4, cuts = { .3, .6, .82 }, sep = STRW[1] })
local brim = c:ellipse(32, 19.5, 21, 3.5)
brim:cut(c:rect(21, 0, 43, 17))
local rI, rT = O.shade(c, brim, STRW, { R = 2, amb = .3, wrap = .4, sep = STRW[2] })
O.tex(c, rI, rT, STRW, function(x, y, i) if x % 3 == 0 then return -1 end end)

-- face: half-lidded, very serious eyes
c:eyeLocked(25, 24)
c:eyeLocked(33, 24)
-- pale eye rings so the cream discs sit on a lighter ground, not straight on crow-black
for _, ex in ipairs({ 25, 33 }) do O.mark(c, { { ex - 1, 25 }, { ex - 1, 26 }, { ex - 1, 27 }, { ex + 5, 25 }, { ex + 5, 26 }, { ex + 5, 27 } }, CROW[5]) end

O.shift(c, -1, 0)
O.done(c, "mh-stitch-crow-yard")
