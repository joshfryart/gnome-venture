-- Samovar Puff (bb-samovar-puff), yard sprite 64x64. Opus richness pass (c03/opus3), built on c03/opus2.
-- Richness pass: hammered brass (hue-shifted 6-tone ramp, a tall specular streak, deeper flutes with lit ridges,
-- patina flecks in the shade), stamped fair medals on the band, a curlier steam puff, a Gzhel-blue painted cup.
-- closer look: a poppy-seed bublik (bagel) hung on a string from its left ring handle, for the tea nobody asked for. Common, brewroot, Birchbramble. "Steams up the porch and pours tea nobody asked for."
-- A plump brass samovar: flared footed plinth, pear-shaped fluted urn with an engraved band, two ring handles,
-- a crowned collar and a short chimney puffing one curly steam cloud (fixes the two grey balls of the first pass).
-- Face on the urn belly. quirk: its tap is open and tea is overflowing a little cup on a saucer nobody put out.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-samovar-puff-yard", 64)

local BR   = { "#46201c", "#7a3a20", "#a85e28", "#d4963a", "#eec468", "#faeaae" }
local DK   = { "#3a1c16", "#5c2e1a", "#86501f", "#b07a2c", "#d6a84a", "#eccf7e" }
local STM  = { "#7c7f9e", "#a6a9c2", "#cdd0e0", "#eceef5" }
local TEA  = { "#4e2212", "#7e3c18", "#b5662a", "#dc9a4e" }
local CUP  = { "#5a5c84", "#8a8db0", "#bfc2d8", "#e6e8f1" }
local GZ   = "#3a5aa8"
local BUB  = { "#7a3a1c", "#b8743a", "#e0aa62", "#f6d696" }
local PAT  = "#5a7a6a"

c:groundShadow(32, 58, 21, 3)

-- feet and flared plinth
for _, fx in ipairs({ 21, 39 }) do O.shade(c, c:ellipse(fx, 56, 3, 1.5), DK, { R = 1, amb = .25 }) end
local plinth = c:poly{ { 22, 48 }, { 38, 48 }, { 43, 54 }, { 17, 54 } }
O.shade(c, plinth, DK, { R = 2, amb = .25, sep = DK[1], rim = true })
O.dots(c, { { 21, 52 }, { 24, 52 }, { 27, 52 }, { 30, 52 }, { 33, 52 }, { 36, 52 }, { 39, 52 } }, DK[6])

-- ring handles (behind the urn edge)
for _, hx in ipairs({ 15, 45 }) do
  local ring = c:ellipse(hx, 31, 3.5, 4.5)
  ring:cut(c:ellipse(hx, 31, 1.5, 2.5))
  O.shade(c, ring, DK, { R = 1, amb = .3, rim = true })
end

-- urn body: pear shape, fluted lower half
local body = c:ellipse(30, 38, 14, 10.5)
body:add(c:ellipse(30, 30, 10.5, 6))
local bI, bT = O.shade(c, body, BR, { sphere = { 26, 32, 17 }, amb = .2, wrap = .4, sep = BR[1], rim = true, bounce = "#8a6a8c", bmax = 2 })
O.tex(c, bI, bT, BR, function(x, y, i)
  if y >= 42 and (x - 30) % 4 == 0 and i >= 2 then return -1 end -- flutes
  if y >= 42 and (x - 30) % 4 == 1 and i <= 5 then return 1 end  -- lit flute ridge
  if (x == 19 or x == 20) and y >= 32 and y <= 41 and i >= 3 then return 6 - i end -- tall specular streak
  local face = x > 20 and x < 41 and y > 31 and y < 46
  if not face and y < 42 and H(x, y, 31) > .9 and i >= 3 and i <= 5 then return 1 end -- hammered glints
end)
-- patina flecks in the shaded lower right
O.mark(c, { { 40, 44 }, { 41, 41 }, { 38, 47 }, { 42, 38 } }, PAT)
-- engraved band with gold studs
for x = 17, 43 do if body:has(x, 28) then c:put(x, 28, BR[2], bT) end if body:has(x, 29) then c:put(x, 29, BR[5], bT) end end
-- stamped fair medals on the band (round, lit upper-left, dark lower-right)
for _, mx in ipairs({ 21, 27, 33, 39 }) do
  O.mark(c, { { mx, 28 }, { mx + 1, 28 } }, BR[6]) O.mark(c, { { mx, 29 }, { mx + 1, 29 } }, BR[4])
  O.mark(c, { { mx + 1, 30 } }, BR[2])
end

-- crowned collar and chimney
local collar = c:rect(23, 22, 37, 25)
collar:add(c:poly{ { 22, 22 }, { 38, 22 }, { 36, 20 }, { 24, 20 } })
O.shade(c, collar, DK, { R = 1, amb = .3, sep = DK[1], rim = true })
O.dots(c, { { 24, 19 }, { 28, 19 }, { 32, 19 }, { 36, 19 } }, DK[5])
local chim = c:rect(27, 12, 33, 19)
O.shade(c, chim, BR, { R = 2, amb = .25, sep = BR[1], rim = true })
O.shade(c, c:rect(25, 10, 35, 12), DK, { R = 1, amb = .3, sep = DK[1] })
O.dots(c, { { 26, 10 }, { 27, 10 }, { 28, 10 } }, DK[6])

-- one curly steam puff rising off the chimney
local stm = O.unionCircles{ { 27, 6, 3, 2.5 }, { 32, 4.5, 3.5, 3 }, { 37, 6.5, 2.5, 2 } }
stm:add(c:rect(25, 6, 39, 8))
O.shade(c, stm, STM, { R = 2, amb = .4, cuts = { .3, .55, .8 }, rim = true })
O.dots(c, { { 31, 5 }, { 32, 5 }, { 33, 6 }, { 33, 7 }, { 32, 7 }, { 31, 6 } }, STM[2]) -- curl inside the puff
O.dots(c, { { 26, 7 }, { 36, 7 } }, STM[1])
O.dots(c, { { 41, 5 } }, STM[3]) O.dots(c, { { 43, 3 } }, STM[4])

-- tap: spout out of the lower right with a valve knob
local sp, sn = O.tube({ { 39, 44 }, { 43, 43 }, { 46, 44 }, { 48, 46 } }, function(t) return 1.6 - t * .5 end)
O.shadeN(c, sp, sn, DK, { amb = .3, sep = DK[1] })
O.shade(c, c:rect(43, 40, 45, 41), BR, { R = 1, amb = .4, sep = BR[1] })

-- face
c:eyeLocked(23, 34) c:eyeLocked(33, 34)
c:cheek(20, 40) c:cheek(39, 40)
O.dots(c, { { 27, 41 }, { 28, 42 }, { 29, 42 }, { 30, 42 }, { 31, 42 }, { 32, 41 } }, P.ink)
O.dot(c, 29, 43, "#e05a6a") O.dot(c, 30, 43, "#e05a6a")

-- quirk: little cup on a saucer, overflowing with tea nobody asked for
local sau = c:ellipse(53, 55.5, 6.5, 1.5)
O.shade(c, sau, CUP, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
local cup = c:rrect(49, 49, 56, 54, 2)
cup:add(c:rect(49, 49, 56, 51))
O.shade(c, cup, CUP, { R = 2, amb = .35, cuts = { .3, .55, .8 }, sep = CUP[1], rim = true })
O.flat(c, c:rect(57, 50, 58, 51), CUP[2], "handle") O.dot(c, 58, 52, CUP[2])
O.mark(c, { { 50, 52 }, { 52, 53 }, { 54, 52 }, { 51, 52 }, { 53, 53 } }, GZ) -- Gzhel-blue painted band
O.mark(c, { { 48, 56 }, { 52, 56 }, { 56, 56 } }, GZ)
O.dots(c, { { 50, 49 }, { 51, 49 }, { 52, 49 }, { 53, 49 }, { 54, 49 }, { 55, 49 } }, TEA[3])
O.dots(c, { { 51, 48 }, { 52, 48 }, { 53, 48 }, { 54, 48 } }, TEA[3]) O.dots(c, { { 52, 48 } }, TEA[4])
O.dots(c, { { 50, 50 }, { 51, 50 }, { 52, 50 }, { 53, 50 }, { 54, 50 }, { 55, 50 } }, TEA[2])
O.dots(c, { { 50, 50 }, { 50, 51 }, { 49, 52 } }, TEA[2]) -- spill down the side
O.dots(c, { { 48, 55 }, { 49, 55 }, { 50, 55 } }, TEA[3]) -- puddle on the saucer
-- the stream from the tap
O.dots(c, { { 49, 47 }, { 49, 48 } }, TEA[3])
O.dots(c, { { 50, 47 } }, TEA[4])

-- closer look: a poppy-seed bublik hung on the left ring handle
O.flat(c, c:line({ { 12, 35 }, { 11, 38 } }, 1), "#8a7a6a", "string")
for _, b in ipairs({ { 11, 42 } }) do
  local r = c:ellipse(b[1], b[2], 3.5, 3)
  r:cut(c:rect(b[1] - 1, b[2] - 1, b[1], b[2])) -- the hole (inked by the outline)
  O.shade(c, r, BUB, { R = 1, amb = .35, wrap = .4, cuts = { .3, .6, .85 }, sep = BUB[1] })
end
O.mark(c, { { 9, 40 }, { 12, 39 }, { 13, 42 }, { 9, 44 }, { 11, 45 } }, "#4a2e2e") -- poppy seeds

O.shift(c, -3, 1)
O.done(c, "bb-samovar-puff-yard")
