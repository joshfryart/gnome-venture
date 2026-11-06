-- fava-bean (final, Opus single pass). A slim curved fava pod on the diagonal, split open along its upper seam:
-- glossy green shell (6 tones, per-pixel light, waxy bloom specks, a darker suture seam on the shade side, cool
-- reflected light lower-right), pale wall rim at the cut, white cottony lining shaded under the near rim, and three
-- plump pale-green beans each with the black hilum "eye" at the stem end, AO + contact shadows in the lining.
-- Olive stem with a small star calyx at the top. Draft by Sonnet replaced.
-- quirk: the fourth bean is already gone; only its bean-shaped dent is left in the cotton by the tip.
local NAME = "fava-bean"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local POD   = { "#173a33", "#22573e", "#327a45", "#4b9c4c", "#74bd59", "#a8db78" }
local LIN   = { "#6f7f62", "#98a985", "#c2cfa8", "#e1e9c6", "#f4f6e0" }
local BEAN  = { "#2b5236", "#3f7641", "#5f9a4c", "#86bc5e", "#b3d983", "#def1b2" }
local STEM  = { "#3c4a2a", "#5d6b35", "#84904a", "#adb56a" }
local BLOOM, COOL, SPEC, HIL = "#c9e9a0", "#3f7f86", "#f4ffe0", "#2b1c26"

-- pod body: tube along a gentle S, lumpy over the beans, pointed at the tip (lower-left)
local P = { { 12, 52 }, { 18, 38 }, { 32, 20 }, { 50, 13 } }
local BT = { 0.3, 0.47, 0.64, 0.8 }
local pm, pn, PT, PS = A.tube(P, function(t)
  local w = 5.4 * sin(pi * min(1, t * 0.93 + 0.05)) ^ 0.42
  for _, b in ipairs(BT) do w = w + 0.55 * max(0, 1 - abs(t - b) / 0.07) end
  if t < 0.12 then w = w * (0.35 + t / 0.12 * 0.65) end
  return w
end)
-- opening lens (slightly toward the lit side)
local function lens(t) if t < 0.18 or t > 0.88 then return -9 end return 0.66 * sin(pi * (t - 0.18) / 0.7) ^ 0.55 end
local open = HP.mask()
pm:each(function(x, y) local k = K(x, y) local s, t = PS[k], PT[k]
  local L = lens(t) if L > 0 and abs(s + 0.12) < L then open:set(x, y) end end)
local shell = pm:copy():cut(open)

-- shell tones
local pbias = {}
local ptok = { r = { name = "pod" } }
local pidx, pv = A.shade(c, shell, pn, POD, { amb = 0.08, wrap = 0.25, bias = pbias, tok = ptok })
-- suture seam (shade side) and cool reflected light
shell:each(function(x, y) local k = K(x, y) local s, t = PS[k], PT[k]
  if s > 0.62 and s < 0.8 and t > 0.1 and t < 0.94 then c:put(x, y, POD[max(1, pidx[k] - 1)], ptok) end
end)
local rim = X.rim(pn)
shell:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and PT[k] > 0.15 and PT[k] < 0.9 and PS[k] > 0.5 then c:put(x, y, COOL, ptok) end end)
-- waxy bloom specks on the lit shell
shell:shrink(1):each(function(x, y) local k = K(x, y)
  if pidx[k] >= 4 and X.hash(x, y, 7) > 0.86 then c:put(x, y, BLOOM, ptok) end end)
-- cut wall: pale rim on the far (lower-right) lip, dark on the near (upper-left) lip
local ltok = { r = { name = "lining" } }
open:each(function(x, y) local k = K(x, y) local s, t = PS[k], PT[k]
  local L = lens(t) local u = (s + 0.12) / L   -- -1 near lip .. +1 far lip
  local i
  if u < -0.62 then i = 1 elseif u < -0.3 then i = 2 elseif u < 0.25 then i = 3 elseif u < 0.7 then i = 4 else i = 5 end
  if X.hash(x, y, 3) > 0.8 then i = min(5, i + 1) end       -- cotton fuzz
  c:put(x, y, LIN[i], ltok)
end)
shell:each(function(x, y) local k = K(x, y)
  for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    if open:has(x + d[1], y + d[2]) then
      c:put(x, y, PS[k] > -0.12 and "#d8efb0" or POD[2], ptok) return end
  end end)

-- beans (three) + empty dent (quirk)
local lb = {}
for i, t in ipairs(BT) do
  local x, y = A.bez(P, t)
  local x2, y2 = A.bez(P, min(1, t + 0.01))
  local x1, y1 = A.bez(P, max(0, t - 0.01))
  local ang = atan(y2 - y1, x2 - x1)
  local px, py = 0.6, 0.6
  lb[i] = { x = x - 0.6, y = y - 0.6, ang = ang }
end
-- dent first
do local b = lb[4]
  local m = A.oval(b.x, b.y, 2.9, 2.0, b.ang, 1):clip(open)
  m:each(function(x, y) local dx, dy = x - b.x, y - b.y
    c:put(x, y, (dx + dy) < 0 and LIN[1] or LIN[3], ltok) end)
end
for i = 1, 3 do local b = lb[i]
  local m, n = A.oval(b.x, b.y, 3.4, 2.7, b.ang, 0.9)
  m:clip(pm)
  -- contact shadow on lining / shell (lower-right of each bean)
  m:shift(1, 1):each(function(x, y) if open:has(x, y) and not m:has(x, y) then c:put(x, y, LIN[1], ltok) end end)
  local btok = { r = { name = "bean" .. i } }
  local bias = {}
  -- near-lip shadow falls across the upper-left of each bean
  m:each(function(x, y) local k = K(x, y) if (PS[k] or 0) < -0.48 then bias[k] = -1 end end)
  local idx = A.shade(c, m, n, BEAN, { amb = 0.1, wrap = 0.3, bias = bias, tok = btok })
  -- hilum eye at the stem-side end (upper-right), slightly toward the viewer
  local ca, sa = cos(b.ang), sin(b.ang)
  for _, q in ipairs{ { 2.2, -0.3 }, { 2.6, 0.5 }, { 1.7, 0.6 } } do
    local hx = floor(b.x + q[1] * ca - q[2] * sa + 0.5)
    local hy = floor(b.y + q[1] * sa + q[2] * ca + 0.5)
    if m:has(hx, hy) then c:put(hx, hy, HIL, btok) end
  end
  -- gloss
  local sx, sy = A.specAt(m, n, 30)
  if sx then c:put(sx, sy, SPEC, btok) end
end

-- stem + calyx at the top end
local sm, sn = A.tube({ { 49, 13 }, { 52, 11 }, { 54, 9 }, { 54, 5 } }, function(t) return 1.5 - t * 0.5 end)
sm:cut(pm)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
for _, q in ipairs{ { 47, 11, 2 }, { 48, 10, 3 }, { 46, 13, 2 }, { 50, 15, 1 }, { 51, 14, 2 }, { 48, 15, 1 } } do
  if pm:has(q[1], q[2]) or sm:has(q[1], q[2]) or true then c:put(q[1], q[2], STEM[q[3]]) end
end
c:put(54, 5, STEM[4])
-- shell specular on the lit upper wall near the stem
do local best, bx, by
  local sp = X.spec(pn, 40)
  shell:shrink(1):each(function(x, y) local k = K(x, y) if PT[k] > 0.55 and PT[k] < 0.8 and (not best or sp[k] > best) then best, bx, by = sp[k], x, y end end)
  if bx then c:put(bx, by, SPEC) c:put(bx + 1, by, POD[6]) end
end
-- tip: a dry little brown point
c:put(12, 52, STEM[2])
A.save(c, NAME)
