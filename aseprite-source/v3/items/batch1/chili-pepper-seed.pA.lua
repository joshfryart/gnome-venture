-- chili-pepper-seed pass A. Three flat cream chili seeds (kidney discs with a hilum notch) on a slim, curved,
-- glossy chili leaf. quirk: a little red-hot heat squiggle rises off the top seed.
local NAME = "chili-pepper-seed.pA"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g1.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local LEAF = { "#173d36", "#215640", "#2f7348", "#45924e", "#69b057", "#98cc6c" }
local VEIN = "#b8de84"
local SEED = { "#8c5a2a", "#b5803a", "#d7a650", "#ecc56c", "#f7dc92", "#fdedbb" }

-- seeds first (masks), leaf painted under with their shadows
local seeds = {   -- cx, cy, rx, ry, angle, notch angle, tilt x, tilt y
  { 20, 42, 5.2, 4.6, 0.4, 2.4, -0.15, -0.1 }, { 32, 41, 5.0, 4.3, -0.5, 0.2, 0.15, -0.2 }, { 23, 30, 4.8, 4.2, 1.0, 3.8, -0.2, 0.1 },
}
for _, s in ipairs(seeds) do
  local m = G.oval(s[1], s[2], s[3], s[4], s[5], 1)
  local nx, ny = math.floor(s[1] + math.cos(s[6]) * (s[3] + 0.3) + .5), math.floor(s[2] + math.sin(s[6]) * (s[3] + 0.3) + .5)
  for dy = -1, 1 do for dx = -1, 1 do if math.abs(dx) + math.abs(dy) <= 1 then m.s[K(nx + dx, ny + dy)] = nil end end end
  s.hx, s.hy = math.floor(s[1] + math.cos(s[6]) * (s[3] - 1.6) + .5), math.floor(s[2] + math.sin(s[6]) * (s[3] - 1.6) + .5)
  local n = X.pillow(m, 3.6)
  for k, v in pairs(n) do n[k] = { G.norm(v[1] + s[7], v[2] + s[8], v[3]) } end
  s.m, s.n = m, n
end

local lm, ln, LT, LS, len = G.blade(12, 51, 30, 36, 56, 11, function(t)
  if t > 0.985 then return -1 end
  return math.max(0.4, 7.2 * math.sin(math.pi * math.min(1, t * 0.92 + 0.08) ^ 1.25) ^ 0.75)
end, { fold = 0.25 })
for k, v in pairs(ln) do   -- gentle ripple along the blade
  local w = math.sin(LT[k] * len / 5.5) * 0.18
  ln[k] = { G.norm(v[1] - w, v[2] - w, v[3]) }
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 2, 2, -1) G.cast(bias, lm, s.m, 1, 2, 0) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if math.abs(s) < 0.13 and t > 0.03 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) end
  for _, vt in ipairs{ 7, 13, 19, 25, 31, 37, 43 } do
    local d = t * len - (vt + math.abs(s) * 5)
    if d > -0.6 and d < 0.6 and math.abs(s) > 0.2 and math.abs(s) < 0.78 then
      c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
  end
end)
-- petiole
local pet = c:line({ { 8, 57 }, { 12, 51 } }, 2)
pet:each(function(x, y) if not lm:has(x, y) then c:put(x, y, (x + y) % 2 == 0 and LEAF[4] or LEAF[3]) end end)

for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  G.toneN(c, vis, s.n, SEED, { bias = sb, tok = tok, amb = 0.05, wrap = 0.15, cuts = { 0.2, 0.38, 0.52, 0.64, 0.8 } })
  if vis:has(s.hx, s.hy) then c:put(s.hx, s.hy, SEED[1], tok) end
  -- thick margin: inner ring a step darker on the shade half, lighter on the lit half
  s.m:shrink(1):edge():each(function(x, y) if vis:has(x, y) then
    local nn = s.n[K(x, y)]
    if nn[1] + nn[2] > 0 then c:put(x, y, SEED[2], tok) else c:put(x, y, SEED[6], tok) end end end)
  local bx, by = G.specAt(vis, s.n, 30)
  if bx then c:put(bx, by, "#fff6dc", tok) c:put(bx + 1, by, SEED[6], tok) end
end

-- quirk: heat squiggle
local pts = {}
for i = 0, 13 do pts[#pts + 1] = { 24 + math.floor(math.sin(i * 0.5) * 1.6 + .5), 25 - i } end
local cols = { "#c92f2f", "#c92f2f", "#e8493b", "#e8493b", "#f2683a", "#f2683a", "#f58b3a", "#f58b3a", "#f5ab3a", "#f5ab3a", "#f7c84a", "#f7c84a", "#ffe38a", "#ffe38a" }
for i, p in ipairs(pts) do c:put(p[1], p[2], cols[i]) end
for i = 1, #pts - 1 do   -- fill diagonal gaps
  local a, b = pts[i], pts[i + 1]
  if math.abs(a[1] - b[1]) > 1 then c:put(math.floor((a[1] + b[1]) / 2), a[2], cols[i]) end
end
G.save(c, NAME)
