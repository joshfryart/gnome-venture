-- chili-pepper-seed (pass B, final). Three flat cream chili seeds (round discs with a thick rim, a hilum beak and
-- a dark hilum dot) on a slim, glossy, gently S-curved chili leaf: V-fold on the midrib, side veins (pale on the
-- lit half, dark on the shade half), a wet specular streak, wavy margin, cool reflected light on the lower edge,
-- AO + contact shadow under each seed. History: chili-pepper-seed.pA (pass A).
-- quirk: a little red-hot heat squiggle rises off the top seed.
local NAME = "chili-pepper-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g1.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local LEAF = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local VEIN, GLOSS, COOL = "#bfe28a", "#dff2a8", "#3c6f74"
local SEED = { "#8a5628", "#b57d38", "#d6a44e", "#eac36a", "#f6da90", "#fdecbb" }

local seeds = {   -- cx, cy, rx, ry, angle, beak angle, tilt x, tilt y
  { 18, 45, 4.8, 4.3, 0.4, 2.3, -0.15, -0.1 }, { 30, 43, 4.6, 4.1, -0.5, 0.3, 0.15, -0.15 }, { 23, 33, 4.3, 3.9, 1.0, 3.9, -0.25, 0.05 },
}
for _, s in ipairs(seeds) do
  local m = G.oval(s[1], s[2], s[3], s[4], s[5], 1)
  -- beak: a small notch with a nub (the hilum hook of a chili seed)
  local ca, sa = math.cos(s[6]), math.sin(s[6])
  local nx, ny = math.floor(s[1] + ca * (s[3] + 0.2) + .5), math.floor(s[2] + sa * (s[3] + 0.2) + .5)
  m.s[K(nx, ny)] = nil
  local px, py = math.floor(nx - sa * 1.6 + .5), math.floor(ny + ca * 1.6 + .5)
  m.s[K(px, py)] = nil
  s.hx, s.hy = math.floor(s[1] + ca * (s[3] - 1.4) + .5), math.floor(s[2] + sa * (s[3] - 1.4) + .5)
  local n = X.pillow(m, 3.4)
  for k, v in pairs(n) do n[k] = { G.norm(v[1] + s[7], v[2] + s[8], v[3]) } end
  s.m, s.n = m, n
end

-- leaf: gentle S curve, widest a third of the way up, long drawn tip
local lm, ln, LT, LS, len = G.blade(13, 50, 28, 38, 56, 10, function(t)
  if t > 0.985 then return -1 end
  local u = math.min(1, t * 0.93 + 0.07)
  return math.max(0.45, 7.4 * math.sin(math.pi * u ^ 1.35) ^ 0.7)
end, { fold = 0.42 })
-- wavy margin: nibble the edge every ~6 px
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] > 0.12 and LT[k] < 0.9 and math.sin(LT[k] * len / 1.9) > 0.55 and LS[k] > 0 then lm.s[k] = nil end end)
for k, v in pairs(ln) do
  local w = math.sin((LT[k] or 0) * len / 6) * 0.12
  ln[k] = { G.norm(v[1] - w, v[2] - w, v[3]) }
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 2, 2, -1) G.cast(bias, lm, s.m, 1, 3, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
local rim = X.rim(ln)
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if math.abs(s) < 0.12 and t > 0.03 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vt in ipairs{ 6, 12, 18, 24, 30, 36, 42 } do
    local d = t * len - (vt + math.abs(s) * 5.5)
    if d > -0.55 and d < 0.55 and math.abs(s) > 0.18 and math.abs(s) < 0.74 then
      c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  end
  -- wet gloss streak on the lit half, between the veins
  if s < -0.35 and s > -0.62 and t > 0.52 and t < 0.78 then c:put(x, y, GLOSS, ltok) return end
end)
lm:edge():each(function(x, y) local k = K(x, y)        -- cool bounce on the lower-right edge
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)
-- petiole (thin, slightly curved, with a paler top edge)
local pet = c:line({ { 9, 57 }, { 10, 55 }, { 12, 52 } }, 1)
local ptok = { r = { name = "pet" } }
pet:each(function(x, y) if not lm:has(x, y) then c:put(x, y, LEAF[4], ptok) end end)
c:put(10, 57, LEAF[3], ptok) c:put(11, 55, LEAF[3], ptok) c:put(13, 52, LEAF[4], ptok)

for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) G.cast(sb, s.m, seeds[j].m, 1, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  -- flat disc: face one tone, bevel ring + side wall around it
  local r1, r2 = s.m:edge(), s.m:shrink(1):edge()
  vis:each(function(x, y) local k = K(x, y)
    local nn = s.n[k] local d = nn[1] + nn[2]
    local col
    if r1:has(x, y) then col = d < -0.1 and SEED[4] or (d > 0.1 and SEED[1] or SEED[2])
    elseif r2:has(x, y) then col = d < -0.1 and SEED[6] or (d > 0.1 and SEED[3] or SEED[4])
    else col = (x - s[1]) + (y - s[2]) > 1.5 and SEED[4] or SEED[5] end
    if sb[k] then col = SEED[math.max(1, ({ [SEED[1]] = 1, [SEED[2]] = 2, [SEED[3]] = 3, [SEED[4]] = 4, [SEED[5]] = 5, [SEED[6]] = 6 })[col] - 2)] end
    c:put(x, y, col, tok)
  end)
  if vis:has(s.hx, s.hy) then c:put(s.hx, s.hy, SEED[1], tok) end
  local bx, by = G.specAt(vis, s.n, 30)
  if bx then c:put(bx, by, "#fff6dc", tok) end
end

-- quirk: heat squiggle (starts 1 px above the seed, red to gold as it rises)
local pts = {}
for i = 0, 12 do pts[#pts + 1] = { 23 + math.floor(math.sin(i * 0.55 + 0.4) * 1.6 + .5), 25 - i } end
local cols = { "#b52e3f", "#c92f2f", "#e8493b", "#e8493b", "#f2683a", "#f2683a", "#f58b3a", "#f58b3a", "#f5ab3a", "#f7c84a", "#f7c84a", "#ffe38a", "#ffe38a" }
for i, p in ipairs(pts) do c:put(p[1], p[2], cols[i]) end
G.save(c, NAME)
