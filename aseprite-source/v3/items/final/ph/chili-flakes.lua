-- chili-flakes (final, Opus single pass). A slim twist of kraft paper rolled into a cone, lying tilted with its mouth up to
-- the right, heaped with crushed chili flakes that spill over the lip into a little pile on the ground. Material: paper
-- per-pixel cone light on a 6-tone kraft ramp, a spiral overlap seam and two lengthwise creases (dark groove + lit
-- lip), crinkled torn lip with a darker inside; flakes as a pillow-lit mound broken into 5-tone shards with gold seeds.
-- AO under the heap where it meets the paper, 2-tone ground shadow.
-- quirk: one stray flake has landed on the folded tip of the cone.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("chili-flakes")
local KR = { "#4a2c2e", "#7a4a36", "#a4703e", "#c8944e", "#e2b86c", "#f6dc9a" }
local FL = { "#4e0e20", "#86182a", "#c02c2a", "#e8502e", "#ff8a48" }
local SEED = { "#c8902e", "#f6d070" }
local ptok, ftok = { r = { name = "paper" } }, { r = { name = "flakes" } }
c:groundShadow(36, 53, 18, 2)

-- cone
local T0, M = { 12, 48 }, { 41, 27 }
local ax, ay = M[1] - T0[1], M[2] - T0[2]
local L = sqrt(ax*ax + ay*ay) local ux, uy = ax / L, ay / L
local px, py = -uy, ux  -- points lower-right
local cone, cn, CT, CS = A.tube({ T0, { T0[1] + ax/3, T0[2] + ay/3 }, { T0[1] + 2*ax/3, T0[2] + 2*ay/3 }, M },
  function(t) return 0.7 + 8.6 * t ^ 0.9 end)
local cut = HP.mask()
cone:each(function(x, y) if CT[K(x, y)] >= 0.995 then cut:set(x, y) end end)
cone:cut(cut)
-- mouth ellipse (opening), lip ring
local mouth = A.rell(M[1], M[2], ux, uy, 3.2, 9.6)
local inner = A.rell(M[1] + ux * 0.4, M[2] + uy * 0.4, ux, uy, 2.2, 8.2)
local paper = cone:copy():add(mouth:copy():cut(inner))
local pn = {}
paper:each(function(x, y) local k = K(x, y)
  if cn[k] then pn[k] = cn[k] else
    local s = (x - M[1]) * px + (y - M[2]) * py
    local sn = max(-0.95, min(0.95, s / 9.6))
    pn[k] = { px * sn - ux * 0.3, py * sn - uy * 0.3, sqrt(1 - sn*sn) } end end)
local pidx = A.shade(c, paper, pn, KR, { amb = 0.08, wrap = 0.25, tok = ptok })
-- lip: far (upper) rim is the paper's inside -> darker; crinkle notches
paper:each(function(x, y) local k = K(x, y)
  if not cn[k] then
    local s = (x - M[1]) * px + (y - M[2]) * py
    local a = (x - M[1]) * ux + (y - M[2]) * uy
    if a > 0.3 then c:put(x, y, KR[(s < 0) and 3 or 2], ptok) else c:put(x, y, KR[(s < 0) and 6 or 4], ptok) end
  end end)
-- creases + spiral seam
cone:each(function(x, y) local k = K(x, y) local t, s = CT[k], CS[k]
  if not t or t < 0.08 then return end
  local i = pidx[k] or 3
  if abs(s - 0.35) < 0.09 and t < 0.92 then c:put(x, y, KR[max(1, i - 2)], ptok)
  elseif abs(s - 0.47) < 0.07 and t < 0.92 then c:put(x, y, KR[min(6, i + 1)], ptok) end
  if abs(s + 0.45) < 0.08 and t > 0.2 and t < 0.9 then c:put(x, y, KR[min(6, i + 1)], ptok) end
  -- spiral seam: s rises with t
  local sp = -0.9 + (t - 0.25) * 2.4
  if t > 0.25 and t < 0.95 and abs(s - sp) < 0.07 then c:put(x, y, KR[max(1, i - 2)], ptok)
  elseif t > 0.25 and t < 0.95 and abs(s - sp + 0.13) < 0.06 then c:put(x, y, KR[min(6, i + 1)], ptok) end
end)
-- folded tip: a slightly paler twist
c:put(T0[1] - 1, T0[2] + 1, KR[5], ptok) c:put(T0[1], T0[2] + 1, KR[4], ptok) c:put(T0[1] - 1, T0[2], KR[3], ptok)

-- flake mound inside mouth + spill + ground pile
local heap = inner:copy():add(HP.ellipse(M[1] + 1.5, M[2] - 1, 3.5, 6))
heap:add(A.tube({ { 44, 33 }, { 47, 37 }, { 48, 41 }, { 48, 46 } }, function(t) return 1.3 + t * 0.6 end))
local pile = HP.ellipse(49, 49, 7, 3):cut(HP.rect(0, 51, 63, 63))
heap:add(pile)
heap:cut(cone)
local hn = X.pillow(heap, 3)
local hv = X.light(hn, { amb = 0.08, wrap = 0.25 })
local hb = {}
X.ao(hb, heap, paper, 1, -1)
heap:each(function(x, y) local k = K(x, y)
  local r = X.hash(x, y, 7)
  local i = 1
  for j, t in ipairs{ 0.22, 0.42, 0.62, 0.8 } do if hv[k] >= t then i = j + 1 end end
  i = i + (hb[k] or 0) + (r < 0.25 and -1 or (r > 0.85 and 1 or 0))
  i = max(1, min(5, i))
  c:put(x, y, FL[i], ftok)
  if r > 0.93 then c:put(x, y, SEED[hv[k] > 0.5 and 2 or 1], ftok) end
end)
-- a few lone loose flakes beside the pile (touching ground, 2px each)
for _, q in ipairs{ { 40, 51 }, { 57, 49 } } do c:put(q[1], q[2], FL[3], ftok) c:put(q[1] + 1, q[2], FL[4], ftok) end
-- glint on the mound
c:put(M[1] - 1, M[2] - 4, "#ffd0a0", ftok)
-- quirk: stray flake on the folded tip
c:put(14, 45, FL[4], ftok) c:put(15, 45, FL[2], ftok)

A.save(c, "chili-flakes")
