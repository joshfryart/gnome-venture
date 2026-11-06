-- nessberry (final, Opus single pass). A slim tapering bunch of eight round blue-violet berries hanging on thin
-- pedicels from a woody rachis, air between each berry; one slim serrated leaf off the top and a coiled tendril.
-- Material: per-pixel sphere light (6-tone indigo), dusty waxy bloom flecks, star crown scar on each berry, glossy
-- cream specular per berry (glossy material), warm-violet reflected light lower-right, rachis bark 4-tone with AO
-- where pedicels join, leaf midrib + veins.
-- quirk: one berry in the bunch has not ripened yet: pale green with a pink blush.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "nessberry"
local c = A.new(NAME)
local BER = { "#1a1440", "#2a2266", "#3c3892", "#5256ba", "#7680da", "#a8b6f2" }
local RAW = { "#3e5a3a", "#5e8a46", "#8cb45a", "#bcd67a", "#e4b0a0", "#f6e2bc" }
local BLOOM, BOUNCE, SPEC = "#a0a4cc", "#7a4a9a", "#fff4d6"
local BARK = { "#3e2a26", "#64463a", "#8e6c4c", "#b89468" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local R = 3.2
local berries = { { 27, 26 }, { 37, 26 }, { 23, 34 }, { 32, 34 }, { 41, 34 }, { 27, 42 }, { 37, 42 }, { 32, 50 } }
local RAWI = 7

-- rachis + pedicels (behind)
local btok = { r = { name = "bark" } }
local rach = A.stem(c, { { 33, 8 }, { 32, 15 }, { 32, 30 }, { 32, 45 } }, function(t) return 1.4 - 0.7 * t end, BARK, { tok = btok })
local function ped(x0, y0, x1, y1)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do local t = i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not rach:has(x, y) then c:put(x, y, (x < 32) and BARK[3] or BARK[2], btok) end
  end
end
for i, b in ipairs(berries) do
  local jy = b[2] - 6
  if b[1] == 32 then ped(32, jy + 2, b[1], b[2] - 2) else ped(32, jy, b[1], b[2] - 2) end
  c:put(32, jy, BARK[1], btok)                                    -- dark node where the pedicel leaves
end
c:put(33, 7, BARK[4], btok) c:put(32, 7, BARK[3], btok)          -- paler cut end of the stalk

-- leaf off the top (left), tendril coil (right)
A.leaf(c, 32, 13, 22, 14, 13, 8, 3.8, LEAF, { serr = true, pw = 0.8, cut = rach })
local tt = { r = { name = "tendril" } }
local TC = { "#3f9150", "#7cc35a" }
local coil = { { 34, 14 }, { 36, 13 }, { 38, 12 }, { 40, 11 }, { 42, 11 }, { 44, 12 }, { 45, 14 }, { 44, 16 }, { 42, 16 }, { 41, 15 }, { 42, 14 } }
for i, p in ipairs(coil) do c:put(p[1], p[2], (p[2] <= 12 and p[1] < 44) and TC[2] or TC[1], tt) end

-- berries
local all = HP.mask()
for i, b in ipairs(berries) do b.m = c:ellipse(b[1], b[2], R, R) all:add(b.m) end
for i, b in ipairs(berries) do
  local ramp = (i == RAWI) and RAW or BER
  local n = X.sphere(b[1] - 0.4, b[2] - 0.4, R + 0.6, b.m)
  local bias = {}
  X.ao(bias, b.m, c:rect(b[1] - 1, b[2] - R - 2, b[1] + 1, b[2] - R - 1), 1, -1)   -- AO at the pedicel
  local tok = { r = { name = "berry" .. i } }
  local idx = A.shade(c, b.m, n, ramp, { bias = bias, tok = tok, amb = 0.05, wrap = 0.2 })
  if i == RAWI then
    -- pink blush on the lit cheek replaces the top two greens
    b.m:each(function(x, y) local k = K(x, y) if idx[k] == 4 and x < b[1] then c:put(x, y, RAW[5], tok) end end)
  else
    -- dusty bloom flecks on mid/shade tones
    b.m:each(function(x, y) local k = K(x, y)
      if idx[k] >= 2 and idx[k] <= 4 and X.hash(x, y, i) > 0.78 then c:put(x, y, (idx[k] >= 3) and BLOOM or BER[4], tok) end end)
  end
  -- reflected light lower-right edge
  local rim = X.rim(n)
  b.m:edge():each(function(x, y) if rim[K(x, y)] > 0.7 then c:put(x, y, (i == RAWI) and RAW[2] or BOUNCE, tok) end end)
  -- star crown scar, lower-right of centre (the berry's blossom end faces us, slightly turned)
  local sx, sy = floor(b[1] + 1.2 + .5), floor(b[2] + 1.2 + .5)
  local dk = ramp[1]
  c:put(sx, sy, dk, tok) c:put(sx - 1, sy, ramp[2], tok) c:put(sx, sy - 1, ramp[2], tok) c:put(sx + 1, sy, ramp[2], tok) c:put(sx, sy + 1, ramp[2], tok)
  -- specular: glossy, one per berry
  local gx, gy = floor(b[1] - 1.4 + .5), floor(b[2] - 1.6 + .5)
  c:put(gx, gy, SPEC, tok) c:put(gx + 1, gy, ramp[6], tok)
end
A.save(c, NAME)
