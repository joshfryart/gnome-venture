-- antler-shard (final pass, Opus single pass). A snapped length of deer antler lying on the diagonal: a slim curved
-- beam from a jagged break (lower left) to a polished point (upper right), one tine forking up-left.
-- Material: per-pixel tube light (6-tone brown), longitudinal gutters (dark groove + lit lip) running the length,
-- pearling bumps near the base, tips fading to polished ivory with a specular streak, cool reflected light on the
-- lower-right edge, AO in the crotch of the fork. Break: oval cross-section with a pale compact rim and a porous
-- spongy core, a hairline crack running up the beam.
-- quirk: a loop of red twine is knotted round the beam, one frayed end dangling (somebody's lucky charm).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin
local c = A.new("antler-shard")
local ANT   = { "#3a2228", "#57352e", "#7a4e38", "#9c6c48", "#bf8f5e", "#dfba86" }
local IVORY = { "#6b5040", "#93765c", "#b89c7c", "#d6c09c", "#ecdcb8", "#faf0d4" }
local CORE  = { "#5e3a30", "#9a7656", "#d2b488", "#f2e2bc" }
local TW    = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local BOUNCE, SPEC = "#8a6a8a", "#fff4d6"
local tok = { r = { name = "antler" } }

-- tine first (beam paints over its root)
local pt = { { 27, 37 }, { 23, 28 }, { 22, 19 }, { 27, 10 } }
local tm, tn, TT, TS = A.tube(pt, function(t) return 2.9 * (1 - t) ^ 0.75 + 0.45 end)
local pb = { { 13, 51 }, { 18, 37 }, { 34, 33 }, { 52, 15 } }
local bm, bn, BT, BS, bsamp = A.tube(pb, function(t) return 4.1 * (1 - t) ^ 0.6 + 0.55 end)
tm:cut(bm)

local function paint(m, n, T, S, len, ivoryFrom, bias)
  local v = X.light(n, { amb = 0.06, wrap = 0.2 })
  local idx = {}
  m:each(function(x, y) local k = K(x, y)
    local val = v[k] or 0
    local i = 1
    for j, cut in ipairs({ 0.26, 0.44, 0.6, 0.75, 0.89 }) do if val >= cut then i = j + 1 end end
    i = max(1, min(6, i + (bias[k] or 0)))
    -- gutters: grooves along the length, slightly wavy
    local g = (S[k] * 3.2 + sin(T[k] * len * 0.35) * 0.18 + 10) % 1
    if T[k] < ivoryFrom + 0.05 and abs(S[k]) < 0.85 then
      if g < 0.17 then i = max(1, i - 2) elseif g < 0.34 and i >= 2 then i = min(6, i + 1) end
    end
    idx[k] = i
    local ramp = T[k] > ivoryFrom + (X.hash(x, y, 5) - 0.5) * 0.08 and IVORY or ANT
    c:put(x, y, ramp[i], tok)
  end)
  return idx, v
end
local tb = {}
X.ao(tb, tm, bm, 2, -1)
local tidx = paint(tm, tn, TT, TS, 26, 0.55, tb)
local bb = {}
local bidx = paint(bm, bn, BT, BS, 50, 0.7, bb)
-- crotch AO on the beam just under the tine root
bm:each(function(x, y) local k = K(x, y)
  if tm:grow(1):has(x, y) and BS[k] < 0 then c:put(x, y, ANT[max(1, bidx[k] - 2)], tok) end end)

-- pearling bumps near the base: lit pixel, shade pixel lower-right
for _, q in ipairs{ { 0.1, -0.2 }, { 0.16, 0.35 }, { 0.22, -0.5 }, { 0.27, 0.1 }, { 0.33, 0.55 }, { 0.12, 0.6 }, { 0.38, -0.3 } } do
  local s = bsamp[floor(q[1] * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5)
  if bm:has(x, y) and bm:has(x + 1, y + 1) then
    c:put(x, y, ANT[min(6, (bidx[K(x, y)] or 3) + 2)], tok) c:put(x + 1, y + 1, ANT[max(1, (bidx[K(x + 1, y + 1)] or 3) - 1)], tok)
  end
end
-- polished specular streaks on the lit side of both tips + one glint
local function streak(samp, m, ts, sv, ramp)
  for _, t in ipairs(ts) do local s = samp[floor(t * 160) + 1]
    local x, y = floor(s.x + s.px * s.w * sv + .5), floor(s.y + s.py * s.w * sv + .5)
    if m:has(x, y) then c:put(x, y, ramp, tok) end end
end
streak(bsamp, bm, { 0.7, 0.73, 0.76, 0.79 }, -0.45, IVORY[6])
do local s = bsamp[floor(0.74 * 160) + 1] c:put(floor(s.x + s.px * s.w * -0.45 + .5), floor(s.y + s.py * s.w * -0.45 + .5), SPEC, tok) end
-- cool reflected light lower-right on the beam
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.65 and BS[k] > 0.75 and BT[k] > 0.4 and BT[k] < 0.66 then c:put(x, y, BOUNCE, tok) end end)

-- break: oval cross-section facing lower-left
local s0 = bsamp[1]
local cx, cy = s0.x - s0.tx * 0.6, s0.y - s0.ty * 0.6
local cap = A.rell(cx, cy, s0.px, s0.py, 5.0, 2.9)
-- jagged teeth on the break rim
cap:set(floor(cx - 4), floor(cy + 2)) cap:set(floor(cx + 2), floor(cy + 4)) cap:set(floor(cx + 3), floor(cy + 4))
local inner = cap:copy():shrink(1)
cap:each(function(x, y) c:put(x, y, inner:has(x, y) and CORE[3] or CORE[2], tok) end)
inner:each(function(x, y)
  local h = X.hash(x, y, 9)
  if h < 0.34 then c:put(x, y, CORE[1], tok) elseif h > 0.8 then c:put(x, y, CORE[4], tok) end
end)
-- rim: lit upper-left, darker lower-right
cap:edge():each(function(x, y) if (x - cx) + (y - cy) > 0.5 then c:put(x, y, ANT[3], tok) end end)
-- hairline crack running up from the break
local crack = { { 17, 46 }, { 18, 45 }, { 19, 44 }, { 19, 43 }, { 20, 42 } }
for _, p in ipairs(crack) do if bm:has(p[1], p[2]) then c:put(p[1], p[2], ANT[1], tok) c:put(p[1] - 1, p[2], ANT[5], tok) end end

-- quirk: red twine wrapped round the beam (three twisted turns) with a frayed dangling end
local ttok = { r = { name = "twine" } }
local wraps = { 0.27, 0.32, 0.37 }
for wi, tw in ipairs(wraps) do
  local s = bsamp[floor(tw * 160) + 1]
  for j = -6, 6 do local f = j / 6
    local x = floor(s.x + s.px * s.w * f * 1.1 + s.tx * f * 0.8 + .5)
    local y = floor(s.y + s.py * s.w * f * 1.1 + s.ty * f * 0.8 + .5)
    if bm:has(x, y) or bm:grow(1):has(x, y) then
      local tone = f < -0.3 and 4 or (f < 0.4 and 3 or 2)
      if (j + wi) % 3 == 0 then tone = max(1, tone - 1) end   -- twist ticks
      c:put(x, y, TW[tone], ttok)
    end
  end
end
-- dangling end from the lower-right of the wraps
local s = bsamp[floor(0.32 * 160) + 1]
local ex, ey = floor(s.x + s.px * (s.w + 1.4) + .5), floor(s.y + s.py * (s.w + 1.4) + .5)
local tail = { { 0, 0 }, { 1, 1 }, { 1, 2 }, { 2, 3 }, { 2, 4 }, { 2, 5 }, { 3, 6 } }
for i, p in ipairs(tail) do c:put(ex + p[1], ey + p[2], i % 2 == 0 and TW[2] or TW[3], ttok) end
c:put(ex + 2, ey + 7, TW[4], ttok) c:put(ex + 4, ey + 7, TW[3], ttok)

A.save(c, "antler-shard")
