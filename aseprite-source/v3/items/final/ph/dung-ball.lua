-- dung-ball (final, Opus single pass). A round ball of packed dung with a slim dung beetle on the left, head down,
-- hind legs braced up on the ball (they push backwards). Ground shadow under the ball (it stands).
-- Material: per-pixel sphere light on a 6-tone earthy ramp, cool reflected light lower-right, packed lumps (hash
-- tone steps), fibrous straw bits lit by facing, AO where beetle touches. Beetle: glossy iridescent green-blue
-- elytra with a seam, bevelled pronotum, specular streak, 1 px legs with toothed fore tibiae, clypeus scoop.
-- quirk: a two-leaf seedling has sprouted from the top of the ball.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt, math.atan
local c = A.new("dung-ball")
local D  = { "#2a1b1f", "#4a2f27", "#6b4630", "#8c623d", "#ad814f", "#cba46c" }
local ST = { "#7c6236", "#a98a48", "#d2b66a", "#efdb98" }
local BE = { "#141a2c", "#1f3048", "#25505e", "#2f7a74", "#4fa88a", "#a6e0bc" }
local LEGC = "#3a2a3a"
local BOUNCE = "#7d5a6a"
local dtok, btok = { r = { name = "dung" } }, { r = { name = "beetle" } }

local CX, CY, R = 38, 33, 13.5
c:groundShadow(CX + 1, CY + R + 2, 13, 2)

-- ball: sphere normals, slightly lumpy silhouette
local m = HP.mask()
for y = floor(CY - R - 2), floor(CY + R + 2) do for x = floor(CX - R - 2), floor(CX + R + 2) do
  local dx, dy = x - CX, y - CY
  local a = atan(dy, dx)
  local rr = R + sin(a * 5 + 1) * 0.35 + sin(a * 9) * 0.25
  if dx * dx + dy * dy <= rr * rr then m:set(x, y) end
end end
local n = X.sphere(CX, CY, R, m)
-- lumpy bump field on normals
for k, v in pairs(n) do local x, y = k % 1024 - 256, k // 1024 - 256
  local h = X.hash(floor(x / 3), floor(y / 3), 11) - 0.5
  n[k] = { A.norm(v[1] + h * 0.35, v[2] + (X.hash(floor(x / 3), floor(y / 3), 12) - 0.5) * 0.35, v[3]) }
end
local bias = {}
-- beetle masks first (needed for AO), painted after
local bodyC = { 22.5, 40.5 } -- elytra centre
local bm, bn = A.oval(bodyC[1], bodyC[2], 5.6, 3.6, -0.75)
local pm, pn = A.oval(18.2, 45.6, 3.0, 2.6, -0.75)
local hm, hn = A.oval(15.6, 48.6, 2.0, 1.6, -0.75)
X.ao(bias, m, bm, 2, -1)
local idx = A.shade(c, m, n, D, { amb = 0.08, wrap = 0.2, bias = bias, tok = dtok })
-- texture: lumps (single pixel tone flecks)
m:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 5)
  if h < 0.07 then c:put(x, y, D[max(1, (idx[k] or 3) - 1)], dtok)
  elseif h > 0.95 and (idx[k] or 1) >= 3 then c:put(x, y, D[min(6, idx[k] + 1)], dtok) end
end)
-- straw fibres: short 2-3 px strokes in random directions, toned by light
local dirs = { { 1, 0 }, { 0, 1 }, { 1, 1 }, { 1, -1 } }
for i = 1, 26 do
  local x = floor(CX - R + X.hash(i, 1, 31) * 2 * R)
  local y = floor(CY - R + X.hash(i, 2, 31) * 2 * R)
  local d = dirs[floor(X.hash(i, 3, 31) * 4) + 1]
  local L = 2 + floor(X.hash(i, 4, 31) * 2)
  for j = 0, L - 1 do
    local px, py = x + d[1] * j, y + d[2] * j
    local k = K(px, py)
    if m:has(px, py) and not m:edge():has(px, py) and idx[k] then
      local t = idx[k] >= 5 and 4 or (idx[k] >= 3 and 3 or (idx[k] >= 2 and 2 or 1))
      c:put(px, py, ST[t], dtok)
    end
  end
end
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) local dx, dy = x - CX, y - CY
  if dx > 2 and dy > 2 and (rim[k] or 0) > 0.55 then c:put(x, y, BOUNCE, dtok) end end)
-- moist highlight: one 2x1 + cream
c:put(31, 24, D[6], dtok) c:put(32, 24, D[6], dtok) c:put(31, 25, "#f2dca8", dtok)

-- quirk: seedling on top
do
  local sx, sy = CX + 1, floor(CY - R) - 1
  local L = { "#2b5a3e", "#3f8a4c", "#73bd58", "#b4e07a" }
  local ltok = { r = { name = "sprout" } }
  for j = 0, 4 do c:put(sx, sy - j, j < 2 and L[2] or L[3], ltok) end
  A.map(c, { "abb.....cc", "abbb...ccd", ".bbbb.cccd", "...bb.cc.." }, sx - 5, sy - 8, { a = L[4], b = L[3], c = L[3], d = L[2] }, ltok)
  -- midribs
  c:put(sx - 3, sy - 6, L[2], ltok) c:put(sx - 2, sy - 5, L[2], ltok)
  c:put(sx + 2, sy - 6, L[1], ltok) c:put(sx + 3, sy - 7, L[1], ltok)
  -- soil crumb at the base
  c:put(sx - 1, sy + 1, D[2], dtok) c:put(sx + 1, sy + 1, D[2], dtok)
end

-- beetle legs (behind body): hind legs braced up onto the ball, middle legs down to ground, fore legs digging
local function seg(x0, y0, x1, y1, col)
  local N = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, N do local t = N == 0 and 0 or i / N
    c:put(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5), col, btok) end
end
-- hind legs: femur up-right, tibia along the ball surface
seg(26, 37, 27, 32, LEGC) seg(27, 32, 26, 28, LEGC)
seg(27, 40, 30, 38, LEGC) seg(30, 38, 31, 35, LEGC)
-- middle legs to ground
seg(21, 43, 21, 48, LEGC) seg(21, 48, 23, 50, LEGC)
seg(24, 42, 26, 46, LEGC) seg(26, 46, 27, 49, LEGC)
-- fore legs (toothed)
seg(17, 47, 14, 51, LEGC) c:put(13, 51, LEGC, btok) c:put(15, 51, LEGC, btok)
seg(19, 47, 19, 51, LEGC) c:put(20, 51, LEGC, btok)

-- elytra, pronotum, head
local bb = {}
X.ao(bb, bm, pm, 1, -1)
local bi = A.shade(c, bm, bn, BE, { amb = 0.06, wrap = 0.1, bias = bb, tok = btok })
local pi_ = A.shade(c, pm, pn, BE, { amb = 0.06, wrap = 0.1, tok = btok })
local hi = A.shade(c, hm, hn, BE, { amb = 0.04, wrap = 0.05, bias = (function() local t = {} hm:each(function(x, y) t[K(x, y)] = -1 end) return t end)(), tok = btok })
-- dark seam between pronotum and elytra
bm:each(function(x, y) if pm:grow(1):has(x, y) and not pm:has(x, y) then c:put(x, y, BE[1], btok) end end)
pm:each(function(x, y) if hm:grow(1):has(x, y) and not hm:has(x, y) then c:put(x, y, BE[1], btok) end end)
-- elytral suture along the body axis (from pronotum toward rear-up-right)
for i = 0, 5 do local x, y = floor(20.5 + i * 0.75 + .5), floor(43.2 - i * 0.62 + .5) if bm:has(x, y) then c:put(x, y, BE[2], btok) end end
-- striae: faint lit ridge lines on the lit half
for i = 0, 4 do local x, y = floor(20.5 + i * 0.8 + .5), floor(41.0 - i * 0.65 + .5) if bm:has(x, y) then c:put(x, y, BE[5], btok) end end
-- specular streak + glint
c:put(21, 39, BE[6], btok) c:put(22, 38, BE[6], btok) c:put(21, 38, "#eafff2", btok)
c:put(17, 44, BE[6], btok)
-- clypeus scoop teeth on the head front
c:put(13, 49, BE[3], btok) c:put(13, 50, BE[2], btok)
-- antenna club
c:put(15, 46, LEGC, btok) c:put(14, 45, BE[4], btok)
A.save(c, "dung-ball")
