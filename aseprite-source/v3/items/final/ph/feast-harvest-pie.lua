-- feast-harvest-pie (final, Opus single pass). A slim lattice-topped berry-apple pie on a shallow cream plate, seen 3/4,
-- one wedge already served so the cut face shows golden top crust, glossy plum filling with apple chunks, and the base crust.
-- Material: domed per-pixel light; woven lattice (over/under, each strip rounded, cast shadow into the filling gaps),
-- crimped bead rim, fluted crust wall, sugar sparkle; concave glazed plate with a cobalt band and a dark edge;
-- contact shadow where the pie sits and inside the empty wedge, two crumbs. quirk: one curl of steam rising from the cut.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, atan, sqrt, max, min, pi = math.floor, math.abs, math.sin, math.cos, math.atan, math.sqrt, math.max, math.min, math.pi
local norm = A.norm
local c = A.new("feast-harvest-pie")

local CRUST = { "#5a2630", "#8c4630", "#bb6e32", "#de9a42", "#f2c266", "#fde7a6" }
local FILL  = { "#2e0f2a", "#561637", "#86203f", "#b4324a", "#de5560", "#ff9488" }
local APPLE = "#f6d27c"
local PLATE = { "#4a4566", "#7a7795", "#a8a7bd", "#cfd0da", "#ebe7e2", "#fdf8ee" }
local BLUE  = { "#26306a", "#33489a", "#4d6cc4" }
local SPEC, STEAM = "#fff4d6", { "#e6dcef", "#fbf6ee" }

local cx, cy, rx, ry, H = 32, 33, 19, 8.5, 6
local PX, PY, PRX, PRY = 32, 41, 25, 7.5
local T1, T2 = 0.22, 1.22

local function uv(x, y, ox, oy) return (x - cx) / rx, (y - (oy or cy)) / ry end
local function inTop(x, y) local u, v = uv(x, y) return u*u + v*v <= 1 end
local function ang(x, y) local u, v = uv(x, y) return atan(v, u) end
local function inSec(x, y) if not inTop(x, y) then return false end local a = ang(x, y) return a >= T1 and a <= T2 end
local function inRT(x, y) return inTop(x, y) and not inSec(x, y) end

-- masks
local RT = A.pmask(8, 20, 56, 46, inRT)
local SW = HP.mask()
for d = 0, H do RT:shift(0, d):each(function(x, y) SW:set(x, y) end) end
local P1x, P1y = cx + rx * cos(T1), cy + ry * sin(T1)
local QUAD = c:poly{ { cx, cy }, { floor(P1x + .5), floor(P1y + .5) }, { floor(P1x + .5), floor(P1y + .5) + H }, { cx, cy + H } }
QUAD:clip(SW)
local FACE = QUAD:copy():cut(RT)
local WALL = SW:copy():cut(RT):cut(FACE)

-- ground shadow + plate
c:groundShadow(PX, PY + 7, 23, 3)
local ptop = A.emask(PX, PY, PRX, PRY)
local pund = A.emask(PX, PY + 2, PRX - 1, PRY):cut(ptop)
A.vcyl(c, pund, { PLATE[1], PLATE[1], PLATE[2], PLATE[2], PLATE[3], PLATE[3] }, PX - PRX, PX + PRX, { amb = 0.1 })
local pn, pbias = {}, {}
ptop:each(function(x, y)
  local u, v = (x - PX) / PRX, (y - PY) / PRY
  local rr = sqrt(u*u + v*v)
  local k = K(x, y)
  if rr > 0.78 then local s = (rr - 0.78) / 0.22 pn[k] = { norm(-u / rr * 0.55 * (1 - s * 0.4), -v / rr * 0.55, 1) }
  else pn[k] = { norm(0.05, 0.08, 1) } end
end)
-- contact shadow of the pie on the plate (right/below), and inside the empty wedge
A.contact(pbias, ptop, SW, 1, 1, -1) A.contact(pbias, ptop, SW, 2, 1, -1)
A.contact(pbias, ptop, SW, 0, 1, -1)
local pidx = A.shade(c, ptop, pn, PLATE, { amb = 0.18, wrap = 0.35, bias = pbias })
ptop:each(function(x, y)
  local u, v = (x - PX) / PRX, (y - PY) / PRY
  local rr = sqrt(u*u + v*v)
  if rr > 0.84 and rr < 0.92 and not SW:has(x, y) then
    local i = pidx[K(x, y)] or 3
    c:put(x, y, BLUE[i >= 5 and 3 or (i >= 3 and 2 or 1)])
  end
end)
-- rim lip highlight (back edge catches light) + one glaze glint
for x = PX - 14, PX - 6 do local y = floor(PY - PRY * sqrt(1 - ((x - PX) / PRX)^2) + 1.2) if not SW:has(x, y) then c:put(x, y, PLATE[6]) end end
c:put(PX - 20, PY - 2, SPEC)

-- pie wall: fluted crust, cylinder light, deep base row
local wb = {}
WALL:each(function(x, y) local k = K(x, y)
  if x % 3 == 0 then wb[k] = -1 end
  if not SW:has(x, y + 1) then wb[k] = (wb[k] or 0) - 2 elseif not SW:has(x, y + 2) then wb[k] = (wb[k] or 0) - 1 end
end)
local _, wn = A.vcyl(c, WALL, CRUST, cx - rx, cx + rx, { amb = 0.1, wrap = 0.3, bias = wb, ny = function() return 0.25 end })
-- cool bounce off the plate on the lower-right wall
WALL:each(function(x, y) if x > cx + 8 and not SW:has(x, y + 1) then c:put(x, y, "#9a5a5c") end end)

-- top: crimp ring, lattice, filling
local lat, tn, tb, kind = HP.mask(), {}, {}, {}
local function strip(p) local m = p % 7 return m < 3, (m / 3 - 0.5) * 2 end
RT:each(function(x, y)
  local u, v = uv(x, y)
  local rr = sqrt(u*u + v*v)
  local a = atan(v, u)
  local k = K(x, y)
  local dome = { u * 0.35, v * 0.35 }
  local crimp = 0.83 - 0.07 * abs(sin(a * 9))
  if rr > crimp then
    local s = (rr - 0.92) / 0.09
    tn[k] = { norm(u / rr * s * 0.9 + dome[1], v / rr * s * 0.9 + dome[2], 1) }
    kind[k] = "rim"
    if abs(sin(a * 9)) < 0.18 then tb[k] = -1 end
  else
    local Xx, Yy = x - cx, (y - cy) * rx / ry * 0.82
    local p, q = Xx + Yy + 40, Xx - Yy + 40
    local s1, a1 = strip(p)
    local s2, a2 = strip(q)
    local over = (floor(p / 7) + floor(q / 7)) % 2 == 0
    if s1 and (not s2 or over) then
      tn[k] = { norm(a1 * 0.5 + dome[1], a1 * 0.5 + dome[2], 1) } kind[k] = "s1" lat:set(x, y)
      if s2 then kind[k] = "x1" end
    elseif s2 then
      tn[k] = { norm(a2 * 0.5 + dome[1], -a2 * 0.5 + dome[2], 1) } kind[k] = "s2" lat:set(x, y)
      if s1 then kind[k] = "x2" end
    else
      tn[k] = { norm(dome[1], dome[2], 1) } kind[k] = "f"
    end
  end
end)
-- weave: under-strip darkens next to the crossing; filling sunk + shaded by strips (cast lower-right)
local fillM, crustM = HP.mask(), HP.mask()
RT:each(function(x, y) local k = K(x, y) if kind[k] == "f" then fillM:set(x, y) else crustM:set(x, y) end end)
local fb = {}
fillM:each(function(x, y) fb[K(x, y)] = -1 end)
A.contact(fb, fillM, crustM, 1, 1, -1)
A.contact(fb, fillM, crustM, 0, 1, -1)
RT:each(function(x, y) local k = K(x, y)
  local kd = kind[k]
  if kd == "s1" or kd == "s2" then
    local other = kd == "s1" and "x2" or "x1"
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      if kind[K(x + d[1], y + d[2])] == other then tb[k] = (tb[k] or 0) - 1 break end
    end
  end
end)
local cidx = A.shade(c, crustM, tn, CRUST, { amb = 0.12, wrap = 0.3, bias = tb, tok = { r = { name = "crust" } } })
local fidx = A.shade(c, fillM, tn, FILL, { amb = 0.1, wrap = 0.3, bias = fb, tok = { r = { name = "fill" } } })
-- gloss on filling, sugar sparkle on crust
fillM:each(function(x, y) local k = K(x, y)
  if (fidx[k] or 0) >= 4 and X.hash(x, y, 3) > 0.72 then c:put(x, y, FILL[6]) end end)
crustM:each(function(x, y) local k = K(x, y)
  if (cidx[k] or 0) >= 5 and X.hash(x, y, 7) > 0.86 then c:put(x, y, CRUST[6]) end end)

-- cut face: top crust, filling with apple chunks, base crust
local F_top = function(x) return cy + (x - cx) * (P1y - cy) / (P1x - cx) end
FACE:each(function(x, y)
  local d = y - F_top(x)
  local col
  if d < 1.6 then col = (x < cx + 3) and CRUST[3] or CRUST[4]
  elseif d > H - 1.2 then col = CRUST[2]
  else
    local h = X.hash(x, y, 11)
    if h > 0.74 then col = APPLE elseif h > 0.5 then col = FILL[4] elseif x < cx + 4 then col = FILL[2] else col = FILL[3] end
  end
  c:put(x, y, col)
end)
-- filling seeping slightly onto the plate at the cut foot
c:put(floor(P1x) - 2, floor(P1y) + H + 1, FILL[3]) c:put(floor(P1x) - 3, floor(P1y) + H + 1, FILL[2])
-- two crumbs in the empty wedge
c:put(cx + 9, cy + 11, CRUST[4]) c:put(cx + 10, cy + 11, CRUST[3])
c:put(cx + 14, cy + 9, CRUST[5])
-- pie glint on the lit crust
c:put(cx - 12, cy - 5, SPEC) c:put(cx - 11, cy - 5, CRUST[6])

-- quirk: a single steam curl rising from the cut
local sx, sy = cx + 9, cy - 9
local curl = { {0,0},{0,-1},{-1,-2},{-1,-3},{0,-4},{1,-5},{1,-6},{0,-7},{-1,-8},{-1,-9},{0,-10},{1,-11} }
for i, p in ipairs(curl) do
  c:put(sx + p[1], sy + p[2], i % 4 == 1 and STEAM[1] or STEAM[2])
  c:put(sx + p[1] + 1, sy + p[2], STEAM[1])
end
A.save(c, "feast-harvest-pie")
