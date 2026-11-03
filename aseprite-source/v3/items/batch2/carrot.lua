-- carrot (batch2, Opus single pass). Slim, gently curved tap root lying on the diagonal (crown upper-right, tip
-- lower-left), rounded shoulder tapering to a fine point; three thin feathery fronds of lobed pinnae fanning up.
-- Material: per-pixel cylinder light (6-tone orange, cool-violet shade), raised growth rings (dark groove + lit lip),
-- two lenticel nubs on the edge, waxy specular streak on the shoulder, cool reflected light lower-right, AO + a dark
-- sunken crown where the stalks meet. Fronds: 2-tone stalks, 6-tone lobed pinnae with a dark base where they join.
-- quirk: a ladybird is out for a walk on the right frond.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2("carrot")
local OR   = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STALK = { "#2e6a44", "#5b9a52", "#8cc066" }
local SPEC, BOUNCE = "#fff1cf", "#b04a5c"

-- fronds first (root painted over them where they meet)
local CX, CY = 40, 25
local ltok = { r = { name = "leaf" } }
local function frond(p, pinnae)
  -- pinnae: list of {t, side(+1/-1), len}
  local pm = HP.mask()
  local base = {}
  for _, q in ipairs(pinnae) do
    local t, side, L = q[1], q[2], q[3]
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.01))
    local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local ux, uy = G.rot(tx, ty, side * 0.95)
    local nl = max(1, floor(L / 2.2 + 0.5))
    for i = 1, nl do
      local f = i / nl
      local r = 1.75 - f * 0.45
      pm:add(G.rell(x + ux * (L * f - 0.6), y + uy * (L * f - 0.6), ux, uy, r + 0.35, r - 0.2))
    end
    base[#base + 1] = { floor(x + ux * 1.2 + .5), floor(y + uy * 1.2 + .5) }
  end
  -- terminal leaflet
  local ex, ey = G.bez(p, 1)
  local x1, y1 = G.bez(p, 0.96)
  local ux, uy = ex - x1, ey - y1 local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  pm:add(G.rell(ex + ux * 0.6, ey + uy * 0.6, ux, uy, 2.4, 1.3))
  local n = X.pillow(pm, 1.6)
  G.toneN(c, pm, n, LEAF, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.25 })
  for _, b in ipairs(base) do if pm:has(b[1], b[2]) then c:put(b[1], b[2], LEAF[2], ltok) end end
  -- stalk: 1 px, lit pixel + shade pixel beside it near the base
  local sm = c:line({ { floor(p[1][1]), floor(p[1][2]) } }, 1)
  for i = 0, 60 do
    local t = i / 60
    local x, y = G.bez(p, t)
    local xi, yi = floor(x + .5), floor(y + .5)
    c:put(xi, yi, t < 0.15 and STALK[2] or STALK[3], ltok)
    if t < 0.45 then c:put(xi + 1, yi, STALK[1], ltok) end
  end
  return pm
end
local fl = frond({ { CX - 1, CY }, { 35, 17 }, { 28, 13 }, { 18, 11 } },
  { {0.38, 1, 4.4}, {0.46, -1, 4.0}, {0.6, 1, 4.0}, {0.68, -1, 3.6}, {0.84, 1, 3.0}, {0.88, -1, 2.6} })
local fm = frond({ { CX, CY - 1 }, { 41, 16 }, { 43, 12 }, { 44, 8 } },
  { {0.36, -1, 4.0}, {0.44, 1, 4.2}, {0.62, -1, 3.6}, {0.7, 1, 3.4}, {0.86, -1, 2.6}, {0.88, 1, 2.4} })
local fr = frond({ { CX + 1, CY + 1 }, { 48, 20 }, { 54, 17 }, { 59, 12 } },
  { {0.34, -1, 4.0}, {0.42, 1, 3.6}, {0.6, -1, 3.6}, {0.68, 1, 3.2}, {0.86, -1, 2.6} })

-- root
local p = { { CX, CY + 2 }, { 33, 33 }, { 23, 43 }, { 14, 55 } }
local function hw(t)
  if t < 0.07 then return 4.4 + (t / 0.07) * 1.5 end
  return 5.9 * ((1 - t) / 0.93) ^ 0.88 + 0.35
end
local rm, rn, RT, RS, samp = G.tube(p, hw)
-- lenticel nubs: 1 px bumps on the edge (outline follows them)
local nubs = { { 0.36, -1 }, { 0.55, 1 } }
for _, nb in ipairs(nubs) do
  local s = samp[floor(nb[1] * 160) + 1]
  local w = s.w + 0.9
  local x, y = floor(s.x + s.px * w * nb[2] + .5), floor(s.y + s.py * w * nb[2] + .5)
  if not rm:has(x, y) then rm:set(x, y) rn[K(x, y)] = { s.px * nb[2] * 0.9, s.py * nb[2] * 0.9, 0.4 } RT[K(x, y)] = nb[1] RS[K(x, y)] = nb[2] * 0.95 end
end
local v = X.light(rn, { amb = 0.06, wrap = 0.22 })
local bias = {}
-- crown AO
rm:each(function(x, y) local k = K(x, y) if RT[k] < 0.04 then bias[k] = -1 end end)
local rtok = { r = { name = "root" } }
local idx = X.tone(c, rm, v, OR, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 }, bias = bias, tok = rtok })
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- growth rings: grooves across the root (curve slightly with the cylinder), lit lip on the crown side
local rings = { { 0.2, -0.6, 0.7 }, { 0.31, -0.2, 0.85 }, { 0.43, -0.65, 0.4 }, { 0.55, -0.1, 0.85 }, { 0.68, -0.6, 0.5 }, { 0.8, -0.3, 0.8 } }
rm:each(function(x, y) local k = K(x, y)
  local t, s = RT[k], RS[k]
  for i, r in ipairs(rings) do
    local d = (t - r[1]) * LEN + s * s * 1.4
    if s > r[2] and s < r[3] then
      local cur = idx[k] or 3
      if d > -0.5 and d < 0.5 then c:put(x, y, OR[max(1, cur - 2)], rtok)
      elseif d >= -1.5 and d <= -0.5 and s < 0 and cur >= 4 then c:put(x, y, OR[min(6, cur + 1)], rtok) end
    end
  end
end)
-- cool reflected light lower-right edge
local rim = X.rim(rn)
rm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.7 and RS[k] > 0.8 and RT[k] > 0.12 and RT[k] < 0.8 then c:put(x, y, BOUNCE, rtok) end end)
-- specular streak along the lit shoulder + one glint
for _, q in ipairs{ { 0.1, -0.5 }, { 0.13, -0.5 }, { 0.16, -0.48 }, { 0.2, -0.46 } } do
  local s = samp[floor(q[1] * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5)
  c:put(x, y, OR[6], rtok)
end
do local s = samp[floor(0.12 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.5 + .5), floor(s.y + s.py * s.w * -0.5 + .5), SPEC, rtok) end
-- sunken crown: dark cup + stalk stubs
local crown = G.rell(CX, CY + 1.2, 0.62, 0.78, 2.4, 1.2)
crown:each(function(x, y) if rm:has(x, y) then c:put(x, y, OR[1], rtok) end end)
c:put(CX - 1, CY, STALK[1], ltok) c:put(CX, CY, STALK[2], ltok) c:put(CX + 1, CY + 1, STALK[1], ltok)

-- quirk: a ladybird out for a walk on the right frond (hand-placed pixels, head up)
local lx, ly = 52, 12
local map = {
  "..KKK..",
  ".hcKRR.",
  "hhkKRkr",
  "hRRKRRr",
  ".RkKrd.",
  "..rKd..",
}
local BC = { K = "#2b1c26", h = "#ff7a5a", c = "#fff1cf", R = "#e8493b", r = "#b52e3f", d = "#6e2038", k = "#3a1a26" }
for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if BC[ch] then c:put(lx + xx - 4, ly + yy - 1, BC[ch]) end end end
G.save2(c, "carrot")
