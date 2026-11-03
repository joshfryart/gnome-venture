-- ico-taco (final, Opus, aR0_0). Crisp corn shell seen from the side, round side down, packed full.
-- Shell: 6-tone toasted masa on a domed normal field, lit upper-left, pale rim lip with a dark under-row for its
-- thickness, toasted blisters (dark spot + lit crest), cool bounce on the lower-right, and the shadowed inner wall
-- showing behind the filling at the left horn. Filling: crumbly beef (noise-stepped lumps), ruffled lettuce with
-- pale veins, three glossy diced tomatoes with one specular each, cheese shreds draped over the rim. AO where the
-- filling sinks behind the rim.
-- quirk: someone already took a bite out of the right horn (pale broken edge, two crumbs falling).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-taco")
local SH  = { "#6e3420", "#a45a2a", "#d08a3a", "#eab052", "#f8cf78", "#fff0b0" }
local INW = { "#5a2c1e", "#80442a", "#a4643a" }
local BEEF = { "#2e1612", "#4a2418", "#6a3620", "#8a4c2a", "#ac683a" }
local LET = { "#1c4a34", "#2a6a3c", "#3f8c44", "#5eac4c", "#8acc5c", "#bce67c" }
local TOM = { "#5e1530", "#9a1f36", "#d0333a", "#ee5a44", "#ff9070", "#ffd0b4" }
local CH  = { "#9a5a14", "#e0a024", "#ffd04a", "#fff09a" }
local BOUNCE, SPEC = "#b0708a", "#fff4d6"
local CX = 31
local function rimY(x) return 31 - 0.017 * (x - CX) ^ 2 end
local function heap(x) return 3.5 * max(0, 1 - ((x - CX) / 21) ^ 2) end   -- filling piles up in the middle   -- shell top edge, horns rise
-- bite at the right horn
local bite = HP.ellipse(51.5, 22.5, 3.6, 3.6):add(HP.ellipse(54.5, 27.5, 3.4, 3.4)):add(HP.ellipse(48.5, 18.0, 2.6, 2.6))

-- shell front mask
local shell = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = (x + 0.5 - CX) / 22.5, (y + 0.5 - 26) / 20.5
  if dx * dx + dy * dy <= 1 and y + 0.5 >= rimY(x + 0.5) then shell:set(x, y) end
end end
shell:cut(bite)

-- inner back wall at the left horn (and a sliver at the right) behind the filling
local wall = HP.mask()
for x = 9, 14 do local ry = rimY(x + 0.5) for y = floor(ry) - 3, floor(ry) do
  local dx, dy = (x + 0.5 - CX) / 22.5, (y + 0.5 - 27) / 20.5
  if dx * dx + dy * dy <= 1 then wall:set(x, y) end end end
wall:cut(shell) wall:cut(bite)
local wtok = { r = { name = "inwall" } }
wall:each(function(x, y) c:put(x, y, (x < 12) and INW[3] or INW[2], wtok) end)

-- lettuce: ruffled band of bumps
local let = HP.mask()
local LB = {}
for i = 0, 8 do
  local x = 13.5 + i * 4.2 local y = rimY(x) - 5.5 - heap(x) + ((i % 2 == 0) and 0 or 1.2)
  LB[#LB + 1] = { x, y }
  let:add(HP.ellipse(x, y, 3.6, 3.3))
end
for x = 11, 51 do for y = floor(rimY(x + 0.5) - 5 - heap(x + 0.5)), floor(rimY(x + 0.5)) + 1 do let:set(x, y) end end
-- frilly notches between bumps
for i = 1, #LB - 1 do local mx = floor((LB[i][1] + LB[i + 1][1]) / 2 + .5) local my = floor(min(LB[i][2], LB[i + 1][2]) - 2.6)
  let.s[K(mx, my)] = nil end
let:cut(bite)
local function despeck(m) for _ = 1, 2 do local kill = {}
  m:each(function(x, y) local n = 0 for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do if m:has(x + d[1], y + d[2]) then n = n + 1 end end
    if n <= 1 then kill[#kill + 1] = K(x, y) end end)
  for _, k in ipairs(kill) do m.s[k] = nil end end end
despeck(let)
local ln = {}
let:each(function(x, y) local best, bb
  for _, b in ipairs(LB) do local q = (x + 0.5 - b[1]) ^ 2 + (y + 0.5 - b[2]) ^ 2 if not best or q < best then best, bb = q, b end end
  local nx, ny = (x + 0.5 - bb[1]) / 4.4, (y + 0.5 - bb[2]) / 4.4
  if ny > 0.2 then ny = 0.2 + (ny - 0.2) * 0.3 end
  ln[K(x, y)] = { A.norm(nx, ny, sqrt(max(0.05, 1 - nx * nx - ny * ny))) } end)
local lb = {}
let:each(function(x, y) if y + 0.5 > rimY(x + 0.5) - 3 then lb[K(x, y)] = -1 end end)
local ltok = { r = { name = "lettuce" } }
local lidx = A.shade(c, let, ln, LET, { amb = 0.08, wrap = 0.2, bias = lb, tok = ltok })
-- pale veins: little arcs in each bump
for _, b in ipairs(LB) do
  local x, y = floor(b[1] + .5), floor(b[2] + .5)
  for _, p in ipairs({ { x - 1, y - 1 }, { x, y }, { x + 1, y + 1 } }) do
    if let:has(p[1], p[2]) then A.step(c, lidx, LET, p[1], p[2], 2, ltok) end end
end

-- beef: crumbly lumps along the rim
local beef = HP.mask()
for i = 0, 10 do local x = 12.5 + i * 3.6 beef:add(HP.ellipse(x, rimY(x) - 1.6 - heap(x) * 0.3 + ((i % 3 == 1) and -0.7 or 0), 2.2, 1.7)) end
beef:cut(bite) despeck(beef)
local bn = X.pillow(beef, 2)
local bb = {}
beef:each(function(x, y) local k = K(x, y)
  bb[k] = (X.hash(x, y, 7) < 0.25) and -1 or ((X.hash(x, y, 3) > 0.85) and 1 or 0)
  if y + 0.5 > rimY(x + 0.5) - 1.2 then bb[k] = bb[k] - 1 end end)
A.shade(c, beef, bn, BEEF, { amb = 0.1, wrap = 0.25, bias = bb, cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = { r = { name = "beef" } } })

-- tomatoes: diced, glossy
local function tomato(x0, y0, w, h)
  local m = HP.rrect(x0, y0, x0 + w - 1, y0 + h - 1, 1)
  m:cut(bite)
  local n = X.pillow(m, 1.6)
  local tok = { r = { name = "tom" .. x0 } }
  local idx = A.shade(c, m, n, TOM, { amb = 0.12, wrap = 0.3, tok = tok })
  c:put(x0 + 1, y0 + 1, TOM[6], tok) c:put(x0 + 2, y0 + 1, TOM[5], tok)
  -- cut-face seeds on the lower side
  c:put(x0 + w - 2, y0 + h - 2, TOM[2], tok)
  return m
end
local t1 = tomato(18, floor(rimY(20) - 9 - heap(20)), 5, 4)
local t2 = tomato(29, floor(rimY(31) - 10 - heap(31)), 5, 4)
local t3 = tomato(39, floor(rimY(41) - 9 - heap(41)), 5, 4)

-- front shell: domed, toasted
local sn = A.dome(shell, CX - 0.5, 24, 22, 5, 0.55)
local sbias = {}
shell:each(function(x, y) local k = K(x, y) local ry = rimY(x + 0.5)
  if y + 0.5 - ry < 1.5 and y + 0.5 - ry >= 1 then sbias[k] = -2 end end)
local stok = { r = { name = "shell" } }
local sidx = A.shade(c, shell, sn, SH, { amb = 0.1, wrap = 0.3, bias = sbias, tok = stok })
-- rim lip: top row pale
shell:each(function(x, y) if not shell:has(x, y - 1) and not bite:has(x, y - 1) then
  c:put(x, y, x < CX + 8 and SH[6] or SH[5], stok) sidx[K(x, y)] = 6 end end)
-- toasted blisters
for i = 1, 34 do
  local x, y = floor(10 + X.hash(i, 1, 11) * 42), floor(33 + X.hash(i, 2, 13) * 13)
  if shell:has(x, y) and shell:has(x - 1, y - 1) and shell:has(x + 1, y + 1) and y > rimY(x) + 3 and X.hash(i, 3, 5) < 0.5 then
    A.step(c, sidx, SH, x, y, -2, stok) A.step(c, sidx, SH, x - 1, y - 1, 1, stok)
  end
end
-- bounce on the lower-right edge
local rimn = X.rim(sn)
shell:edge():each(function(x, y) local k = K(x, y)
  if rimn[k] and rimn[k] > 0.55 and y > 36 and x > CX + 4 then c:put(x, y, BOUNCE, stok) end end)
-- specular glint on the lit belly
c:put(18, 36, SPEC, stok) c:put(19, 36, SH[6], stok)
-- bite: fresh broken edge, paler crumb
bite:grow(1):cut(bite):each(function(x, y) if shell:has(x, y) then c:put(x, y, SH[5], stok) end end)

-- cheese shreds draped over the rim (2 px strands, 4 tones)
local ctok = { r = { name = "cheese" } }
for _, s in ipairs({ { 15, -1 }, { 25, 1 }, { 36, -1 }, { 45, 1 } }) do
  local x0, d = s[1], s[2]
  local y0 = floor(rimY(x0) - 3)
  for j = 0, 5 do
    local x = x0 + floor(j * d * 0.5 + .5) local y = y0 + j
    if not bite:has(x, y) then
      c:put(x, y, j < 2 and CH[4] or CH[3], ctok) c:put(x + 1, y, j < 3 and CH[3] or CH[2], ctok)
    end
  end
  c:put(x0 + floor(5 * d * 0.5 + .5) + 1, y0 + 5, CH[1], ctok)
end

-- crumbs falling from the bite
A.map(c, { "ab", "bc" }, 56, 34, { a = SH[5], b = SH[4], c = SH[2] }, { r = { name = "crumb" } })
A.map(c, { "ab" }, 54, 39, { a = SH[4], b = SH[2] }, { r = { name = "crumb2" } })

A.save(c, "ico-taco")
