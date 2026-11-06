-- plum (final pass, Opus, aC35_2). A round European plum, slightly taller than wide: deep violet skin lit per pixel,
-- a suture groove curving down the front (lit lip + dark crease), a frosty waxy bloom in soft patches over the lit
-- half, one hard specular, cool blue reflected light on the lower-right rim, a dark stem cavity, a slim woody stem
-- and one serrated plum leaf with midrib and veins, AO where stem and leaf meet the fruit.
-- quirk: a fingertip has wiped a clean oval through the bloom, showing glossy dark skin with its own tiny glint.
local NAME = "plum"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local PL = { "#22163a", "#36225e", "#512f88", "#6c43ae", "#8c62cc", "#b896e6" }
local BL = { "#3a2a6a", "#4a3884", "#6450a6", "#7e6cc0", "#a090da", "#c4b6ee" }   -- bloom over each tone
local GLOSS = { "#1c1232", "#2c1a50", "#3f2472", "#55329a" }
local COOL = { "#3a5aa0", "#4a76b8" }
local WOOD = { "#2e1e1c", "#4a2e24", "#6c4430", "#8e6040", "#b08058", "#d0a47a" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }

local cx, cy = 31, 38
local fm = HP.mask()
for y = 20, 56 do for x = 12, 52 do
  local dx, dy = (x - cx) / 14.6, (y - cy) / (y < cy and 15.2 or 14.4)
  -- shallow dip at the top where the stem sits
  local dip = (y < cy) and 0.10 * max(0, 1 - abs(x - cx - 1) / 5) or 0
  if dx * dx + dy * dy <= 1 - dip * 1.6 then fm:set(x, y) end
end end
local n = {}
local np = X.pillow(fm, 6)
fm:each(function(x, y) local k = K(x, y)
  local nx, ny = (x - cx) / 15.2, (y - cy) / 15.4
  local q = nx * nx + ny * ny
  local sx, sy, sz = nx, ny, sqrt(max(0.02, 1 - q))
  -- suture groove: a crease along a curve, normals tilt across it
  local scx = cx + 6 + 3 * sin((y - 22) / 34 * pi) - (y - 22) * 0.12
  local d = x - scx
  if abs(d) < 3 and y > 23 and y < 52 then sx = sx - 0.35 * (d / 3) * (1 - abs(d) / 3) * 3 end
  local a = np[k]
  n[k] = { A.norm(sx * 0.75 + a[1] * 0.25, sy * 0.75 + a[2] * 0.25, sz * 0.75 + a[3] * 0.25) }
end)
local bias = {}
-- stem cavity AO
fm:each(function(x, y) if y < 25 and abs(x - cx - 1) <= 2 and y <= 22 + (2 - abs(x - cx - 1)) then bias[K(x, y)] = -2 end end)
local ftok = { r = { name = "fruit" } }
local idx, v = A.shade(c, fm, n, PL, { tok = ftok, amb = 0.05, wrap = 0.2, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, bias = bias })
-- suture crease line + lit lip on its left
for y = 24, 51 do
  local scx = floor(cx + 6 + 3 * sin((y - 22) / 34 * pi) - (y - 22) * 0.12 + 0.5)
  if fm:has(scx, y) then c:put(scx, y, PL[max(1, idx[K(scx, y)] - 2)], ftok) idx[K(scx, y)] = max(1, idx[K(scx, y)] - 2) end
  if fm:has(scx - 1, y) and y > 26 and y < 48 then local k = K(scx - 1, y) idx[k] = min(6, idx[k] + 1) c:put(scx - 1, y, PL[idx[k]], ftok) end
end
-- cool reflected light lower right
local rim = X.rim(n)
fm:each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and idx[k] <= 2 and not bias[k] then c:put(x, y, rim[k] > 0.75 and COOL[2] or COOL[1], ftok) end end)
-- waxy bloom: soft frosty patches over the lit half (coarse blobs, no dither)
local wipe = function(x, y) local dx, dy = (x - 23.5) / 3.6, (y - 42) / 2.4 return dx * dx + dy * dy <= 1 end
fm:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if i < 3 or bias[k] then return end
  local hb = X.hash(x // 3, y // 3, 11) + X.hash((x + 1) // 2, (y + 1) // 2, 5) * 0.5
  local lit = (x - cx) * 0.6 + (y - cy) < 6
  if lit and hb > 0.95 and not wipe(x, y) then c:put(x, y, BL[i], ftok) end
end)
-- quirk: wiped oval, glossy, with a tiny glint
fm:each(function(x, y) if wipe(x, y) then local k = K(x, y)
  local i = max(1, min(4, idx[k] - 1)) c:put(x, y, GLOSS[i], ftok) end end)
for _, p in ipairs{ { 21, 41, GLOSS[4] }, { 22, 40, GLOSS[4] }, { 23, 40, "#8a6ad0" }, { 22, 41, "#c4b0f0" } } do c:put(p[1], p[2], p[3], ftok) end
-- main specular (upper-left), plus sparkle
for _, p in ipairs{ { 21, 28, "#f4ecff" }, { 22, 28, "#f4ecff" }, { 21, 29, "#d8c8f8" }, { 20, 30, "#c0aaf0" }, { 23, 27, "#d8c8f8" } } do c:put(p[1], p[2], p[3], ftok) end

-- stem: slim woody shaft out of the cavity, slight lean
local stok = { r = { name = "stem" } }
local sm, sn, STT, SSS = A.tube({ { 32, 24 }, { 32, 19 }, { 33, 15 }, { 35, 11 } }, function(t) return 0.95 + 0.25 * (1 - t) end)
local sbias = {}
sm:each(function(x, y) if y >= 22 then sbias[K(x, y)] = -1 end end)
local sidx = A.shade(c, sm, sn, WOOD, { tok = stok, amb = 0.12, wrap = 0.3, bias = sbias })
-- bark knot ring + pale cut tip
sm:each(function(x, y) local k = K(x, y) if abs(STT[k] - 0.55) < 0.04 then c:put(x, y, WOOD[2], stok) end end)
c:put(35, 10, WOOD[6], stok) c:put(36, 10, WOOD[5], stok)

-- leaf: serrated elliptic plum leaf off the stem to the right
local ltok = { r = { name = "leaf" } }
local lbias = {}
local lm0 = A.leaf(c, 35, 15, 43, 8, 53, 13, 4.3, LEAF, { tok = ltok, serr = 2.6, vs = 3.0, pw = 0.7, cut = sm, bias = lbias })
-- petiole
for _, p in ipairs{ { 34, 15 }, { 35, 15 } } do c:put(p[1], p[2], LEAF[3], ltok) end
-- contact shadow of the leaf onto the fruit (leaf sits above, fruit top shading)
A.save(c, NAME)
