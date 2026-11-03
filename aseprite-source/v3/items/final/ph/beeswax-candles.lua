-- beeswax-candles (final pass, Opus). A pair of slim hand-dipped beeswax tapers standing side by side, bound
-- with a twisted twine band and a little bow in the gap. Each taper is lit per pixel as a cylinder (6-tone
-- honey-gold): faint dip rings, a vertical specular streak on the lit flank, cool reflected light on the shade
-- edge, AO rows above and below the twine, contact shadow under the bow. Tall taper is lit: melt pool glowing on
-- its rim, a tapered flame (ember, gold, cream core) on a dark wick. Short taper is unlit: dipped cone tip and a
-- burnt, curled wick. 2-tone ground shadow.
-- quirk: one drip has run down the lit taper and frozen right over the twine knot.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local NAME = "beeswax-candles"
local c = A.new(NAME)
local W = A.WAX
local T = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }      -- red cotton twine
local BOUNCE, SPEC = "#b98a86", "#fffbe6"
local YB = 51

c:groundShadow(31, YB + 1, 13, 2)

local function taper(cx, ytop, w0, w1, cone)
  local m, n, Tt, S = X.cyl(cx, ytop, cx, YB, function(t)
    local w = w0 + (w1 - w0) * t
    if cone then
      local d = (t * (YB - ytop))            -- px from the top
      if d < 4 then w = w * (0.35 + 0.65 * sqrt(d / 4)) end
    end
    return w
  end)
  return m, n, Tt, S
end
-- tall lit taper (flat melted top), short unlit taper (dipped cone tip)
local L = { cx = 25.5, top = 19, w0 = 2.0, w1 = 2.9 }
local R = { cx = 36.5, top = 28, w0 = 1.9, w1 = 2.7 }
L.m, L.n, L.T, L.S = taper(L.cx, L.top, L.w0, L.w1, false)
R.m, R.n, R.T, R.S = taper(R.cx, R.top, R.w0, R.w1, true)

local TW = 41                                  -- twine band rows TW, TW+1
for _, P in ipairs{ L, R } do
  local bias = {}
  P.m:each(function(x, y)
    local k = K(x, y)
    if y == TW - 1 or y == TW + 2 then bias[k] = -1 end    -- AO next to the band
    if y == TW + 3 and x > P.cx then bias[k] = -1 end      -- contact shadow under the band (shade side)
    if y >= YB - 1 then bias[k] = (bias[k] or 0) - 1 end   -- foot on the ground
  end)
  P.idx = A.tone(c, P.m, P.n, W, { bias = bias, amb = 0.08, wrap = 0.22, cuts = { 0.1, 0.26, 0.44, 0.62, 0.82 }, hi = 5 })
  -- dip rings: every 5 px a lit row on the lit half (wax layers), offset per taper
  P.m:each(function(x, y)
    local s = P.S[K(x, y)]
    if (y + (P == L and 0 or 2)) % 5 == 0 and s < 0.2 and abs(y - TW) > 2 and y < YB - 2 and y > P.top + 3 then A.step(c, P.idx, W, x, y, 1, 1, 5) end
  end)
  -- specular streak + cool bounce on the shade edge
  P.m:each(function(x, y)
    local s = P.S[K(x, y)]
    if s > -0.62 and s < -0.3 and y > P.top + 2 and y < YB - 3 and abs(y - TW) > 1 and (y % 7) ~= 1 then A.set(c, P.idx, W, x, y, 6) end
    if s > 0.8 and y > P.top + 3 and y < YB - 2 and abs(y - TW) > 1 then c:put(x, y, BOUNCE) end
  end)
end

-- lit taper top: shallow melt pool (glowing), dark rim at the back, bright lip in front
local ytop = L.top
for x = floor(L.cx - L.w0), floor(L.cx + L.w0 + 0.99) do
  if L.m:has(x, ytop) then c:put(x, ytop, W[3]) end
  if L.m:has(x, ytop + 1) then c:put(x, ytop + 1, W[6]) end
end
c:put(floor(L.cx), ytop + 1, A.CREAM)
-- wick + flame
c:put(floor(L.cx), ytop - 1, "#3a2426") c:put(floor(L.cx), ytop - 2, "#5a2e2a")
local FL = {
  "...e...",
  "..eo...",
  "..ooe..",
  ".eoyo..",
  ".oyYye.",
  ".oyWYo.",
  ".oYWYo.",
  "..yWy..",
  "...k...",
}
local fmap = { e = "#e8493b", o = "#f58a2a", y = "#ffc84a", Y = "#ffe98a", W = A.CREAM, k = "#5a2e2a" }
c:paint(FL, floor(L.cx) - 3, ytop - 10, fmap)

-- unlit taper: burnt wick curling over at the tip
for _, p in ipairs{ { 0, -1, "#3a2426" }, { 0, -2, "#3a2426" }, { 1, -3, "#3a2426" }, { 2, -3, "#5a3a34" } } do
  c:put(floor(R.cx) + p[1], R.top + p[2], p[3])
end
c:put(floor(R.cx) - 1, R.top + 2, W[6])

-- red twine band: twisted 2-row cord across both tapers and the gap (diagonal twist strands)
local band = HP.mask()
for x = floor(L.cx - L.w1 - 0.5), floor(R.cx + R.w1 + 0.99) do
  for y = TW, TW + 1 do
    local onL = L.m:has(x, y) or L.m:has(x - 1, y) and x <= L.cx + 3
    local onR = R.m:has(x, y) or R.m:has(x + 1, y) and x >= R.cx - 3
    if L.m:has(x, y) or R.m:has(x, y) or (x > L.cx and x < R.cx) then band:set(x, y) end
  end
end
band:each(function(x, y)
  local u = (x + (y - TW)) % 3
  local col = T[3]
  if u == 0 then col = T[1] elseif u == 1 then col = (y == TW) and T[4] or T[3] else col = T[2] end
  -- band wraps round the tapers: darker on each taper's shade edge
  if (L.m:has(x, y) and L.S[K(x, y)] > 0.6) or (R.m:has(x, y) and R.S[K(x, y)] > 0.6) then col = T[1] end
  c:put(x, y, col)
end)
-- bow knot in the gap: two loops above, two tails below
local BOW = {
  ".aa...ab.",
  "a..b.a..c",
  ".abbdbbc.",
  ".........",
  ".........",
  "...bdc...",
  "..ab.bc..",
  "..b...c..",
  ".ab....c.",
}
local bmap = { a = T[4], b = T[3], c = T[2], d = T[1] }
local bx0 = floor((L.cx + R.cx) / 2 + 0.5) - 4
c:paint(BOW, bx0, TW - 3, bmap)
-- quirk: drip run down the lit taper (from the melt pool) and frozen over the knot: lit bead with a shade side
local path = {}
for y = ytop + 2, TW - 2 do path[#path + 1] = { (y < TW - 7) and 26 or 27, y } end
for _, p in ipairs(path) do
  local x, y = p[1], p[2]
  c:put(x, y, (y % 5 == 0) and W[5] or W[6])
  if L.m:has(x + 1, y) then c:put(x + 1, y, W[3]) end
  if y == TW - 7 then c:put(27, y, W[6]) end
end
for _, p in ipairs{ { 27, TW - 1, 6 }, { 28, TW - 1, 5 }, { 27, TW, 5 }, { 28, TW, 3 }, { 26, TW, 4 }, { 27, TW + 1, 3 } } do
  c:put(p[1], p[2], W[p[3]])
end
c:put(27, TW - 1, SPEC)

A.save(c, NAME)
