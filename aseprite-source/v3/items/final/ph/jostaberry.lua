-- jostaberry (final pass, Opus single pass). A slim hanging raceme: a thin woody strig curving down from a short
-- twig, five glossy purple-black berries on short pedicels alternating left/right with air between them, each with
-- a dusty blue waxy bloom, one glint, cool reflected light and a dry brown calyx tuft at the bottom. A single
-- three-lobed currant-type leaf (serrated, midribs and veins) on the twig.
-- quirk: the lowest berry is not ripe yet: still a blushing red-green.
local NAME = "jostaberry"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local BER = { "#120a1c", "#221430", "#341c44", "#4a2858", "#6a3e78", "#a07cb0" }
local UNR = { "#4a1a26", "#7a2a2e", "#b0403a", "#d8644a", "#ee9a6a", "#ffd4a0" }
local LEAF = { "#163e34", "#21583e", "#2f7446", "#45924c", "#6cb256", "#a6d474" }
local WOOD = { "#3a2222", "#5e3a2c", "#865838", "#b07e4e", "#d6a874" }
local BLOOM, BLOOM2 = "#8a8cc0", "#a8a8d4"
local CALYX = { "#3a2418", "#6a4428", "#9a6a3a" }

-- strig (woody, thin) from the twig down through the raceme
local strig = { { 29, 8 }, { 30, 18 }, { 31, 30 }, { 31, 44 } }
local sm, sn = A.tube(strig, function(t) return t < 0.3 and 1.0 or 0.6 end)
-- berries {cx, cy, r, side(-1 left / 1 right), ramp}
local berries = {
  { 23, 23, 5.4, -1 },
  { 39, 27, 5.8, 1 },
  { 23, 37, 5.8, -1 },
  { 39, 41, 5.4, 1 },
  { 30, 48, 3.8, 0, unripe = true },
}
local all = HP.mask()
for _, b in ipairs(berries) do
  b.m, b.n = A.oval(b[1], b[2], b[3], b[3] - 0.2, 0, 1)
  all:add(b.m)
end
-- pedicels: thin green-brown links from strig to the top of each berry
local ped = HP.mask()
local pedpx = {}
for _, b in ipairs(berries) do
  local sx = b[4] == 0 and 31 or 30 + (b[2] > 26 and 1 or 0)
  local sy = b[4] == 0 and 44 or b[2] - floor(b[3]) - 1
  local tx, ty = b[1] - b[4] * 1, b[2] - floor(b[3]) + 1
  local m = HP.line({ { sx, sy }, { tx, ty - 1 } }, 1)
  m:cut(b.m) ped:add(m)
end

-- leaf: three lobes from a base point on the twig, painted back to front
local LB = { 33, 13 }
local lobes = {
  { 32, 12, 43, 8, 53, 9, 4.6 },   -- main lobe, right
  { 32, 12, 39, 15, 49, 18, 3.4 }, -- lower lobe
  { 32, 12, 36, 7, 41, 3, 3.2 },   -- upper lobe (behind)
}
local ltok = { r = { name = "leaf" } }
local leafm = HP.mask()
local order = { 3, 2, 1 }
for _, i in ipairs(order) do
  local L = lobes[i]
  local m, n, T, S, len = A.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t)
    if t > 0.99 then return -1 end
    local w = L[7] * sin(pi * min(1, t * 0.8 + 0.14)) ^ 0.7
    -- serration: small teeth along the edge
    if floor(t * 22) % 2 == 0 and t > 0.25 then w = w - 0.6 end
    return max(0.5, w)
  end, { fold = 0.4 })
  local vis = m:copy()
  local b = {}
  X.ao(b, vis, leafm, 1, -1)
  A.leaf(c, vis, n, T, S, { ramp = LEAF, vein = "#a8d47c", cool = "#2e6068", per = 3.6, sweep = 3, len = len, bias = b, tok = ltok, t0 = 0.06 })
  leafm:add(vis)
end
-- leaf stalk (petiole) from the twig
local pet = HP.line({ { 30, 11 }, { 31, 12 }, { 32, 12 } }, 1)

-- twig + strig paint
local wtok = { r = { name = "wood" } }
local all2 = HP.mask():add(all)
sm:cut(all2)
local sb = {}
X.ao(sb, sm, leafm, 1, -1)
A.shade(c, sm, sn, WOOD, { tok = wtok, bias = sb, cuts = { 0.2, 0.42, 0.62, 0.82 } })
-- twig top: pale cut end + a bud node
c:put(29, 7, WOOD[5], wtok) c:put(30, 7, WOOD[4], wtok) c:put(28, 8, WOOD[3], wtok)
c:put(30, 19, WOOD[1], wtok) c:put(31, 19, WOOD[2], wtok)
pet:each(function(x, y) if not leafm:has(x, y) then c:put(x, y, "#5a7a3a", wtok) end end)
ped:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and "#6a6a36" or "#4a5030", wtok) end)

-- berries
for i, b in ipairs(berries) do
  local R = b.unripe and UNR or BER
  local tok = { r = { name = "berry" .. i } }
  local bias = {}
  -- AO where the pedicel meets (top) and contact shadow from the berry/strig above
  b.m:each(function(x, y) if y <= b[2] - b[3] + 1.5 and abs(x - (b[1] - b[4])) <= 1 then bias[K(x, y)] = -1 end end)
  local idx = A.seed(c, b.m, b.n, R, { tok = tok, bias = bias, rim = b.unripe and "#7a6a8a" or "#33406e",
    cuts = { 0.1, 0.24, 0.42, 0.6, 0.8 }, amb = 0.05, wrap = 0.18 })
  if b.unripe then
    -- green shoulder blush on the lit top
    b.m:each(function(x, y) local k = K(x, y) if y < b[2] - 1 and x < b[1] + 1 and (idx[k] or 1) >= 3 then
      c:put(x, y, (idx[k] >= 5) and "#d8d070" or "#a8a050", tok) end end)
    -- faint stripes (gooseberry heritage)
    for yy = b[2] - 2, b[2] + 3 do if b.m:has(b[1] + 2, yy) then c:put(b[1] + 2, yy, R[max(1, (idx[K(b[1] + 2, yy)] or 3) - 1)], tok) end end
  else
    -- waxy bloom: scattered dusty pixels on the lit half
    b.m:each(function(x, y) local k = K(x, y)
      local h = X.hash(x, y, i)
      if (idx[k] or 1) >= 3 and (idx[k] or 1) <= 5 and h < 0.1 then c:put(x, y, h < 0.035 and BLOOM2 or BLOOM, tok) end end)
  end
  -- glint (2 px) + one cream point
  local gx, gy = floor(b[1] - b[3] * 0.45 + 0.5), floor(b[2] - b[3] * 0.45 + 0.5)
  c:put(gx, gy, "#fff4d6", tok) c:put(gx + 1, gy, R[6], tok) c:put(gx, gy + 1, R[6], tok)
  -- dry calyx tuft at the bottom (sticks out of the silhouette)
  local bx, by = b[1] + (b[4] == 0 and 0 or b[4]), floor(b[2] + b[3] + 0.5)
  for _, q in ipairs{ { 0, 0, 1 }, { -1, 0, 2 }, { 1, 0, 2 }, { 0, 1, 2 }, { -1, 1, 3 }, { 1, 1, 1 } } do
    c:put(bx + q[1], by + q[2], CALYX[q[3]], tok) end
  c:put(bx, by - 1, R[1], tok)
end
-- contact shadow on berries under the strig crossing nothing; leaf shadow on the upper-right berry top
A.save(c, NAME)
