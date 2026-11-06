-- ico-tent (final, Opus). A slim A-frame ridge tent in 3/4 view: lit front gable with the door flaps tied back on a
-- dark doorway, the long side wall falling into shade, a wooden front pole with a round finial, two guy ropes to
-- wooden pegs, ground shadow.
-- Material: 6-tone canvas (moss, cool-teal shade) lit per pixel from planar normals with a sag curve, diagonal
-- weave on both walls, cream lining on the curled flaps, gold ties, one gold hem stitch along the front, ridge seam
-- line where the walls meet, ambient dark at the top of the doorway and under the flaps, twisted ropes, wood grain
-- on the pole.
-- quirk: a pair of little red gnome boots waits outside the door.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_1.lua")
local HP, X, K = R.HP, R.X, R.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = R.new("ico-tent")
local CAN  = { "#173a3c", "#22564a", "#2f7a4c", "#4a9a50", "#74ba5a", "#a8d872" }
local LIN  = { "#8a6e48", "#d8c08a", "#f2e2b4", "#fff4d6" }
local DARK = { "#160f22", "#241a3a", "#35295f" }
local WOOD = { "#3e2422", "#5e3a2a", "#864c33", "#a86a40", "#c88f5c", "#e8b982" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local ROPE = { "#8a6a4a", "#d8c09a" }
local RED  = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

c:groundShadow(33, 53, 25, 2)
local A, BL, BR = { 27, 13 }, { 8, 52 }, { 42, 52 }
local RT, RB = { 37, 10 }, { 56, 47 }
-- guy ropes + pegs (behind the tent)
local function rope(x0, y0, x1, y1)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for s = 0, n do c:put(floor(x0 + (x1 - x0) * s / n + .5), floor(y0 + (y1 - y0) * s / n + .5), ROPE[(s % 2) + 1]) end
end
rope(12, 44, 9, 51) rope(53, 40, 57, 47)
local function peg(x, y)
  c:put(x, y - 1, WOOD[5]) c:put(x + 1, y - 1, WOOD[3])
  c:put(x, y, WOOD[4]) c:put(x + 1, y, WOOD[2])
  c:put(x, y + 1, WOOD[3]) c:put(x + 1, y + 1, WOOD[1])
end
peg(8, 51) peg(57, 47)

-- side wall (shade side), then the front gable over it
local side = c:poly{ A, RT, RB, BR }
local front = c:poly{ A, BL, BR }
side:cut(front)
local function canvasN(m, base, sagAxis)
  local n = {}
  m:each(function(x, y)
    -- canvas sags between pole and pegs: normal tilts up a little toward the middle of each wall
    local t = (y - 12) / 40
    local sag = 0.22 * math.sin(math.pi * max(0, min(1, t)))
    n[K(x, y)] = { R.norm(base[1], base[2] - sag, base[3]) }
  end)
  return n
end
local sideN = canvasN(side, { 0.75, -0.15, 0.55 })
local sbias = {}
side:each(function(x, y) if (x - y) % 5 == 0 then sbias[K(x, y)] = -1 end end)   -- weave
-- seam row along the ridge edge with the front
R.touch(side, front):each(function(x, y) sbias[K(x, y)] = -2 end)
local sidx, _, stok = R.shade(c, side, sideN, CAN, { amb = 0.15, wrap = 0.3, bias = sbias, cuts = { 0.25, 0.42, 0.58, 0.74, 0.88 } })
-- ridge highlight on the top edge of the side wall
side:each(function(x, y) if not side:has(x, y - 1) and not front:has(x, y - 1) and x > A[1] + 1 then c:put(x, y, CAN[4], stok) end end)

local fN = canvasN(front, { -0.35, -0.3, 0.88 })
local fbias = {}
front:each(function(x, y)
  if (x + y) % 5 == 0 then fbias[K(x, y)] = -1 end
  if (x - A[1]) > (y - A[2]) * 0.2 then fbias[K(x, y)] = (fbias[K(x, y)] or 0) - 1 end   -- right half turns away a little
end)
-- hem band darker
front:each(function(x, y) if y >= 50 then fbias[K(x, y)] = (fbias[K(x, y)] or 0) - 1 end end)
local fidx, _, ftok = R.shade(c, front, fN, CAN, { amb = 0.15, wrap = 0.3, bias = fbias, cuts = { 0.25, 0.42, 0.58, 0.74, 0.88 } })
-- lit edge along the left slope (bevel of the stretched canvas)
front:each(function(x, y) if not front:has(x - 1, y) and y > A[2] + 1 and y < 49 then c:put(x, y, CAN[6], ftok) end end)

-- doorway: dark interior with a back wall and an ambient top
local door = c:poly{ { 26, 23 }, { 17.5, 52 }, { 35.5, 52 } }
local dtok = { r = { name = "door" } }
door:each(function(x, y)
  local col = DARK[2]
  if y < 30 then col = DARK[1] end
  if y >= 44 and x >= 23 and x <= 30 then col = DARK[3] end                  -- glimpse of the back wall / bedroll
  if not door:has(x - 1, y) or not door:has(x, y - 1) then col = DARK[1] end
  c:put(x, y, col, dtok)
end)
-- bedroll inside: a warm rolled blanket
local bed = c:rrect(22, 46, 31, 50, 2)
local bn = {}
bed:each(function(x, y) local s = (y - 48) / 3 bn[K(x, y)] = { R.norm(-0.2, s, sqrt(max(0.05, 1 - s*s))) } end)
local bedR = { "#3a1a3a", "#6e2848", "#a83a4e", "#d0584e", "#ee8a62" }
R.shade(c, bed, bn, bedR, { amb = 0.05, cuts = { 0.2, 0.42, 0.62, 0.82 } })
for x = 24, 30, 3 do c:put(x, 47, "#ee8a62") c:put(x, 48, "#a83a4e") end      -- plaid stripe

-- flaps curled back, cream lining showing, gold ties
local flapL = c:poly{ { 26, 23 }, { 17.5, 52 }, { 13, 52 }, { 18.5, 38 } }
local flapR = c:poly{ { 26.5, 23 }, { 35.5, 52 }, { 40, 52 }, { 33.5, 38 } }
local function flap(m, lit)
  local ftk = { r = { name = "flap" } }
  m:each(function(x, y)
    local edgeIn = lit and not m:has(x + 1, y) or (not lit and not m:has(x - 1, y))
    local col = lit and LIN[3] or LIN[2]
    if y < 30 then col = lit and LIN[4] or LIN[3] end
    if edgeIn then col = LIN[1] end
    c:put(x, y, col, ftk)
  end)
end
flap(flapL, true) flap(flapR, false)
-- ambient under the flaps on the canvas
for y = 24, 52 do
  for x = 8, 44 do
    if front:has(x, y) and not flapL:has(x, y) and not flapR:has(x, y) and not door:has(x, y) then
      if flapL:has(x + 1, y) or flapR:has(x - 1, y) then R.step(c, fidx, CAN, x, y, -2, ftok) end
    end
  end
end
for _, t in ipairs{ { 15, 39 }, { 35, 39 } } do
  c:put(t[1], t[2], GOLD[4]) c:put(t[1] + 1, t[2], GOLD[3]) c:put(t[1] + 2, t[2], GOLD[3])
  c:put(t[1], t[2] + 1, GOLD[2]) c:put(t[1] + 1, t[2] + 1, GOLD[2]) c:put(t[1] + 2, t[2] + 1, GOLD[1])
end
-- hem stitch along the front bottom (the one stitch)
local pts = {}
c:stitch{ { 10, 50 }, { 16, 50 } } c:stitch{ { 37, 50 }, { 41, 50 } }

-- front pole above the apex with a round finial
local pole = c:rect(26, 8, 28, 14)
local pn = {}
pole:each(function(x, y) local s = (x - 27) / 1.6 pn[K(x, y)] = { R.norm(s, 0, sqrt(max(0.05, 1 - s*s))) } end)
local pidx, _, ptok = R.shade(c, pole, pn, WOOD, { amb = 0.1 })
c:put(27, 11, WOOD[3], ptok)                                                   -- grain mark
local fin = c:ellipse(27, 6, 2, 2)
local finN = X.sphere(26.4, 5.4, 2, fin)
R.shade(c, fin, finN, WOOD, { amb = 0.08 })
c:put(26, 5, WOOD[6])
-- ambient where the canvas meets the pole
for x = 25, 29 do if front:has(x, 14) then R.step(c, fidx, CAN, x, 14, -1, ftok) end end

-- quirk: little red boots waiting outside the door
local BOOT = {
  "abb.",
  "abb.",
  "abbb",
  "dddd" }
local function boot(x, y)
  local map = { a = RED[4], b = RED[3], d = RED[1] }
  for j, row in ipairs(BOOT) do for i = 1, #row do local ch = row:sub(i, i)
    if map[ch] then c:put(x + i - 1, y + j - 1, map[ch]) end end end
  c:put(x + 2, y + 2, RED[2]) c:put(x + 3, y + 2, RED[2])
end
boot(20, 52) boot(26, 52)
R.save(c, "ico-tent")
