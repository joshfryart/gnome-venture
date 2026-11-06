-- ico-grapes (final, Opus). A slim hanging bunch: ten glossy grapes stacked 4-3-2-1 with a slight lean, each its own
-- sphere with 1 px of air (ink) where a front grape covers a back one; a thin woody stalk with a curled tendril and a
-- three-lobed vine leaf behind the top-right shoulder.
-- Material: per-pixel sphere light snapped to a 6-tone violet ramp; waxy bloom (dusty lavender flecks on the mid tones),
-- one bright specular + hi on every grape (glossy fruit), a cool blue reflected light on the lower-right rims, AO where
-- grapes tuck behind their neighbours and under the stalk. Leaf: pillow light on a 6-tone moss ramp, midrib + side veins
-- with a lit lip, a dark tuck where it meets the stalk. Stalk: 3-tone wood with twist marks.
-- quirk: a single dewdrop is sliding down the lowest grape.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, atan, cos, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.atan, math.cos, math.sin
local c = A.new("ico-grapes")
local GR   = { "#2a1946", "#41256f", "#5c3595", "#7b4bbd", "#9d72da", "#c9a8f2" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#a6d672" }
local WOOD = { "#51302b", "#6e4430", "#935f3c", "#b97a4a", "#d9a46a" }
local BLOOM_HI, BLOOM_LO = "#b19dd6", "#8873b4"
local BOUNCE, SPEC = "#5f74c6", "#fff4d6"
local gtok, ltok, wtok = A.tok("grape"), A.tok("leaf"), A.tok("stalk")

-- grape centres, back (top) to front (bottom)
local GRP = {
  { 23, 23.5 }, { 31.5, 23 }, { 40, 23.5 },
  { 19, 30.5 }, { 27.5, 30 }, { 36, 30 }, { 44.5, 31 },
  { 23.5, 37.5 }, { 32, 37 }, { 40.5, 37.5 },
  { 28, 44 }, { 36.5, 44.5 },
  { 32, 51 },
}
local RX, RY = 4.25, 4.55

-- leaf (behind everything): three lobes fanning to the upper-right from a petiole base
local LB = { 36, 20 }
local TIPS = { { 38, 6 }, { 50, 7 }, { 53, 18 } }
local leaf = HP.poly{ { 35.5, 21.5 }, { 34, 16 }, { 35, 11 }, { 37, 7 }, { 38.5, 5.5 }, { 40, 8 }, { 41, 9 }, { 42.5, 12.5 },
  { 44, 9 }, { 47, 8 }, { 50.5, 6.5 }, { 49.5, 10 }, { 50, 11.5 }, { 47.5, 14.5 }, { 50, 15.5 }, { 53.5, 18 }, { 50, 20 },
  { 47, 21.5 }, { 42, 22.5 }, { 38, 22.5 } }
local ln = X.pillow(leaf, 2.2)
local lidx = A.shade(c, leaf, ln, LEAF, { tok = ltok, amb = 0.12, wrap = 0.3 })
-- veins: midrib to each lobe tip (dark groove, lit lip on the upper-left), short side veins
for _, tp in ipairs(TIPS) do
  local dx, dy = tp[1] - LB[1], tp[2] - LB[2]
  local L = sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  for s = 1, L - 2 do
    local x, y = floor(LB[1] + ux * s + .5), floor(LB[2] + uy * s + .5)
    if leaf:has(x, y) then
      A.step(c, lidx, LEAF, x, y, -2, ltok)
      if s > 2 and s % 2 == 0 and leaf:has(x - 1, y - 1) and not leaf:edge():has(x - 1, y - 1) then A.step(c, lidx, LEAF, x - 1, y - 1, 1, ltok) end
      if s > 3 and s < L - 4 and s % 3 == 0 then
        for _, sd in ipairs{ -1, 1 } do
          local vx, vy = ux * 0.6 - uy * sd * 0.8, uy * 0.6 + ux * sd * 0.8
          for q = 1, 2 do
            local xx, yy = floor(x + vx * q + .5), floor(y + vy * q + .5)
            if leaf:has(xx, yy) and not leaf:edge():has(xx, yy) then A.step(c, lidx, LEAF, xx, yy, -1, ltok) end
          end
        end
      end
    end
  end
end
-- tuck: dark base near the petiole
for _, p in ipairs{ { 36, 20 }, { 37, 20 }, { 36, 19 }, { 37, 21 }, { 38, 21 } } do if leaf:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end

-- stalk: woody rachis from the bunch top up, curving left to a cut tip
local sp = { { 31.5, 20 }, { 31, 16 }, { 34, 13 }, { 31.5, 10 } }
local sm, sn, ST, SS, ssamp = A.tube(sp, function(t) return 1.55 - t * 0.35 end)
local sidx = A.shade(c, sm, sn, WOOD, { tok = wtok, amb = 0.15, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- twist marks: diagonal dark ticks every 3 px
sm:each(function(x, y) local k = K(x, y)
  if ST[k] > 0.15 and ST[k] < 0.92 and floor(ST[k] * 16 + SS[k] * 1.2) % 3 == 0 then A.step(c, sidx, WOOD, x, y, -1, wtok) end end)
-- pale cut end grain at the tip
for _, p in ipairs{ { 30, 9 }, { 31, 9 }, { 32, 9 } } do if sm:has(p[1], p[2]) then c:put(p[1], p[2], WOOD[5], wtok) end end
-- tendril: curls to the left off the stalk (1 px, reads as a twist)
A.map(c, {
  ".www....",
  "w...w...",
  "w.w..w..",
  ".ww..w..",
  ".....w..",
  "......ww",
}, 23, 11, { w = WOOD[3] }, wtok)

-- grapes
local masks = {}
for i, g in ipairs(GRP) do masks[i] = A.ell(g[1], g[2], RX, RY) end
local all = HP.mask()
for i, g in ipairs(GRP) do
  local m = masks[i]:copy()
  local front = HP.mask()
  for j = i + 1, #GRP do front:add(masks[j]) end
  local vis = m:copy():cut(front:grow(1))
  local n = X.sphere(g[1] - 0.6, g[2] - 0.8, RX + 0.4, vis)
  local bias = {}
  X.ao(bias, vis, front, 2, -1)
  -- AO under the stalk on the top grapes
  if i <= 4 then X.ao(bias, vis, sm, 1, -1) end
  local idx = A.shade(c, vis, n, GR, { tok = gtok, amb = 0.06, wrap = 0.2, bias = bias, cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 } })
  -- waxy bloom: dusty flecks on mid tones
  vis:each(function(x, y) local k = K(x, y)
    local h = X.hash(x, y, 3)
    if idx[k] == 4 and h < 0.22 then c:put(x, y, BLOOM_HI, gtok)
    elseif idx[k] == 3 and h < 0.16 then c:put(x, y, BLOOM_LO, gtok) end end)
  -- cool reflected light on the lower-right rim
  local rim = X.rim(n)
  vis:edge():each(function(x, y) local k = K(x, y)
    if rim[k] > 0.8 and not front:grow(2):has(x, y) and (idx[k] or 1) <= 2 and X.hash(x, y, 9) < 0.7 then c:put(x, y, BOUNCE, gtok) end end)
  -- specular: cream pixel + hi beside it, upper-left
  local sx, sy = floor(g[1] - 2 + .5), floor(g[2] - 2.4 + .5)
  if vis:has(sx, sy) then c:put(sx, sy, SPEC, gtok) end
  if vis:has(sx + 1, sy) then c:put(sx + 1, sy, GR[6], gtok) end
  if vis:has(sx, sy + 1) then c:put(sx, sy + 1, GR[6], gtok) end
  all:add(vis)
end
-- air ring between overlapping grapes (inside the bunch only)
for i = 1, #GRP do
  local front = HP.mask()
  for j = i + 1, #GRP do front:add(masks[j]) end
  local ring = front:grow(1):cut(front)
  ring:each(function(x, y) if masks[i]:has(x, y) then A.unpaint(c, x, y) end end)
end

-- quirk: a dewdrop sliding down the lowest grape (glass: bright rim, pale core, ink-free)
A.map(c, {
  ".a.",
  "abc",
  "bdc",
  ".c.",
}, 34, 52, { a = "#e4f6ff", b = "#9fd8ec", c = "#5f9ad0", d = SPEC }, A.tok("dew"))
A.save(c, "ico-grapes")
