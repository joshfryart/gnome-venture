-- ico-pointing (Opus single pass, aA8_2). A gnome's hand pointing right, seen from the back: long slim index finger
-- with a pale nail and knuckle creases, thumb folded on top, three curled fingers stacked under the palm, coming out
-- of a turned-back sleeve cuff.
-- Material: every finger is a capsule lit per pixel (6-tone warm skin, cool-violet deep), AO rows where fingers
-- tuck under the palm and under the index finger, a 1 px cast shadow under the thumb, waxy highlight on the knuckle;
-- cuff is moss-green wool with diagonal weave lines, a deep fold where it turns back and a gold stitched hem.
-- quirk: a red thread is tied around the index finger in a little bow (so as not to forget something).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new("ico-pointing")

local SKIN = { "#6e3440", "#a65a4e", "#cf8466", "#eba97e", "#f9c99c", "#ffe6c4" }
local NAIL = { "#e9a990", "#f9d2c0", "#fff0e2" }
local WOOL = { "#1f3f3e", "#285a45", "#347a4c", "#4c9b55", "#74ba62", "#a3d47c" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local stok = { r = { name = "skin" } }

-- curled fingers first (furthest back), bottom to top so each upper one overlaps the one below
local curls = {
  { 28, 46, 35, 46, 2.9 },   -- little
  { 28, 41, 39, 41, 3.0 },   -- ring
  { 28, 36, 41, 36, 3.1 },   -- middle
}
local fingerM = HP.mask()
for i, f in ipairs(curls) do
  local m, n = A.capsule(f[1], f[2], f[3], f[4], f[5])
  local v = A.lightV(n, 0.1, 0.3)
  local bias = {}
  -- AO where it tucks under the finger above
  m:each(function(x, y) if y <= f[2] - 2 then bias[K(x, y)] = -1 end end)
  A.toneV(m, v, SKIN, CUTS, bias, { r = { name = "curl" .. i } })
  -- underside line of this finger where it lies over the one below (deep crease between fingers)
  if i > 1 then m:each(function(x, y) if not m:has(x, y + 1) and fingerM:has(x, y + 1) then A.px(x, y, SKIN[2]) end end) end
  fingerM:add(m)
end
-- palm / back of hand
local palm = c:rrect(18, 20, 33, 47, 6)
do
  local n = X.pillow(palm, 6)
  local v = A.lightV(n, 0.1, 0.3)
  local bias = {}
  A.toneV(palm, v, SKIN, CUTS, bias, stok)
  -- knuckle row shading where curled fingers emerge
  for y = 33, 47 do if palm:has(33, y) and fingerM:has(34, y) then A.px(33, y, SKIN[2], stok) end end
end
-- index finger
local IY = 26
local idx, inn = A.capsule(30, IY, 55, IY, 3.6)
local iv = A.lightV(inn, 0.1, 0.3)
local ib = {}
idx:each(function(x, y) if x < 33 then ib[K(x, y)] = (ib[K(x, y)] or 0) - 1 end end)
A.toneV(idx, iv, SKIN, CUTS, ib, stok)
-- AO under the index finger on the middle finger below
for x = 31, 42 do if A.at(x, 30) and not idx:has(x, 30) then
  local h = A.at(x, 30) for i, col in ipairs(SKIN) do if col:lower() == h then A.px(x, 30, SKIN[max(1, i - 2)]) end end end end
-- nail on top near the tip
A.pts({ { 53, 23 }, { 54, 23 }, { 55, 23 }, { 52, 24 }, { 53, 24 }, { 54, 24 }, { 55, 24 }, { 56, 24 } }, NAIL[2], stok)
A.pts({ { 53, 23 }, { 54, 23 } }, NAIL[3], stok)
A.pts({ { 52, 25 }, { 53, 25 }, { 54, 25 }, { 55, 25 }, { 56, 25 } }, NAIL[1], stok)
-- knuckle creases (two short curved lines) on the index
A.pts({ { 41, 24 }, { 42, 25 }, { 42, 26 }, { 41, 27 } }, SKIN[3], stok)
A.pts({ { 50, 25 }, { 50, 26 } }, SKIN[3], stok)
-- waxy knuckle highlight where the index meets the hand
A.pts({ { 33, 23 }, { 34, 23 } }, SKIN[6], stok)

-- thumb folded on top, pointing forward-up
local th, tn = A.capsule(21, 22, 34, 18, 3.4)
local tv = A.lightV(tn, 0.1, 0.3)
local tb = {}
A.toneV(th, tv, SKIN, CUTS, tb, { r = { name = "thumb" } })
-- cast shadow under the thumb on the hand
th:shift(1, 1):each(function(x, y) if not th:has(x, y) and (palm:has(x, y) or idx:has(x, y)) then
  local h = A.at(x, y) for i, col in ipairs(SKIN) do if col:lower() == h then A.px(x, y, SKIN[max(1, i - 2)]) end end end end)
-- thumbnail
A.pts({ { 32, 16 }, { 33, 16 }, { 34, 16 }, { 33, 17 }, { 34, 17 } }, NAIL[2]) A.px(32, 16, NAIL[3])
A.pts({ { 35, 17 }, { 35, 18 } }, NAIL[1])
-- palm/finger spec glint
A.pts({ { 22, 25 }, { 23, 25 } }, SKIN[6], stok)
A.px(37, 24, "#fff4d6")

-- sleeve cuff (turned back) -----------------------------------------------------------------------------------
local cuff = c:rrect(7, 15, 20, 51, 3)
local cn = X.pillow(cuff, 4)
local cv = A.lightV(cn, 0.1, 0.3)
local cb = {}
-- turned-back fold: deep row at x = 15, band 16..20 is the folded-back part (sits a bit proud)
cuff:each(function(x, y) if x == 15 then cb[K(x, y)] = -2 elseif x == 14 then cb[K(x, y)] = -1 end end)
local ctok = { r = { name = "wool" } }
local cid = A.toneV(cuff, cv, WOOL, CUTS, cb, ctok)
-- AO on the hand where it leaves the cuff
A.retone(c:rect(21, 20, 22, 47):clip(palm), SKIN, -1, stok)
-- diagonal weave lines
cuff:each(function(x, y)
  if (x + y) % 4 == 0 and x ~= 15 and x ~= 14 then
    local h = A.at(x, y) for i, col in ipairs(WOOL) do if col:lower() == h then A.px(x, y, WOOL[max(1, i - 1)], ctok) end end
  end end)
for y = 16, 50 do if cuff:has(15, y) then A.px(15, y, WOOL[1], ctok) end if cuff:has(16, y) then A.px(16, y, WOOL[5], ctok) end end
-- gold stitched hem along the fold-back band
c:stitch({ { 18, 17 }, { 18, 49 } })

-- quirk: red thread bow around the index finger
for y = IY - 3, IY + 3 do if idx:has(46, y) then A.px(46, y, y < IY and "#e8493b" or "#b52e3f") end end
A.bmp({
  "rr.rr",
  "rDkDr",
  ".rkr.",
  "..t.d",
}, 44, 18, { r = "#e8493b", D = "#b52e3f", k = "#6e2038", t = "#e8493b", d = "#b52e3f" }, { r = { name = "thread" } })
A.done()
