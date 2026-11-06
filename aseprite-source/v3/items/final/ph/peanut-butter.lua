-- peanut-butter (final pass, Opus aC32_4). An open glass jar of peanut butter on a 2-tone ground shadow: cylinder-lit
-- butter seen through the glass (cool glass walls, bright left rim streak, pale core), thick glass lip ring, kraft paper
-- label with a peanut stamp and torn corner, a glossy swirled crown with a curl peak, and a slim wooden spreader stuck in
-- it (grain lines, paler end, AO where it enters the butter).
-- quirk: a fat drip has run over the rim and down the glass onto the label.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "peanut-butter"
local c = A.new(NAME)
local PB = { "#5e3424", "#8a5430", "#b47a40", "#d29e58", "#e8c07a", "#f8e0a6" }
local GL = { "#3e5a7a", "#5f8aa8", "#8bbcd0", "#b8e2e8", "#e4f8f6" }
local PAP = { "#8f6a44", "#b88e5c", "#d8b47c", "#efd6a0", "#fbecc4" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#d49a62", "#e8b982", "#f6d6a6" }
local INK = "#2b1c26"

c:groundShadow(32, 56, 14, 2)
-- jar body
local X0, X1, Y0, Y1 = 19, 44, 27, 55
local jar = c:rrect(X0, Y0, X1, Y1, 3)
local cx, rw = (X0 + X1) / 2, (X1 - X0) / 2 + 0.5
local jtok = { r = { name = "jar" } }
local inner = jar:shrink(2)
-- butter inside (cylinder light), level line at y 30
local jidx = {}
jar:each(function(x, y) local k = K(x, y)
  local s = (x - cx) / rw
  local nx, nz = s, sqrt(max(0.02, 1 - s * s))
  local L = X.L
  local val = max(0, nx * L[1] + nz * L[3]) * 0.92 + 0.06
  if inner:has(x, y) and y >= 30 then
    local i = 1 for j, t in ipairs(A.CUTS) do if val >= t then i = j + 1 end end
    if y >= Y1 - 3 then i = i - 1 end           -- AO at the base
    i = max(1, min(6, i)) jidx[k] = i
    c:put(x, y, PB[i], jtok)
  else
    -- glass wall / empty glass above the butter
    local i = val > 0.75 and 4 or val > 0.5 and 3 or val > 0.25 and 2 or 1
    if inner:has(x, y) then i = min(5, i + 1) end
    c:put(x, y, GL[i], jtok)
  end
end)
-- glass: bright streak on the left wall, faint second streak right, dark base band
for y = Y0 + 4, Y1 - 4 do c:put(X0 + 3, y, GL[5], jtok) if y % 5 ~= 0 then c:put(X0 + 4, y, GL[4], jtok) end end
for y = Y0 + 8, Y1 - 10 do c:put(X1 - 3, y, GL[4], jtok) end
for x = X0 + 2, X1 - 2 do c:put(x, Y1, GL[1], jtok) c:put(x, Y1 - 1, (x < cx) and GL[2] or GL[1], jtok) end
-- glass lip: thick ring at the top
local lip = c:rrect(X0 - 1, Y0 - 2, X1 + 1, Y0 + 1, 1)
lip:each(function(x, y) local s = (x - cx) / (rw + 1)
  local i = y == Y0 - 2 and 5 or y == Y0 + 1 and 2 or (s < -0.3 and 4 or s < 0.4 and 3 or 2)
  if s > 0.8 then i = max(1, i - 1) end
  c:put(x, y, GL[i], jtok) end)

-- label: kraft paper band
local lab = c:rect(X0 + 1, 37, X1 - 1, 48)
local ltok = { r = { name = "label" } }
lab:each(function(x, y) local s = (x - cx) / rw
  local i = s < -0.65 and 4 or s < 0.15 and 5 or s < 0.6 and 4 or s < 0.82 and 3 or 2
  if y == 37 then i = max(1, i - 1) end
  if y == 48 then i = max(1, i - 2) end
  c:put(x, y, PAP[i], ltok) end)
-- torn lower-right corner
for _, p in ipairs{ {X1 - 1, 48}, {X1 - 2, 48}, {X1 - 1, 47} } do c:put(p[1], p[2], GL[2], jtok) end
c:put(X1 - 2, 47, PAP[2], ltok) c:put(X1 - 3, 48, PAP[2], ltok)
-- peanut stamp (ink brown two-lobe) on the label
A.map(c, {
  "....aa..",
  "...abba.",
  "...abba.",
  "..aaba..",
  ".abba...",
  ".abba...",
  "..aa....",
}, 27, 39, { a = PB[1], b = PB[3] }, ltok)

-- crown: swirled heap above the rim, curl peak
local crown = c:ellipse(31.5, 25, 11, 3.5):add(c:ellipse(31, 22, 7, 3)):add(c:ellipse(32, 19, 3.5, 2))
crown:set(34, 16) crown:set(35, 16) crown:set(35, 17) crown:set(33, 17)
local cn = A.body(crown, 29, 23, 9, 3, 0.4)
-- spreader (masks first for AO)
local wm, wn, WT, WS = A.tube({ { 38, 22 }, { 41, 17 }, { 44, 13 }, { 47, 9 } }, function(t) return t < 0.75 and 1.25 or 1.6 end)
local cb = {}
X.ao(cb, crown, wm, 1, -1)
-- swirl grooves: spiral lines on the heap
crown:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - 31.5) / 11, (y - 22) / 4.5
  local r = sqrt(dx * dx + dy * dy)
  local a = math.atan(dy, dx)
  local f = (r * 3.1 + a / (2 * pi)) % 1
  if f < 0.16 and r > 0.15 then cb[k] = (cb[k] or 0) - 2 elseif f < 0.32 and r > 0.15 then cb[k] = (cb[k] or 0) + 1 end
end)
local ctok = { r = { name = "crown" } }
A.shade(c, crown, cn, PB, { amb = 0.1, wrap = 0.3, bias = cb, tok = ctok })
c:put(27, 20, "#fff4d6", ctok) c:put(28, 20, PB[6], ctok)
-- butter pressed against the glass just under the rim is darker (AO under the crown)
for x = X0 + 2, X1 - 2 do local k = K(x, 30) if jidx[k] then c:put(x, 30, PB[max(1, jidx[k] - 2)], jtok) end end

-- spreader: wood, grain, pale end, AO where it enters
local wtok = { r = { name = "spreader" } }
wm:cut(crown:copy():cut(crown:edge()))
local widx = A.shade(c, wm, wn, WOOD, { amb = 0.12, wrap = 0.3, tok = wtok })
wm:each(function(x, y) local k = K(x, y)
  if WT[k] and WT[k] > 0.15 and (floor(WT[k] * 30) % 4 == 0) and WS[k] > -0.2 then c:put(x, y, WOOD[max(1, widx[k] - 1)], wtok) end
  if WT[k] and WT[k] > 0.97 then c:put(x, y, WOOD[6], wtok) end
end)
-- butter smear on the blade near the heap
for _, p in ipairs{ {39, 20}, {40, 19}, {40, 20} } do if wm:has(p[1], p[2]) then c:put(p[1], p[2], PB[4], wtok) end end

-- quirk: drip over the rim on the left, down the glass onto the label
local dtok = { r = { name = "drip" } }
for y = Y0 - 2, 39 do
  local w = (y >= 37) and 3 or 2
  for dx = 0, w - 1 do
    local xx = 22 + dx - ((y >= 37) and 1 or 0)
    local i = dx == 0 and 5 or (dx == w - 1 and 2 or 4)
    c:put(xx, y, PB[i], dtok)
  end
end
c:put(21, 40, PB[2], dtok) c:put(22, 40, PB[3], dtok) c:put(23, 40, PB[2], dtok)
c:put(22, 32, PB[6], dtok)

A.save(c, NAME)
