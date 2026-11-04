-- driftwood (final, Opus single pass). A slim sun-bleached forked branch on the diagonal: blunt snapped butt lower-left
-- with pale cracked end grain, tapering to a sea-worn point upper-right, one side fork rising and one short stub.
-- Material: per-pixel tube light on a 6-tone silver-driftwood ramp (warm hi, cool-violet shade), long wavy grain
-- grooves with a lit lip, a dark knot hole with a rim, a check crack, AO where the fork and stub join the shaft.
-- quirk: a ribbon of green seaweed is snagged over the shaft and dangles below.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt
local c = A.new("driftwood")
local W  = { "#3b3343", "#5c5462", "#82797f", "#a99f9b", "#cfc5b6", "#ece4d0" }
local EG = { "#6a5444", "#8f7660", "#b39a7c", "#d2bc98", "#e9d8b4" }
local tok = { r = { name = "wood" } }

-- grain: grooves along the tube at fixed across-offsets, wobbling, broken by hash gaps
local function grain(m, T, S, idx, hw, len, seed, lines)
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if not t or t < 0.03 or t > 0.97 then return end
    local w = hw(t)
    local along = t * len
    for gi, g in ipairs(lines) do
      local off = s * (w + 0.5) - (g * w + sin(along * 0.33 + gi * 1.7) * 0.6)
      if abs(off) < 0.5 and X.hash(floor(along / 4), gi, seed) > 0.22 then
        local cur = idx[k] or 3
        c:put(x, y, W[max(1, cur - (s > 0.3 and 1 or 2))], tok)
        idx[k] = max(1, cur - 1)
      end
    end
  end)
end

local function lenOf(samp) local L = 0 for i = 2, #samp do L = L + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end return L end

-- side fork (painted first; shaft paints over its root)
local pF = { { 27, 38 }, { 27, 31 }, { 29, 23 }, { 33, 14 } }
local hwF = function(t) return 2.3 - t * 1.1 end
local mF, nF, TF, SF, idxF, sF = A.stem(c, pF, hwF, W, { tok = tok })
-- stub (lower side, snapped)
local pS = { { 43, 26 }, { 46, 28 }, { 49, 30 }, { 51, 32 } }
local hwS = function(t) return 1.9 - t * 0.3 end
local mS, nS, TS, SS, idxS, sS = A.stem(c, pS, hwS, W, { tok = tok })
-- main shaft
local pM = { { 11, 50 }, { 22, 44 }, { 36, 28 }, { 54, 17 } }
local hwM = function(t)
  if t > 0.9 then return max(0.6, 3.0 * (1 - (t - 0.9) / 0.1) ^ 0.6) end
  return 3.5 - t * 0.6 + sin(t * 9) * 0.25
end
local mM, nM, TM, SM, samp
mM, nM, TM, SM, samp = A.tube(pM, hwM)
-- AO on fork + stub where the shaft meets them
local bF, bS = {}, {}
X.ao(bF, mF, mM, 2, -1) X.ao(bS, mS, mM, 2, -1)
idxF = A.shade(c, mF, nF, W, { amb = 0.14, wrap = 0.3, bias = bF, tok = tok })
idxS = A.shade(c, mS, nS, W, { amb = 0.14, wrap = 0.3, bias = bS, tok = tok })
grain(mF, TF, SF, idxF, hwF, lenOf(sF), 3, { -0.35, 0.4 })
-- shaft (over fork root)
local idxM = A.shade(c, mM, nM, W, { amb = 0.12, wrap = 0.3, tok = tok })
grain(mM, TM, SM, idxM, hwM, lenOf(samp), 7, { -0.6, -0.1, 0.35, 0.75 })
-- dark joint line where fork/stub tuck under the shaft
mM:grow(1):cut(mM):each(function(x, y)
  if mF:has(x, y) or mS:has(x, y) then c:put(x, y, W[1], tok) end end)

-- snapped end of the stub: pale end grain disc
do local s = sS[#sS]
  for _, q in ipairs{ { 0, 0, 3 }, { -1, 0, 4 }, { 1, 0, 2 }, { 0, -1, 4 }, { 0, 1, 2 } } do
    c:put(floor(s.x + .5) + q[1], floor(s.y + .5) + q[2], EG[q[3]], tok) end
  c:put(floor(s.x + .5), floor(s.y + .5), EG[2], tok)
end
-- butt end grain: ellipse across the tube at t=0, with rings + radial check
do
  local s = samp[1]
  local ux, uy = s.px, s.py
  local cx, cy = s.x + s.tx * 0.6, s.y + s.ty * 0.6
  local m = HP.mask()
  for y = floor(cy) - 5, floor(cy) + 5 do for x = floor(cx) - 5, floor(cx) + 5 do
    local dx, dy = x - cx, y - cy
    local a = dx * ux + dy * uy
    local b = dx * s.tx + dy * s.ty
    local r = (a / 3.7) ^ 2 + (b / 1.9) ^ 2
    if r <= 1 then m:set(x, y)
      local tone = r < 0.12 and 2 or (r < 0.45 and 4 or (r < 0.62 and 3 or 5))
      if a > 1.6 then tone = max(1, tone - 1) end
      c:put(x, y, EG[tone], tok)
    end
  end end
  c:put(floor(cx + ux * 1.5 + .5), floor(cy + uy * 1.5 + .5), EG[1], tok)
  c:put(floor(cx + ux * 2.5 + .5), floor(cy + uy * 2.5 + .5), EG[1], tok)
end

-- knot hole on the shaft
local function at(samp, t, s) local p = samp[floor(t * (#samp - 1)) + 1] return floor(p.x + p.px * p.w * s + .5), floor(p.y + p.py * p.w * s + .5), p end
do local kx, ky = at(samp, 0.27, 0.05)
  local map = { ".abb.", "abKKc", "bKKdc", ".ccc." }
  A.map(c, map, kx - 2, ky - 2, { a = W[5], b = W[4], K = "#2e2430", d = "#4a3a44", c = W[2] }, tok)
end
-- check crack near the tip
do for i, q in ipairs{ { 0.66, -0.2 }, { 0.68, -0.1 }, { 0.70, -0.05 }, { 0.72, 0.1 } } do
  local x, y = at(samp, q[1], q[2]) c:put(x, y, W[1], tok) end end
-- specular: one bleached glint on the lit upper ridge
do local x, y = at(samp, 0.46, -0.6) c:put(x, y, "#fbf4e2", tok) c:put(x + 1, y - 1, W[6], tok) end

-- quirk: seaweed ribbon draped over the shaft at t~0.56, dangling down
do
  local x0, y0 = at(samp, 0.55, -1.05)
  local SW = { "#1f4a3a", "#2f6e44", "#4e9a4c", "#86c45e" }
  local stok = { r = { name = "weed" } }
  -- across the shaft (from top edge down-right to bottom edge)
  local p = samp[floor(0.55 * (#samp - 1)) + 1]
  for i = -1.1, 1.3, 0.25 do
    local x, y = floor(p.x + p.px * p.w * i + .5), floor(p.y + p.py * p.w * i + .5)
    c:put(x, y, i < -0.2 and SW[4] or (i < 0.6 and SW[3] or SW[2]), stok)
    c:put(x + 1, y, i < 0 and SW[3] or SW[2], stok)
  end
  -- contact shadow on the wood just downstream of the ribbon
  for i = -0.8, 0.9, 0.3 do
    local x, y = floor(p.x + p.px * p.w * i + .5) + 2, floor(p.y + p.py * p.w * i + .5)
    if mM:has(x, y) and c:get(x, y) ~= SW[2] and c:get(x, y) ~= SW[3] and c:get(x, y) ~= SW[4] then
      local k = K(x, y) c:put(x, y, W[max(1, (idxM[k] or 3) - 1)], tok) end
  end
  -- dangling tail, wavy, 2px then 1px
  local bx, by = floor(p.x + p.px * p.w * 1.3 + .5), floor(p.y + p.py * p.w * 1.3 + .5)
  for j = 1, 8 do
    local x = bx + floor(sin(j * 0.9) * 1.2 + .5)
    local y = by + j
    c:put(x, y, j < 5 and SW[3] or SW[2], stok)
    if j < 5 then c:put(x + 1, y, SW[2], stok) end
  end
  -- little bladder (float) at the end
  local ex = bx + floor(sin(9 * 0.9) * 1.2 + .5)
  c:put(ex, by + 9, SW[3], stok) c:put(ex + 1, by + 9, SW[2], stok)
  c:put(ex, by + 10, SW[2], stok) c:put(ex + 1, by + 10, SW[1], stok)
  c:put(ex, by + 9, SW[4], stok)
end
A.save(c, "driftwood")
