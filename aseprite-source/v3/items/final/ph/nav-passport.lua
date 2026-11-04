-- nav-passport (final, Opus single pass). A slim upright passport: teal-blue cloth cover with a diagonal weave, a
-- debossed hinge groove and a blind-stamped frame; a raised gold globe (sphere light, meridians and latitudes, glint)
-- with two raised gold title bars; a worn red visa stamp ring; the cream page block showing at the right and bottom
-- with page lines and a dark row where it meets the cover.
-- quirk: a striped train ticket with a punched hole pokes out of the top of the pages.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("nav-passport")
local BLUE  = { "#182448", "#213a68", "#2b5486", "#3770a2", "#4f8fbc", "#7cb6d4" }
local GOLD  = { "#6e3a1a", "#a3621f", "#d08f28", "#ecb53a", "#fbd968", "#fff1b4" }
local PAGE  = { "#8a6a5a", "#b8977c", "#d9bf9c", "#ecdcb8", "#f8eed0" }
local RED   = { "#7a1f34", "#b52e3f", "#e04a44" }
local TICK  = { "#9a7a5c", "#d6bc8e", "#efdcae", "#fff0c8" }

-- quirk first (cover paints over its lower end): a ticket tilted out of the top of the pages
local tm = c:poly{ { 36, 7 }, { 43, 5 }, { 46, 16 }, { 39, 18 } }
local ti = {}
tm:each(function(x, y)
  local v = 3
  if x + y * 0.28 < 38 + 0.28 * 7 + 1 then v = 4 end
  if (x - 36) * 0.27 - (y - 7) > -1.2 then v = 2 end
  ti[K(x, y)] = v c:put(x, y, TICK[v])
end)
-- red stripe across, punched hole, contact shadow where it enters the pages
A.ln(c, 37, 11, 44, 9, RED[2], tm) A.ln(c, 37, 12, 44, 10, RED[1], tm)
c:put(40, 7, A.INK) c:put(41, 7, TICK[1])
A.ln(c, 38, 15, 45, 13, TICK[1], tm)

-- page block (offset right/down so it shows behind the front cover)
local pm = c:rrect(19, 12, 47, 56, 2)
pm:each(function(x, y)
  local v = 4
  if x >= 46 then v = (x == 47) and 3 or 5 end
  if y >= 55 then v = (y == 56) and 3 or 4 end
  if x >= 46 and y % 3 == 0 then v = v - 1 end           -- page lines on the fore-edge
  if y >= 55 and x % 4 == 1 then v = v - 1 end
  c:put(x, y, PAGE[max(1, v)])
end)

-- cover
local cm = c:rrect(16, 10, 45, 54, 2)
local cn = X.pillow(cm, 2.2, 0.8)
local bias = {}
-- hinge groove: dark line at x=21, lit lip at x=22; spine side slightly rounder/darker
cm:each(function(x, y) local k = K(x, y)
  if x <= 18 then bias[k] = -1 end
end)
local ci = A.shade(c, cm, cn, BLUE, { bias = bias, wrap = 0.35 })
A.adjust(c, cm, ci, BLUE, function(x, y, i)
  if y <= 11 or y >= 53 then return nil end
  if x == 21 then return -2 end
  if x == 22 then return 1 end
  -- diagonal cloth weave on the flat front
  if x >= 24 and x <= 43 and y >= 13 and y <= 51 then
    if (x + y) % 4 == 0 then return -1 end
    if (x - y) % 6 == 0 and (x + y) % 2 == 1 then return 1 end
  end
end)
-- page block AO: darker row where pages meet the cover
for y = 12, 55 do if c:get(46, y) and not cm:has(46, y) then c:put(46, y, PAGE[2]) end end
for x = 19, 46 do if not cm:has(x, 55) then c:put(x, 55, PAGE[2]) end end
-- blind-stamped frame (debossed: dark top/left, lit bottom/right)
for x = 25, 42 do c:put(x, 14, BLUE[2]) c:put(x, 50, BLUE[5]) end
for y = 14, 50 do c:put(25, y, BLUE[2]) c:put(42, y, BLUE[5]) end
c:put(42, 14, BLUE[3]) c:put(25, 50, BLUE[3])

-- globe emblem (raised gold sphere)
local gx, gy, gr = 33.5, 25.5, 7
local gm = c:ellipse(gx, gy, gr, gr)
local gn = X.sphere(gx - 0.6, gy - 0.6, gr, gm)
-- cast shadow on cover lower-right
A.cast(c, cm, ci, BLUE, gm, 1, 1, -2)
local gi = A.shade(c, gm, gn, GOLD, { wrap = 0.15, amb = 0.05 })
-- meridians + latitudes engraved one tone down
A.adjust(c, gm, gi, GOLD, function(x, y, i)
  local dx, dy = x - gx, y - gy
  local r = sqrt(dx*dx + dy*dy)
  if r > gr - 0.6 then return nil end
  if abs(dx) < 0.6 then return -2 end                                 -- central meridian
  if abs(dy) < 0.6 then return -2 end                                  -- equator
  local e = (dx / 3.6)^2 + (dy / (gr + 0.3))^2                          -- meridian ellipse
  if abs(e - 1) < 0.2 then return -1 end
  if abs(abs(dy) - 4) < 0.5 and abs(dx) < 5 then return -1 end         -- latitudes
end)
c:put(30, 21, GOLD[6]) c:put(31, 21, GOLD[6]) c:put(30, 22, "#fffbe6")
-- title bars: raised gold, lit top, dark bottom, cast shadow
local function bar(x0, x1, y)
  for x = x0, x1 do
    c:put(x, y, GOLD[5]) c:put(x, y + 1, GOLD[3])
    c:put(x + 1, y + 2, BLUE[2])
  end
  c:put(x0, y + 1, GOLD[2]) c:put(x1, y, GOLD[4]) c:put(x1 + 1, y + 1, BLUE[2])
end
bar(26, 41, 36) bar(29, 38, 40)

-- worn red visa stamp (ink on cloth: ring + inner ring + star, with a gap where the ink missed)
local sx, sy = 36, 46
for y = sy - 5, sy + 5 do for x = sx - 5, sx + 5 do
  local d = sqrt((x - sx)^2 + (y - sy)^2)
  local ang = math.atan(y - sy, x - sx)
  local gap = ang > 2.2 and ang < 2.9
  if not gap and d >= 3.6 and d < 4.7 then c:put(x, y, (x + y) % 5 == 0 and RED[1] or RED[2]) end
  if d < 1.6 and not (x == sx and y == sy) then c:put(x, y, RED[2]) end
end end
c:put(sx, sy, RED[3]) c:put(sx - 3, sy - 2, RED[3])

-- cover bright edge top-left (bevel highlight) + one cream glint on the corner
for x = 18, 43 do if (c:get(x, 10)) then c:put(x, 10, BLUE[5]) end end
c:put(18, 11, BLUE[6]) c:put(19, 11, BLUE[6])

A.save(c, "nav-passport")
