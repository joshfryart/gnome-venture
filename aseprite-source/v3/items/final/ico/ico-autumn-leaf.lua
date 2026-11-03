-- ico-autumn-leaf (final pass, Opus). A five-lobed maple leaf in full autumn colour on a slim curved stalk.
-- Structure: five pointed lobes (long top, two broad sides, two short lower) with saw-tooth margins, deep sinuses
-- between lobes, a palmate vein fan from the stalk, side veins on each lobe, stalk curving off lower right.
-- Material: each lobe V-folds along its midrib (lit / shade halves), colour turns from gold at the heart through
-- orange to scarlet at the tips, pale veins with a dark lower edge, AO where the lobes overlap and at the stalk.
-- quirk: a single round raindrop sits on the left lobe, bright rim and pale core.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_4.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local MP, SC, AM, SK, GL = R.maple, R.scarlet, R.amber, R.stalk, R.glass
local floor, abs, max, min, sin, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.pi, math.sqrt
local c = A.new("ico-autumn-leaf")

local CX, CY = 32, 37
-- lobes: tip, control point, half width, saw period
local lobes = {
  { tip = { 32, 7 },  ctl = { 32, 22 }, w = 10,  p = 6 },
  { tip = { 7, 23 },  ctl = { 19, 30 }, w = 9,   p = 6 },
  { tip = { 57, 23 }, ctl = { 45, 30 }, w = 9,   p = 6 },
  { tip = { 14, 50 }, ctl = { 22, 44 }, w = 6,   p = 5 },
  { tip = { 50, 50 }, ctl = { 42, 44 }, w = 6,   p = 5 },
  -- secondary points (maple shoulders) on the top and side lobes
  { tip = { 20, 13 }, ctl = { 26, 22 }, w = 4.5, p = 4, from = { 30, 25 }, minor = true },
  { tip = { 44, 13 }, ctl = { 38, 22 }, w = 4.5, p = 4, from = { 34, 25 }, minor = true },
  { tip = { 12, 38 }, ctl = { 18, 36 }, w = 4,   p = 4, from = { 24, 34 }, minor = true },
  { tip = { 52, 38 }, ctl = { 46, 36 }, w = 4,   p = 4, from = { 40, 34 }, minor = true },
}
-- stalk first (behind)
local stalk, stn = A.tube({ { 32, 40 }, { 33, 47 }, { 35, 52 }, { 38, 56 } }, function(t) return 1.6 - t * 0.3 end)
local stIdx = A.shadeN(c, stalk, stn, SK, { amb = 0.15, wrap = 0.35 })

local leaf = HP.mask()
local N, T, S, owner = {}, {}, {}, {}
for li, L in ipairs(lobes) do
  local w, p = L.w, L.p
  local fx, fy = (L.from or { CX, CY })[1], (L.from or { CX, CY })[2]
  local m, n, TT, SS, len = A.blade(fx, fy, L.ctl[1], L.ctl[2], L.tip[1], L.tip[2], function(t)
    if t > 0.99 then return -1 end
    local base = w * sin(pi * min(1, 0.32 + t * 0.7)) ^ 0.8
    base = base * min(1, (1 - t) * 3.2)               -- pointed tip
    local saw = ((t * 40 / p) % 1)                    -- saw teeth pointing toward the tip
    return max(0.3, base * (0.72 + 0.42 * saw))
  end, { fold = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    -- keep the pixel from the lobe whose midrib is closest
    if not owner[k] or (not L.minor and abs(SS[k]) < abs(S[k])) then N[k], T[k], S[k], owner[k] = n[k], TT[k], SS[k], li end
  end)
  leaf:add(m)
end
-- heart: fill the centre
local heart = c:ellipse(CX, CY - 2, 7, 6)
heart:each(function(x, y) local k = K(x, y) if not owner[k] then
  N[k] = { A.norm((x - CX) / 14, (y - CY) / 14, 1) } T[k], S[k], owner[k] = 0, 0, 0 end end)
leaf:add(heart)

-- light, then colour zone by distance from the heart (gold heart, orange body, scarlet tips)
local v = X.light(N, { amb = 0.1, wrap = 0.3 })
local cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }
local idx, zone = {}, {}
leaf:each(function(x, y) local k = K(x, y)
  local i = 1 for j, t in ipairs(cuts) do if v[k] >= t then i = j + 1 end end
  -- AO where lobes overlap (pixel close to another lobe's ownership)
  for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    local o = owner[K(x + d[1], y + d[2])]
    if o and o ~= owner[k] and owner[k] ~= 0 and o ~= 0 then i = i - 1 break end
  end
  idx[k] = max(1, min(6, i))
  local t = T[k] + (X.hash(x, y, 3) - 0.5) * 0.05
  zone[k] = (t > 0.62) and SC or ((t < 0.2 and owner[k] ~= 0) or owner[k] == 0) and AM or MP
end)
local function paint(x, y) local k = K(x, y) c:put(x, y, zone[k][idx[k]]) end
leaf:each(paint)
local function stepL(x, y, d) local k = K(x, y) if idx[k] then idx[k] = max(1, min(6, idx[k] + d)) paint(x, y) end end

-- veins: midribs from the heart to each tip, pale with a dark lower edge; side veins
for li, L in ipairs(lobes) do if not L.minor then
  local n = 40
  for s = 0, n do local t = s / n
    if t < 0.9 then
      local u = 1 - t
      local x = floor(u * u * CX + 2 * u * t * L.ctl[1] + t * t * L.tip[1] + 0.5)
      local y = floor(u * u * CY + 2 * u * t * L.ctl[2] + t * t * L.tip[2] + 0.5)
      if leaf:has(x, y) then
        local k = K(x, y) zone[k] = AM idx[k] = min(6, max(4, idx[k]) + 1) paint(x, y)
        if leaf:has(x + 1, y + 1) and t > 0.15 and (s % 2 == 0) then local k2 = K(x + 1, y + 1) if zone[k2] ~= AM then stepL(x + 1, y + 1, -1) end end
      end
    end
  end
end end
-- side veins: thin lighter strokes every few px along S = +-0.5 bands
leaf:each(function(x, y) local k = K(x, y)
  if owner[k] and owner[k] > 0 and T[k] > 0.25 and T[k] < 0.8 then
    local a = abs(S[k])
    local L = lobes[owner[k]]
    local d = (T[k] * 30 - a * 6) % 5
    if a > 0.25 and a < 0.75 and d < 0.8 then stepL(x, y, S[k] < 0 and 1 or -1) end
  end
end)

-- AO on the leaf where the stalk joins
for _, p in ipairs{ { 31, 41 }, { 32, 42 }, { 33, 41 }, { 31, 42 } } do stepL(p[1], p[2], -1) end
-- specular bloom on the top lobe (waxy cuticle)
c:put(28, 19, AM[6]) c:put(29, 19, A.CREAM) c:put(28, 20, AM[6])

-- quirk: raindrop on the left lobe
A.map(c, {
  ".ab.",
  "acbd",
  "bccd",
  ".dd.",
}, 17, 30, { a = GL[6], b = GL[5], c = GL[4], d = GL[3] })
c:put(18, 31, A.CREAM)
c:put(18, 34, MP[1]) c:put(19, 34, MP[1]) c:put(20, 34, MP[2]) c:put(21, 33, MP[2])   -- contact shadow under the drop

A.save(c, "ico-autumn-leaf")
