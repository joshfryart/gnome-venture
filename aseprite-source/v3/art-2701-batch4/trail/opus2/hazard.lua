-- hazard (32x32 trail map marker, Opus second pass over the Haiku draft). A triangular warning board
-- (red paint border, yellow face, dark "!", a wooden edge showing its thickness, nails at the corners)
-- on a stout post, with a rockfall at its foot: a big cracked boulder on the left, rubble on the right.
-- quirk: the board has been hit before; a cream sticking plaster is slapped over a crack in its corner.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("hazard")

local W = { "#51302b", "#6e3d2c", "#864c33", "#b97a4a", "#d8a670", "#e8b982" } -- wood
local RD = { "#6e2038", "#9a2a3c", "#c23a3e", "#e2513f", "#f8744c", "#ff9a66" } -- red paint
local YL = { "#d98322", "#f0a02a", "#f5b82e", "#fbcf4a", "#ffe38a" } -- yellow paint
local S = { "#3d3448", "#5b4f63", "#7d6f80", "#a2929e", "#c8b8bc" } -- warm rock
local MARK = "#3a2030"
local function R(x0, y0, x1, y1, hex) for y = y0, y1 do for x = x0, x1 do c:put(x, y, hex) end end end

-- post behind the board
for y = 19, 27 do c:put(14, y, W[5]) c:put(15, y, W[4]) c:put(16, y, W[3]) c:put(17, y, W[2]) end
c:put(15, 25, W[3])

-- board thickness: a wooden edge under the bottom side
R(4, 21, 27, 22, W[4]) R(4, 22, 27, 22, W[2]) c:put(27, 21, W[3]) c:put(4, 21, W[5])
for x = 8, 24, 5 do c:put(x, 21, W[3]) end
R(14, 23, 17, 23, W[1]) -- AO on the post under the board

-- board: red border (lit upper-left edge, shaded lower-right), yellow face with a soft top-down ramp
local outer = c:poly{ { 15, 1 }, { 16, 1 }, { 29, 21 }, { 2, 21 } }
outer:cut(c:rect(2, 21, 29, 21)) -- bottom row becomes the wooden edge
outer:cut(c:rect(15, 1, 16, 1)):cut(c:rect(2, 20, 3, 20)):cut(c:rect(28, 20, 29, 20)) -- soften corners
outer:each(function(x, y)
  local ul = not outer:has(x - 1, y) or not outer:has(x, y - 1)
  local lr = not outer:has(x + 1, y) or not outer:has(x, y + 1)
  local v = RD[3]
  if lr and x > 15 then v = RD[2] elseif ul then v = RD[5] end
  if not outer:has(x, y + 1) then v = RD[1] end
  c:put(x, y, v)
end)
local face = outer:shrink(3)
face:each(function(x, y)
  local v = YL[3]
  if y <= 9 then v = YL[4] elseif y >= 15 then v = YL[2] end
  if not face:has(x, y - 1) or not face:has(x - 1, y) then v = YL[5] end
  if not face:has(x + 1, y) and x > 16 then v = YL[1] end
  if not face:has(x, y + 1) then v = YL[1] end
  c:put(x, y, v)
end)
-- inner bevel: the red just inside the face edge one tone darker (paint groove)
face:grow(1):cut(face):each(function(x, y) if outer:has(x, y) and c:get(x, y) == RD[3] then c:put(x, y, RD[2]) end end)
c:put(14, 3, RD[6]) c:put(15, 3, RD[6]) -- pop on the apex
-- the "!" mark
R(15, 7, 16, 13, MARK) c:put(15, 13, YL[2]) c:put(16, 13, YL[2]) R(15, 12, 16, 12, MARK)
R(15, 15, 16, 16, MARK)
c:put(15, 7, "#5a2a3c") -- worn glint on the mark
-- nails at the three corners
c:put(15, 4, "#e2e0e6") c:put(6, 18, "#e2e0e6") c:put(25, 18, "#aaa9b8")

-- quirk: a crack in the lower-right corner with a sticking plaster slapped over it
c:put(21, 9, RD[1]) c:put(21, 10, YL[1]) c:put(23, 14, YL[1]) c:put(23, 15, RD[1]) c:put(24, 16, RD[1])
T.grid(c, 19, 10, {
  ".pPPPPPp",
  "ppPddPpp",
  "ppdddpqq",
  ".qqqqqq.",
}, { p = "#f2deb4", P = "#fff4d6", d = "#d9a37a", q = "#c9a47a" })

-- rockfall at the foot: a big cracked boulder on the left, rubble on the right
local big = c:ellipse(7.5, 25, 5.5, 4)
big:cut(c:rect(0, 29, 31, 31))
T.vol(c, big, { S[1], S[2], S[3], S[4], S[4] }, { k = 1.3, bias = 0.1 })
c:put(5, 22, S[5]) c:put(6, 22, S[5]) -- pop
c:line({ { 8, 23 }, { 9, 25 }, { 8, 27 } }, 1):each(function(x, y) c:put(x, y, S[1]) end) -- crack
c:put(10, 25, S[4])
for _, r in ipairs{ { 21, 25, 25, 28 }, { 25, 26, 28, 28 }, { 19, 27, 21, 28 } } do
  local m = c:rrect(r[1], r[2], r[3], r[4], 1)
  T.vol(c, m, { S[1], S[2], S[3], S[4] }, { k = 1.4, bias = 0.15 })
end
c:put(22, 25, S[5]) c:put(26, 26, S[4])
T.seam(c, c:rrect(25, 26, 28, 28, 1), c:rrect(21, 25, 25, 28, 1), S[1])
c:put(29, 27, S[3]) c:put(18, 28, S[2]) -- loose pebbles
c:put(3, 28, "#3f9150") c:put(12, 28, "#3f9150") c:put(11, 27, "#7cc35a") -- grass at the boulder foot

T.done(c)
