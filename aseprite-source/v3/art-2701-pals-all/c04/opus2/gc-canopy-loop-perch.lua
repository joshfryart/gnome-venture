-- Canopy Loop (gc-canopy-loop), perch sprite 36x36. Opus second pass (c04/opus2), hand-built at this size:
-- the scalloped leaf clump hanging by its vine loop from a rope, a pink hibiscus, a raised leaf-hand,
-- face in the middle of the clump (2x3 pills, smile, cheeks).
-- quirk: a tiny red parrot (hand-placed pixels) sitting on the rope, being greeted.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gc-canopy-loop-perch", 36)

local LEAF  = { "#173a2c", "#1f5a3a", "#2f7a3e", "#4f9e46", "#82c25a", "#bde28a" }
local VINE  = { "#3a2a1e", "#5e4a2a", "#86703a", "#a89a52" }
local ROPE  = { "#6a4a2a", "#a8804e", "#d4b47a" }
local BIRD  = { "#5a1424", "#a82632", "#d8402e", "#f0703e" }
local FLOW  = { "#7a1e4a", "#c83a6a", "#f0709a", "#fbb0c4" }

-- rope
for x = 2, 33 do
  local y = 6 + ((x > 8 and x < 27) and 1 or 0)
  O.dot(c, x, y, (x % 3 == 0) and ROPE[1] or ROPE[2])
end
-- parrot
local B = { ".rr.", "rrrb", "wrr.", "wrr.", ".yy." }
local BM = { r = BIRD[3], b = "#f5dc9a", w = "#2f63a8", y = "#f0be38" }
for j, row in ipairs(B) do for i = 1, 4 do local ch = row:sub(i, i) if BM[ch] then O.dot(c, 3 + i, j, BM[ch]) end end end
O.dot(c, 5, 1, BIRD[4]) O.dot(c, 6, 2, P.ink)
-- vine + loop
O.flat(c, c:rect(17, 10, 17, 14), VINE[3], "vine") O.dot(c, 18, 10, VINE[3])
local loop = c:ellipse(19, 6, 2.5, 2.5) loop:cut(c:rect(19, 6, 19, 6))
O.flat(c, loop, VINE[3], "loop") O.dots(c, { { 17, 5 }, { 18, 4 } }, VINE[4])
for x = 17, 21 do O.dot(c, x, 7, (x % 3 == 0) and ROPE[1] or ROPE[2]) end

-- leafy clump
local CX, CY = 17, 22
local circ = { { CX, CY, 8.5, 8 } }
for k = 0, 9 do local a = k / 10 * 2 * math.pi + .3 circ[#circ + 1] = { CX + math.cos(a) * 8.3, CY + math.sin(a) * 8, 2.1, 2.1 } end
local body = O.unionCircles(circ)
O.shade(c, body, LEAF, { sphere = { 14, 18, 13 }, amb = .2, wrap = .4, rim = true, bounce = "#3a7a8a", bmax = 2, sep = LEAF[1] })

-- wave hand
O.flat(c, c:rect(27, 18, 27, 20), VINE[3], "arm") O.dot(c, 26, 21, VINE[3])
O.shade(c, c:ellipse(28, 15.5, 1.6, 2.2), LEAF, { R = 1, amb = .35, sep = LEAF[1] })
-- hibiscus
O.shade(c, O.unionCircles{ { 9, 15, 1.8, 1.8 }, { 12, 14, 1.8, 1.8 }, { 10.5, 17.5, 1.8, 1.8 } }, FLOW, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = FLOW[1] })
O.dot(c, 10, 15, "#f0be38")

c:eyeSmall(13, 20)
c:eyeSmall(20, 20)
O.dot(c, 11, 24, "#f5809f") O.dot(c, 23, 24, "#f5809f")
O.dots(c, { { 15, 24 }, { 16, 25 }, { 17, 25 }, { 18, 24 } }, P.ink)

O.shift(c, 0, 1)
O.done(c, "gc-canopy-loop-perch")
