-- nav-together (final, Opus single pass). Two slim sunflowers, a tall one and a smaller one, their heads turned toward
-- each other. Petals: two rings (a darker back ring and a lit front ring), each petal cupped with its own light and a
-- dark crease where it overlaps a neighbour. Seed discs: domed 6-tone brown with a Fibonacci spiral of seed pits and
-- an olive centre. 3 px tube stems with a lit side, heart leaves with a fold, midrib and side veins, AO under the heads.
-- quirk: the two stems cross near the ground like linked arms.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, sqrt, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.sqrt, math.max, math.min, math.abs
local c = A.new("nav-together")
local PET  = { "#7a3414", "#b85a18", "#e08a1e", "#f6b42c", "#ffd658", "#fff0a0" }
local DISC = { "#2a1714", "#45271b", "#663a21", "#86522a", "#a46c38", "#c48c56" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#1d4a3a", "#2a6442", "#3f8048", "#5f9e50", "#86bc5e", "#b2d878" }

-- stems first (heads and leaves paint over them)
local function stem(p, w)
  local m, n, T, S = A.tube(p, function() return w end)
  A.shade(c, m, n, STEM, { wrap = 0.3 })
  return m, T
end
-- leaves
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return w * sin(pi * (t ^ 0.75)) ^ 0.8 + 0.2 end, { fold = 0.5 })
  local idx = A.shade(c, m, n, LEAF, { wrap = 0.25 })
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.13 and t > 0.06 and t < 0.9 then c:put(x, y, LEAF[min(6, idx[k] + 1)])
    else
      local d = (t * len - abs(s) * w * 1.1) % 3.6
      if d < 0.7 and abs(s) < 0.8 and t > 0.12 and t < 0.85 then c:put(x, y, LEAF[max(1, idx[k] - 1)]) end
    end
  end)
  return m
end

local s1m = stem({ { 24, 27 }, { 25, 38 }, { 30, 47 }, { 34, 56 } }, 1.2)
local s2m = stem({ { 42, 36 }, { 41, 45 }, { 33, 49 }, { 28, 56 } }, 1.2)
-- crossing: big stem passes in front at the lower crossing (redraw a short piece of it)
do
  local m, n = A.tube({ { 24, 27 }, { 25, 38 }, { 30, 47 }, { 34, 56 } }, function() return 1.2 end)
  local part = HP.mask()
  m:each(function(x, y) if y >= 51 and y <= 55 then part:set(x, y) end end)
  local pn = {} part:each(function(x, y) pn[K(x, y)] = n[K(x, y)] end)
  A.shade(c, part, pn, STEM, { wrap = 0.3 })
  -- contact shadow on the stem behind
  part:shift(1, 1):each(function(x, y) if s2m:has(x, y) and not part:has(x, y) then c:put(x, y, STEM[1]) end end)
end
local l1 = leaf(25, 41, 17, 36, 13, 42, 3.4)
local l2 = leaf(40, 46, 47, 41, 53, 46, 3.0)

-- sunflower head
local function head(cx, cy, rd, rp, np, rot)
  local all = HP.mask()
  local function petals(ring, off, dark)
    for i = 0, np - 1 do
      local a = (i + off) / np * 2 * pi + rot
      local ux, uy = cos(a), sin(a)
      local pr = (rd + rp) / 2 + (ring == 1 and -0.4 or 0)
      local hl = (rp - rd) / 2 + 0.6
      local m, n = A.oval(cx + ux * pr, cy + uy * pr, hl, ring == 1 and 1.9 or 1.6, a, 1.3)
      -- cup the petal: tilt normal outward along its length
      m:each(function(x, y) local k = K(x, y)
        local nn = n[k]
        local dx, dy = x - cx, y - cy
        local d = sqrt(dx*dx + dy*dy) + 0.01
        local q = (d - rd) / (rp - rd)
        local a1, a2, a3 = A.norm(nn[1] + dx / d * 0.35 * q, nn[2] + dy / d * 0.35 * q, nn[3])
        n[k] = { a1, a2, a3 }
      end)
      local bias = {}
      if dark then m:each(function(x, y) bias[K(x, y)] = -2 end) end
      -- crease where it lies on a petal already painted
      m:edge():each(function(x, y)
        for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
          local qx, qy = x + d[1], y + d[2]
          if not m:has(qx, qy) and all:has(qx, qy) then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 break end
        end
      end)
      A.shade(c, m, n, PET, { bias = bias, wrap = 0.3, amb = 0.12 })
      -- central petal vein
      for t = -0.5, 0.4, 0.15 do
        local x, y = floor(cx + ux * (pr + t * hl) + .5), floor(cy + uy * (pr + t * hl) + .5)
        if m:has(x, y) and not dark then local cur = c:get(x, y) if cur ~= PET[6]:lower() then c:put(x, y, PET[3]) end end
      end
      all:add(m)
    end
  end
  petals(1, 0.5, true)
  petals(2, 0, false)
  -- disc
  local dm = c:ellipse(cx, cy, rd, rd)
  local dn = X.sphere(cx, cy, rd, dm)
  for k, nn in pairs(dn) do dn[k] = { A.norm(nn[1] * 0.7, nn[2] * 0.7, nn[3]) } end
  local dbias = {}
  dm:edge():each(function(x, y) dbias[K(x, y)] = -1 end)
  local idx = A.shade(c, dm, dn, DISC, { bias = dbias, wrap = 0.2 })
  -- seed spiral pits
  local ga = pi * (3 - sqrt(5))
  for i = 1, 60 do
    local r = sqrt(i / 60) * (rd - 0.6)
    local x, y = floor(cx + cos(i * ga + rot) * r + .5), floor(cy + sin(i * ga + rot) * r + .5)
    local k = K(x, y)
    if dm:has(x, y) and idx[k] and i % 2 == 0 then c:put(x, y, DISC[max(1, idx[k] - 2)])
    elseif dm:has(x, y) and idx[k] and i % 5 == 1 and idx[k] >= 4 then c:put(x, y, DISC[6]) end
  end
  -- olive centre
  c:put(floor(cx), floor(cy), "#6b6a2a") c:put(floor(cx) - 1, floor(cy) - 1, "#8f8a3a")
  -- glint
  c:put(floor(cx - rd * 0.45), floor(cy - rd * 0.55), "#e8b982")
  all:add(dm)
  return all, dm
end
local h1 = head(24, 19, 5.2, 11.5, 13, 0.1)
local h2 = head(43, 30, 4.2, 9.2, 11, 0.35)
-- AO on stems right under each head
for _, sm in ipairs{ s1m, s2m } do
  sm:each(function(x, y)
    if (h1:has(x, y - 1) or h1:has(x, y - 2) or h2:has(x, y - 1) or h2:has(x, y - 2)) and not h1:has(x, y) and not h2:has(x, y) then c:put(x, y, STEM[1]) end
  end)
end

A.save(c, "nav-together")
