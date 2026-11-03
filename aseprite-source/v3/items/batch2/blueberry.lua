-- blueberry (batch2, Opus single pass). Slim sprig: a thin red-brown twig arching across the top with a pale cut
-- end, two elliptic blueberry leaves (V-fold, midrib, angled veins, red-tinged margin near the tip, cool bounce),
-- and four berries hanging on hair-thin pedicels with 1-2 px of air between them. Berries: per-pixel sphere light
-- on a 6-tone indigo ramp, powdery dusty bloom on the lit half, a 5-sepal crown cup facing the viewer, one soft
-- specular + glint, cool reflected light lower-right, a dark dimple where each pedicel meets the berry.
-- History: Sonnet draft (fat 5-berry clump, low-left) replaced.
-- quirk: one small berry on the end is still blushing pink, not ripe yet.
local NAME = "blueberry"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local BLU   = { "#1a1640", "#29286a", "#373f92", "#4c58b2", "#6d7fcc", "#9cb0e4" }
local BLOOM = { [3] = "#55609e", [4] = "#6c78b8", [5] = "#8e9bd0", [6] = "#b7c3e6" }  -- dusty, greyer twin per tone
local PINK  = { "#3d1b3c", "#66284f", "#923d67", "#b95c7c", "#d98a92", "#f2bdb0" }
local PBLOOM = { [4] = "#c27a8e", [5] = "#dca0a4" }
local LEAF  = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local TW    = { "#3e2228", "#5e2f2e", "#844236", "#a85e44", "#c98a5e" }
local VEIN, COOL, RED = "#bfe28a", "#3c6f74", "#a8443e"
local SPEC, BOUNCE, PBOUNCE = "#f4f2ff", "#4a76b8", "#a0739a"

-- leaves -----------------------------------------------------------------------------------------
local function leaf(ax, ay, cx, cy, bx, by, w, veins, redtip)
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.94 + 0.06)
    return max(0.45, w * sin(pi * u ^ 1.15) ^ 0.75)
  end, { fold = 0.45 })
  local tok = { r = { name = "leaf" .. ax } }
  G.toneN(c, m, n, LEAF, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.13 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], tok) return end
    for _, vt in ipairs(veins) do
      local d = t * len - (vt + abs(s) * 4.2)
      if d > -0.5 and d < 0.5 and abs(s) > 0.22 and abs(s) < 0.72 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], tok) return end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y)
    if S[k] > 0.55 and T[k] > 0.12 and T[k] < 0.85 then c:put(x, y, COOL, tok) end
    if redtip and T[k] > 0.8 then c:put(x, y, RED, tok) end
  end)
  return m
end
local lA = leaf(36, 11, 44, 2, 55, 4, 4.4, { 4, 8, 12, 16 }, true)
local lB = leaf(22, 10, 18, 3, 11, 2, 3.2, { 3.5, 7 }, false)

-- twig -------------------------------------------------------------------------------------------
local tw, tn, TT, TS = G.tube({ {6, 15}, {14, 8}, {30, 7}, {45, 14} }, function(t) return 1.5 - 0.6 * t end)
local bias = {}
X.ao(bias, tw, lA, 1, -1)
G.toneN(c, tw, tn, TW, { tok = { r = { name = "twig" } }, cuts = { 0.3, 0.5, 0.68, 0.84 }, bias = bias })
-- cut end: pale wood with a darker ring
for _, p in ipairs{ {5, 15, "#e8c28e"}, {6, 14, "#e8c28e"}, {6, 15, "#c98a5e"}, {5, 16, "#a85e44"}, {6, 16, "#a85e44"}, {7, 14, "#c98a5e"} } do
  if tw:has(p[1], p[2]) or p[1] <= 6 then c:put(p[1], p[2], p[3]) end
end
-- leaf scars / nodes: tiny lit bumps on the upper edge
c:put(15, 8, TW[5]) c:put(27, 6, TW[5]) c:put(27, 7, TW[4])

-- berries ----------------------------------------------------------------------------------------
-- cx, cy, r, pedicel start (on twig), ramp, crown offset
local berries = {   -- cx, cy, r, pedicel start, ramp, crown offset, pedicel bend
  { 17, 27, 6.6, { 14, 10 }, BLU,  { 1, 1 }, -3 },
  { 32, 25, 7.0, { 31, 8 },  BLU,  { 1, 1 }, 3 },
  { 24, 41, 7.0, { 22, 8 },  BLU,  { 1, 2 }, 1 },
  { 39, 40, 5.0, { 41, 12 }, PINK, { 0, 1 }, 3 },
}
-- pedicels first (behind), 1 px, red-green with a lit upper part
for _, b in ipairs(berries) do
  local sx, sy = b[4][1], b[4][2]
  local tx, ty = b[1], floor(b[2] - b[3])
  local pts = {}
  for j = 0, 10 do local t = j / 10
    local x, y = G.bez({ { sx, sy }, { sx + b[7], sy + (ty - sy) * 0.35 }, { tx + b[7] * 0.4, ty - 3 }, { tx, ty + 1 } }, t)
    pts[#pts + 1] = { floor(x + .5), floor(y + .5) } end
  local ln = c:line(pts, 1)
  ln:each(function(x, y) if not tw:has(x, y) then c:put(x, y, (y - sy) < (ty - sy) * 0.55 and "#94503c" or "#7a8a48", { r = { name = "ped" } }) end end)
end
for i, b in ipairs(berries) do
  local cx, cy, r, R = b[1], b[2], b[3], b[5]
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - 0.3, cy - 0.3, r, m)
  local tok = { r = { name = "berry" .. i } }
  local bb = {}
  local idx = X.tone(c, m, X.light(n, { amb = 0.05, wrap = 0.22 }), R, { cuts = { 0.2, 0.37, 0.53, 0.68, 0.83 }, tok = tok, bias = bb })
  -- powdery bloom: the lit half goes dusty in patches (bigger patches than single specks)
  local BL = R == BLU and BLOOM or PBLOOM
  m:each(function(x, y) local k = K(x, y) local i2 = idx[k]
    local h = X.hash(floor(x / 2), floor(y / 2), i * 7) * 0.6 + X.hash(x, y, i) * 0.4
    if BL[i2] and i2 >= 4 and (x - cx) + (y - cy) < 3 and h > 0.5 then c:put(x, y, BL[i2], tok) end
  end)
  -- cool reflected light on the lower-right rim
  local rim = X.rim(n)
  m:edge():each(function(x, y) if rim[K(x, y)] > 0.62 then c:put(x, y, R == BLU and BOUNCE or PBOUNCE, tok) end end)
  -- crown: 5-sepal cup facing the viewer, lower-right of centre
  local ox, oy = floor(cx + b[6][1]), floor(cy + b[6][2])
  if r >= 6 then
    -- star-shaped cup: deep centre, 5 sepals radiating, each sepal lit on its upper-left face
    local star = {
      ".l...l.",
      "..sSs..",
      "lsdddS.",
      "..ddd..",
      ".sS.Ss.",
      ".l...l." }
    for yy, row in ipairs(star) do for xx = 1, #row do local ch = row:sub(xx, xx)
      local x, y = ox + xx - 4, oy + yy - 3
      if ch == "d" then c:put(x, y, R[1], tok) elseif ch == "S" then c:put(x, y, R[2], tok)
      elseif ch == "s" then c:put(x, y, R[3], tok) elseif ch == "l" then c:put(x, y, R[6], tok) end
    end end
  else
    for _, p in ipairs{ {0,0}, {1,0}, {0,1} } do c:put(ox + p[1], oy + p[2], R[1], tok) end
    for _, p in ipairs{ {-1,-1}, {2,-1}, {1,1}, {-1,1} } do c:put(ox + p[1], oy + p[2], R[5], tok) end
    c:put(ox + 1, oy + 1, R[2], tok)
  end
  -- stem dimple at the top where the pedicel meets
  local dx, dy = cx, floor(cy - r) + 1
  c:put(dx, dy, R[1], tok) c:put(dx - 1, dy, R[2], tok) c:put(dx + 1, dy, R[2], tok)
  -- specular: soft 2x1 + a single glint
  local sx, sy = floor(cx - r * 0.45 + .5), floor(cy - r * 0.42 + .5)
  c:put(sx, sy, SPEC, tok) c:put(sx + 1, sy, R[6], tok)
  if r >= 6 then c:put(sx - 1, sy + 1, R[6], tok) end
end
G.save(c, NAME)
