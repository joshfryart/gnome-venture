-- newt-tail (final, Opus single pass). A slim, laterally flattened newt tail sweeping from a cut base at lower left
-- up to a fine tip at upper right: dark olive-brown back with round black-brown spots, a wavy translucent teal crest
-- fin along the top edge (fin rays), a fiery orange belly stripe along the underside, pink cut end with a pale
-- vertebra dot. Material: per-pixel tube light (6-tone skin, 5-tone crest, 5-tone belly), wet speculars along the
-- lit ridge, cool reflected light under the belly, AO where crest meets body.
-- quirk: the very tip has curled into a tight little hook, like it is still twitching.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "newt-tail"
local c = A.new(NAME)
local SKIN  = { "#1e1a22", "#33302e", "#4c4a36", "#6a6a40", "#8f8c4e", "#b8b06a" }
local CREST = { "#1e4458", "#2c6c80", "#3f98a4", "#68c4c4", "#a8e8dc" }
local BELLY = { "#7a2a24", "#b8421e", "#e8661e", "#fb9234", "#ffc46a" }
local SPOT, FLESH, FLESHD, BONE = "#1c1418", "#e8838e", "#b5506a", "#fbe6d0"
local COOL, SPEC = "#6f86b8", "#fff4d6"

local P = { { 13, 50 }, { 27, 54 }, { 42, 42 }, { 49, 16 } }
local wf = function(t) return 4.3 * (1 - t) ^ 0.8 + 0.45 end
-- crest fin: wider tube, keep only the dorsal (upper-left, S<0) side beyond the body
local fm, fn, FT, FS = A.tube(P, function(t)
  if t < 0.06 or t > 0.93 then return 0 end
  return wf(t) + 1.6 + 1.1 * sin(pi * (t - 0.06) / 0.87) + 0.7 * sin(t * 46)
end)
local bm, bn, BT, BS = A.tube(P, wf)
fm:cut(bm)
fm:each(function(x, y) if FS[K(x, y)] > 0 then fm.s[K(x, y)] = nil end end)
local ctok = { r = { name = "crest" } }
local cb = {}
X.ao(cb, fm, bm, 1, -1)
local cidx = A.shade(c, fm, X.pillow(fm, 1.5), CREST, { amb = 0.2, wrap = 0.35, cuts = { 0.25, 0.45, 0.65, 0.82 }, bias = cb, tok = ctok })
-- fin rays: thin darker lines across the crest
fm:each(function(x, y) local k = K(x, y)
  if (FT[k] * 70) % 3.2 < 0.8 and not cb[k] then c:put(x, y, CREST[max(1, cidx[k] - 1)], ctok) end end)
-- crest rim: pale translucent edge
fm:edge():each(function(x, y) local k = K(x, y)
  if not bm:has(x + 1, y) and not bm:has(x, y + 1) and cidx[k] >= 3 and X.hash(x, y, 2) > 0.4 then c:put(x, y, CREST[5], ctok) end end)

-- body
local btok = { r = { name = "tail" } }
local bias = {}
local idx, v = A.shade(c, bm, bn, SKIN, { amb = 0.05, wrap = 0.25, bias = bias, tok = btok })
-- belly stripe on the underside (S > 0.5)
bm:each(function(x, y) local k = K(x, y)
  if BS[k] > 0.5 + 0.08 * sin(BT[k] * 30) and BT[k] < 0.9 then
    local i = max(1, min(5, idx[k] + 1))
    c:put(x, y, BELLY[i], btok)
  end
end)
-- spots: round dark blotches on the back
local spots = { 0.12, 0.22, 0.31, 0.42, 0.52, 0.63, 0.74 }
for i, t in ipairs(spots) do
  local x, y = A.bez(P, t)
  local w = wf(t)
  local off = (i % 2 == 0) and -0.35 or 0.05
  -- perpendicular (lit side negative)
  local x2, y2 = A.bez(P, t + 0.01)
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
  local sx, sy = x + px * off * w, y + py * off * w
  local r = max(0.6, w * 0.32)
  bm:each(function(xx, yy) local k = K(xx, yy)
    if (xx - sx)^2 + (yy - sy)^2 <= r * r + 0.3 and BS[k] < 0.45 then
      c:put(xx, yy, (idx[k] >= 5) and SKIN[2] or SPOT, btok) end end)
end
-- wet speculars along the lit ridge
local sp = X.spec(bn, 30)
bm:each(function(x, y) local k = K(x, y)
  if sp[k] > 0.55 and BT[k] > 0.08 and BT[k] < 0.7 and X.hash(x, y, 4) > 0.55 then c:put(x, y, SKIN[6], btok) end end)
c:put(17, 46, SPEC, btok) c:put(18, 46, SPEC, btok) c:put(41, 30, SPEC, btok)
-- cool reflected light under the belly
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.7 and BT[k] > 0.1 and BT[k] < 0.8 then c:put(x, y, COOL, btok) end end)

-- cut end at the base: pink flesh oval facing lower-left, pale vertebra
local etok = { r = { name = "cut" } }
local em = A.oval(12, 50, 2.0, 4.0, -0.35, 0.8)
em:each(function(x, y) c:put(x, y, (x + y < 61) and FLESH or FLESHD, etok) end)
c:put(12, 50, BONE, etok) c:put(12, 49, BONE, etok)
c:put(13, 47, FLESHD, etok)

-- quirk: tip curls into a hook
local hm, hn = A.tube({ { 49, 16 }, { 51, 10 }, { 47, 7 }, { 45, 11 } }, function(t) return 0.75 - 0.3 * t end)
hm:cut(bm)
A.shade(c, hm, hn, SKIN, { amb = 0.15, wrap = 0.3, tok = btok })
A.save(c, NAME)
