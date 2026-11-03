-- ico-butterfly (final, Opus). Front-on swallowtail with wings spread: two broad forewings, two rounder hindwings with
-- slim swallow tails, a slim segmented body, a round head with a smile and clubbed antennae.
-- Material: wing membrane = pillow normals with a gentle fold (6-tone sea-teal), dark radiating veins, a dusk velvet
-- border band with cream lunule spots, an ember eyespot on each hindwing, AO where forewing laps over hindwing and where
-- the wings join the body; body = cylinder light (6-tone dusk) with segment rings and a fuzzy lit thorax.
-- quirk: something has nibbled a neat bite out of the right hindwing.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("ico-butterfly")
local WING = { "#1f3d66", "#285a8a", "#3582ad", "#4fb0c4", "#84d6d2", "#c4f2e4" }
local BORD = { "#1e1838", "#2e2654", "#43397a", "#5e52a0" }
local BODY = { "#1c1530", "#2c2148", "#3f3068", "#58468e", "#7a66b4", "#a896dc" }
local EYE  = { "#8e2238", "#e8533a", "#ffa04a" }
local SPOT = "#fff0c4"

local AX = 31.5
local function mirror(m) local n = HP.mask() m:each(function(x, y) n:set(63 - x, y) end) return n end
local function elli(cx, cy, rx, ry, ang)
  local m = HP.mask() local ca, sa = cos(ang), sin(ang)
  for y = floor(cy - 16), floor(cy + 16) do for x = floor(cx - 16), floor(cx + 16) do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u, v = (dx * ca + dy * sa) / rx, (-dx * sa + dy * ca) / ry
    if u * u + v * v <= 1 then m:set(x, y) end
  end end
  return m
end
-- left wings (right = mirror): forewing points up-left to a rounded apex, hindwing rounder with a swallow tail
local function close(m) return m:grow(1):shrink(1) end
local foreL = close(HP.poly{ { 31, 23 }, { 28, 18 }, { 22, 12 }, { 15, 8.5 }, { 9, 8 }, { 6, 10.5 }, { 5.5, 15 }, { 7.5, 21 },
  { 12, 25.5 }, { 19, 28 }, { 26, 28.5 }, { 31, 28 } })
local hindL = close(HP.poly{ { 31, 28 }, { 24, 28 }, { 17, 30 }, { 12.5, 34 }, { 12, 39 }, { 15, 43 }, { 20, 45 }, { 25, 43.5 },
  { 29, 40 }, { 31, 36 } })
hindL:add(HP.line({ { 19, 43 }, { 17, 47 }, { 16, 51 } }, 3))  -- swallow tail
hindL:add(A.ell(16, 51, 1.6, 1.4))
local foreR, hindR = mirror(foreL), mirror(hindL)
-- quirk: bite out of the right hindwing outer edge
hindR:cut(A.ell(52.5, 37.5, 2.8, 2.6))

local body = HP.rrect(30, 20, 33, 46, 2)
local function wing(m, root, isFore, tok, over, veins)
  local n, d = X.pillow(m, 2.2)
  -- gentle fold: tilt normals away from the root
  m:each(function(x, y) local k = K(x, y) local dx, dy = x - root[1], y - root[2]
    local l = sqrt(dx * dx + dy * dy) + 0.01
    n[k] = { A.norm(n[k][1] + dx / l * 0.22, n[k][2] + dy / l * 0.22, n[k][3]) } end)
  local bias = {}
  X.ao(bias, m, body, 2, -1)
  if over then A.cast(bias, m, over, 1, 1, -1) X.ao(bias, m, over, 1, -1) end
  local v = X.light(n, { amb = 0.12, wrap = 0.3 })
  local idx = X.tone(c, m, v, WING, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = tok })
  -- veins: rays from the root to the outer edge, dark, stopping at the border band
  for _, tg in ipairs(veins) do
    local n2 = 40
    for i = 0, n2 do local t = i / n2
      local x, y = floor(root[1] + (tg[1] - root[1]) * t + 0.5), floor(root[2] + (tg[2] - root[2]) * t + 0.5)
      local k = K(x, y)
      if m:has(x, y) and d[k] > 2.2 and t > 0.18 then
        if (idx[k] or 0) > 2 then idx[k] = idx[k] - 2 c:put(x, y, WING[idx[k]], tok) end
      end
    end
  end
  -- velvet border with cream lunules
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x + 0.5 - root[1], y + 0.5 - root[2]
    local r = sqrt(dx * dx + dy * dy)
    if d[k] < 2.1 and r > 6.5 then
      local t = max(1, min(4, (idx[k] or 3) - 1))
      c:put(x, y, BORD[t], tok)
    end
  end)
  return idx, d
end
local tokHL, tokHR, tokFL, tokFR = A.tok("hindL"), A.tok("hindR"), A.tok("foreL"), A.tok("foreR")
local VF = { { 9, 9 }, { 6, 13 }, { 6.5, 18 }, { 10, 23.5 }, { 16, 27 }, { 15, 9 } }
local VH = { { 13, 34 }, { 13, 40 }, { 18, 44.5 }, { 24, 44 } }
local function mv(v) local o = {} for i, p in ipairs(v) do o[i] = { 63 - p[1], p[2] } end return o end
local _, dHL = wing(hindL, { 30, 29 }, false, tokHL, foreL, VH)
local _, dHR = wing(hindR, { 33, 29 }, false, tokHR, foreR, mv(VH))
local _, dFL = wing(foreL, { 30, 23 }, true, tokFL, nil, VF)
local _, dFR = wing(foreR, { 33, 23 }, true, tokFR, nil, mv(VF))
-- cream lunule spots along the outer border, one per angular step
local function lunules(m, d, root, tok, col, step, rmin)
  local bins = {}
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x + 0.5 - root[1], y + 0.5 - root[2]
    local r = sqrt(dx * dx + dy * dy)
    if d[k] >= 0.9 and d[k] < 1.6 and r > rmin and m:has(x + 1, y) and d[K(x + 1, y)] and d[K(x + 1, y)] < 2.1 then
      local b = floor((atan(dy, dx) + pi) / step)
      if not bins[b] or r > bins[b][3] then bins[b] = { x, y, r } end
    end
  end)
  for b, p in pairs(bins) do if b % 2 == 0 then c:put(p[1], p[2], col, tok) c:put(p[1] + 1, p[2], col, tok) end end
end
lunules(foreL, dFL, { 30, 23 }, tokFL, SPOT, 0.2, 13)
lunules(foreR, dFR, { 33, 23 }, tokFR, "#e2d2b0", 0.2, 13)
lunules(hindL, dHL, { 30, 29 }, tokHL, SPOT, 0.3, 11)
lunules(hindR, dHR, { 33, 29 }, tokHR, "#e2d2b0", 0.3, 11)
-- ember eyespots on the hindwings near the tails
local function eyespot(x, y, tok, lit)
  A.map(c, { ".oo.", "oRRo", "oRKo", ".oo." }, x, y, { o = EYE[1], R = lit and EYE[3] or EYE[2], K = A.INK }, tok)
end
eyespot(17, 36, tokHL, true) eyespot(43, 36, tokHR, false)

-- body: cylinder light + segment rings
local btok = A.tok("body")
local bn = {}
body:each(function(x, y) local u = (x - 31.5) / 2.5 bn[K(x, y)] = { A.norm(u, 0, sqrt(max(0.05, 1 - u * u))) } end)
local bb = {}
body:each(function(x, y) if y > 46 then bb[K(x, y)] = -1 end end)
local bidx = A.shade(c, body, bn, BODY, { tok = btok, bias = bb, amb = 0.1, wrap = 0.3 })
for _, y in ipairs{ 31, 34, 37, 40, 43 } do for x = 30, 33 do A.step(c, bidx, BODY, x, y, -2, btok) end end
-- fuzzy thorax highlight
c:put(31, 22, BODY[6], btok) c:put(30, 24, BODY[5], btok) c:put(31, 26, BODY[6], btok)

-- head with eyes and a smile
local head = A.ell(31.5, 16, 4, 3.6)
local htok = A.tok("head")
local hn = X.sphere(31.5, 16, 4, head)
local hb = {} head:each(function(x, y) hb[K(x, y)] = 1 end)
A.shade(c, head, hn, BODY, { tok = htok, amb = 0.4, wrap = 0.4, bias = hb })
c:eyeSmall(29, 14) c:eyeSmall(33, 14)
c:put(31, 18, BODY[1]) c:put(32, 18, BODY[1]) c:put(30, 17, BODY[2]) c:put(33, 17, BODY[2])
-- antennae with clubbed tips
local atok = A.tok("ant")
for _, s in ipairs{ -1, 1 } do
  local pts = {}
  for i = 0, 8 do local t = i / 8 pts[#pts + 1] = { floor(31.5 + s * (1.5 + t * 6.5 + t * t * 1.0) + 0.5) - (s < 0 and 1 or 0), floor(12 - t * 5 + 0.5) } end
  for _, p in ipairs(pts) do c:put(p[1], p[2], BODY[2], atok) end
  local tx, ty = pts[#pts][1], pts[#pts][2]
  A.map(c, { "KL", "KK" }, tx + (s < 0 and -1 or 0), ty - 1, { K = BODY[3], L = BODY[6] }, atok)
end
A.save(c, "ico-butterfly")
