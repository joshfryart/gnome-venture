-- lentil (final, Opus single pass). One short, flat lentil pod split open on the diagonal: papery straw valves
-- with net veins, a shaded inner lining cradling two lens-shaped olive-brown lentils (raised rim, flat face, glint).
-- A wiry stalk with paired oval leaflets and a curling tendril (twist) rises from the pod; three loose lentils lie below.
-- quirk: one loose lentil has split into its two halves, showing the bright orange inside of a red lentil.
local NAME = "lentil"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, atan = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.atan
local c = A.new(NAME)

local POD  = { "#5a4224", "#86653a", "#b08e52", "#d2b46c", "#ead290", "#f8eabc" }
local LINE = { "#4a3428", "#6e5240", "#987a5c", "#c4a884" }
local LEN  = { "#3a3218", "#5c5426", "#827a36", "#a8a04a", "#c8c06a", "#ece296" }
local RED  = { "#7a2a1c", "#b04020", "#de6224", "#f4892c", "#fcb24e", "#ffdc8a" }
local STEM = { "#2a4a30", "#3e6a3a", "#5a8c44", "#82ae58", "#aed07a", "#d4ea9e" }

-- stalk + leaflets (behind the pod)
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { {45, 25}, {48, 20}, {49, 15}, {52, 10} }, function(t) return 0.9 end, STEM, { tok = stok })
local ltok = { r = { name = "leaflets" } }
local lfm = HP.mask()
for _, q in ipairs{ { 0.35, -1 }, { 0.45, 1 }, { 0.72, -1 }, { 0.8, 1 } } do
  local x, y = A.bez({ {45, 25}, {48, 20}, {49, 15}, {52, 10} }, q[1])
  local ux, uy = A.rot(0.2, -1, q[2] * 1.05)
  local L = 3.8 - q[1] * 1.2
  lfm:add(A.rell(x + ux * (L + 0.5), y + uy * (L + 0.5), ux, uy, L, 1.5))
end
lfm:cut(sm)
local lfidx = A.shade(c, lfm, X.pillow(lfm, 1.6), STEM, { tok = ltok, amb = 0.12, wrap = 0.3 })
-- tendril curl at the tip
local tt = { {52, 10}, {54, 8}, {56, 9}, {56, 11}, {54, 12}, {53, 11} }
HP.line(tt, 1):each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and STEM[4] or STEM[2], stok) end)

-- pod: back valve (outer shell seen past the opening) and the opening
local AXp, AYp, CXp, CYp, BXp, BYp = 13, 41, 28, 34, 47, 23
local pm, pn, PT, PS, plen = A.blade(AXp, AYp, CXp, CYp, BXp, BYp, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 7.2 * sin(pi * min(1, t * 0.96 + 0.03)) ^ 0.55)
end, { fold = 0.2 })
local ptok = { r = { name = "pod" } }
local pidx = A.toneN(c, pm, pn, POD, { tok = ptok, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 }, amb = 0.2, wrap = 0.35 })
-- opening: lining visible between the valves (upper-left half of the pod, toward the middle)
local open = HP.mask()
pm:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  local hw = 0.72 * sin(pi * min(1, max(0, (t - 0.1) / 0.8))) ^ 0.6
  if t > 0.1 and t < 0.9 and s < 0.2 and s > 0.2 - hw * 1.25 then open:set(x, y) end
end)
local otok = { r = { name = "lining" } }
open:each(function(x, y) local k = K(x, y) local s = PS[k]
  local i = (s > 0.0) and 1 or ((s > -0.3) and 2 or 3)
  c:put(x, y, LINE[i], otok) end)
-- valve lips: pale lit edge on the lower lip, deep row under the upper lip
open:each(function(x, y)
  if not open:has(x, y + 1) and pm:has(x, y + 1) then c:put(x, y + 1, POD[6], ptok) end
  if not open:has(x, y - 1) and pm:has(x, y - 1) then c:put(x, y - 1, POD[5], ptok) end end)
-- net veins on the outer valve
pm:each(function(x, y) local k = K(x, y)
  if open:has(x, y) then return end
  local t, s = PT[k], PS[k]
  if s > 0.35 and s < 0.85 then
    local d = (t * plen + s * 5) % 4.5
    if d < 0.8 then c:put(x, y, POD[max(1, (pidx[k] or 3) - 1)], ptok) end
  end end)
-- stalk scar at the pod tip and a dry beak at the base
c:put(47, 24, POD[2], ptok)
HP.line({ {13, 41}, {10, 43}, {9, 45} }, 1):each(function(x, y) c:put(x, y, POD[3], ptok) end)

-- two lentils in the pod
for i, p in ipairs{ { 23, 35.5 }, { 32, 31 } } do
  local m = A.lens(c, p[1], p[2], 3.6, 2.6, -0.5, LEN, { tok = { r = { name = "pl" .. i } } })
  -- contact shadow on the lining
  m:shift(1, 1):each(function(x, y) if open:has(x, y) and not m:has(x, y) then c:put(x, y, LINE[1], otok) end end)
end

-- loose lentils below + quirk: split red lentil
local gt = { r = { name = "g1" } }
local l1 = A.lens(c, 19, 52, 3.6, 2.6, 0.15, LEN, { tok = gt })
local l2 = A.lens(c, 28, 53, 3.6, 2.6, -0.1, LEN, { tok = { r = { name = "g2" } }, cut = l1 })
-- split halves: two half-discs, flat orange faces up, a small gap between
local hA = A.oval(38, 50, 3.2, 2.4, -0.3, 0.6)
local hB = A.oval(45, 48, 3.2, 2.4, -0.3, 0.6)
for j, h in ipairs{ hA, hB } do
  local tok = { r = { name = "half" .. j } }
  local cx = (j == 1) and 38 or 45
  local cy = (j == 1) and 50 or 48
  h:each(function(x, y) local dx, dy = x - cx, y - cy
    local r = (dx / 3.6) ^ 2 + (dy / 2.8) ^ 2
    local i = (r > 0.62) and 2 or ((dx + dy < -1) and 5 or 4)
    if r > 0.62 and dx + dy < 0 then i = 3 end
    if r > 0.62 and dx + dy > 2 then i = 1 end
    c:put(x, y, RED[i], tok) end)
  -- seed-coat rim: olive skin peeking at the lower-right edge
  h:edge():each(function(x, y) if (x - cx) + (y - cy) > 1.5 then c:put(x, y, LEN[2], tok) end end)
  c:put(cx - 1, cy - 1, RED[6], tok) c:put(cx, cy - 1, RED[6], tok)
end
-- tiny germ notch on one half
c:put(38, 51, RED[3], { r = { name = "half1" } })
A.save(c, NAME)
