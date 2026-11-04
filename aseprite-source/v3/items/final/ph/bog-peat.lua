-- bog-peat (Opus single pass, aR21_2). A spade-cut brick of peat in 3/4 view: fibrous layered front face with
-- pale root fibres and dark voids, smooth spade-scrape marks, a darker side face, bevelled lit edges, deep AO
-- along the base, a crumbly top edge capped by a pillowy cushion of sphagnum moss that spills over the lip,
-- and stringy roots trailing from the bottom corner.
-- quirk: a single bog cranberry sits on the moss.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin = math.floor, math.max, math.min, math.abs, math.sin
local c = A.new2("bog-peat")
local PEAT = { "#1d1318", "#2e1e20", "#452e27", "#5e4232", "#7b5a41", "#a27c55" }
local FIB  = "#b8935e"
local MOSS = { "#173f36", "#24544a", "#3f9150", "#62ad55", "#8fcc62", "#c8e480" }
local x0, x1, yT, yB, dx = 12, 43, 31, 50, 8   -- front face; depth offset (up-right)
local front, side = HP.mask(), HP.mask()
for x = x0, x1 do
  local top = yT + ((X.hash(x, 1, 3) > 0.72) and 1 or 0)
  for y = top, yB do front:set(x, y) end
end
for x = x1 + 1, x1 + dx do
  local k = x - x1
  for y = yT - k, yB - k do side:set(x, y) end
end
-- moss cushion on the top face (with bumps), spilling over the front lip
local topf = HP.poly({ {x0, yT}, {x1, yT}, {x1 + dx, yT - dx}, {x0 + dx, yT - dx} })
local moss = topf:copy()
for x = x0, x1 + dx do
  local lift = floor(X.hash(x, 2, 9) * 2.4)
  for y = 0, lift do
    local yy = (x <= x1) and (yT - dx - y + max(0, 0)) or (yT - dx - y)
    if x >= x0 + dx - 1 or x <= x1 then end
  end
end
-- bumpy top rim of the cushion
for x = x0 + 1, x1 + dx - 1 do
  local yb = yT - dx - 1
  if x < x0 + dx then yb = yT - (x - x0) - 1 end
  local up = floor(X.hash(x, 5, 2) * 2.2)
  for y = yb - up, yb do moss:set(x, y) end
end
-- drips over the front lip
for _, d in ipairs{ {15, 2}, {16, 1}, {22, 1}, {27, 3}, {28, 2}, {34, 1}, {39, 2}, {40, 1} } do
  for y = yT, yT + d[2] - 1 do moss:set(d[1], y) end
end
front:cut(moss) side:cut(moss)

-- front face: layered bands + fibre streaks + voids, lit bevel top and left, AO base
local ftok = { r = { name = "peatF" } }
front:each(function(x, y)
  local band = sin(y * 1.3 + X.hash(floor(x / 6), y, 4) * 1.5)
  local i = 4
  if band > 0.55 then i = 5 elseif band < -0.6 then i = 3 end
  if y >= yB - 1 then i = (y == yB) and 1 or 2 end
  if x == x0 and y < yB - 1 then i = 5 end
  if y == yT + 1 and not moss:has(x, y - 1) and X.hash(x, 8, 1) > 0.3 then i = 6 end
  if x == x1 then i = min(i, 4) end
  c:put(x, y, PEAT[i], ftok)
end)
-- spade scrape marks: smooth vertical strokes (slightly paler, no fibre)
local scrape = { 20, 31, 37 }
for _, sx in ipairs(scrape) do for y = yT + 3, yB - 3 do
  if X.hash(sx, y, 12) > 0.2 then c:put(sx, y, PEAT[5], ftok) c:put(sx + 1, y, PEAT[3], ftok) end end end
-- fibre streaks and voids
for i = 1, 22 do
  local fx, fy = x0 + 2 + floor(X.hash(i, 1, 21) * (x1 - x0 - 4)), yT + 3 + floor(X.hash(i, 2, 21) * (yB - yT - 6))
  local L = 2 + floor(X.hash(i, 3, 21) * 3)
  local sl = X.hash(i, 4, 21) > 0.5 and 1 or 0
  if i % 4 == 0 then
    c:put(fx, fy, PEAT[1], ftok) c:put(fx + 1, fy, PEAT[2], ftok) c:put(fx, fy - 1, PEAT[3], ftok)
  else
    for j = 0, L - 1 do local yy = fy + ((j == L - 1) and sl or 0)
      if front:has(fx + j, yy) then c:put(fx + j, yy, FIB, ftok) end end
    if front:has(fx, fy + 1) then c:put(fx, fy + 1, PEAT[2], ftok) end
  end
end
-- side face: darker version, bright corner edge
local stok = { r = { name = "peatS" } }
side:each(function(x, y)
  local k = x - x1
  local band = sin((y + k) * 1.3 + X.hash(9, y + k, 4) * 1.5)
  local i = 3
  if band > 0.55 then i = 4 elseif band < -0.6 then i = 2 end
  if y >= yB - k - 1 then i = 1 end
  if x == x1 + 1 then i = 5 end
  c:put(x, y, PEAT[i], stok)
end)
for _, q in ipairs{ {47, 34}, {49, 30}, {46, 41} } do c:put(q[1], q[2], PEAT[5], stok) c:put(q[1] + 1, q[2], PEAT[4], stok) end
-- moss: pillow + per-pixel bumps (sphagnum heads)
local heads = {}
for i = 1, 30 do local hx, hy = x0 + floor(X.hash(i, 1, 31) * (x1 + dx - x0)), yT - dx - 2 + floor(X.hash(i, 2, 31) * (dx + 4))
  if moss:has(hx, hy) then heads[#heads + 1] = { hx, hy, 1.8, 1.1 } end end
local mn = A.hnorm(moss, 2, A.bumps(heads))
local mbias = {}
moss:each(function(x, y) if y >= yT then mbias[K(x, y)] = -1 end end)
local mtok = { r = { name = "moss" } }
local midx = X.tone(c, moss, X.light(mn, { amb = 0.1, wrap = 0.3 }), MOSS, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = mbias, tok = mtok })
for _, h in ipairs(heads) do if (midx[K(h[1], h[2])] or 1) >= 4 then c:put(h[1], h[2], MOSS[6], mtok) end end
-- AO: peat directly under the moss lip
front:each(function(x, y) if moss:has(x, y - 1) then c:put(x, y, PEAT[2], ftok) end end)
side:each(function(x, y) if moss:has(x, y - 1) or moss:has(x - 1, y - 1) then c:put(x, y, PEAT[1], stok) end end)
-- roots trailing from the bottom-left corner (1 px, pale with a shade pixel)
local ROOT = { "#6f5440", "#b8935e", "#dcc08a" }
local rtok = { r = { name = "root" } }
for _, p in ipairs{ {13, 51, 1}, {13, 52, 2}, {12, 53, 2}, {12, 54, 3}, {17, 51, 2}, {18, 52, 1}, {18, 53, 2} } do
  c:put(p[1], p[2], ROOT[p[3]], rtok) end
-- quirk: cranberry
local cm = c:ellipse(36, 20, 2, 2)
local cn = X.sphere(35.6, 19.6, 2, cm)
X.tone(c, cm, X.light(cn, { amb = 0.08, wrap = 0.2 }), { "#5e1a2e", "#8f2236", "#c22f3c", "#e8493b", "#ff7a5c", "#ffb39a" }, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = { r = { name = "berry" } } })
c:put(35, 19, "#fff1cf") c:put(37, 22, "#7a5cc0")
A.save2(c, "bog-peat")
