-- coir-fibre (final, Opus single pass). A slim sheaf of coconut-husk fibre lying on the diagonal, pinched by two
-- twisted twine bindings; the fibres run lengthwise as separate strands of varying tone (rust, tan, dark husk),
-- round-lit as a bundle, with AO rows where the bindings bite in, and frayed fans of loose strands at both ends.
-- quirk: one stray fibre springs out of the middle in a loose curl.
local NAME = "coir-fibre"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local COIR = { "#4a261c", "#6e3a22", "#93522a", "#b46e36", "#d1904c", "#ebb872" }
local TW = { "#5c4632", "#86683e", "#ad8c52", "#ccae6c", "#e8d092", "#f8ecbc" }

local AX, AY, BX, BY = 14, 47, 50, 17
local TIES = { 0.3, 0.7 }
local function wfn(t)
  local w = 5.0 - 0.9 * abs(t - 0.5) * 2
  for _, tt in ipairs(TIES) do local d = abs(t - tt) if d < 0.07 then w = w - 1.4 * (1 - d / 0.07) end end
  return w
end
local m, n, T, S = X.cyl(AX, AY, BX, BY, wfn)
local vx, vy = BX - AX, BY - AY
local L = sqrt(vx * vx + vy * vy)
local ux, uy = vx / L, vy / L
local px, py = -uy, ux
if px + py < 0 then px, py = -px, -py end

-- frayed fans at both ends: 1px strands spreading from the bundle tip
local ftok = { r = { name = "fringe" } }
local fan = HP.mask()
local fpix = {}
local function strand(ox, oy, dx, dy, l, tone)
  for i = 0, l do
    local x, y = floor(ox + dx * i + .5), floor(oy + dy * i + .5)
    if not m:has(x, y) then fan:set(x, y) fpix[#fpix + 1] = { x, y, tone } end
  end
end
for e = 0, 1 do
  local sgn = e == 0 and -1 or 1
  local ex, ey = (e == 0) and AX or BX, (e == 0) and AY or BY
  for j = -2, 2 do
    local a = j * 0.26 * sgn
    local dx, dy = ux * sgn * cos(a) - uy * sgn * sin(a), uy * sgn * cos(a) + ux * sgn * sin(a)
    local ox, oy = ex + px * j * 1.8, ey + py * j * 1.8
    local l = 4 + ((j + 3) * (e + 2)) % 3
    strand(ox, oy, dx, dy, l, (j % 2 == 0) and 4 or (j < 0 and 5 or 3))
  end
end

-- bundle: strand texture lengthwise
local tok = { r = { name = "coir" } }
local v = X.light(n, { amb = 0.08, wrap = 0.3 })
local bias = {}
m:each(function(x, y) local k = K(x, y)
  local s = S[k]
  local sid = floor((s + 1) * 4.6 + 0.5)                    -- strand index across the bundle
  local h = X.hash(sid, 7, 3)
  local b = (h < 0.3) and -1 or ((h > 0.78) and 1 or 0)
  -- broken strand gaps along the length
  if X.hash(sid, floor(T[k] * L / 5), 11) < 0.18 then b = b - 1 end
  for _, tt in ipairs(TIES) do if abs(T[k] - tt) < 0.11 then b = b - 1 end end
  bias[k] = b
end)
X.tone(c, m, v, COIR, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = tok })
-- fringe strands, darker toward their tips
for _, p in ipairs(fpix) do c:put(p[1], p[2], COIR[p[3]], ftok) end

-- twine bindings: 3px bands wrapping the bundle, with a diagonal twist pattern
local twtok = { r = { name = "twine" } }
for i, tt in ipairs(TIES) do
  local band = HP.mask()
  local cx, cy = AX + vx * tt, AY + vy * tt
  for y = floor(cy) - 9, floor(cy) + 9 do for x = floor(cx) - 9, floor(cx) + 9 do
    local rx, ry = x - cx, y - cy
    local a, s = rx * ux + ry * uy, rx * px + ry * py
    if abs(a) <= 1.6 and abs(s) <= wfn(tt) + 1.1 then band:set(x, y) end
  end end
  local _, bn = X.cyl(cx - ux * 3, cy - uy * 3, cx + ux * 3, cy + uy * 3, function() return wfn(tt) + 1.1 end, band)
  local bv = X.light(bn, { amb = 0.1, wrap = 0.3 })
  local bidx = X.tone(c, band, bv, TW, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, tok = twtok })
  band:each(function(x, y) local k = K(x, y)
    local rx, ry = x - cx, y - cy
    local a, s = rx * ux + ry * uy, rx * px + ry * py
    if floor(a + s * 0.9 + 20) % 3 == 0 then c:put(x, y, TW[max(1, (bidx[k] or 3) - 2)], twtok) end   -- twist groove
  end)
  -- tied tail on the lower binding
  if i == 1 then
    local tx, ty = cx + px * (wfn(tt) + 1.6), cy + py * (wfn(tt) + 1.6)
    for j = 0, 3 do c:put(floor(tx + px * j + .5 + (j % 2)), floor(ty + py * j + .5), TW[(j % 2 == 0) and 4 or 2], twtok) end
  end
end
-- one glint on the upper twine
c:put(floor(AX + vx * 0.7 - px * 4 + .5), floor(AY + vy * 0.7 - py * 4 + .5), A.CREAM, twtok)

-- quirk: a stray fibre springing out of the bundle top in a loose curl
local sx, sy = AX + vx * 0.5 - px * 5.2, AY + vy * 0.5 - py * 5.2
local curl = { { 0, 0 }, { -1, -1 }, { -1, -2 }, { -2, -3 }, { -3, -3 }, { -4, -2 }, { -4, -1 }, { -3, 0 } }
for i, q in ipairs(curl) do local x, y = floor(sx + q[1] + .5), floor(sy + q[2] + .5)
  if not m:has(x, y) then c:put(x, y, COIR[i < 4 and 4 or 5], ftok) end end

A.save(c, NAME)
