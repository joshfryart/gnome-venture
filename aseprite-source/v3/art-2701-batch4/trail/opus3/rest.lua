-- rest (32x32 trail map marker, Opus third pass: richness over ../opus2/rest.lua).
-- A chunky plank bench seen from the front: one wide back board on two posts, a lit seat with a
-- grainy front edge, splayed legs and a stretcher. A puffy blue quilted pillow with gold corner
-- tassels leans in the left corner; a red glazed mug of tea sits on the right.
-- Light from the upper left (warm rim light on the top-left edges), one cel shade on the lower
-- right, an olive bounce light from the grass on the undersides.
-- Material: wood grain dashes, a knot with growth rings, pale end grain on the board ends,
-- quilted diamond seams on the pillow, a glazed mug with a tea surface.
-- quirk: the steam from the mug curls up into a bold sleepy "Z" (2 px strokes, so it survives 16 px).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("rest")

-- wood: deep violet-brown .. warm straw (hue drifts violet in the shade, yellow in the light)
local W = { "#3f2333", "#5e3330", "#83492f", "#a8683c", "#cc9055", "#e8b878" }
local RIM = "#f6d89c" -- rim light on the top-left edges
local BOUNCE = "#7a6a3a" -- green-olive bounce light from the grass, on undersides
local END = "#efc98e" -- pale end grain
-- pillow blue, 6 tones
local B = { "#262c5a", "#33407e", "#4660a6", "#5f82c6", "#86a9e2", "#b8d2f4" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
-- red glazed mug
local M = { "#5a1a30", "#8a2436", "#b8343c", "#dc4a40", "#f2754f", "#ffa070" }
local TEA = { "#4a2a26", "#7a4a30" }
local CREAM = "#fff4d6"
local ST = { "#a9b2d6", "#d6dcef", "#eef1fb" } -- steam shade, base, light
local function R(x0, y0, x1, y1, hex) for y = y0, y1 do for x = x0, x1 do c:put(x, y, hex) end end end
local function P(x, y, hex) c:put(x, y, hex) end
local function E(x, y) c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end

-- back posts (seen between back board and seat)
for _, x in ipairs{ 5, 25 } do
  R(x, 12, x, 15, W[5]) R(x + 1, 12, x + 1, 15, W[4]) R(x + 2, 12, x + 2, 15, W[2])
  P(x, 12, W[2]) P(x + 1, 12, W[1]) P(x + 2, 12, W[1]) -- shadow cast by the back board
  P(x + 1, 14, W[3]) -- grain
end

-- back board: x2..29, y8..11
R(2, 8, 29, 8, W[6]) R(2, 9, 29, 10, W[4]) R(2, 11, 29, 11, W[3])
R(2, 9, 29, 9, W[5])
R(2, 8, 12, 8, RIM)
-- grain dashes (long streaks that wander between rows)
for _, g in ipairs{ { 3, 10, 6 }, { 14, 10, 15 }, { 22, 9, 24 }, { 26, 10, 28 }, { 8, 9, 10 }, { 18, 10, 19 } } do
  R(g[1], g[2], g[3], g[2], W[3])
end
-- knot with growth rings (visible between pillow and mug)
P(16, 9, W[3]) P(17, 9, W[4]) P(15, 10, W[3]) P(16, 10, W[1]) P(17, 10, W[2]) P(18, 10, W[3])
P(16, 11, W[2])
-- ends: pale end grain left, dark cut right
P(2, 9, END) P(2, 10, W[5]) R(29, 9, 29, 11, W[2]) P(29, 8, W[5])
E(2, 11) E(29, 8)
P(28, 11, BOUNCE)

-- seat: top plane y16..17, front edge y18..19
R(1, 16, 30, 16, W[6]) R(1, 17, 30, 17, W[5])
R(1, 16, 10, 16, RIM)
R(1, 18, 30, 18, W[4]) R(1, 19, 30, 19, W[3])
for _, g in ipairs{ { 4, 18, 7 }, { 13, 18, 16 }, { 22, 18, 23 }, { 9, 17, 11 }, { 19, 17, 21 } } do
  R(g[1], g[2], g[3], g[2], g[2] == 17 and W[4] or W[3])
end
P(26, 18, W[2]) P(27, 18, W[3]) -- a small knot on the front edge
P(1, 17, END) P(1, 18, END) P(1, 19, W[4]) -- end grain
P(30, 16, W[4]) P(30, 17, W[3]) P(30, 18, W[2]) P(30, 19, W[1])
-- underside shadow
R(3, 20, 28, 20, W[1])

-- legs (splay out at the feet)
for _, L in ipairs{ { 3, 1 }, { 26, -1 } } do
  local x, s = L[1], L[2]
  for y = 21, 28 do
    local ox = (y >= 25) and -s or 0
    local a, b, d = W[5], W[4], W[2]
    if s == -1 then a, b, d = W[4], W[3], W[2] end
    if y >= 26 then d = BOUNCE end
    P(x + ox, y, a) P(x + 1 + ox, y, b) P(x + 2 + ox, y, d)
  end
  P(x, 21, W[2]) P(x + 1, 21, W[1]) P(x + 2, 21, W[1]) -- AO under the seat
  P(x + 1, 23, W[3]) -- grain
  P(x - s, 28, W[3]) P(x + 1 - s, 28, W[2]) P(x + 2 - s, 28, W[1])
end
-- stretcher
R(6, 25, 25, 25, W[5]) R(6, 26, 25, 26, W[3]) P(6, 25, W[6])
R(10, 26, 12, 26, W[2]) R(18, 26, 21, 26, W[2])
R(14, 26, 15, 26, W[2])

-- grass tufts at the feet
local function tuft(x, y) P(x, y, "#3f9150") P(x + 1, y - 1, "#7cc35a") P(x + 1, y, "#3f9150") P(x + 2, y, "#24544a") end
tuft(7, 29) tuft(21, 29)

-- pillow: puffy quilted cushion leaning in the left corner, x4..13, y6..15
local pm = c:rrect(4, 6, 13, 15, 2)
pm:add(c:rect(4, 6, 4, 6)):add(c:rect(13, 6, 13, 6)):add(c:rect(4, 15, 4, 15)):add(c:rect(13, 15, 13, 15))
pm:cut(c:rect(5, 6, 5, 6)):cut(c:rect(12, 6, 12, 6)):cut(c:rect(5, 15, 5, 15)):cut(c:rect(12, 15, 12, 15))
T.vol(c, pm, { B[2], B[3], B[4], B[5], B[5] }, { k = 1.5, bias = 0.3 })
-- tufting: seams run from the button to the four corners (an X), one tone darker than under them
local down = { [B[2]] = B[1], [B[3]] = B[2], [B[4]] = B[3], [B[5]] = B[4], [B[1]] = B[1], [B[6]] = B[5] }
for _, q in ipairs{ { 6, 8 }, { 7, 9 }, { 11, 8 }, { 10, 9 }, { 6, 13 }, { 7, 12 }, { 11, 13 }, { 10, 12 } } do
  c:put(q[1], q[2], down[c:get(q[1], q[2])] or B[2])
end
-- puffs between the seams catch the light (upper-left one brightest)
P(8, 7, B[6]) P(9, 7, B[6]) P(5, 10, B[5]) P(6, 10, B[5])
-- gold button at the centre, gold tassels on the pinched corners
P(8, 10, GOLD[3]) P(9, 10, GOLD[2]) P(8, 11, GOLD[2]) P(9, 11, GOLD[1])
P(4, 6, GOLD[4]) P(13, 6, GOLD[3]) P(4, 15, GOLD[2]) P(13, 15, GOLD[1])
-- pillow shadow on the seat
R(5, 16, 13, 16, W[4]) R(6, 17, 12, 17, W[4]) P(14, 16, W[5])

-- mug: x17..22, y10..15, handle x23..24
R(17, 11, 22, 15, M[3])
R(17, 11, 17, 14, M[5]) R(18, 11, 18, 14, M[4])
R(21, 11, 21, 15, M[2]) R(22, 11, 22, 15, M[1])
R(17, 15, 21, 15, M[2]) P(17, 15, M[3])
P(18, 12, M[6]) P(18, 13, M[6]) -- glaze specular
R(18, 10, 21, 10, CREAM) P(17, 10, "#f2deb4") P(22, 10, "#d9b98a") -- rim
R(18, 11, 21, 11, TEA[1]) P(18, 11, TEA[2]) P(17, 11, CREAM) P(22, 11, "#d9b98a")
P(20, 14, M[4]) -- reflected light from the seat
P(23, 12, M[3]) P(24, 12, M[2]) P(24, 13, M[1]) P(23, 14, M[2]) P(24, 14, M[1])
R(16, 16, 23, 16, W[4]) -- contact shadow on the seat
P(23, 16, W[5])

-- quirk: steam rises from the tea and curls into a bold sleepy "Z"
P(19, 9, ST[2]) P(20, 8, ST[2]) P(20, 7, ST[3]) P(21, 6, ST[2]) P(22, 6, ST[1])
T.grid(c, 23, 1, {
  "LLLLLL",
  "lllLLs",
  "..LLs.",
  ".LLs..",
  "LLLlll",
  "llssss",
}, { L = ST[3], l = ST[2], s = ST[1] })

T.done(c)
