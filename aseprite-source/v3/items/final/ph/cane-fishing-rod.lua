-- cane-fishing-rod (final, Opus single pass, replaces the Sonnet draft). A slim, gently bowed bamboo cane on the diagonal
-- (butt lower-left, tip upper-right): per-pixel cylinder light on a 6-tone straw ramp, swollen nodes (dark groove + lit
-- lip), fine grain streaks, a twisted red cord whipping for the grip with a pale end-grain butt cap, a brass line guide
-- at the tip. The line falls in a soft curve to a glossy red/cream float and a bevelled steel hook.
-- quirk: a single green leaf has sprouted from one node; the cane is still alive.
local NAME = "cane-fishing-rod"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new(NAME)

local CANE = { "#5a3a22", "#8a6230", "#b8913e", "#d6b555", "#ead27a", "#f8eeb0" }
local CORD = { "#4e1630", "#7a1f34", "#ad2e36", "#d8483c", "#f07a52", "#ffb08a" }
local END  = { "#8a6230", "#d6b986", "#efdcae" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEEL = { "#3a3c56", "#5c5f7c", "#8a8ca4", "#c2c4d4", "#eef0f6" }
local LINE = "#ddd6c4"

-- the line + float + hook first (cane paints over where they meet)
local TIP = { 53, 9 }
local lp = { TIP, { 57, 18 }, { 56, 28 }, { 52, 35 } }
local ltok = { r = { name = "line" } }
for i = 0, 80 do local x, y = A.bez(lp, i / 80) c:put(floor(x + .5), floor(y + .5), LINE, ltok) end
-- float: red cap over a cream belly, small stick on top
local FX, FY = 52, 39
local fm = c:ellipse(FX, FY, 3, 3.5)
local fn = X.sphere(FX - 0.3, FY - 0.3, 3.5, fm)
local FRED = { "#6e2038", "#9c2a3a", "#c63a3c", "#e8573f", "#ff8a5c", "#ffc0a0" }
local FCR  = { "#7a6a72", "#a8949a", "#cdb9b4", "#e8d8c8", "#f8ecd8", "#fff4e4" }
local v = X.light(fn, { amb = 0.08, wrap = 0.2 })
local ftok = { r = { name = "float" } }
fm:each(function(x, y) local k = K(x, y)
  local r = (y <= FY) and FRED or FCR
  local i = 1 for j, t in ipairs(A.CUTS) do if v[k] >= t then i = j + 1 end end
  c:put(x, y, r[i], ftok) end)
for x = FX - 3, FX + 3 do if fm:has(x, FY + 1) then c:put(x, FY + 1, x < FX + 1 and FCR[3] or FCR[2], ftok) end end -- seam band
c:put(FX - 1, FY - 2, "#fff1cf", ftok) c:put(FX - 2, FY - 1, FRED[6], ftok)
c:put(FX, FY - 4, CANE[3], ftok) c:put(FX, FY - 5, CANE[4], ftok)
-- line below the float + hook
for y = FY + 4, FY + 7 do c:put(FX, y, LINE, ltok) end
local htok = { r = { name = "hook" } }
A.map(c, {
  "dc...",
  "cb...",
  "cb..e",
  "cb.cb",
  ".cbba",
}, FX - 1, FY + 8, { a = STEEL[1], b = STEEL[2], c = STEEL[4], d = STEEL[5], e = STEEL[3] }, htok)
c:put(FX, FY + 8, STEEL[3], htok)

-- cane: cubic bezier tube, tapering
local p = { { 9, 56 }, { 22, 41 }, { 37, 23 }, { 53, 9 } }
local function hw(t)
  if t < 0.27 then return 2.35 end
  return 2.0 - (t - 0.27) / 0.73 * 1.25
end
local m, n, T, S, samp = A.tube(p, hw)
local NODES = { 0.36, 0.52, 0.67, 0.81, 0.93 }
local bias = {}
local ctok = { r = { name = "cane" } }
local grip = HP.mask()
m:each(function(x, y) local k = K(x, y) if T[k] < 0.27 then grip:set(x, y) end end)
local cane = m:copy():cut(grip)
local idx = A.shade(c, cane, n, CANE, { amb = 0.1, wrap = 0.3, tok = ctok })
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
cane:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  for _, nt in ipairs(NODES) do
    local d = (t - nt) * LEN
    if d > -0.5 and d < 0.5 then c:put(x, y, CANE[max(1, idx[k] - 3)], ctok) return
    elseif d >= 0.5 and d < 1.5 and s < 0.4 then c:put(x, y, CANE[min(6, idx[k] + 1)], ctok) return end
  end
  -- grain streak along the lit side
  if s > -0.55 and s < -0.25 and X.hash(floor(t * LEN / 3), 1, 4) > 0.45 then c:put(x, y, CANE[min(6, idx[k] + 1)], ctok) end
  if s > 0.35 and s < 0.6 and X.hash(floor(t * LEN / 2), 2, 7) > 0.6 then c:put(x, y, CANE[max(1, idx[k] - 1)], ctok) end
end)
-- node swellings: 1px bumps on both edges
for _, nt in ipairs(NODES) do
  local s = samp[floor(nt * 160) + 1]
  for _, sd in ipairs{ -1, 1 } do
    local w = s.w + 0.9
    local x, y = floor(s.x + s.px * w * sd + .5), floor(s.y + s.py * w * sd + .5)
    if not m:has(x, y) then c:put(x, y, sd < 0 and CANE[5] or CANE[2], ctok) m:set(x, y) end
  end
end
-- grip: twisted cord whipping (diagonal bands) with AO where it meets the cane
local gtok = { r = { name = "grip" } }
local gi = A.shade(c, grip, n, CORD, { amb = 0.1, wrap = 0.3, tok = gtok })
grip:each(function(x, y) local k = K(x, y)
  local u = T[k] * LEN + S[k] * 1.6
  local ph = u % 2.2
  if ph < 0.8 then c:put(x, y, CORD[max(1, gi[k] - 2)], gtok)
  elseif ph < 1.3 and S[k] < 0.3 then c:put(x, y, CORD[min(6, gi[k] + 1)], gtok) end
  if T[k] > 0.25 then c:put(x, y, CORD[1], gtok) end
end)
-- butt cap: pale end grain with a dark pith ring
local b0 = samp[1]
local cap = HP.mask()
for _, q in ipairs{ { 0, 0 }, { -1, 0 }, { 0, 1 }, { -1, 1 }, { 1, 0 }, { 0, -1 }, { 1, 1 }, { -1, -1 } } do end
local ex, ey = floor(b0.x - b0.tx * 0.8 + .5), floor(b0.y - b0.ty * 0.8 + .5)
A.map(c, { ".ab", "bcb", "ba." }, ex - 2, ey - 1, { a = END[3], b = END[2], c = END[1] }, gtok)
-- tip ring (brass guide)
local te = samp[#samp]
c:put(floor(te.x + .5), floor(te.y + .5), "#f5b82e", ctok)
c:put(floor(te.x + 1.5), floor(te.y - 0.5), "#8f4a1f", ctok)
c:put(floor(te.x + .5), floor(te.y - 0.5), "#ffe38a", ctok)
-- specular glint on the cane
do local s = samp[floor(0.45 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.45 + .5), floor(s.y + s.py * s.w * -0.45 + .5), "#fffbe0", ctok) end

-- quirk: a leaf sprouting from the node at t=0.52, upper-left side
do
  local s = samp[floor(0.52 * 160) + 1]
  local bx, by = s.x - s.px * (s.w + 0.5), s.y - s.py * (s.w + 0.5)
  c:put(floor(bx + 1.5), floor(by + 1.5), LEAF[2]) c:put(floor(bx + .5), floor(by + .5), LEAF[3])
  local lm = A.leaf(c, bx, by, bx - 4, by - 6, bx - 11, by - 6, 2.7, LEAF, { vs = 2.6, pw = 0.7 })
end

A.save(c, NAME)
