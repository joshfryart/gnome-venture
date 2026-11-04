-- hollyhock-seed (final, Opus single pass aC12_2). Three flat, wheel-like hollyhock seeds (tan discs with a ribbed,
-- darker rim, a sunken centre and a hilum notch) on a torn scrap of round, crinkled hollyhock leaf (scalloped margin
-- on the intact side, ragged torn edge on the right, palmate veins fanning from the petiole stub, cool reflected
-- edge, AO + contact shadow under each seed). The middle seed has sprouted: pale stem, two round mallow cotyledons
-- and a first true leaf that is the hollyhock leaf in miniature (rounded, five shallow lobes, palmate veins).
-- quirk: a fallen pink hollyhock petal curls over the left edge of the scrap.
local NAME = "hollyhock-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local SEED = { "#3e2620", "#5e3a28", "#84583a", "#a8794e", "#c99e6c", "#e8c896" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local PET = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local ltok, stok, ptok = { r = { name = "leaf" } }, { r = { name = "stem" } }, { r = { name = "petal" } }

-- leaf scrap: flattened round leaf, scalloped margin, torn right edge
local LX, LY = 14, 52                      -- petiole point (veins fan from here)
local scrap = HP.mask()
for y = 34, 60 do for x = 6, 58 do
  local dx, dy = (x - 31) / 22, (y - 47) / 10
  local a = atan(y - LY, x - LX)
  local sc = 0.06 * abs(sin(a * 7))          -- scallops
  local r = sqrt(dx * dx + dy * dy)
  local torn = x > 46 + 4 * X.hash(0, floor(y / 2), 21) + 2 * sin(y * 1.3)
  if r <= 1 - sc and not torn then scrap:set(x, y) end
end end
local seeds = { { 23, 49, 4.2, 2.7 }, { 32, 46, 4.2, 2.7 }, { 40, 51, 4.0, 2.6 } }
for _, s in ipairs(seeds) do s.m = c:ellipse(s[1], s[2], floor(s[3]), floor(s[4])) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, scrap, s.m, 1, -1) A.cast(bias, scrap, s.m, 1, 2, -1) end
local ln = X.pillow(scrap, 4)
-- crinkle: small bumps between veins
for k, v in pairs(ln) do local x, y = k % 1024 - 256, k // 1024 - 256
  local a = atan(y - LY, x - LX)
  local w = sin(a * 14) * 0.25
  ln[k] = { A.norm(v[1] + w * 0.6, v[2] - w * 0.4, v[3]) } end
local lidx = A.shade(c, scrap, ln, LEAF, { amb = 0.12, wrap = 0.3, bias = bias, tok = ltok })
-- palmate veins
for _, a in ipairs{ -0.55, -0.22, 0.08, 0.38 } do
  for t = 2, 40 do local x, y = floor(LX + cos(a) * t + 0.5), floor(LY + sin(a) * t * 0.55 + 0.5)
    if scrap:shrink(1):has(x, y) and not bias[K(x, y)] then c:put(x, y, (t % 9 == 0) and LEAF[5] or VEIN, ltok) c:put(x, y + 1, LEAF[3], ltok) end end
end
-- torn edge: pale broken tissue
scrap:edge():each(function(x, y) if x > 44 and not scrap:has(x + 1, y) then c:put(x, y, "#b4d690", ltok)
  elseif y > 52 and x > 28 and not scrap:has(x, y + 1) then c:put(x, y, COOL, ltok) end end)
for _, q in ipairs{ { 13, 52, 3 }, { 12, 53, 2 }, { 11, 53, 3 }, { 10, 54, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from the middle seed: stem, round cotyledons, scalloped true leaf
local sm = A.stem(c, { { 32, 45 }, { 31, 38 }, { 32, 31 }, { 32, 25 } }, function(t) return 1.0 end, STEM, { tok = stok })
local function roundLeaf(cx, cy, r, lobes, veins)
  local m = HP.mask()
  for y = floor(cy - r - 2), floor(cy + r + 2) do for x = floor(cx - r - 2), floor(cx + r + 2) do
    local a = atan(y - cy, x - cx)
    local rr = r * (1 - (lobes > 0 and 0.12 * abs(sin(a * lobes / 2 + 0.3)) or 0))
    if (x - cx) ^ 2 + ((y - cy) * 1.1) ^ 2 <= rr * rr then m:set(x, y) end
  end end
  m:cut(sm)
  local nn = X.pillow(m, max(2, r * 0.7))
  local idx = A.shade(c, m, nn, LEAF, { amb = 0.14, wrap = 0.3, tok = ltok })
  if veins then
    for _, a in ipairs{ -2.6, -1.57, -0.55, -2.1, -1.05 } do
      for t = 1, r - 1 do local x, y = floor(cx + cos(a) * t + 0.5), floor(cy + 2 + sin(a) * t + 0.5)
        if m:shrink(1):has(x, y) then c:put(x, y, (a < -1.57) and LEAF[6] or LEAF[4], ltok) end end
    end
  end
  return m
end
local cl = roundLeaf(24, 31, 3.6, 0, false)
local cr = roundLeaf(40, 30, 3.6, 0, false)
for _, p in ipairs{ { 25, 31 }, { 26, 31 }, { 27, 32 } } do c:put(p[1], p[2], LEAF[6], ltok) end
for _, p in ipairs{ { 39, 30 }, { 38, 31 }, { 37, 31 } } do c:put(p[1], p[2], LEAF[3], ltok) end
for _, p in ipairs{ { 28, 33 }, { 29, 33 }, { 30, 32 }, { 34, 32 }, { 35, 32 }, { 36, 32 } } do c:put(p[1], p[2], STEM[2], stok) end
local tl = roundLeaf(32, 18, 7.2, 5, true)
c:put(32, 21, LEAF[3], ltok) c:put(32, 22, STEM[1], stok)

-- seeds: ribbed rim, sunken centre, hilum notch
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local m = HP.mask()
  for y = floor(s[2] - s[4] - 1), floor(s[2] + s[4] + 1) do for x = floor(s[1] - s[3] - 1), floor(s[1] + s[3] + 1) do
    local u, v = (x - s[1]) / (s[3] + 0.45), (y - s[2]) / (s[4] + 0.45)
    if u * u + v * v <= 1 then m:set(x, y) end end end
  m:cut(c:rect(floor(s[1] + s[3]), floor(s[2]), floor(s[1] + s[3]), floor(s[2])))   -- notch
  m:each(function(x, y)
    local u, v = (x - s[1]) / (s[3] + 0.45), (y - s[2]) / (s[4] + 0.45)
    local r = sqrt(u * u + v * v)
    local lit = -(u * 0.6 + v * 0.8)        -- >0 upper-left
    local ii
    if r > 0.6 then
      ii = (lit > 0.25) and 5 or (lit > -0.3 and 4 or 3)
      local a = atan(v, u)
      if floor((a + pi) * 11 / pi) % 2 == 0 then ii = ii - 1 end   -- ribs
      if lit > 0.6 and r > 0.8 then ii = 6 end
    else
      ii = (lit > 0.1) and 3 or 4                                    -- dished centre: lit side dark
      if r < 0.25 then ii = 2 end
    end
    if bias[K(x, y)] and i > 1 then end
    c:put(x, y, SEED[max(1, min(6, ii))], tok)
  end)
end
-- the sprouting seed's coat splits where the stem leaves it
c:put(32, 45, STEM[2], stok) c:put(31, 45, SEED[2], {}) c:put(33, 45, SEED[2], {})

-- quirk: fallen pink petal curling over the left edge
local pm = HP.mask()
for _, r in ipairs{ { 8, 40, 11 }, { 9, 39, 12 }, { 10, 40, 13 }, { 11, 41, 13 }, { 12, 41, 12 }, { 13, 42, 12 }, { 14, 43, 11 }, { 15, 44, 9 } } do
  for x = r[1] - 1, r[1] + 3 do if x >= r[2] - 5 and x <= r[3] + 2 then end end end
pm = c:ellipse(11, 43, 5, 3)
pm:cut(c:rect(15, 40, 17, 42))
pm:each(function(x, y)
  local i = (x + y < 52) and 4 or ((x + y < 55) and 3 or 2)
  if y == 46 then i = 2 end
  if (x == 9 or x == 12) and y > 42 then i = max(1, i - 1) end
  c:put(x, y, PET[i], ptok) end)
c:put(7, 42, PET[4], ptok) c:put(8, 41, A.CREAM, ptok)
for _, p in ipairs{ { 14, 47 }, { 15, 46 }, { 16, 45 } } do if scrap:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end
A.save(c, NAME)
