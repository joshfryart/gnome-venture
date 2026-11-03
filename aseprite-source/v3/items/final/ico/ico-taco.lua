-- ico-taco (final, Opus). Crisp corn shell seen from the front, round side down, packed full.
-- Shell: 6-tone toasted masa, lit upper-left, curved like a cup (normals bend out from the fold), a pale rim
-- lip with a dark under-row (thickness), toasted blisters (dark spot + lit crest), cool bounce lower-right,
-- and the shadowed inner wall showing at both horns. Filling: crumbly beef base, ruffled lettuce with pale
-- veins, three glossy diced tomatoes with a specular each, shredded cheese strands. Contact shadow where the
-- filling sinks behind the rim.
-- quirk: someone already took a bite out of the right horn (crumbs falling).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-taco")
local TAC = { "#6a3422", "#9a562c", "#c8863a", "#e6ad56", "#f6cf7e", "#fff0b4" }
local MEAT = { "#2e1614", "#4a2418", "#6e3a22", "#93542e" }
local LEAF = { "#1f4a34", "#2e7646", "#45954c", "#6ab455", "#9dd06c", "#cdeb8e" }
local TOM = { "#5e1530", "#a3243a", "#d8392f", "#f0603a", "#ff9468", "#ffd0a8" }
local CHZ = { "#a8561c", "#e08a22", "#f8b832", "#ffe070" }
local BOUNCE, SPEC = "#b06a6a", "#fff4d6"
local stok, ftok, mtok, ltok, ttok, ctok = { r = { name = "shell" } }, { r = { name = "inner" } }, { r = { name = "meat" } },
  { r = { name = "leaf" } }, { r = { name = "tom" } }, { r = { name = "chz" } }
local CX, TOP = 32, 24
local RX, RY = 22.5, 19.5
-- crescent: the near half of the tortilla, its open edge sagging in the middle so both horns turn up
local function TE(x) local d = (x - CX) / RX return TOP + 5.5 * (1 - d * d) - 3 end

-- bite (quirk): scalloped hole at the right horn, removed from everything
local bite = c:ellipse(53.5, 20.5, 3.8, 3.8):add(c:ellipse(51, 17, 2.8, 2.8)):add(c:ellipse(55, 25, 2.4, 2.4))

-- filling --------------------------------------------------------------
-- beef base
local meat = HP.mask()
for i = 0, 11 do
  local x = 13 + i * 3.4 local y = TE(x) - 1 + (X.hash(i, 1, 5) - 0.5) * 2
  meat:add(c:ellipse(x, y, 2.4, 2.2))
end
meat:each(function(x, y) if y > TE(x) + 1 then meat.s[K(x, y)] = nil end end)
meat:cut(bite)
meat:each(function(x, y) local h = X.hash(x, y, 7)
  local i = h < 0.3 and 2 or (h < 0.75 and 3 or 4)
  if y >= TE(x) - 1 then i = max(1, i - 1) end
  c:put(x, y, MEAT[i], mtok) end)
-- lettuce ruffle: overlapping frilly lobes
local lm = HP.mask()
local lobes = {}
for i = 0, 9 do
  local x = 13.5 + i * 4.1 + (X.hash(i, 2, 3) - 0.5) * 1.2
  local y = TE(x) - 4.5 - sin(i / 9 * pi) * 2.5 + (X.hash(i, 3, 3) - 0.5) * 1.5
  local r = 3.1 + X.hash(i, 4, 3) * 0.8
  lobes[#lobes + 1] = { x, y, r }
  local m = c:ellipse(x, y, r, r - 0.4)
  -- frill: notch the rim
  m:edge():each(function(px, py) if X.hash(px, py, 11) > 0.72 then m.s[K(px, py)] = nil end end)
  lm:add(m)
end
lm:each(function(x, y) if y > TE(x) + 0.5 then lm.s[K(x, y)] = nil end end)
lm:cut(bite)
local ln = X.pillow(lm, 2.2)
-- each lobe domes a little on its own
lm:each(function(x, y) local k = K(x, y)
  local best, bl = 1e9, nil
  for _, l in ipairs(lobes) do local q = (x - l[1])^2 + (y - l[2])^2 if q < best then best, bl = q, l end end
  local nx, ny = (x - bl[1]) / (bl[3] + 1), (y - bl[2]) / (bl[3] + 1)
  local o = ln[k]
  ln[k] = { A.norm(o[1] + nx * 0.8, o[2] + ny * 0.8, o[3]) }
end)
local lb = {}
X.ao(lb, lm, meat:copy():cut(lm), 1, -1)
local lidx = A.shade(c, lm, ln, LEAF, { amb = 0.14, wrap = 0.3, bias = lb, tok = ltok })
-- pale veins radiating from lobe bases
lm:each(function(x, y) local k = K(x, y)
  for _, l in ipairs(lobes) do
    local dx, dy = x - l[1], y - (l[2] + l[3] * 0.8)
    local d = sqrt(dx*dx + dy*dy)
    if d > 1.2 and d < l[3] + 0.4 then
      local a = math.atan(dy, dx)
      for _, va in ipairs({ -pi / 2, -pi / 2 - 0.9, -pi / 2 + 0.9 }) do
        if abs(a - va) * d < 0.45 and (lidx[k] or 1) >= 3 then c:put(x, y, LEAF[6], ltok) end
      end
    end
  end
end)
-- tomatoes: glossy diced cubes
local tm = HP.mask()
local function tomato(x0, y0, w, h)
  local m = c:rrect(x0, y0, x0 + w - 1, y0 + h - 1, 1)
  m:cut(bite)
  local n = X.pillow(m, 1.8)
  local b = {}
  local idx = A.shade(c, m, n, TOM, { amb = 0.1, wrap = 0.3, tok = ttok, bias = b })
  -- seed pocket: paler jelly + seed
  c:put(x0 + w - 2, y0 + h - 2, TOM[5], ttok)
  c:put(x0 + 1, y0 + 1, SPEC, ttok) c:put(x0 + 2, y0 + 1, TOM[6], ttok)
  tm:add(m)
  return m
end
tomato(17, TOP - 9, 5, 4)
tomato(29, TOP - 10, 5, 5)
tomato(40, TOP - 9, 5, 4)
-- dark row on the lettuce under each tomato (contact shadow)
A.touch(lm:copy():cut(tm), tm):each(function(x, y) if y > 0 then
  for _, l in ipairs({ 0 }) do end
  local below = tm:has(x, y - 1) or tm:has(x - 1, y)
  if below then A.step(c, lidx, LEAF, x, y, -2, ltok) end end end)
-- shredded cheese: short slanted strands
local cm = HP.mask()
local function shred(pts)
  for i = 1, #pts - 1 do
    local m = c:line({ pts[i], pts[i + 1] }, 2)
    cm:add(m)
  end
end
shred({ { 23, TOP - 4 }, { 27, TOP - 6 } })
shred({ { 35, TOP - 5 }, { 38, TOP - 3 } })
shred({ { 12, TOP - 6 }, { 15, TOP - 8 } })
shred({ { 45, TOP - 5 }, { 48, TOP - 7 } })
shred({ { 30, TOP + 1 }, { 31, TOP + 5 } })
cm:cut(bite) cm:cut(tm)
cm:each(function(x, y)
  local top = not cm:has(x, y - 1)
  local left = not cm:has(x - 1, y)
  c:put(x, y, top and (left and CHZ[4] or CHZ[3]) or CHZ[2], ctok)
end)
A.touch(lm:copy():cut(cm):cut(tm), cm):each(function(x, y) if cm:has(x - 1, y - 1) or cm:has(x, y - 1) then A.step(c, lidx, LEAF, x, y, -1, ltok) end end)

-- front shell ----------------------------------------------------------
local shell = c:ellipse(CX, TOP - 3, RX, RY + 3)
shell:each(function(x, y) if y < TE(x) then shell.s[K(x, y)] = nil end end)
shell:cut(bite)
-- gently convex tortilla: pillow bevel plus a slight overall tilt to the lower right
local sn = X.pillow(shell, 3.5)
for k, v in pairs(sn) do sn[k] = { A.norm(v[1] + 0.1, v[2] + 0.05, v[3]) } end
local sidx = A.shade(c, shell, sn, TAC, { amb = 0.12, wrap = 0.3, tok = stok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- open edge: 1 px pale lip (the tortilla's thickness catching light)
shell:each(function(x, y) local k = K(x, y)
  if not shell:has(x, y - 1) and not bite:has(x, y - 1) then
    local i = x < CX + 10 and 6 or 5 c:put(x, y, TAC[i], stok) sidx[k] = i end
end)
-- toasted blisters: small dark spots with a lit crest above-left
local spots = { { 18, 30 }, { 25, 35 }, { 34, 31 }, { 41, 35 }, { 47, 28 }, { 30, 40 }, { 15, 34 }, { 37, 40 }, { 23, 30 }, { 45, 37 }, { 13, 27 }, { 51, 25 } }
for _, p in ipairs(spots) do
  local x, y = p[1], p[2]
  if shell:has(x, y) and shell:has(x + 1, y) then
    A.step(c, sidx, TAC, x, y, -2, stok) A.step(c, sidx, TAC, x + 1, y, -1, stok)
    if shell:has(x - 1, y - 1) and y - 1 > TE(x) + 1 then A.step(c, sidx, TAC, x - 1, y - 1, 1, stok) end
  end
end
-- corn speckle
shell:each(function(x, y) if y > TOP + 3 and X.hash(x, y, 21) > 0.93 then A.step(c, sidx, TAC, x, y, -1, stok) end end)
-- cool bounce on the lower-right edge
shell:edge():each(function(x, y)
  local dx, dy = x - CX, y - TOP
  if dx > 2 and dy > 6 and dx + dy * 0.6 > 13 then c:put(x, y, BOUNCE, stok) end end)
-- one pop on the shell
c:put(17, TOP + 4, TAC[6], stok) c:put(18, TOP + 4, TAC[6], stok)
-- contact shadow: filling row just above the rim
local fill = meat:copy():add(lm):add(cm):add(tm)
fill:each(function(x, y) if shell:has(x, y + 1) then
  local h = c:get(x, y)
  if lm:has(x, y) then c:put(x, y, LEAF[1], ltok) elseif meat:has(x, y) then c:put(x, y, MEAT[1], mtok) end
end end)
-- bite edge: crumbly darker shell along the bite
A.touch(shell, bite):each(function(x, y) A.step(c, sidx, TAC, x, y, -1, stok) end)
-- crumbs falling from the bite
c:put(57, 32, TAC[4], stok) c:put(58, 32, TAC[3], stok) c:put(57, 33, TAC[2], stok)
c:put(55, 37, TAC[5], stok) c:put(56, 37, TAC[3], stok)
A.save(c, "ico-taco")
