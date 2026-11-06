-- pickled-peppers (C34, Opus artist pass). Tapered crock-shaped glass jar (wide mouth, narrow foot) with a red
-- enamel screw lid (knurled ridges, bevel, bright top edge); inside, glossy curved chillies in red, sunny yellow and
-- green criss-cross in amber brine: 6-tone tube light, one wet streak each, ruffled calyx caps with hooked stems,
-- a floating ring slice showing pith and seeds; a small paper label with a hand-drawn chilli.
-- quirk: the peppers are so hot a wavy curl of heat is rising out from under the lid.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_4.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("pickled-peppers")

local RED = { "#5c1630", "#901d32", "#c42a2c", "#e84a2c", "#fb7a44", "#ffb07a" }
local YEL = { "#7a3e1e", "#b0661c", "#dc961e", "#f4bc2a", "#ffd95a", "#fff09a" }
local GRN = { "#173f36", "#22593c", "#2f783c", "#4e9a40", "#7abd4e", "#b0da6c" }
local CAL = { "#1a3a2c", "#285636", "#3c7a3c", "#5c9c44", "#86bc56", "#b8dc78" }
local BRINE = { "#86422e", "#b8663a", "#dc904c", "#f0b66a", "#fad290", "#fff0c4" }
local LID = { "#4e1426", "#82202e", "#b8302e", "#dc4a34", "#f47a52", "#ffb08a" }
local LBL = { "#8a6a52", "#bca07a", "#dcc49a", "#f0e0bc", "#faf0d8", "#fffaec" }

A.shadow(32, 56, 13, 1.5)
local J = A.jar{ pts = { { 19, 14 }, { 21, 15 }, { 23, 15.5 }, { 52, 12.5 }, { 54, 11.5 } }, level = 26, brine = BRINE }
local IN = J.inside

local function chilli(ax, ay, dx, dy, bend, ramp, w)
  w = w or 2.4
  local vx, vy = dx - ax, dy - ay
  local L = sqrt(vx * vx + vy * vy)
  local px, py = -vy / L, vx / L
  local p = { { ax, ay }, { ax + vx * 0.33 + px * bend, ay + vy * 0.33 + py * bend },
    { ax + vx * 0.7 + px * bend, ay + vy * 0.7 + py * bend }, { dx, dy } }
  local m, n, T, S, sm = G.tube(p, function(t)
    if t < 0.07 then return w * 0.85 end
    return w * ((1 - t) / 0.93) ^ 0.55 + 0.35
  end)
  m:clip(IN)
  local cal, body = HP.mask(), HP.mask()
  m:each(function(x, y) if T[K(x, y)] < 0.08 then cal:set(x, y) else body:set(x, y) end end)
  A.part(body, n, ramp, { amb = 0.08, wrap = 0.25, edge = 2, ao = { { cal, 1, -1 } } })
  -- wet streak along the lit side
  body:each(function(x, y) local k = K(x, y) if abs(S[k] + 0.45) < 0.14 and T[k] > 0.18 and T[k] < 0.6 then c:put(x, y, ramp[6]) end end)
  local s = sm[floor(0.24 * #sm)]
  local gx, gy = floor(s.x + s.px * s.w * -0.45 + .5), floor(s.y + s.py * s.w * -0.45 + .5)
  if IN:has(gx, gy) then c:put(gx, gy, A.SPEC) end
  A.part(cal, n, CAL, { amb = 0.15, wrap = 0.3, edge = 1 })
  -- hooked stem out of the cap
  local ux, uy = -vx / L, -vy / L
  local s0x, s0y = ax + ux * 1.5, ay + uy * 1.5
  local pts = { { s0x, s0y }, { s0x + ux * 2, s0y + uy * 2 }, { s0x + ux * 3 + px * 1.5, s0y + uy * 3 + py * 1.5 } }
  for i, q in ipairs(pts) do local x, y = floor(q[1] + .5), floor(q[2] + .5)
    if IN:has(x, y) then c:put(x, y, i == 1 and CAL[2] or CAL[4]) if i == 3 then c:put(x, y, CAL[5]) end end end
end
-- back to front
chilli(20, 40, 29, 52, -1.5, GRN, 2.0)
chilli(43, 28, 24, 50, -2.5, YEL, 2.4)
chilli(36, 27, 20, 45, 2, RED, 2.3)
chilli(21, 28, 39, 51, 3, RED, 2.5)
chilli(30, 28, 44, 46, -2, RED, 2.2)

-- floating ring slice: red skin, pale pith, seeds
do
  local cx, cy = 41, 38
  local m = A.ell(cx, cy, 3.4, 3.0)
  A.part(m, A.ellN(m, cx, cy, 3.4, 3.0), RED, { clip = IN, edge = 1 })
  local inner = A.ell(cx, cy, 2.0, 1.6)
  inner:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and "#ffe8a8" or "#f6c878") end)
  c:put(cx - 1, cy, "#fff6d0") c:put(cx, cy + 1, "#e0a050")
end

-- paper label with a hand-drawn chilli
do
  local m = HP.rect(23, 44, 40, 49)
  A.vband(m, 22, 41, LBL, { nocontact = true })
  for x = 23, 40 do c:put(x, 44, LBL[5]) c:put(x, 49, LBL[2]) end
  A.map({
    ".....gg.",
    "rrrrrgg.",
    "RrrrrrrG",
    ".RRRrr..",
  }, 28, 45, { r = "#e84a2c", R = "#a8243a", g = "#4e9a40", G = "#2f783c" })
  for x = 37, 39 do c:put(x, 46, "#c8a07a") end c:put(25, 46, "#c8a07a") c:put(25, 47, "#c8a07a")
end

A.glassFront(J, { top = 3, gaps = { { 41, 50 } }, wide = 12 })

-- enamel screw lid
local lid = HP.mask()
for y = 15, 21 do local w = (y == 15) and 14 or 15 for x = 32 - w, 31 + w do lid:set(x, y) end end
A.vband(lid, 17, 46, LID, { nocontact = true, round = function(x, y) return y == 15 and -0.7 or (y == 21 and 0.5 or 0) end })
-- knurled ridges on the skirt, bright top edge, dark thread line under
for x = 18, 45, 2 do for y = 18, 20 do A.darken(x, y, 1) end end
for x = 19, 37 do c:put(x, 16, LID[6]) end
c:put(21, 17, "#fff4e0") c:put(22, 17, "#fff4e0")
for x = 17, 46 do c:put(x, 22, "#3c6a9c") end

-- quirk: heat curl rising from under the lid
A.map({
  "..ab",
  ".a..",
  "..ba",
  "...b",
  "..a.",
  ".ab.",
}, 43, 8, { a = "#ffb07a", b = "#fb7a44" })
A.fin()
