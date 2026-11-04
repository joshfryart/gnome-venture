-- living-moss (final, Opus single pass). A lumpy cushion of bright moss (each lump lit as its own dome, star-leaf
-- speckle, fuzzy tufted rim) sitting on a flat bevelled pebble with AO where moss meets stone. Three slender
-- reddish setae rise and curve, each ending in a nodding gold-brown capsule with a pale lid.
-- quirk: it is alive - two sleepy eyes peek out between the lumps.
local NAME = "living-moss"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, max, min, sqrt, floor = math.abs, math.max, math.min, math.sqrt, math.floor
local c = A.new(NAME)

local MOSS  = { "#173d33", "#245a3c", "#367a40", "#55a046", "#84c654", "#bde27a" }
local STONE = { "#3c3d58", "#5a5c78", "#7c7e98", "#a3a4b8", "#c9c9d6", "#e6e4ec" }
local SETA  = { "#6e2a2e", "#a24a36", "#d07a48" }
local CAPS  = { "#5a3420", "#8f5a26", "#c88a32", "#f0c062" }

-- pebble: flat ellipse, bevelled top
local stone = c:ellipse(32, 50, 18, 5)
local sn = X.pillow(stone, 4)
-- moss lumps (cx, cy, r)
local lumps = { { 20, 44, 5.5 }, { 27, 40, 6.5 }, { 35, 39, 6.5 }, { 42, 42, 5.5 }, { 46, 46, 3.8 }, { 16, 47, 3.6 }, { 31, 45, 6 } }
local moss = HP.mask()
for _, l in ipairs(lumps) do moss:add(c:ellipse(l[1], l[2], l[3], l[3] * 0.85)) end
local mb = HP.mask() moss:each(function(x, y) if y <= 49 then mb:set(x, y) end end) moss = mb
-- stone shading with AO under the moss
local sb = {}
X.ao(sb, stone, moss, 2, -1)
local stok = { r = { name = "stone" } }
local sidx = A.shade(c, stone, sn, STONE, { bias = sb, tok = stok, amb = 0.12, wrap = 0.3 })
-- stone texture: a few pits and a bright bevel edge
stone:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 11) > 0.9 and sidx[k] > 2 and not moss:has(x, y) then c:put(x, y, STONE[sidx[k] - 1], stok) end end)

-- moss normals: nearest lump dome
local mn = {}
moss:each(function(x, y)
  local best, bl
  for _, l in ipairs(lumps) do
    local d = ((x - l[1]) / l[3]) ^ 2 + ((y - l[2]) / (l[3] * 0.85)) ^ 2
    if not best or d < best then best, bl = d, l end
  end
  local nx, ny = (x - bl[1]) / (bl[3] + 0.5), (y - bl[2]) / (bl[3] * 0.85 + 0.5)
  local q = max(0.03, 1 - nx * nx - ny * ny)
  local l = sqrt(nx * nx + ny * ny + q)
  mn[K(x, y)] = { nx / l, ny / l, sqrt(q) / l, d = best }
end)
local mbias = {}
moss:each(function(x, y) local k = K(x, y)
  if mn[k].d > 0.7 then mbias[k] = -1 end                  -- creases between lumps
  if y >= 48 then mbias[k] = (mbias[k] or 0) - 1 end       -- underside meets stone
end)
local mtok = { r = { name = "moss" } }
local midx = A.shade(c, moss, mn, MOSS, { bias = mbias, tok = mtok, amb = 0.1, wrap = 0.3 })
-- star-leaf speckle texture
moss:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 5)
  if h > 0.8 and midx[k] < 6 then c:put(x, y, MOSS[midx[k] + 1], mtok)
  elseif h < 0.16 and midx[k] > 1 then c:put(x, y, MOSS[midx[k] - 1], mtok) end end)
-- fuzzy rim: tiny tufts sticking out of the top edge
local tufts = HP.mask()
moss:grow(1):cut(moss):each(function(x, y)
  if y < 46 and not moss:has(x, y - 1) and moss:has(x, y + 1) and X.hash(x, y, 9) > 0.55 then tufts:set(x, y) end end)
tufts:each(function(x, y) c:put(x, y, (x < 34) and MOSS[5] or MOSS[4], mtok) end)
-- contact shadow line on the stone right under the moss
moss:each(function(x, y) if not moss:has(x, y + 1) and stone:has(x, y + 1) then c:put(x, y + 1, STONE[1], stok) end end)

-- setae with nodding capsules (base x,y, top x,y, nod dir)
local function seta(bx, by, tx, ty, dir)
  local tok = { r = { name = "seta" } }
  local pts = { { bx, by }, { bx + (tx - bx) * 0.2, by - (by - ty) * 0.45 }, { tx - dir * 2, ty + 4 }, { tx, ty } }
  local prev
  for i = 0, 40 do
    local x, y = A.bez(pts, i / 40)
    local xi, yi = floor(x + 0.5), floor(y + 0.5)
    if not moss:has(xi, yi) then c:put(xi, yi, (i > 30) and SETA[3] or (i % 6 < 3 and SETA[2] or SETA[1]), tok) end
  end
  -- capsule: small tilted oval hanging from the top, pale lid at the tip
  local cx, cy = tx + dir * 1.5, ty + 1.5
  local m, n = A.oval(cx, cy, 2.2, 1.3, dir > 0 and 0.9 or -0.9 + math.pi, 0.8)
  A.shade(c, m, n, CAPS, { tok = tok, amb = 0.12, wrap = 0.25, cuts = { 0.25, 0.5, 0.75 } })
  local lx, ly = floor(cx + dir * 1.6 + 0.5), floor(cy + 1.8 + 0.5)
  c:put(lx, ly, "#f2e8c4", tok)
  local hx, hy = floor(cx - 0.5), floor(cy - 0.5)
  if m:has(hx, hy) then c:put(hx, hy, CAPS[4], tok) end
end
seta(24, 37, 20, 15, -1)
seta(33, 35, 34, 11, 1)
seta(40, 38, 45, 19, 1)

-- quirk: sleepy eyes peeking out (half-lidded: 2x2 ink with a moss lid row and a glint)
local etok = { r = { name = "eyes" } }
for _, e in ipairs{ { 29, 43 }, { 35, 43 } } do
  local x, y = e[1], e[2]
  c:put(x, y, MOSS[2], etok) c:put(x + 1, y, MOSS[2], etok)
  c:put(x, y + 1, A.INK, etok) c:put(x + 1, y + 1, A.INK, etok)
  c:put(x, y + 2, A.INK, etok) c:put(x + 1, y + 2, A.INK, etok)
  c:put(x, y + 1, A.CREAM, etok)
end

A.save(c, NAME)
