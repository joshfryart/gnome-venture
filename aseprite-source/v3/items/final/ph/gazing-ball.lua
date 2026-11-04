-- gazing-ball (final, Opus single pass). A mirrored garden gazing ball held in a brass cup on a slim stone pedestal.
-- Ball: per-pixel mirror reflection (sky graded to a pale horizon, curved tree line, dark grass below), bright rim on
-- the lit side and a dark rim on the shade side, a big window highlight and one sparkle. Brass cup: bevel, bright
-- edge, dark gap where it grips the glass. Pedestal: turned column with bevelled rings, stone grain, chamfered
-- plinth, AO under each overhang, ground shadow.
-- quirk: a tiny reflected gnome (red hat, round nose) peers out of the ball, bent by the curve.
local NAME = "gazing-ball"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local SKYR  = { "#26346c", "#34549a", "#4f7ec0", "#7eaedc", "#b0d6f0", "#e2f4ff" }
local TREE  = { "#16302e", "#22483a" }
local GRASS = { "#1a3430", "#28503c", "#3a6e46", "#56904e" }
local BRASS = { "#4a2c1c", "#7a4a24", "#a8702e", "#d09a3c", "#ecc66a", "#fff0b0" }
local STONE = { "#36364e", "#50516a", "#6e7088", "#9092a6", "#b6b6c6", "#dcdce6" }
local CX = 32

c:groundShadow(CX, 54, 13, 2)

-- plinth: chamfered block
local ptok = { r = { name = "plinth" } }
local plinth = c:rrect(CX - 10, 48, CX + 9, 53, 1)
local pidx = A.shade(c, plinth, X.pillow(plinth, 2), STONE, { tok = ptok, amb = 0.12 })
for x = CX - 9, CX + 8 do c:put(x, 48, STONE[6], ptok) c:put(x, 49, STONE[5], ptok) end   -- top chamfer face
c:put(CX - 10, 49, STONE[4], ptok) c:put(CX + 9, 49, STONE[3], ptok)
plinth:each(function(x, y) if y >= 50 and X.hash(x, y, 21) > 0.8 then A.step(c, pidx, STONE, x, y, -1, ptok) end end)

-- column: turned shaft with two bevelled rings
local ctok = { r = { name = "column" } }
local col = c:rect(CX - 3, 36, CX + 1, 47)
local cn = {}
col:each(function(x, y) local s = (x - (CX - 1)) / 3 cn[K(x, y)] = { s, 0, sqrt(max(0.05, 1 - s * s)) } end)
local cb = {}
for x = CX - 3, CX + 1 do cb[K(x, 47)] = -1 cb[K(x, 37)] = -2 cb[K(x, 38)] = -1 end
local cidx = A.shade(c, col, cn, STONE, { tok = ctok, bias = cb, amb = 0.1 })
local function ring(y, w)
  local r = c:rect(CX - 1 - w, y, CX - 1 + w, y + 1)
  local rn = {}
  r:each(function(x, yy) local s = (x - (CX - 1)) / (w + 0.5) rn[K(x, yy)] = { s, yy == y and -0.5 or 0.4, 0.8 } end)
  A.shade(c, r, rn, STONE, { tok = ctok })
end
ring(42, 3)
ring(46, 4)
-- grain flecks on the shaft
c:put(CX - 2, 40, STONE[5], ctok) c:put(CX, 44, STONE[3], ctok)

-- ball: mirror reflection
local BR, BY = 12.5, 22
local ball = c:ellipse(CX - 0.5, BY, BR, BR)
local bn = X.sphere(CX - 0.5, BY, BR, ball)
local bv = X.light(bn, { amb = 0.1, wrap = 0.35 })
local btok = { r = { name = "ball" } }
ball:each(function(x, y) local k = K(x, y) local n = bn[k]
  local nx, ny = n[1], n[2]
  local h = ny - 0.32 * nx * nx                      -- reflected horizon bends with the sphere
  local v = bv[k]
  local col
  if h < 0.12 then
    local i = 2 + floor(v * 3.2 + (h + 0.9) * 1.4)
    col = SKYR[max(2, min(6, i))]
  elseif h < 0.27 then
    local bump = X.hash(x, 0, 31) > 0.5 and 0.2 or 0.17
    col = (h < bump) and SKYR[5] or TREE[(h > 0.22) and 1 or 2]
  else
    local i = 1 + floor(v * 3.6)
    col = GRASS[max(1, min(4, i))]
  end
  c:put(x, y, col, btok)
end)
-- pale core band just above the horizon (glass glow)
ball:each(function(x, y) local n = bn[K(x, y)] local h = n[2] - 0.32 * n[1] * n[1]
  if h > 0.03 and h < 0.11 and abs(n[1]) < 0.7 then c:put(x, y, SKYR[6], btok) end end)
-- rims: bright on the lit upper-left, dark on the shade side
ball:edge():each(function(x, y) local n = bn[K(x, y)]
  local d = n[1] * -0.6 + n[2] * -0.8
  if d > 0.35 then c:put(x, y, SKYR[6], btok) elseif d < -0.3 then c:put(x, y, SKYR[1], btok) end end)
-- window highlight: curved 4-pane glint upper-left + streak
for _, p in ipairs{ {26, 14}, {27, 14}, {25, 15}, {26, 15}, {28, 13}, {29, 13}, {24, 17}, {24, 16} } do c:put(p[1], p[2], "#fffaf0", btok) end
c:put(27, 16, SKYR[6], btok) c:put(25, 18, SKYR[6], btok)
c:put(36, 29, SKYR[5], btok) c:put(37, 28, SKYR[5], btok)   -- secondary reflected light low right

-- quirk: tiny reflected gnome, squashed by the curve, standing on the reflected lawn
A.map(c, {
  "..h..",
  ".hhr.",
  "hhrrd",
  ".sns.",
  ".bbb.",
}, CX + 1, 22, { h = "#e8493b", r = "#b52e3f", d = "#6e2038", s = "#f0b98d", n = "#c98462", b = "#fff4d6" })

-- brass cup gripping the ball's base
local cup = c:ellipse(CX - 0.5, 34, 6, 2.6):cut(c:ellipse(CX - 0.5, 31.6, 5, 2.2))
cup:add(c:rect(CX - 3, 35, CX + 2, 36))
local cupn = {}
cup:each(function(x, y) local s = (x - (CX - 0.5)) / 6.5 cupn[K(x, y)] = { s, 0.3, sqrt(max(0.05, 1 - s * s)) } end)
local kidx = A.shade(c, cup, cupn, BRASS, { tok = { r = { name = "cup" } }, amb = 0.12 })
-- dark gap where brass meets glass; bright top edge
cup:each(function(x, y) if ball:has(x, y - 1) and not cup:has(x, y - 1) then
  if x < CX - 1 then c:px(x, y, BRASS[6]) else c:px(x, y, BRASS[4]) end end end)
ball:each(function(x, y) if cup:has(x, y + 1) then c:px(x, y, GRASS[1]) end end)
c:px(CX - 4, 34, BRASS[6]) c:px(CX - 3, 34, BRASS[6])
-- AO under the cup on the column top
for x = CX - 3, CX + 1 do c:px(x, 37, STONE[1]) end

-- sparkle on the glass
c:sparkle(22, 19)

A.save(c, NAME)
