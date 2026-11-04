-- nav-almanac (final, Opus single pass). A slim, upright cloth-bound almanac: dusk-blue padded cover with a diagonal
-- cloth weave and a blind-stamped frame, a raised gold sun-and-crescent-moon emblem with two title bars, a rounded spine
-- with two raised gold bands, gold metal corner caps (bevel, bright edge, rivet), the cream page block showing on the
-- right and bottom, a red ribbon marker with a notched tail.
-- quirk: a pressed autumn leaf pokes out of the top of the pages.
local NAME = "nav-almanac"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local COV = { "#1c2046", "#283163", "#354683", "#465ea3", "#6782c2", "#98b0df" }
local GOLD = { "#6a381c", "#975820", "#c78424", "#e9ab30", "#f8d264", "#fff0b4" }
local PAGE = { "#7d6c62", "#a9967e", "#cdb994", "#e6d6b0", "#f6ebc8", "#fff4d6" }
local RIB = { "#5e1c34", "#8e2638", "#bf3640", "#e2513f", "#f6835a", "#ffb48a" }
local LF = { "#5c2a1c", "#8a3f1c", "#b85e22", "#dc8a2c", "#f2b448", "#fde08a" }

local FX0, FY0, FX1, FY1 = 12, 10, 44, 49        -- front board incl. spine
---------------------------------------------------------------- back board + page block
local back = HP.rrect(14, 12, 47, 52, 2)
local btok = A.tok("back")
back:each(function(x, y) c:put(x, y, (y >= 52 or x >= 47) and COV[1] or COV[2], btok) end)
local pages = HP.rect(16, 11, 46, 51)
local ptok = A.tok("pages")
pages:each(function(x, y)
  local i
  if x >= 45 then i = (y % 2 == 0) and 4 or 5 if x == 46 then i = i - 1 end   -- fore-edge leaves
  elseif y >= 50 then i = (x % 2 == 0) and 4 or 3 if y == 51 then i = i - 1 end -- tail edge
  else i = 5 end
  if x >= 45 and y >= 50 then i = 2 end                                        -- corner tuck
  c:put(x, y, PAGE[i], ptok)
end)
-- ambient row under the front board on the page edges
for x = 17, 45 do c:put(x, 50, PAGE[2], ptok) end
for y = 12, 49 do c:put(45, y, PAGE[min(3, (y % 2 == 0) and 3 or 2)], ptok) end

---------------------------------------------------------------- quirk: pressed leaf out of the top pages (behind the board)
do
  local m, n, T, S = A.blade(39, 13, 41, 9, 45, 6, function(t) if t > 0.97 then return -1 end return max(0.4, 2.3 * sin(pi * min(1, 0.15 + t * 0.85)) ^ 0.7) end, { fold = 0.3 })
  local tok = A.tok("leaf")
  A.shade(c, m, n, LF, { tok = tok, amb = 0.2, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 then c:put(x, y, LF[2], tok) end
    if S[k] > 0.2 and S[k] < 0.6 and (x + y) % 3 == 0 then c:put(x, y, LF[3], tok) end end)
  -- lobe nicks: a maple-ish leaf
  for _, p in ipairs{ { 42, 10, LF[2] }, { 44, 8, LF[3] } } do if m:has(p[1], p[2]) then c:put(p[1], p[2], p[3], tok) end end
end

---------------------------------------------------------------- front board (padded, cloth)
local front = HP.rrect(17, FY0, FX1, FY1, 2)
local spine = HP.rrect(FX0, FY0, 17, FY1, 1)
front:cut(spine)
local ftok = A.tok("cover")
local fn = X.pillow(front, 3, 0.9)
local fb = {}
-- hinge groove next to the spine
front:each(function(x, y) if x == 18 then fb[K(x, y)] = -2 elseif x == 19 then fb[K(x, y)] = -1 end end)
local fidx = A.shade(c, front, fn, COV, { tok = ftok, bias = fb, amb = 0.22, wrap = 0.35, cuts = { 0.12, 0.3, 0.48, 0.66, 0.86 } })
-- cloth weave: sparse diagonal threads
front:each(function(x, y) local k = K(x, y)
  local i = fidx[k]
  if i and x > 19 and (x - y) % 4 == 0 and X.hash(x, y, 9) > 0.35 then c:put(x, y, COV[max(1, i - 1)], ftok) end
  if i and x > 19 and (x + y) % 5 == 0 and X.hash(x, y, 2) > 0.7 then c:put(x, y, COV[min(6, i + 1)], ftok) end
end)
-- blind-stamped frame: dark line, lit lip below/right
local fr = HP.rect(21, 14, 40, 45):cut(HP.rect(22, 15, 39, 44))
fr:each(function(x, y) c:put(x, y, COV[2], ftok) end)
for x = 22, 40 do c:put(x, 46, COV[5], ftok) end
for y = 15, 45 do c:put(41, y, COV[3], ftok) end
for x = 22, 39 do c:put(x, 15, COV[5], ftok) end
for y = 16, 44 do c:put(22, y, COV[5], ftok) end

---------------------------------------------------------------- spine (rounded) with raised gold bands
do local tok = A.tok("spine")
  local n = {}
  spine:each(function(x, y)
    local s = (x - 14.5) / 3.2
    s = max(-0.95, min(0.95, s))
    n[K(x, y)] = { s, 0, sqrt(1 - s * s) }
  end)
  local idx = A.shade(c, spine, n, COV, { tok = tok, amb = 0.2, wrap = 0.35, cuts = { 0.12, 0.3, 0.48, 0.66, 0.86 } })
  for _, by in ipairs{ 14, 44 } do
    for y = by, by + 2 do for x = FX0, 17 do if spine:has(x, y) then
      local i = (idx[K(x, y)] or 3) + (y == by and 1 or (y == by + 2 and -2 or 0))
      c:put(x, y, GOLD[max(1, min(6, i))], tok)
    end end end
  end
  -- ambient line where the spine meets the board
  for y = FY0 + 1, FY1 - 1 do c:put(17, y, COV[1], tok) end
end

---------------------------------------------------------------- gold emblem: sun + crescent moon, title bars
local gtok = A.tok("gold")
local sun = HP.ellipse(33, 25, 3, 3)
local rays = HP.mask()
for i = 0, 7 do local a = i * pi / 4
  for r = 5, 6 do rays:set(floor(33 + cos(a) * r + .5), floor(25 + sin(a) * r + .5)) end end
local moon = HP.ellipse(29, 29, 6, 6):cut(HP.ellipse(32, 26, 5.3, 5.3))
local em = sun:copy():add(rays):add(moon)
local bars = HP.rect(24, 38, 37, 39):add(HP.rect(27, 41, 34, 41))
em:add(bars)
local en = X.pillow(em, 1.4, 1.2)
local eidx = A.shade(c, em, en, GOLD, { tok = gtok, amb = 0.15, wrap = 0.25, cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 } })
-- debossed shadow lower-right of the gold
em:shift(1, 1):each(function(x, y) if front:has(x, y) and not em:has(x, y) then c:put(x, y, COV[2], ftok) end end)
-- moon face: a tiny closed eye and a sun core
c:put(27, 30, GOLD[2], gtok) c:put(26, 30, GOLD[2], gtok)
c:put(32, 24, GOLD[6], gtok) c:put(33, 24, GOLD[6], gtok)

---------------------------------------------------------------- metal corner caps (right corners)
local ctok = A.tok("caps")
local function cap(cx, cy, sx, sy)
  local m = HP.mask()
  for y = FY0, FY1 do for x = 17, FX1 do
    if abs(x - cx) + abs(y - cy) <= 4 and front:has(x, y) then m:set(x, y) end end end
  for y = FY0, FY1 do for x = 17, FX1 do if m:has(x, y) then
    local d = abs(x - cx) + abs(y - cy)
    local i = 4
    if d == 4 then i = 2 elseif d == 3 then i = 5 end         -- dark inner seam, bright bevel edge
    if sx > 0 and sy > 0 and d < 3 then i = 3 end              -- lower corner sits in shade
    c:put(x, y, GOLD[i], ctok)
  end end end
  c:put(cx - 2 * sx, cy - 1 * sy, GOLD[1], ctok)               -- rivet
  c:put(cx - 2 * sx - 1, cy - 1 * sy - 1, GOLD[6], ctok)
end
cap(FX1, FY0, 1, -1)
cap(FX1, FY1, 1, 1)

---------------------------------------------------------------- ribbon marker out of the tail
do local tok = A.tok("ribbon")
  local m = HP.mask()
  for y = 50, 55 do local off = (y >= 53) and 1 or 0 for x = 35 + off, 37 + off do m:set(x, y) end end
  m.s[K(37, 55)] = nil                                                   -- notched tail
  m:each(function(x, y)
    local off = (y >= 53) and 1 or 0
    local i = ({ 5, 4, 2 })[x - 34 - off] or 3
    if y == 50 then i = 1 end                                              -- tucked under the board
    if y == 53 then i = max(1, i - 1) end                                  -- fold
    c:put(x, y, RIB[i], tok)
  end)
  c:put(35, 52, RIB[6], tok)
end

A.save(c, NAME)
