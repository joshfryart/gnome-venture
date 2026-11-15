-- signpost (32x32 trail map marker, Opus second pass over the Haiku draft). A stout fingerpost with
-- a little peaked cap, planted in a cairn of grey stones. A blue-painted arrow board points right
-- (cream lettering) and a bare-wood arrow board points left (burnt lettering); nails in gold.
-- quirk: the third board has lost a nail and swings down on the last one, pointing at the ground.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("signpost")

local W = { "#51302b", "#6e3d2c", "#864c33", "#b97a4a", "#d8a670", "#e8b982" } -- wood
local B = { "#2f3a68", "#3f5390", "#5677b8", "#7fa0dc", "#b4cdf2" } -- blue paint
local Y = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff1b8" } -- yellow paint
local S = { "#3d3a55", "#5a5a78", "#7f7f9c", "#a9a9c2", "#d0d0e0" } -- stone
local GOLD = "#ffe38a"
local function R(x0, y0, x1, y1, hex) for y = y0, y1 do for x = x0, x1 do c:put(x, y, hex) end end end

-- post: 4 px, lit left face, dark right face, grain; peaked cap
for y = 4, 26 do
  c:put(14, y, W[5]) c:put(15, y, W[4]) c:put(16, y, W[3]) c:put(17, y, W[2])
end
for _, g in ipairs{ { 15, 7 }, { 15, 12 }, { 15, 21 }, { 16, 17 } } do c:put(g[1], g[2], W[3]) end
T.grid(c, 13, 1, {
  "..aa..",
  ".abbc.",
  "abbbcd",
}, { a = W[6], b = W[5], c = W[3], d = W[2] })

-- an arrow board, pointing dir (1 right, -1 left), 5 rows tall; ramp R = 5 tones dark..light
local function board(x0, x1, y0, dir, P)
  local tipx = dir == 1 and x1 or x0
  for dy = 0, 4 do
    local cut = 2 * math.abs(dy - 2) -- arrow tip tapers
    local a, b = x0, x1
    if dir == 1 then b = x1 - cut else a = x0 + cut end
    local tail = (dir == 1) and a or b -- swallow notch at the tail end
    for x = a, b do
      local v = P[3]
      if dy == 0 then v = P[5] elseif dy == 1 then v = P[4] elseif dy == 3 then v = P[2] elseif dy == 4 then v = P[1] end
      c:put(x, y0 + dy, v)
    end
    if dy == 2 then c.pix[(y0 + dy) * c.w + tail] = nil end
  end
  return tipx
end

-- top board: blue paint, points right, cream lettering
board(9, 29, 5, 1, B)
for _, x in ipairs{ 18, 19, 20, 22, 23, 25 } do c:put(x, 7, "#fff4d6") end
c:put(21, 8, B[5]) c:put(24, 8, B[4])
c:put(12, 6, B[5]) c:put(13, 6, B[5]) -- pop
c:put(15, 7, GOLD) c:put(15, 8, "#d98322") -- nail

-- middle board: bare wood, points left, burnt lettering, grain
board(2, 21, 11, -1, { W[1], W[3], W[4], W[5], W[6] })
for _, x in ipairs{ 5, 6, 8, 9, 10, 12 } do c:put(x, 13, W[1]) end
c:put(7, 14, W[2]) c:put(11, 12, W[2])
c:put(18, 13, W[3]) c:put(19, 13, W[3])
c:put(15, 13, GOLD) c:put(15, 14, "#d98322") -- nail
-- shadow the boards cast on the post
c:put(16, 10, W[1]) c:put(17, 10, W[1]) c:put(16, 16, W[1]) c:put(17, 16, W[1])

-- quirk: the third board hangs on one nail and swings down to the right
T.grid(c, 16, 17, {
  "nYY...........",
  "yyyYY.........",
  "dyyyyYY.......",
  ".ddyyyyYYYY...",
  "...ddyyyyyy...",
  ".....ddyyyyy..",
  "......ddddyyy.",
  "........dddyyy",
  "..........ddd.",
}, { n = GOLD, Y = Y[4], y = Y[3], d = Y[2] })
c:put(17, 17, Y[5]) c:put(18, 17, Y[5])
c:put(20, 19, Y[1]) c:put(22, 20, Y[1]) c:put(24, 21, Y[1]) -- lettering dots
c:put(29, 24, Y[2]) c:put(26, 23, Y[1]) -- arrowhead shading

-- cairn of stones round the foot
local stones = {
  { 9, 25, 13, 28 }, { 18, 25, 22, 28 }, { 12, 23, 15, 26 }, { 14, 26, 19, 29 },
}
for _, s in ipairs(stones) do
  local m = c:rrect(s[1], s[2], s[3], s[4], 1)
  T.vol(c, m, { S[1], S[2], S[3], S[4] }, { k = 1.5, bias = 0.1 })
end
c:put(10, 26, S[5]) c:put(13, 24, S[5]) c:put(15, 27, S[5]) c:put(19, 26, S[5]) -- lit tops
T.seam(c, c:rrect(14, 26, 19, 29, 1), c:rrect(12, 23, 15, 26, 1), S[1])
c:put(11, 28, "#3f9150") c:put(21, 28, "#3f9150") c:put(20, 27, "#7cc35a") -- moss

T.done(c)
