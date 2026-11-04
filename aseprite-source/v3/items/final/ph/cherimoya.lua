-- cherimoya (final, Opus single pass). A heart-shaped custard apple: slim lopsided cone with a shallow shoulder dip at
-- the stalk. Skin of overlapping thumbprint scales: each scale is a small dome in the per-pixel normal field (lit
-- upper-left, shaded lower-right) bounded by a dark U-groove, foreshortened toward the silhouette. 6-tone green ramp,
-- waxy bloom specular, cool reflected light lower-right, dried brown blossom tip, AO under the calyx. Woody stalk with
-- one elliptic velvety leaf (midrib + pinnate veins, paler underside edge).
-- quirk: a ladybird is walking along the leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local NAME = "cherimoya"
local c = A.new(NAME)

local SKIN = { "#1c3a30", "#2b5a3c", "#457a40", "#689a48", "#92bb5a", "#c4dc88" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local WOOD = { "#3a2622", "#5b3e2e", "#81603f", "#a8844f" }
local CX, YT, YB = 31.5, 22, 53

-- body: per-row width profile (round shoulders, tapered lopsided tip), small dip at the stalk
local body = HP.mask()
for y = YT, YB do
  local t = (y - YT) / (YB - YT)
  local w = 13.2 * sin(pi * min(1, t * 0.98 + 0.06)) ^ 0.55
  if t > 0.55 then w = w * (1 - (t - 0.55) * 0.55) end
  local xc = CX + 1.6 * t * t                       -- tip leans right
  for x = floor(xc - w - 1), floor(xc + w + 1) do
    local dx = x + 0.5 - xc
    local dip = (t < 0.12) and (1.6 * math.exp(-(dx * dx) / 9) > (y - YT) + 0.2) or false
    if abs(dx) <= w and not dip then body:set(x, y) end
  end
end
local n0 = A.body(body, CX - 0.5, 35, 14.5, 6, 0.55)

-- stalk + leaf first (fruit overlaps the stalk foot)
local wm = A.stem(c, { { 32, 24 }, { 32, 19 }, { 33, 16 }, { 35, 13 } }, function(t) return 1.3 - 0.35 * t end, WOOD, { cut = body })
c:put(35, 12, WOOD[3]) c:put(36, 12, WOOD[4])                  -- paler snapped end
local lm, LT, LS, lidx = A.leaf(c, 33, 18, 22, 10, 9, 13, 5.2, LEAF, { cut = wm:copy():add(body), vs = 3.0, fold = 0.4 })
-- leaf bends back: its far lobe's underside edge shows paler (velvety underside)
lm:edge():each(function(x, y) local k = K(x, y) if LS[k] and LS[k] < -0.7 and LT[k] > 0.3 and LT[k] < 0.85 then c:put(x, y, "#b4d48e") end end)

-- scales: dome-perturbed normals on a hex grid in (arc, y) space
local SU, SV = 5.2, 4.2
local n, groove, gdeep = {}, {}, {}
body:each(function(x, y) local k = K(x, y) local nn = n0[k]
  local u = 13 * asin(max(-1, min(1, nn[1]))) + CX
  local v = y + 0.5 * (nn[1] * nn[1]) * 3
  local row = floor(v / SV + 0.5)
  local best, sec, bdu, bdv = 1e9, 1e9, 0, 0
  for r = row - 1, row + 1 do
    local off = (r % 2) * SU / 2
    local col = floor((u - off) / SU + 0.5)
    for cc = col - 1, col + 1 do
      local ux, vy = cc * SU + off, r * SV
      local du, dv = (u - ux) / SU, (v - vy) / SV
      local d = du * du + dv * dv * 1.1
      if d < best then sec = best best, bdu, bdv = d, du, dv elseif d < sec then sec = d end
    end
  end
  local px, py = nn[1] + bdu * 0.9, nn[2] + bdv * 0.9
  n[k] = { A.norm(px, py, nn[3]) }
  if sec - best < 0.13 then groove[k] = true gdeep[k] = bdv > 0.05 end
end)
local bias = {}
for k in pairs(groove) do bias[k] = gdeep[k] and -2 or -1 end
X.ao(bias, body, c:rect(29, 20, 35, 21), 2, -1)                 -- AO under the calyx
local stok = { r = { name = "skin" } }
local idx = A.shade(c, body, n, SKIN, { amb = 0.08, wrap = 0.3, bias = bias, tok = stok })
-- cool reflected light lower-right, waxy bloom on the lit shoulder
local rim = X.rim(n0)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.7 and not groove[k] then c:put(x, y, "#4a7a72", stok) end end)
for _, q in ipairs{ { 23, 28, "#f2f6d2" }, { 24, 28, "#f2f6d2" }, { 23, 29, SKIN[6] }, { 25, 28, SKIN[6] }, { 22, 30, SKIN[6] } } do c:put(q[1], q[2], q[3], stok) end
-- calyx: small dark star where the stalk enters
for _, q in ipairs{ { 30, 22, 1 }, { 31, 22, 2 }, { 32, 22, 2 }, { 33, 22, 1 }, { 31, 23, 1 }, { 32, 23, 3 }, { 29, 22, 3 }, { 34, 23, 3 } } do
  c:put(q[1], q[2], q[3] == 3 and SKIN[2] or WOOD[q[3]], stok) end
-- dried blossom tip
local tipx = floor(CX + 1.6) for _, q in ipairs{ { tipx, YB, WOOD[1] }, { tipx + 1, YB, WOOD[2] }, { tipx, YB - 1, WOOD[2] } } do
  if body:has(q[1], q[2]) then c:put(q[1], q[2], q[3], stok) end end

-- quirk: ladybird on the leaf
local LB = { i = A.INK, h = "#ff8a6a", r = "#e2382f", s = "#a8233a", k = "#4a1c2a" }
local rows = { ".ii.", "hrrr", "rkrk", ".ss." }
for yy, row in ipairs(rows) do for xx = 1, 4 do local ch = row:sub(xx, xx)
  if LB[ch] then c:put(22 + xx - 1, 9 + yy - 1, LB[ch]) end end end
A.save(c, NAME)
