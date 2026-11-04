-- lm-delve (aC21_0, Opus single pass). A craggy, low grey outcrop with a timber mine portal: two adzed posts and a
-- lintel (grain lines, pale end grain, iron nail heads), a black shaft with a ladder dropping into it (rails dimming
-- with depth), AO under the lintel and inside the posts, rock strata seams with lit lips, two gold ore flecks, an
-- earth lip with grass tufts. quirk: a little lantern hangs from the lintel's overhang, still lit.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_0.lua")
local R, K = A.R, A.K
local c = A.new("lm-delve")
local ST, WD, GD, EA, LF = R.stone, R.wood, R.gold, R.earth, R.leaf

-- rock outcrop (irregular crag, slightly lopsided peak)
local rock = c:poly{ { 7, 52 }, { 8, 44 }, { 11, 37 }, { 15, 33 }, { 18, 27 }, { 23, 23 }, { 26, 18 }, { 31, 15 },
  { 35, 17 }, { 39, 16 }, { 43, 20 }, { 47, 25 }, { 50, 31 }, { 54, 36 }, { 56, 43 }, { 57, 52 } }
A.lit(c, rock, ST, 6, { amb = 0.1 })
-- strata seams: dark groove with a lit lip below
for _, s in ipairs{ { 11, 40, 22, 38 }, { 17, 31, 24, 29 }, { 42, 27, 51, 33 }, { 44, 41, 55, 39 }, { 28, 21, 36, 20 } } do
  A.ln(c, s[1], s[2], s[3], s[4], ST[2], rock)
  A.ln(c, s[1] + 1, s[2] + 1, s[3], s[4] + 1, ST[5], rock)
end
-- cracks
A.polyline(c, { { 14, 46 }, { 16, 43 }, { 15, 41 } }, ST[2], rock)
A.polyline(c, { { 51, 47 }, { 50, 44 }, { 52, 42 } }, ST[2], rock)
-- gold ore flecks
for _, g in ipairs{ { 13, 35 }, { 47, 36 } } do
  c:px(g[1], g[2], GD[6]) c:px(g[1] + 1, g[2], GD[4]) c:px(g[1], g[2] + 1, GD[3]) c:px(g[1] + 1, g[2] + 1, GD[2])
end

-- shaft (dark opening) + AO
local hole = c:rect(26, 31, 38, 52)
for y = 31, 52 do for x = 26, 38 do
  local col = A.VOID
  if y >= 46 then col = "#120a18" end
  c:px(x, y, col)
end end
-- ladder: rails dim as they go down
for y = 34, 52 do
  local t = (y - 34) / 18
  local hi = t < 0.35 and WD[5] or (t < 0.7 and WD[3] or WD[2])
  local lo = t < 0.35 and WD[3] or WD[1]
  c:px(29, y, hi) c:px(35, y, lo)
end
for _, y in ipairs{ 36, 40, 44, 48 } do
  local col = y < 40 and WD[4] or (y < 46 and WD[3] or WD[2])
  for x = 30, 34 do c:px(x, y, col) end
  c:px(30, y + 1, WD[1]) -- rung shadow
end
c:px(29, 33, WD[6]) c:px(35, 33, WD[4]) -- rounded rail tops
-- posts (cylinder-lit, grain lines)
local postL, postR = c:rect(23, 30, 25, 52), c:rect(39, 30, 41, 52)
A.vcyl(c, postL, WD, 23, 25)
A.vcyl(c, postR, WD, 39, 41)
for y = 33, 51, 5 do c:px(24, y, WD[3]) c:px(24, y + 1, WD[3]) c:px(40, y + 2, WD[2]) end
-- AO where shaft meets posts
for y = 31, 52 do c:px(26, y, "#0d0812") c:px(38, y, "#0d0812") end
-- lintel with overhang and pale end grain
local lintel = c:rect(20, 27, 45, 30)
A.lit(c, lintel, WD, 1.5)
A.ln(c, 22, 28, 42, 28, WD[4]) A.ln(c, 27, 29, 38, 29, WD[3])
A.ln(c, 21, 30, 44, 30, WD[2])
for y = 27, 30 do c:px(20, y, WD[6]) end c:px(20, 28, WD[5]) c:px(20, 30, WD[4])
for y = 27, 30 do c:px(45, y, WD[4]) end c:px(45, 30, WD[3])
for x = 26, 38 do c:px(x, 31, "#0a0610") end -- AO under the lintel
c:px(24, 28, ST[3]) c:px(40, 28, ST[3]) -- nail heads
c:px(24, 27, ST[6])
A.ao(c, rock, lintel:copy():add(postL):add(postR), ST[2])

-- quirk: lantern hanging off the overhang
c:px(44, 31, ST[2]) c:px(44, 32, ST[3])
local lamp = c:rect(43, 34, 45, 37)
c:px(44, 33, ST[4])
for _, p in ipairs{ { 43, 34, GD[4] }, { 44, 34, GD[6] }, { 45, 34, GD[3] }, { 43, 35, GD[5] }, { 44, 35, A.CREAM },
  { 45, 35, GD[4] }, { 43, 36, GD[4] }, { 44, 36, GD[5] }, { 45, 36, GD[2] } } do c:px(p[1], p[2], p[3]) end
for x = 43, 45 do c:px(x, 37, ST[2]) end
c:px(43, 33, ST[3]) c:px(45, 33, ST[2])
c:px(46, 35, GD[3]) -- glow spill on the rock

-- earth lip and grass tufts
local lip = c:rect(7, 52, 57, 55):cut(c:rect(7, 55, 8, 55)):cut(c:rect(56, 55, 57, 55))
A.lit(c, lip, EA, 1.5)
for x = 27, 37 do c:px(x, 52, "#120a18") c:px(x, 53, EA[1]) end
for _, g in ipairs{ 9, 13, 19, 45, 50, 54 } do
  c:px(g, 51, LF[4]) c:px(g + 1, 50, LF[6]) c:px(g + 1, 51, LF[5]) c:px(g + 2, 51, LF[3]) c:px(g + 1, 52, LF[2])
end
c:sparkle(31, 18)
A.fin()
