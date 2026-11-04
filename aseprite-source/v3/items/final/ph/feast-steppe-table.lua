-- feast-steppe-table (B30, Opus single pass). A low round dastarkhan table on four slim turned legs (beads mid-leg,
-- back legs darker and shorter). On the planked top: a stamped round non bread (domed rim, pricked centre, nigella
-- and sesame), a lagan of golden plov with carrot strands, meat and a whole garlic bulb, a cobalt-and-white teapot
-- with a slim spout and a small piala of tea. Material: wood grain + carved groove ring, bread crust dome,
-- ceramic gloss with cotton-boll pattern, ambient rows under every dish and where legs meet the apron.
-- quirk: the teapot lid is tied to the handle with a red thread so it cannot get lost.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = G.new("feast-steppe-table")
local W6 = { "#3d2220", "#5e3426", "#87522f", "#a96f3e", "#cf9a5c", "#ebc58a" }
local BR = { "#5a2a1c", "#8a4422", "#b86a2e", "#d9924a", "#efbb72", "#fbe1a8" }
local PL = { "#6a3a1e", "#9a5a26", "#c8862e", "#e2a845", "#f2c96e", "#fbe6a8" }
local CE = { "#3e4470", "#6c74a0", "#a9afcb", "#d8dcea", "#f0f0f5", "#fffcf2" }
local COB, COBD = "#3a5ab0", "#2a3a80"
local CREAM = "#fff4d6"

local CX, CY, RX, RY = 32, 32, 24, 9
c:groundShadow(CX + 1, 53, 23, 2)

-- legs: turned, 3 px with a 5 px bead and a small foot
local function leg(lx, y0, y1, dark)
  local m = HP.mask()
  for y = y0, y1 do
    local t = (y - y0) / (y1 - y0)
    local w = 1
    if t > 0.38 and t < 0.6 then w = 2 end
    if y == y1 then w = 2 end
    for x = lx - w, lx + w do m:set(x, y) end
  end
  local bias = {}
  m:each(function(x, y) if y <= y0 + 1 then bias[K(x, y)] = -1 end if dark then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end end)
  G.shade(c, m, G.vcylN(m, lx - 2, lx + 2), W6, { bias = bias, amb = 0.1 })
  return m
end
leg(13, 38, 49, true)
leg(51, 38, 49, true)
local fl = leg(21, 40, 52)
local fr = leg(43, 40, 52)

-- apron / edge thickness
local top = HP.ellipse(CX, CY, RX, RY)
local edge = HP.ellipse(CX, CY + 3, RX, RY):cut(top)
local en = {}
edge:each(function(x, y) local s = (x - CX) / (RX + .5) en[K(x, y)] = { G.norm(s * 0.9, 0.5, 0.75) } end)
local eb = {}
edge:each(function(x, y) if top:has(x, y - 1) then eb[K(x, y)] = 1 elseif not edge:has(x, y + 1) then eb[K(x, y)] = -1 end end)
G.shade(c, edge, en, W6, { bias = eb, amb = 0.1 })
-- end grain flecks on the edge
edge:each(function(x, y) if G.hash(x, y, 5) < 0.08 then c:put(x, y, W6[2]) end end)

-- top: pillow bevel, plank grain and a carved groove ring
local tidx = G.pillow(c, top, W6, 2.5, { amb = 0.2, wrap = 0.45, cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 } })
top:each(function(x, y)
  local k = K(x, y)
  local i = tidx[k]
  local g = (y * 1.0 + 0.9 * sin(x * 0.22 + y * 0.7))
  if (floor(g) % 3 == 0) and G.hash(x, y, 2) < 0.75 and i > 2 then c:put(x, y, W6[i - 1]) end
  -- plank seams
  if (x == 24 or x == 41) and i > 2 then c:put(x, y, W6[2]) end
end)
local grooveO, grooveI = HP.ellipse(CX, CY, RX - 3, RY - 2), HP.ellipse(CX, CY, RX - 4, RY - 3)
grooveO:copy():cut(grooveI):each(function(x, y)
  if y < CY or x < CX - 10 then c:put(x, y, W6[2]) else c:put(x, y, W6[6]) end
end)
-- bright lip along the front edge of the top
top:each(function(x, y) if not top:has(x, y + 1) and x < CX + 6 and x > CX - 16 then c:put(x, y, W6[6]) end end)

-- non bread (left)
local bx, by = 17, 29
local bread = HP.ellipse(bx, by, 8.5, 4)
G.ao(c, top, bread, W6[2], 1, 1)
local bidx = G.pillow(c, bread, BR, 2.8, { amb = 0.12, wrap = 0.3 })
local centre = HP.ellipse(bx, by + 0.2, 4.5, 1.8)
centre:each(function(x, y)
  local col = BR[5]
  if (x + y * 2) % 3 == 0 then col = BR[3] end
  c:put(x, y, col)
end)
centre:grow(1):cut(centre):each(function(x, y)
  if bread:has(x, y) then c:put(x, y, (y < by or x < bx - 3) and BR[2] or BR[6]) end end)
for _, p in ipairs{ { 10, 28 }, { 13, 26 }, { 22, 27 }, { 24, 30 }, { 11, 31 }, { 20, 32 } } do
  if bread:has(p[1], p[2]) then c:put(p[1], p[2], (p[1] + p[2]) % 2 == 0 and "#3a2a2a" or CREAM) end end
c:put(12, 27, BR[6]) c:put(13, 27, CREAM)

-- piala of tea (front right), drawn before teapot? no: in front
-- lagan of plov (centre)
local px, py = 32, 37
local dish = HP.ellipse(px, py, 9, 3.2)
local dishSide = HP.ellipse(px, py + 1, 9, 3.2):cut(dish)
G.ao(c, top, dish:copy():add(dishSide), W6[2], 1, 1)
dishSide:each(function(x, y) c:put(x, y, x < px - 3 and CE[3] or CE[2]) end)
G.pillow(c, dish, CE, 1.5, { amb = 0.2, wrap = 0.4 })
dish:copy():cut(HP.ellipse(px, py, 7.5, 2.2)):each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, COB) end end)
local mound = HP.ellipse(px, py - 1.5, 6.5, 4)
mound:each(function(x, y) if y > py + 1 then mound.s[K(x, y)] = nil end end)
local mn = X.sphere(px - 0.5, py - 1.5, 6, mound)
local mb = {}
mound:each(function(x, y) local h = G.hash(x, y, 9) if h < 0.14 then mb[K(x, y)] = -1 elseif h > 0.88 then mb[K(x, y)] = 1 end end)
G.shade(c, mound, mn, PL, { bias = mb, amb = 0.12, wrap = 0.3 })
for _, p in ipairs{ { 28, 35 }, { 29, 34 }, { 34, 37 }, { 35, 36 }, { 37, 34 }, { 30, 37 } } do c:put(p[1], p[2], "#e8662a") end
c:put(29, 35, "#b84a20") c:put(35, 37, "#b84a20")
for _, p in ipairs{ { 26, 36 }, { 33, 35 }, { 36, 37 } } do c:put(p[1], p[2], "#5a2e22") end
-- garlic bulb on top
local gm = HP.ellipse(32, 31, 2, 1.6)
G.shade(c, gm, X.sphere(31.6, 30.6, 2, gm), { "#8a7a6a", "#b8a890", "#d8ccb4", "#ece2cc", "#f8f2e2", "#fffaf0" }, { amb = 0.2 })
c:put(32, 31, "#b8a890") c:put(32, 29, "#d8ccb4") c:put(31, 30, "#fffaf0")

-- teapot (right back)
local tx, ty = 46, 25
local handle = HP.ellipse(tx + 5.5, ty + 0.5, 2.5, 3):cut(HP.ellipse(tx + 5.5, ty + 0.5, 1, 1.5))
local spout = G.sweep({ { tx - 3, ty + 2 }, { tx - 5, ty + 1.5 }, { tx - 6.5, ty - 1 }, { tx - 8, ty - 3 } }, function(t) return 1.3 - 0.6 * t end, 40)
local body = HP.ellipse(tx, ty + 1, 5, 4.5)
local foot = HP.rect(tx - 3, ty + 6, tx + 3, ty + 6)
handle:cut(body)
G.ao(c, top, body:copy():add(foot), W6[2], 1, 1)
G.pillow(c, handle, CE, 1, { amb = 0.15 })
G.pillow(c, spout, CE, 1, { amb = 0.15 })
c:put(tx - 8, ty - 3, CE[2]) -- spout mouth
G.shade(c, foot, G.vcylN(foot, tx - 3, tx + 3), CE, { amb = 0.05 })
local bn = X.sphere(tx - 0.3, ty + 0.7, 5, body)
G.shade(c, body, bn, CE, { amb = 0.12, wrap = 0.3 })
-- cobalt shoulder band + cotton-boll motif
for x = tx - 4, tx + 4 do if body:has(x, ty - 1) and x % 2 == 0 then c:put(x, ty - 1, x > tx + 1 and COBD or COB) end end
for _, p in ipairs{ { 0, 2 }, { -1, 3 }, { 1, 3 }, { 0, 4 } } do c:put(tx - 1 + p[1], ty + p[2], COB) end
c:put(tx - 1, ty + 3, CE[6])
c:put(tx - 3, ty - 1, CE[6]) c:put(tx - 2, ty - 2, CREAM)
-- lid + knob
local lid = HP.ellipse(tx, ty - 3.5, 2.6, 1)
G.pillow(c, lid, CE, 1, { amb = 0.2 })
c:put(tx, ty - 5, COB) c:put(tx + 1, ty - 5, COBD) c:put(tx, ty - 6, COB)
-- quirk: red thread from the knob to the handle
for _, p in ipairs{ { tx + 1, ty - 6 }, { tx + 2, ty - 6 }, { tx + 3, ty - 5 }, { tx + 4, ty - 4 }, { tx + 5, ty - 3 } } do c:put(p[1], p[2], "#d8323a") end
c:put(tx + 2, ty - 7, "#e8493b") c:put(tx + 6, ty - 3, "#b52e3f")

-- piala of tea (front right)
local qx, qy = 43, 36
local pb = HP.ellipse(qx, qy + 1.5, 3, 2):add(HP.rect(qx - 3, qy, qx + 3, qy + 1))
G.ao(c, top, pb, W6[2], 1, 1)
G.shade(c, pb, G.vcylN(pb, qx - 3, qx + 3, 0.2), CE, { amb = 0.1 })
for x = qx - 3, qx + 3 do if pb:has(x, qy + 2) and x % 2 == 1 then c:put(x, qy + 2, COB) end end
local prim = HP.ellipse(qx, qy, 3, 1)
prim:each(function(x, y) c:put(x, y, CE[5]) end)
c:put(qx - 1, qy, "#9a4a1e") c:put(qx, qy, "#c8702a") c:put(qx + 1, qy, "#9a4a1e") c:put(qx - 1, qy, "#e09a4a")

G.save(c, "feast-steppe-table")
