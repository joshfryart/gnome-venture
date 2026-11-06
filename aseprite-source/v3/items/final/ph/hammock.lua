-- hammock (final pass, Opus aC10_5). Two slim turned posts (grain, pale end-grain caps) with a canvas hammock slung
-- between them on twisted rope: rope wraps the posts, three strands fan from an iron ring into each end of the cloth.
-- Cloth: deep sag shaded per pixel as a hanging sling, red/cream/teal stripes following the curve, diagonal weave,
-- gold stitched hem along the near edge, short tassel fringe underneath, AO where cloth gathers.
-- quirk: an open book lies face-down in the hammock, someone's reading paused.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new("hammock")

local WOOD = { "#4e2a26", "#7a4330", "#a5653e", "#c88a52", "#e2b273", "#f4d79e" }
local ROPE = { "#8a5a34", "#c8955a", "#ecd09a" }
local RED  = { "#5e1f34", "#9a2c3c", "#c8403e", "#e8603e", "#ff8a5c", "#ffb48a" }
local CRM  = { "#7a6a72", "#a8949a", "#cdbcb4", "#e6d8c4", "#f6ecd6", "#fff6e2" }
local TEAL = { "#1f3f5c", "#2a5f7e", "#3a86a0", "#4fb0b4", "#7fd2c8", "#b6f0e0" }
local IRON = { "#2f2f44", "#585a74", "#9a9cb2" }

c:groundShadow(32, 52, 26, 2)
-- posts
local tokW = A.tok("wood")
local function post(xl)
  local m = HP.rect(xl, 13, xl + 3, 51)
  local n = {}
  m:each(function(x, y) local t = ((x - xl) / 3) * 2 - 1 t = max(-0.95, min(0.95, t)) n[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
  local bias = {}
  m:each(function(x, y) if y >= 50 then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, WOOD, { amb = 0.12, wrap = 0.3, bias = bias, tok = tokW })
  -- grain
  m:each(function(x, y) if (x - xl) == 1 + (floor(y / 7) % 2) and (y % 7) < 4 and y > 16 then A.step(c, idx, WOOD, x, y, -1, tokW) end end)
  -- end grain cap (pale) + bevel row
  for x = xl, xl + 3 do c:put(x, 13, x == xl + 3 and WOOD[5] or WOOD[6], tokW) c:put(x, 14, WOOD[3], tokW) end
  c:put(xl + 1, 13, WOOD[5], tokW)
  return m, idx
end
local pL, iL = post(8)
local pR, iR = post(52)

-- rope wraps on the posts (3 turns, twist pattern), AO row under
local tokR = A.tok("rope")
for _, xl in ipairs{ 8, 52 } do
  for y = 18, 20 do for x = xl - 1, xl + 4 do
    local p = (x + y) % 3
    c:put(x, y, p == 0 and ROPE[3] or (p == 1 and ROPE[2] or ROPE[1]), tokR)
  end end
  for x = xl, xl + 3 do c:put(x, 21, WOOD[1], tokW) end
end
-- iron rings
local tokI = A.tok("iron")
local function ring(cx, cy)
  for _, p in ipairs{ { -1, -1, 2 }, { 0, -1, 3 }, { 1, 0, 2 }, { 0, 1, 1 }, { -1, 1, 1 }, { -2, 0, 3 }, { 1, -1, 2 }, { -2, -1, 3 }, { -1, 2, 1 }, { 0, 2, 1 }, { 1, 1, 1 } } do
    c:put(cx + p[1], cy + p[2], IRON[p[3]], tokI)
  end
end
-- ropes post -> ring -> cloth (strands fan out)
A.rope(c, { { 12, 19 }, { 16, 22 } }, 1, ROPE, tokR)
A.rope(c, { { 51, 19 }, { 47, 22 } }, 1, ROPE, tokR)
ring(17, 23) ring(47, 23)
for _, e in ipairs{ { 18, 24, 21, 23 }, { 18, 24, 21, 26 }, { 17, 25, 21, 29 } } do A.rope(c, { { e[1], e[2] }, { e[3], e[4] } }, 1, ROPE, tokR) end
for _, e in ipairs{ { 46, 24, 43, 23 }, { 46, 24, 43, 26 }, { 47, 25, 43, 29 } } do A.rope(c, { { e[1], e[2] }, { e[3], e[4] } }, 1, ROPE, tokR) end

-- cloth: between x 21..43; near (top) edge and underside curves
local CX0, CX1 = 21, 43
local function topE(x) local f = (x - CX0) / (CX1 - CX0) return 22.5 + 12 * sin(pi * f) ^ 1.1 end
local function botE(x) local f = (x - CX0) / (CX1 - CX0) return 29.5 + 13.5 * sin(pi * f) ^ 0.9 end
local cloth = A.maskF(CX0, 20, CX1, 48, function(x, y) return y >= topE(x) and y <= botE(x) end)
local n, V, bias = {}, {}, {}
cloth:each(function(x, y) local k = K(x, y)
  local a, b = topE(x), botE(x)
  local v = (y - a) / max(1, b - a)                 -- 0 near edge .. 1 underside
  V[k] = v
  local f = (x - CX0) / (CX1 - CX0)
  local nx = (f - 0.5) * -0.9                       -- sag: ends tilt toward centre
  local ny = -0.7 + v * 1.5                         -- near edge faces up, underside faces down
  n[k] = { A.norm(nx, ny, 0.8) }
  if f < 0.12 or f > 0.88 then bias[k] = -1 end    -- gathered ends in shadow
end)
local tokC = A.tok("cloth")
local Lv = X.light(n, { amb = 0.12, wrap = 0.35 })
local idx = {}
cloth:each(function(x, y) local k = K(x, y)
  local val = Lv[k]
  local i = 1 for j, t in ipairs(A.CUTS) do if val >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  -- stripes follow the curve
  local s = V[k] * 7
  local band = floor(s)
  local R = (band == 1 or band == 5) and TEAL or ((band == 3) and RED or CRM)
  if band == 0 then R = RED end
  -- diagonal weave texture
  if (x + y * 2) % 4 == 0 and i > 1 then i = i - 1 end
  idx[k] = i
  c:put(x, y, R[i], tokC)
end)
-- gold stitch along the near hem
local hem = {}
for x = CX0 + 2, CX1 - 2 do hem[#hem + 1] = { x, floor(topE(x) + 1.5) } end
c:stitch(hem)
-- tassel fringe under the sling
local tokF = A.tok("fringe")
for x = CX0 + 3, CX1 - 3, 3 do local yb = floor(botE(x)) + 1
  local L = 2 + (x % 2)
  for d = 0, L - 1 do c:put(x, yb + d, d == L - 1 and RED[3] or ROPE[2], tokF) end
end

-- quirk: open book face-down (tented) in the sag
local tokB = A.tok("book")
A.map(c, {
  "....ac....",
  "...abBc...",
  "..abBBBc..",
  ".abBBBBBc.",
  "dppppppppd",
}, 27, 30, { a = "#5e459e", b = "#8a6fd0", B = "#a98ae0", c = "#35295f", p = "#f6ecd6", d = "#cdbcb4" }, tokB)
c:put(30, 32, "#c9b2f0", tokB) c:put(29, 33, "#c9b2f0", tokB)
-- one cream glint on the lit post cap
c:put(9, 13, A.CREAM, tokW)
A.save(c, "hammock")
