-- Acorn Nip (mw-acorn-nip), perch sprite 36x36 (treehouse, shown at 36x36). Opus pass, hand-built
-- at this size (not a downscale): fewer cap scales, 2x3 pill eyes, 1px cheeks, tail as a single curl.
-- quirk: the forgotten baby acorn, here 3x4 px on the cap beside the stalk.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("acorn-nip-perch", 36)

local NUT  = { "#5c3322", "#8e532e", "#bd7a3c", "#dc9d4f", "#f0c06e", "#fae0a0" }
local CAP  = { "#3a2630", "#573a35", "#77553c", "#967046", "#b48e58", "#d1af76" }
local FUR  = { "#5e2626", "#923a2a", "#c45a30", "#e27d3c", "#f2a35e", "#fbca8c" }
local CRM  = { "#c08a66", "#d9a982", "#ecc7a0", "#f7e0bd", "#fdeccc" }

c:groundShadow(16, 33, 11, 2)

-- tail
local tm, tn = O.tube({ { 21, 31 }, { 31, 30 }, { 33, 15 }, { 25, 8 } },
  function(t) return 1.8 + 2.5 * math.sin(math.pi * math.min(1, t * 1.15)) end)
O.shadeN(c, tm, tn, FUR, { amb = .2, wrap = .4 })
O.mark(c, { {28,25},{29,24}, {29,18},{30,17} }, FUR[2])
O.dots(c, { {24,8},{25,7} }, FUR[6])

-- ears
O.shade(c, c:poly{ {5,14}, {4,4}, {10,11} }, FUR, { R = 1 })
O.shade(c, c:poly{ {26,14}, {27,4}, {21,11} }, FUR, { R = 1 })
O.dots(c, { {5,8},{6,9},{6,10} }, "#c94f84")
O.dots(c, { {26,8},{25,9},{25,10} }, "#b5425f")

-- nut body
local body = c:ellipse(15.5, 24.5, 9, 8.5)
O.shade(c, body, NUT, { sphere = { 14, 22, 10 }, amb = .15, wrap = .3 })
O.mark(c, { {9,28},{9,29},{22,28},{22,29},{21,30} }, NUT[2]) -- shell stripes
-- muzzle + belly
O.shade(c, c:ellipse(15.5, 25.5, 3.5, 2), CRM, { R = 1, amb = .5 })
local belly = c:ellipse(15.5, 30.5, 3.5, 1.5)
O.shade(c, belly, CRM, { R = 1, amb = .4 })

-- cap
local cap = c:ellipse(15.5, 15.5, 10.5, 5.5)
cap:cut(c:rect(0, 19, 35, 35))
for x = 5, 26, 3 do cap:cut(c:rect(x, 18, x, 18)) end
local cb = {}
cap:each(function(x, y)
  if y % 3 == 1 and (x + (y // 3) % 2 * 2) % 4 == 0 then cb[K(x, y)] = -1 end
  if y % 3 == 0 and (x + (y // 3) % 2 * 2) % 4 == 3 then cb[K(x, y)] = 1 end
  if y == 18 then cb[K(x, y)] = (cb[K(x, y)] or 0) - 1 end
end)
O.shade(c, cap, CAP, { R = 3, bias = cb, amb = .25, wrap = .35 })
-- stalk
O.dots(c, { {16,9},{16,8},{17,7},{18,7} }, CAP[2])
O.dot(c, 16, 8, CAP[4])

-- quirk: baby acorn in the cap
O.dots(c, { {11,6},{12,6},{13,6},{14,6} }, CAP[4]) O.dot(c, 12, 6, CAP[6])
O.dot(c, 13, 5, CAP[2])
O.dots(c, { {11,7},{12,7},{12,8} }, NUT[5]) O.dots(c, { {13,7},{13,8} }, NUT[4]) O.dots(c, { {14,7},{11,8} }, NUT[3])
O.dots(c, { {12,9},{13,9} }, NUT[2])

-- paws + feet
O.dots(c, { {11,28},{12,28} }, FUR[4]) O.dot(c, 12, 29, FUR[2]) O.dot(c, 11, 29, FUR[3])
O.dots(c, { {19,28},{20,28} }, FUR[4]) O.dot(c, 20, 29, FUR[2]) O.dot(c, 19, 29, FUR[3])
O.dots(c, { {9,33},{10,33},{11,33},{12,33} }, FUR[3]) O.dot(c, 9, 33, FUR[4])
O.dots(c, { {19,33},{20,33},{21,33},{22,33} }, FUR[3]) O.dot(c, 22, 33, FUR[2])

-- face
c:eyeSmall(11, 20)
c:eyeSmall(19, 20)
O.dots(c, { {9,24},{10,24} }, "#f5809f") O.dots(c, { {21,24},{22,24} }, "#f5809f")
O.dots(c, { {15,24},{16,24} }, P.ink)
O.dots(c, { {14,26},{17,26} }, "#6e2c2a") O.dots(c, { {15,26},{16,26} }, "#a8483a")

O.shift(c, 0, -1)
O.done(c, "acorn-nip-perch")
