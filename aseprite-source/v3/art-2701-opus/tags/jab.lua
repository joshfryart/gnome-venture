-- jab (Opus). Tag "quick" (Jab: a quick poke). A red knitted gnome mitten balled into a fist, shot forward to the
-- right on a slight upward slant, ribbed oatmeal cuff behind it, three speed streaks trailing, a small gold pop
-- burst where the knuckles land. Material: pillow-lit wool (6-tone red), knit V-stitch rows, ribbed cuff columns,
-- AO under the thumb pocket and at the cuff seam.
-- quirk: the mitten is worn through at the knuckle and a pink fingertip peeks out of the hole.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, cos, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.cos, math.sin
local c = O.new("jab")

local WOOL = { "#5e1631", "#8e1f3a", "#c0303f", "#e2503f", "#f57e58", "#ffb48a" }
local RIB  = { "#5a4038", "#8a6a54", "#b89874", "#d8bf94", "#efdcb2", "#fff0cf" }
local SKIN = { "#7a4036", "#c98462", "#f0b98d", "#ffe0bd" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local SPD  = { "#3a86b0", "#8bc4ea", "#e4f6ff" }

local A = -0.55                     -- axis angle (pointing up-right a touch)
local ux, uy = cos(A), sin(A)
local vx, vy = -uy, ux              -- +v = down-ish
local OX, OY = 34, 30               -- fist centre
local function L(u, v) return OX + u * ux + v * vx, OY + u * uy + v * vy end
local function rbox(hw, hh, r, du)
  return function(u, v)
    u = u - (du or 0)
    local qx, qy = max(abs(u) - (hw - r), 0), max(abs(v) - (hh - r), 0)
    return qx * qx + qy * qy <= r * r
  end
end

-- fist: front (right) end rounder than the back
local fist, FU, FV = O.lmask(OX, OY, A, 24, function(u, v)
  if u < -11 or u > 12.5 then return false end
  local r = u > 0 and 8 or 4
  return rbox(12, 10.5, r)(u, v)
end)
-- thumb pocket lying across the near side, tip curling down over the front
local tp = {}
for i, p in ipairs{ { -7, -8 }, { 0, -12.5 }, { 9, -10 }, { 10.5, -3 } } do local x, y = L(p[1], p[2]) tp[i] = { x, y } end
local thumb, tn, TT, TS = O.tube(tp, function(t) return 3.8 - 0.8 * t end)
-- cuff: ribbed band behind the fist
local cuff, CU, CV = O.lmask(OX, OY, A, 30, function(u, v) return u >= -20 and u <= -10 and abs(v) <= 9.5 - max(0, -16 - u) * 0.15 end)

-- cuff (drawn first, the fist overlaps it)
do
  local tok = O.tok("cuff")
  local n = {}
  cuff:each(function(x, y) local k = K(x, y)
    local s = max(-0.95, min(0.95, CV[k] / 10.5))
    n[k] = { vx * s, vy * s, sqrt(1 - s * s) }
  end)
  local b = {}
  cuff:each(function(x, y) local k = K(x, y)
    local u = CU[k]
    -- rib columns: every 3rd column sinks
    if floor(u + 20.5) % 3 == 2 then b[k] = -1 end
    if u > -11.6 then b[k] = (b[k] or 0) - 1 end   -- AO at the seam with the fist
  end)
  local idx = O.shade(c, cuff, n, RIB, { bias = b, tok = tok, amb = 0.12, wrap = 0.35 })
end

-- fist wool
local fidx
do
  local tok = O.tok("fist")
  local b = {}
  O.cast(b, fist, thumb, 1, 2, -1)
  X.ao(b, fist, thumb, 1, -1)
  fidx = O.pill(c, fist, 5, WOOL, { bias = b, tok = tok, wrap = 0.3, tilt = { -0.2, -0.3, 1, 0.1 } })
  -- knit V stitches, only on the lit mid tones so the shade side stays calm
  fist:each(function(x, y) local k = K(x, y)
    local u, v = FU[k], FV[k]
    local col = (u + 40) % 5
    local row = (v + 40) % 4
    local hit = (row < 1 and (col < 1 or (col >= 2 and col < 3))) or (row >= 1 and row < 2 and col >= 1 and col < 2)
    if hit and fidx[k] >= 4 and fidx[k] <= 5 then O.step(c, fidx, WOOL, x, y, -1, tok) end
  end)
  -- curled-finger creases on the front face
  for _, cr in ipairs{ { 10.5, 0.5 }, { 10.5, 4.5 } } do
    for d = -1, 1 do local x, y = L(cr[1] + d * 0.6, cr[2] + d * 0.2) O.step(c, fidx, WOOL, floor(x + .5), floor(y + .5), -2, tok) end
  end
end

-- thumb pocket
do
  local tok = O.tok("thumb")
  local b = {}
  thumb:each(function(x, y) local k = K(x, y) if TS[k] > 0.55 then b[k] = -1 end end)
  local idx = O.shade(c, thumb, tn, WOOL, { bias = b, tok = tok, wrap = 0.3, amb = 0.12 })
  -- separating line where the thumb lies on the fist (lower edge)
  thumb:each(function(x, y) if not thumb:has(x + 1, y + 1) and fist:has(x + 1, y + 1) then O.step(c, idx, WOOL, x, y, -2, tok) end end)
  local hx, hy = L(0, -9)
  c:put(floor(hx + .5), floor(hy + .5) + 1, WOOL[6], tok) c:put(floor(hx + .5) + 1, floor(hy + .5) + 1, WOOL[6], tok)
end

-- quirk: worn hole on the top-front knuckle, a fingertip pokes out
do
  local tok = O.tok("hole")
  local hx, hy = L(8, 2)
  hx, hy = floor(hx + .5), floor(hy + .5)
  O.map(c, {
    "f.dd..",
    ".dbbd.",
    "dbnssd",
    "dsssad",
    ".daad.",
    "..dd.f",
  }, hx - 2, hy - 2, { d = WOOL[1], b = SKIN[4], n = "#fff0e6", s = SKIN[3], a = SKIN[2], f = WOOL[5] }, tok)
end

-- speed streaks (2 px tall, tapering to the left)
do
  local tok = O.tok("speed")
  for i, s in ipairs{ { -6.5, 13 }, { 0.5, 17 }, { 7, 11 } } do
    local v, len = s[1], s[2]
    for t = 0, len do
      local u = -24 - t
      local x, y = L(u, v)
      x, y = floor(x + .5), floor(y + .5)
      local tone = t < 3 and SPD[3] or t < len * 0.6 and SPD[2] or SPD[1]
      c:put(x, y, tone, tok)
      if t < len - 3 then c:put(x, y + 1, t < 3 and SPD[2] or SPD[1], tok) end
    end
  end
end

-- pop burst at the knuckles: small 4-point gold star
do
  local tok = O.tok("pop")
  local bx, by = L(17.5, -4)
  bx, by = floor(bx + .5), floor(by + .5)
  O.map(c, {
    "....g....",
    "....g....",
    "...gyg...",
    "..gyhyg..",
    "ggyhwhygg",
    "..gyhyg..",
    "...gyg...",
    "....g....",
    "....g....",
  }, bx - 4, by - 4, { g = GOLD[2], y = GOLD[3], h = GOLD[4], w = O.CREAM }, tok)
end

O.save(c, "jab")
