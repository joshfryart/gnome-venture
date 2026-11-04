-- root_cellar-lantern (final, Opus-style single pass). A grassy cellar mound with a round-arched stone doorway: the
-- plank door stands ajar on its left hinge, amber light pours out over a shelf of jars and fans across the step.
-- Beside it a slim wooden shepherd's-hook post holds an iron lantern on a chain; its glow warms the grass and post.
-- Material: per-pixel lit 6-tone grass with tufts + blade fringe, voussoir stone arch with seams and a keystone,
-- planked door with iron straps, glass panes with a cream flame, hard-pixel amber floor spill, AO around the arch.
-- quirk: a little moth circles the lantern.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "root_cellar-lantern" }
local M, S, W, AM, I = A.MOSS, A.STONE, A.WOOD, A.AMBER, A.IRON
local H = A.hash

c:groundShadow(26, 56, 19, 2)
c:groundShadow(55, 57, 3, 1)

-- footing: packed earth strip with pebbles
local foot = c:rect(6, 54, 44, 55)
local fidx = A.lit(c, foot, W, 1, { amb = 0.12 })
foot:each(function(x, y) local h = H(x, y, 21)
  if h > 0.86 then c:px(x, y, W[min(6, (fidx[K(x, y)] or 3) + 2)]) elseif h < 0.08 then c:px(x, y, W[1]) end end)

-- mound
local DX = 24.5
local mound = HP.mask()
for y = 18, 53 do
  local t = (y - 18) / 35
  local hw = 18 * sqrt(1 - (1 - t) ^ 2.2)
  local off = -1 * (1 - t)
  for x = floor(25 + off - hw + 0.5), floor(25 + off + hw - 0.5) do mound:set(x, y) end
end
local open, frame = HP.mask(), HP.mask()
for y = 28, 53 do for x = 14, 35 do
  local dx, dy = x - DX, y - 38.5
  local inO, inF
  if y >= 39 then
    inO = x >= 19 and x <= 30
    inF = (x >= 16 and x <= 18) or (x >= 31 and x <= 33)
  else
    local d2 = dx * dx + dy * dy
    inO = d2 <= 6.3 * 6.3
    inF = (not inO) and d2 <= 9.3 * 9.3
  end
  if inO then open:set(x, y) end
  if inF then frame:set(x, y) end
end end
local key = c:rect(23, 28, 26, 29)
frame:add(key)
local all = frame:copy():add(open)
local n = X.pillow(mound, 11)
local bias = {}
X.ao(bias, mound, all, 2, -1)
mound:each(function(x, y)
  local d = sqrt((x - 48) ^ 2 + (y - 27) ^ 2)
  if d < 11 then local k = K(x, y) bias[k] = (bias[k] or 0) + 1 end
end)
local idx = A.shade(c, mound, n, M, { amb = 0.04, wrap = 0.12, bias = bias, cuts = { 0.24, 0.42, 0.58, 0.74, 0.88 } })
mound:each(function(x, y) local h = H(x, y, 3)
  if h > 0.9 then A.bump(c, idx, M, x, y, 1) elseif h < 0.06 then A.bump(c, idx, M, x, y, -1) end end)
-- clover flecks: short bright dashes
for _, p in ipairs{ { 11, 40 }, { 33, 24 }, { 36, 46 }, { 14, 48 }, { 28, 22 }, { 38, 36 } } do
  if mound:has(p[1], p[2]) and mound:has(p[1] + 1, p[2]) then c:px(p[1], p[2], M[6]) c:px(p[1] + 1, p[2], M[5]) end
end
-- blade fringe along the crown
for x = 14, 36 do
  local top
  for y = 18, 30 do if mound:has(x, y) then top = y break end end
  if top and H(x, 1, 5) > 0.5 then
    c:px(x, top - 1, M[5])
    if H(x, 2, 6) > 0.78 then c:px(x, top - 2, M[4]) end
  end
end
-- embedded stones
local sl = c:ellipse(10, 51, 3.5, 2)
A.lit(c, sl, S, 1.5) A.contact(c, sl, M[1], mound)
local sr = c:ellipse(38, 52, 3, 1.8)
A.lit(c, sr, S, 1.5) A.contact(c, sr, M[1], mound)

-- stone arch: voussoirs, jamb courses, seams
local fn = X.pillow(frame, 2)
local fidx2 = A.shade(c, frame, fn, S, { amb = 0.1, wrap = 0.3 })
frame:each(function(x, y)
  local dx, dy = x - DX, y - 38.5
  local i = fidx2[K(x, y)]
  if y <= 38 and not key:has(x, y) then
    local a = math.atan(dy, dx) + math.pi
    local f = a / (math.pi / 7)
    local b = floor(f)
    i = i + ((b % 2 == 0) and 0 or -1)
    if f - b < 0.2 then i = 1 end
  elseif y > 38 then
    local row = floor((y - 39) / 4)
    if (y - 39) % 4 == 3 then i = 1
    else
      local jx = (x <= 18) and 17 or 32
      if x == jx + (row % 2 == 0 and 0 or -1) and (y - 39) % 4 ~= 0 then i = 1 end
      i = i + (((row + (x <= 18 and 0 or 1)) % 2 == 0) and 0 or -1)
    end
  end
  c:put(x, y, S[A.clamp(i)])
end)
for x = 23, 26 do c:px(x, 28, S[6]) c:px(x, 29, S[5]) end
c:px(23, 29, S[4]) c:px(26, 29, S[3]) c:px(26, 28, S[4])
for x = 22, 27 do c:px(x, 30, S[2]) end
-- moss on the arch crown + drips
for _, p in ipairs{ { 20, 31 }, { 21, 30 }, { 28, 30 }, { 29, 31 }, { 24, 27 }, { 27, 29 }, { 17, 38 }, { 32, 39 } } do
  if frame:has(p[1], p[2]) or key:has(p[1], p[2]) then c:px(p[1], p[2], M[H(p[1], p[2], 2) > 0.5 and 5 or 4]) end
end
A.contact(c, frame, M[1], mound:copy():cut(frame):cut(open))

-- interior: amber glow from a lamp deeper in
open:each(function(x, y)
  local d = sqrt(((x - 25.5) / 1.25) ^ 2 + ((y - 48) / 1.0) ^ 2)
  local i = max(2, min(6, 6 - floor(d / 3.1)))
  c:put(x, y, AM[i])
end)
-- shelf with two jars
for x = 25, 30 do c:px(x, 42, AM[1]) end
for _, j in ipairs{ { 26, 39 }, { 29, 40 } } do
  for yy = j[2], 41 do c:px(j[1], yy, AM[1]) c:px(j[1] + 1, yy, AM[2]) end
  c:px(j[1], j[2], AM[3])
end
-- dark top lip under the arch
open:each(function(x, y)
  if not open:has(x, y - 1) or not open:has(x - 1, y) and y < 39 then c:px(x, y, AM[1]) end
end)

-- door leaf, swung inward on the left hinge
local leaf = c:poly{ { 19, 35 }, { 22, 38 }, { 22, 51 }, { 19, 54 } }:clip(open)
local lidx = A.lit(c, leaf, W, 1, { amb = 0.08, bias = (function() local b = {} leaf:each(function(x, y) b[K(x, y)] = -1 end) return b end)() })
leaf:each(function(x, y)
  if x == 21 then c:px(x, y, W[2]) end
  if x == 22 then c:px(x, y, AM[5]) end
end)
for _, yy in ipairs{ 40, 49 } do for x = 19, 22 do if leaf:has(x, yy) then c:px(x, yy, I[3]) if leaf:has(x, yy + 1) then c:px(x, yy + 1, I[2]) end end end end
c:px(22, 44, I[5]) c:px(22, 45, I[3])

-- light spilling over the step and ground
for y = 54, 55 do for x = 18, 31 do c:px(x, y, y == 54 and AM[6] or AM[5]) end end
for x = 17, 32 do c:px(x, 56, AM[5]) end
for x = 15, 34 do c:px(x, 57, AM[4]) end

-- post + hook
local post = A.poly({ { 55, 12 }, { 55, 56 } }, 0.5)
local pm, pn, pU, pS = A.sweep(post, function() return 1.5 end)
local pbias = {}
pm:each(function(x, y) local d = sqrt((x - 48) ^ 2 + (y - 27) ^ 2) if d < 14 then pbias[K(x, y)] = 1 end end)
local pidx = A.shade(c, pm, pn, W, { amb = 0.1, wrap = 0.3, bias = pbias })
pm:each(function(x, y) local h = H(floor(pS[K(x, y)] * 3), floor(pU[K(x, y)] / 4), 8)
  if h > 0.72 then A.bump(c, pidx, W, x, y, -1) elseif h < 0.1 then A.bump(c, pidx, W, x, y, 1) end end)
c:px(55, 30, W[2]) c:px(55, 31, W[2]) c:px(54, 29, W[3]) c:px(56, 32, W[1])   -- a knot
for x = 53, 57 do c:px(x, 56, W[2]) end
for x = 54, 56 do c:px(x, 55, W[3]) end
local hook = A.poly(A.curve({ { 55, 13 }, { 55, 5 }, { 47, 4 }, { 48, 12 } }, 40), 0.4)
local hm, hn = A.sweep(hook, function() return 1.0 end)
A.shade(c, hm, hn, W, { amb = 0.1, wrap = 0.3 })
c:px(48, 11, W[5]) c:px(48, 12, W[6])
-- chain + ring
c:px(48, 13, I[5]) c:px(48, 14, I[2]) c:px(48, 15, I[5])
c:px(47, 16, I[4]) c:px(49, 16, I[3]) c:px(48, 17, I[2])

-- lantern: cap, glass, posts, base
local cap = HP.mask()
for _, r in ipairs{ { 46, 50, 18 }, { 45, 51, 19 }, { 44, 52, 20 }, { 43, 53, 21 } } do for x = r[1], r[2] do cap:set(x, r[3]) end end
A.lit(c, cap, I, 1.5, { amb = 0.1 })
for x = 43, 53 do c:px(x, 21, x < 47 and I[4] or I[2]) end
c:px(46, 18, I[6]) c:px(47, 18, I[5]) c:px(45, 19, I[5])
local gl = { 4, 3, 4, 5, 4, 3, 2 }
for y = 22, 31 do
  for i = 0, 6 do
    local t = gl[i + 1] + ((y >= 30) and -1 or 0)
    c:px(45 + i, y, AM[A.clamp(t)])
  end
  c:px(44, y, I[4]) c:px(52, y, I[2])
end
c:px(45, 23, AM[6]) c:px(45, 24, AM[6]) c:px(46, 23, AM[5])
c:px(48, 25, AM[5])
c:px(48, 26, A.CREAM) c:px(47, 27, AM[5]) c:px(48, 27, A.CREAM) c:px(49, 27, AM[5])
c:px(47, 28, AM[5]) c:px(48, 28, A.CREAM) c:px(49, 28, AM[5]) c:px(48, 29, AM[5])
c:px(48, 30, I[1]) c:px(47, 31, I[3]) c:px(48, 31, I[3]) c:px(49, 31, I[3])
local base = HP.mask()
for x = 43, 53 do base:set(x, 32) end
for x = 44, 52 do base:set(x, 33) end
for x = 46, 50 do base:set(x, 34) end
A.lit(c, base, I, 1.2, { amb = 0.1 })
for x = 43, 53 do c:px(x, 32, x < 48 and I[5] or I[3]) end
for x = 44, 52 do c:px(x, 33, I[2]) end

-- moth
c:px(38, 19, "#cfc8d8") c:px(39, 19, A.CREAM) c:px(40, 19, "#7a5a4a") c:px(41, 19, A.CREAM) c:px(42, 19, "#cfc8d8")
c:px(39, 20, "#cfc8d8") c:px(40, 20, "#7a5a4a") c:px(41, 20, "#cfc8d8")
c:px(39, 18, "#7a5a4a") c:px(41, 18, "#7a5a4a")

A.fin(c, "root_cellar-lantern")
