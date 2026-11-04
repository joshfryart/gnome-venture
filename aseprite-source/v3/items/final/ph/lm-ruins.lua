-- lm-ruins (aC21_0, Opus single pass). Two weathered sandstone columns on a two-step plinth: the left one snapped
-- off (jagged pale break), the right one whole with a capital and a zigzag crack; a fallen fluted drum lies between
-- them showing its lit end face; per-pixel cylinder light (6 tones), flute grooves, chipped plinth corner with the
-- chip lying beside it, AO where stone meets stone, ivy twisting up the tall column (leaves with midribs), moss on the
-- step. quirk: a twig nest on the capital with one blue egg peeping over the rim.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_0.lua")
local R, K, X = A.R, A.K, A.X
local c = A.new("lm-ruins")
local MB, LF, WD, SE = R.marble, R.leaf, R.wood, R.sea
local sin, sqrt, floor = math.sin, math.sqrt, math.floor

-- plinth: two steps, chipped right corner of the upper step
local low = c:rect(8, 48, 56, 52)
A.lit(c, low, MB, 1.5)
local up = c:rect(11, 45, 53, 48):cut(c:poly{ { 50, 44 }, { 54, 44 }, { 54, 47 } })
A.lit(c, up, MB, 1.5)
A.ao(c, low, up, MB[2])
for x = 9, 55 do c:px(x, 52, MB[2]) end
A.polyline(c, { { 30, 48 }, { 31, 50 }, { 30, 52 } }, MB[1], low) -- crack in the lower step
c:px(31, 49, MB[5])
-- the chip, fallen beside the plinth
c:px(55, 46, MB[5]) c:px(56, 46, MB[4]) c:px(55, 47, MB[3]) c:px(56, 47, MB[2])
-- moss on the step
for _, m in ipairs{ { 12, 45, 4 }, { 22, 45, 2 }, { 9, 48, 3 } } do
  for i = 0, m[3] - 1 do c:px(m[1] + i, m[2], i % 2 == 0 and LF[5] or LF[4]) end
end

-- vertical column helper: cylinder light + flutes
local function column(x0, x1, y0, y1)
  local m = c:rect(x0, y0, x1, y1)
  A.vcyl(c, m, MB, x0, x1)
  return m
end
local colL = column(14, 21, 24, 43):cut(c:poly{ { 13, 23 }, { 22, 23 }, { 22, 29 }, { 21, 29 }, { 20, 25 }, { 18, 28 }, { 16, 24 }, { 14, 27 }, { 13, 27 } })
-- re-clear the cut-away pixels (they were painted before cutting)
for y = 23, 29 do for x = 13, 22 do if not colL:has(x, y) and y < 30 then c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end end
-- pale break face on the jag
colL:each(function(x, y) if not colL:has(x, y - 1) then c:px(x, y, MB[6]) end end)
for _, x in ipairs{ 16, 18, 20 } do for y = 29, 41 do if colL:has(x, y) then c:px(x, y, x == 20 and MB[1] or MB[3]) end end end
local colR = column(42, 49, 14, 41)
for _, x in ipairs{ 44, 46, 48 } do for y = 15, 40 do c:px(x, y, x == 48 and MB[1] or MB[3]) end end
-- bases (torus)
local bL = c:rect(13, 42, 22, 44) A.lit(c, bL, MB, 1)
local bR = c:rect(41, 42, 50, 44) A.lit(c, bR, MB, 1)
-- capital: echinus + abacus
local ech = c:rect(41, 12, 50, 13) A.lit(c, ech, MB, 1)
local aba = c:rect(40, 8, 51, 11) A.lit(c, aba, MB, 1.3)
for x = 42, 49 do c:px(x, 14, MB[2]) end -- AO under the capital
-- crack across the tall column
A.polyline(c, { { 42, 27 }, { 44, 29 }, { 46, 27 }, { 48, 30 }, { 49, 29 } }, MB[1])
A.polyline(c, { { 43, 29 }, { 44, 30 }, { 46, 28 }, { 48, 31 } }, MB[5], colR)
A.ao(c, up, colL:copy():add(colR):add(bL):add(bR), MB[2])

-- fallen drum lying between (horizontal cylinder, lit end face on the left)
local drum = c:rect(26, 38, 37, 44)
local n = {}
drum:each(function(x, y) local t = ((y - 38) / 6) * 2 - 1 t = math.max(-.95, math.min(.95, t)) n[K(x, y)] = { 0, t, sqrt(1 - t * t) } end)
X.tone(c, drum, X.light(n, { amb = 0.1, wrap = 0.3 }), MB, { cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 } })
for _, y in ipairs{ 40, 42 } do for x = 27, 37 do c:px(x, y, y == 42 and MB[2] or MB[3]) end end
local face = c:ellipse(25.5, 41, 2, 3)
face:each(function(x, y) c:px(x, y, (x <= 25 and y <= 41) and MB[6] or MB[5]) end)
c:px(25, 41, MB[4]) c:px(26, 41, MB[4]) -- centre dowel hole
for x = 25, 37 do c:px(x, 45, MB[1]) end -- contact shadow on the step

-- ivy twisting up the tall column
local prev
for y = 44, 18, -1 do
  local x = floor(45 + 2.5 * sin(y / 2.6) + .5)
  c:px(x, y, LF[2])
  if prev and math.abs(prev - x) > 1 then c:px((prev + x) // 2, y + 1, LF[2]) end
  prev = x
end
for i, y in ipairs{ 41, 36, 31, 26, 21 } do
  local x = floor(45 + 2.5 * sin(y / 2.6) + .5)
  local s = (i % 2 == 0) and -1 or 1
  local lx = x + s * 2
  c:px(lx, y - 1, LF[6]) c:px(lx + s, y - 1, LF[5])
  c:px(lx, y, LF[4]) c:px(lx + s, y, LF[3]) c:px(lx - s, y, LF[3])
  c:px(lx, y + 1, LF[2])
  c:px(lx, y, LF[2]) -- midrib
end

-- quirk: twig nest with a blue egg
local nest = A.ell(45.5, 6, 4.5, 1.6, 0)
nest:each(function(x, y) c:px(x, y, ((x + y * 2) % 3 == 0) and WD[2] or (y <= 5 and WD[5] or WD[3])) end)
c:px(45, 4, SE[5]) c:px(46, 4, SE[4]) c:px(45, 3, SE[6]) c:px(46, 3, SE[5])
for x = 42, 49 do c:px(x, 7, WD[1]) end
A.fin()
