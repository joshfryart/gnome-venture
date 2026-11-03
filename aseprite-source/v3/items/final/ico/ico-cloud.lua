-- ico-cloud (final, Opus). Cumulus of four overlapping puffs on a softly flattened base. Per-pixel light from a
-- heightfield (max of sphere caps), so every puff rounds on its own and the creases where puffs meet fall into a
-- cool ambient groove. 6-tone sky ramp, warm-cream sunlit tops, cool violet belly, faint lilac bounce on the
-- lower-right rim, a pale wisp line under the top puff.
-- quirk: one fat raindrop has just let go of the belly (with its own glint).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_5.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("ico-cloud")
local CR = A.CREAM
local SKY = { "#4c5a9c", "#6584c4", "#8db5e2", "#b9dcf3", "#e2f3fd", "#fff8e4" }
local BASE = 40
local puffs = { { 20, 33, 8.5 }, { 30, 25, 11 }, { 42, 27, 9.5 }, { 49, 34, 7 } }
local cm = HP.mask()
for _, p in ipairs(puffs) do cm:add(A.ell(p[1], p[2], p[3], p[3])) end
cm:add(c:rrect(15, 30, 54, BASE, 6))
-- flatten the belly: cut below BASE, but keep it softly rounded at the ends
cm:each(function(x, y) if y > BASE then cm.s[K(x, y)] = nil end end)
local function hf(x, y)
  if not cm:has(x, y) then return nil end
  local best, bi = -1e9, 0
  for i, p in ipairs(puffs) do
    local d2 = (x - p[1]) ^ 2 + (y - p[2]) ^ 2
    local r = p[3] + 0.6
    if d2 <= r * r then local h = sqrt(r * r - d2) if h > best then best, bi = h, i end end
  end
  -- flat base: a lying cylinder along x under the puffs
  local by = y - (BASE - 5)
  local hb = sqrt(max(0, 6.2 * 6.2 - by * by)) * 0.9
  local ex = max(0, max(16 - x, x - 53))
  hb = hb - ex * 1.2
  if hb > best then best = hb end
  if best < -1e8 then best = 0 end
  -- belly droops: lower the surface near the flat base
  local up = BASE - y
  if up < 3 then best = best - (3 - up) * 1.1 end
  return best
end
local n = A.hnorm(cm, hf)
-- crease AO: pixels where the two highest caps are nearly equal (puff seams)
local bias = {}
cm:each(function(x, y)
  local h1, h2 = -1e9, -1e9
  for _, p in ipairs(puffs) do
    local d2 = (x - p[1]) ^ 2 + (y - p[2]) ^ 2
    local r = p[3] + 0.6
    if d2 <= r * r then
      local h = sqrt(r * r - d2)
      if h > h1 then h1, h2 = h, h1 elseif h > h2 then h2 = h end
    end
  end
  if h2 > 0 and h1 - h2 < 1.1 then bias[K(x, y)] = -1 end
end)
local tok = A.tok("cloud")
local idx = A.shade(c, cm, n, SKY, { tok = tok, bias = bias, amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- flat belly: bottom 2 rows go to the cool violet tones
cm:each(function(x, y)
  if y == BASE then A.step(c, idx, SKY, x, y, -1, tok) end
  if y == BASE and idx[K(x, y)] > 2 then A.step(c, idx, SKY, x, y, -1, tok) end
end)
-- lilac bounce on the lower-right rim
local rimv = X.rim(n)
cm:edge():each(function(x, y) local k = K(x, y)
  if rimv[k] > 0.55 and y > 31 and y < BASE and x > 40 then c:put(x, y, "#9a8fd8", tok) end end)
-- wisp: pale curl under the top puff
for _, p in ipairs{ { 25, 31 }, { 26, 32 }, { 27, 32 }, { 28, 32 }, { 29, 32 } } do c:put(p[1], p[2], SKY[5], tok) end
for _, p in ipairs{ { 25, 32 }, { 26, 33 }, { 27, 33 }, { 28, 33 } } do c:put(p[1], p[2], SKY[3], tok) end
-- sunlit glint on the top puff
c:put(24, 17, CR, tok) c:put(25, 17, CR, tok) c:put(24, 18, SKY[6], tok)

-- quirk: a raindrop just let go
local tr = A.tok("drop")
local DROP = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local dm = HP.mask()
for y = 44, 52 do for x = 34, 42 do
  local dx, dy = x - 38, y - 49
  if dy >= 0 then if dx * dx + dy * dy <= 2.9 * 2.9 then dm:set(x, y) end
  else if abs(dx) <= (dy + 4.6) * 0.62 then dm:set(x, y) end end
end end
local dn = X.sphere(38, 48.5, 3.2, dm)
local di = A.shade(c, dm, dn, DROP, { tok = tr, amb = 0.2, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
c:put(37, 48, CR, tr) c:put(37, 49, DROP[4], tr)

A.save(c, "ico-cloud")
