-- signpost (32x32 trail map marker, Opus third pass: richness over ../opus2/signpost.lua).
-- A stout fingerpost with a peaked cap, planted in a cairn of grey stones. A blue-painted arrow
-- board points right (cream lettering, chipped paint showing wood), a bare-wood arrow board points
-- left (burnt lettering, grain, a knot). Boards are drawn as flat planks: one lit top edge, a flat
-- face and a raw-wood thickness strip underneath, so they read as boards, not rods.
-- Light from the upper left (rim light on the top-left edges), cel shade on the lower right,
-- olive bounce from the grass on the lowest stones.
-- quirk: the third (red) board has lost a nail and hangs crooked off the last one, its arrow now
-- pointing at the ground; a frayed rope lashing is all that keeps it from falling.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("signpost")

local W = { "#3f2333", "#5e3330", "#83492f", "#a8683c", "#cc9055", "#e8b878" } -- wood
local RIM = "#f6d89c"
local B = { "#24295a", "#323f86", "#4660b0", "#5f84cc", "#8aaee6", "#bcd6f6" } -- blue paint
local RD = { "#4e1630", "#7a2234", "#a8303a", "#d0443e", "#ec6a4c", "#ff9a72" } -- red paint
local S = { "#2f2c45", "#4a4762", "#6a6884", "#8d8ca6", "#b4b3c8", "#d6d6e2" } -- stone
local BOUNCE = "#5f6a52" -- grass bounce on stone
local LICHEN = { "#9aa84e", "#c8c86c" }
local ROPE = { "#8a6a3a", "#c9a46a", "#e6cc92" }
local CREAM = "#fff4d6"
local NAIL = { "#6a6884", "#d6d6e2" }
local function R(x0, y0, x1, y1, hex) for y = y0, y1 do for x = x0, x1 do c:put(x, y, hex) end end end
local function P(x, y, hex) c:put(x, y, hex) end
local function E(x, y) c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end

-- post: 4 px, rim-lit left face, dark right face, grain; peaked cap
for y = 4, 27 do P(14, y, W[5]) P(15, y, W[4]) P(16, y, W[3]) P(17, y, W[2]) end
R(14, 4, 14, 9, RIM)
for _, g in ipairs{ { 15, 11 }, { 15, 12 }, { 16, 18 }, { 15, 21 }, { 15, 22 }, { 16, 25 } } do P(g[1], g[2], W[3]) end
P(16, 21, W[2])
T.grid(c, 13, 1, {
  "..ab..",
  ".abbc.",
  "abbbcd",
}, { a = RIM, b = W[5], c = W[3], d = W[2] })
P(14, 4, W[2]) P(15, 4, W[2]) P(16, 4, W[1]) P(17, 4, W[1]) -- cap overhang shadow

-- flat arrow board, 5 rows: lit top edge, 3-row face, raw-wood thickness strip
local function board(x0, x1, y0, dir, F)
  for dy = 0, 4 do
    local cut = 2 * math.abs(dy - 2)
    local a, b = x0, x1
    if dir == 1 then b = x1 - cut else a = x0 + cut end
    for x = a, b do
      local v = F.face
      if dy == 0 then v = F.top elseif dy == 4 then v = F.edge end
      if dy == 3 and ((dir == 1 and x >= b - 1) or (dir == -1 and x <= a + 1)) then v = F.shade end
      c:put(x, y0 + dy, v)
    end
    if dir == -1 and dy < 4 then c:put(b, y0 + dy, F.shade) end -- right (shade) end of a left board
    if dir == 1 and dy == 0 then for x = x0, x0 + 6 do c:put(x, y0, F.rim or F.top) end end
  end
  local tail = dir == 1 and x0 or x1
  E(tail, y0 + 2) -- swallow notch at the tail
end

-- top board: blue paint, points right
board(8, 29, 5, 1, { top = B[5], face = B[4], shade = B[3], edge = W[3], rim = B[6] })
R(9, 8, 26, 8, B[3]) -- lower face in shade under the overhang of the top edge
for _, g in ipairs{ { 10, 7 }, { 11, 7 }, { 24, 6 }, { 25, 6 } } do P(g[1], g[2], B[3]) end -- grain under the paint
-- chipped paint showing wood
P(12, 6, W[5]) P(13, 6, W[4]) P(27, 8, W[4]) P(9, 9, W[2])
-- cream lettering (three little runes)
P(18, 6, CREAM) P(18, 7, CREAM) P(19, 6, CREAM)
P(21, 6, CREAM) P(22, 7, CREAM) P(21, 7, CREAM)
P(24, 7, CREAM) P(25, 7, CREAM)
P(15, 7, NAIL[2]) P(15, 8, NAIL[1]) -- nail
R(14, 10, 17, 10, W[1]) -- shadow the board casts on the post

-- middle board: bare wood, points left
board(2, 21, 11, -1, { top = W[6], face = W[5], shade = W[4], edge = W[2], rim = RIM })
R(4, 13, 21, 13, W[4]) R(5, 12, 7, 12, W[4]) R(17, 14, 20, 14, W[4]) -- grain streaks
P(19, 12, W[3]) P(19, 13, W[2]) P(20, 13, W[3]) -- knot
-- burnt lettering
P(7, 13, W[1]) P(8, 13, W[1]) P(8, 14, W[1]) P(10, 13, W[1]) P(10, 14, W[1]) P(11, 13, W[1]) P(12, 14, W[1])
P(2, 13, W[4]) -- end grain darker at the tip edge
P(15, 13, NAIL[2]) P(15, 14, NAIL[1])
R(14, 16, 17, 16, W[1])

-- cairn of stones round the foot: hand-lit (rim on the top-left edge, cel shade on the lower right,
-- grass bounce on the bottom edge), back stones first, the front stone last
local function stone(m, rim)
  m:each(function(x, y)
    local ul = not m:has(x - 1, y) or not m:has(x, y - 1)
    local lr = not m:has(x + 1, y) or not m:has(x, y + 1)
    local lr2 = not m:has(x + 2, y) or not m:has(x, y + 2) or not m:has(x + 1, y + 1)
    local v = S[4]
    if lr then v = S[2] elseif lr2 then v = S[3] elseif ul then v = rim and S[6] or S[5] end
    if not m:has(x, y + 1) and m:has(x - 1, y) and m:has(x + 1, y) and x % 2 == 0 then v = BOUNCE end
    c:put(x, y, v)
  end)
  return m
end
local A = stone(c:ellipse(10.5, 26.5, 3.5, 2.5))
local Bs = stone(c:ellipse(20.5, 26, 3.5, 2.5))
local C = stone(c:ellipse(13.5, 23, 2.5, 2), true)
local D = stone(c:ellipse(15.5, 28, 4, 2))
T.seam(c, A:copy():cut(C), C, S[2])
for _, q in ipairs{ A, Bs, C } do T.seam(c, q:copy():cut(D), D, S[1]) end
-- stone texture: a crack, a chip, lichen
P(9, 26, S[3]) P(10, 27, S[2]) P(10, 28, S[3])
P(21, 25, S[3]) P(22, 26, S[3])
P(16, 28, S[5]) P(17, 28, S[5])
P(19, 25, LICHEN[2]) P(20, 25, LICHEN[1]) P(8, 27, LICHEN[1]) P(13, 29, LICHEN[1])
P(6, 29, "#3f9150") P(25, 28, "#3f9150") P(25, 27, "#7cc35a") -- grass

-- quirk: the third board (red paint) hangs crooked off its last nail, sloping 1 down per 2 across
-- columns x16..29; top row at y = 17 + (x-16)//2; 5 rows deep (top edge, face x3, wood edge)
for x = 16, 29 do
  local top = 17 + (x - 16) // 2
  if x <= 25 then -- shaft: lit top edge, face, shaded lower face, raw-wood thickness
    for d = 0, 4 do
      local v = RD[4]
      if d == 0 then v = RD[6] elseif d == 1 then v = RD[5] elseif d == 3 then v = RD[3] elseif d == 4 then v = W[2] end
      c:put(x, top + d, v)
    end
  else -- arrowhead flares one pixel past the shaft, then tapers to the tip
    local k = x - 26
    for d = k - 1, 5 - k do
      local v = RD[4]
      if d == k - 1 then v = RD[6] elseif d == 5 - k then v = RD[2] elseif d >= 3 then v = RD[3] end
      c:put(x, top + d, v)
    end
  end
end
-- paint wear and lettering on the red board
P(25, 23, W[5]) P(26, 23, W[4])
P(22, 21, CREAM) P(23, 22, CREAM) P(24, 22, CREAM) P(19, 19, RD[3])
-- the last nail, and the rope lashing round the post
P(17, 19, NAIL[2]) P(17, 20, NAIL[1])
P(14, 18, ROPE[3]) P(15, 18, ROPE[1]) P(16, 18, ROPE[2]) P(17, 18, ROPE[1])
P(18, 18, ROPE[1]) -- frayed loose end

T.done(c)
