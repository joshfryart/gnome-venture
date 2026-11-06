-- devilled-eggs (final pass, Opus). Two halved eggs on a small oval ceramic plate (cream glaze, blue painted rim line,
-- visible plate thickness, well darkening under the back rim). Egg whites lit as ellipsoids with a flat glossy cut face,
-- cool-violet shade and contact shadows on the plate; golden piped filling lit as a ridged rosette (6 ribs), a paprika
-- dusting and a chive snip on top. AO where the front egg meets the back one.
-- quirk: someone has taken a bite out of the front egg (scalloped tooth edge showing white and yolk).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, atan, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.atan, math.sin, math.cos
local OUT = app.params.out or (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/")
local c = A.new("devilled-eggs")

local PLATE = { "#5f6890", "#8790b2", "#b3bad0", "#d5dbe2", "#ebeee8", "#fbf8ec" }
local BLUE  = { "#2a4a7a", "#3a6fae", "#5f9ad0" }
local WHITE = { "#7f7396", "#aaa1ba", "#cec7d3", "#e8e1dc", "#f7f0e4", "#fffaee" }
local YOLK  = { "#8a4a17", "#c07022", "#e3962c", "#f4ba42", "#fbd86c", "#fff0a6" }
local PAP   = { "#a82a2e", "#d8402f" }
local CHIVE = { "#2f7a46", "#6cbf58" }

c:groundShadow(32, 50, 21, 1.5)
-- plate: underside rim (thickness) then top
local ptok = { r = { name = "plate" } }
local under = c:ellipse(32, 43, 23, 7.5)
under:each(function(x, y) c:put(x, y, x < 22 and PLATE[3] or x < 40 and PLATE[2] or PLATE[1], ptok) end)
local top = c:ellipse(32, 41, 23, 7.5)
local well = c:ellipse(32, 41.5, 17.5, 5)
local nP = {}
top:each(function(x, y)
  local k = K(x, y)
  if well:has(x, y) then nP[k] = { 0, 0, 1 }
  else -- rim: torus-like, tilt outwards
    local dx, dy = (x - 32) / 23, (y - 41) / 7.5
    local l = sqrt(dx*dx + dy*dy) + 1e-6
    nP[k] = { A.norm(dx / l * 0.55, dy / l * 0.55, 1) } end end)
local pi_ = A.shade(c, top, nP, PLATE, { amb = 0.3, wrap = 0.4, tok = ptok, cuts = { 0.2, 0.4, 0.58, 0.74, 0.9 } })
-- well: darker towards the back rim (AO), lighter front
well:each(function(x, y) local e = ((x - 32) / 17.5)^2 + ((y - 41.5) / 5)^2
  local col = PLATE[5]
  if y < 40 and e > 0.55 then col = PLATE[3] elseif e > 0.75 and x > 36 then col = PLATE[4] elseif x < 26 and y < 43 then col = PLATE[6] end
  c:put(x, y, col, ptok) end)
-- inner rim edge line (step between rim and well): shade at the back
local we = well:edge()
we:each(function(x, y) if y <= 41 then c:put(x, y, PLATE[3], ptok) end end)
-- blue painted line on the rim
local ring = c:ellipse(32, 41, 21, 6.6):cut(c:ellipse(32, 41, 20, 5.9))
ring:clip(top):cut(well)
ring:each(function(x, y) c:put(x, y, x < 22 and BLUE[3] or x < 42 and BLUE[2] or BLUE[1], ptok) end)
-- rim gloss
c:put(16, 37, PLATE[6], ptok) c:put(17, 36, PLATE[6], ptok) c:put(18, 36, A.CREAM, ptok)

-- eggs
local function eggMasks(cx, cy, rx, ry)
  local body = c:ellipse(cx, cy, rx, ry)
  local face = c:ellipse(cx - 0.3, cy - 1.6, rx - 1.2, ry - 2.1)
  local fil = c:ellipse(cx + 0.3, cy - 2.6, rx * 0.5, ry * 0.62)
  return body, face, fil
end
local e1b, e1f, e1y = eggMasks(24.5, 36, 9.5, 5.5)
local e2b, e2f, e2y = eggMasks(39, 40, 9.5, 5.5)
-- the bite (front egg, right end): scalloped
local bite = c:ellipse(48.6, 37.6, 2.6, 2.6):add(c:ellipse(49.8, 40.4, 2.2, 2.2)):add(c:ellipse(48.4, 35.0, 1.5, 1.5))
for _, m in ipairs{ e2b, e2f, e2y } do m:cut(bite) end
-- contact shadows on the plate (down-right of each egg)
local tokS = ptok
for _, b in ipairs{ e1b, e2b } do
  b:shift(1, 1):add(b:shift(2, 1)):each(function(x, y) if top:has(x, y) and not b:has(x, y) then
    c:put(x, y, well:has(x, y) and PLATE[2] or PLATE[1], tokS) end end)
end

local function egg(body, face, fil, cx, cy, rx, ry, bias, name)
  local tok = { r = { name = name } }
  local n = {}
  body:each(function(x, y) local dx, dy = (x - cx) / (rx + .5), (y - cy) / (ry + .5)
    local q = 1 - dx*dx - dy*dy n[K(x, y)] = { A.norm(dx, dy * 1.2, sqrt(max(q, 0.03))) } end)
  A.shade(c, body, n, WHITE, { amb = 0.18, wrap = 0.3, bias = bias, tok = tok })
  -- cut face: flat, facing up/viewer; pale; darker lip at the back where the rim curls
  face:each(function(x, y)
    local f = (x - (cx - rx)) / (2 * rx)
    c:put(x, y, f < 0.55 and WHITE[6] or WHITE[5], tok) end)
  face:edge():each(function(x, y) if y > cy - 1.6 then c:put(x, y, WHITE[4], tok) end end)
  -- cool reflected light along the lower-right of the body
  body:edge():each(function(x, y) if x > cx + 2 and y > cy + 1 and not face:has(x, y) then c:put(x, y, "#9f97c4", tok) end end)
  -- filling: ridged rosette dome
  local fx, fy = cx + 0.3, cy - 2.6
  local frx, fry = rx * 0.5, ry * 0.62
  local ytok = { r = { name = name .. "-yolk" } }
  local nY, bY = {}, {}
  fil:each(function(x, y)
    local dx, dy = (x - fx) / (frx + .5), (y - fy) / (fry + .5)
    local r = sqrt(dx*dx + dy*dy)
    local a = atan(dy, dx)
    local rib = sin(a * 6 + r * 2.2) * 0.55 * min(1, r * 1.6)
    local nx, ny = dx + rib * -sin(a), dy + rib * cos(a)
    nY[K(x, y)] = { A.norm(nx, ny, sqrt(max(1 - r*r, 0.05)) + 0.2) }
    if r > 0.82 and dy > 0 then bY[K(x, y)] = -1 end
  end)
  local yi = A.shade(c, fil, nY, YOLK, { amb = 0.1, wrap = 0.25, bias = bY, tok = ytok })
  -- piped tip: brighter peak + spec
  c:put(floor(fx - 1), floor(fy - 1), YOLK[6], ytok) c:put(floor(fx - 2), floor(fy - 1), A.CREAM, ytok)
  -- AO ring where filling sits on the face
  fil:edge():each(function(x, y) if y > fy + 1 then c:put(x, y, YOLK[2], ytok) end end)
  return yi, ytok, fx, fy
end
-- back egg gets AO near the front egg
local b1 = {}
X.ao(b1, e1b, e2b, 2, -1)
egg(e1b, e1f, e1y, 24.5, 36, 9.5, 5.5, b1, "egg1")
local yi2, yt2, fx2, fy2 = egg(e2b, e2f, e2y, 39, 40, 9.5, 5.5, nil, "egg2")
-- bite edge: tooth scallops show the inside (white flesh + yolk), plus a darker bitten rim
local bE = bite:grow(1)
for _, m in ipairs{ e2b } do
  m:each(function(x, y) if bE:has(x, y) then
    if e2y:has(x, y) or e2y:grow(1):has(x, y) and y < 40 then c:put(x, y, YOLK[3], yt2)
    elseif y < 42 then c:put(x, y, WHITE[3], { r = { name = "egg2" } })
    else c:put(x, y, WHITE[2], { r = { name = "egg2" } }) end end end)
end
-- paprika dusting + chive snips
for _, p in ipairs{ { 22, 33 }, { 26, 32 }, { 24, 35 }, { 27, 34 }, { 38, 36 }, { 41, 37 }, { 37, 38 }, { 42, 35 } } do
  c:put(p[1], p[2], (p[1] + p[2]) % 2 == 0 and PAP[2] or PAP[1]) end
c:put(23, 31, CHIVE[2]) c:put(24, 31, CHIVE[1]) c:put(39, 34, CHIVE[2]) c:put(40, 34, CHIVE[1])

A.finish(c, "devilled-eggs", OUT)
