-- cheese-wheel (final, Opus single pass). A waxed gouda-style wheel in 3/4 view, ray-marched per pixel from a small
-- signed-distance model: rounded, slightly bulging drum; a wedge cut out at the front shows two cut faces of pale paste
-- (one lit, one in shade) with real carved eyes (concave holes lit from inside), a 1 px rind band along every cut edge,
-- bevelled rim highlight, waxy specular streak on the rind, an embossed maker's stamp on the top, AO in the wedge corner,
-- 2-tone ground shadow.
-- quirk: a mouse has nibbled the back-left rim (two scalloped tooth bites) and dropped one crumb.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, rad = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.rad
local NAME = "cheese-wheel"
local c = A.new(NAME)

local RIND  = { "#6a2a20", "#9c4122", "#c9631f", "#e68a27", "#f6b440", "#ffd877" }
local PASTE = { "#b27d3c", "#d4a24e", "#ebc366", "#f7d985", "#fde8a6", "#fff3cc" }
local CX, CY, KZ = 31.5, 38, 0.42          -- screen centre of the base, depth foreshortening
local R, H, RR = 21, 13, 2.2
local A1, A2 = rad(38), rad(104)           -- removed wedge (angles in the XZ plane, +z toward the viewer)
local c1, s1, c2, s2 = cos(A1), sin(A1), cos(A2), sin(A2)
local LW = { A.norm(-0.5, 0.82, 0.3) }   -- world light: upper-left, from the front

local holes = {}
local function onFace(a, rho, y, r, into) holes[#holes + 1] = { rho * cos(a) + into * -sin(a), y, rho * sin(a) + into * cos(a), r } end
onFace(A1, 7.0, 7.5, 2.4, 0.5)  onFace(A1, 14.0, 4.0, 2.0, 0.4) onFace(A1, 16.0, 9.6, 1.6, 0.5)
onFace(A2, 9.0, 6.0, 1.7, -0.3) onFace(A2, 15.5, 9.5, 1.3, -0.2)
-- quirk: mouse bites on the back-left rim
local bites = { { (R + 0.4) * cos(rad(236)), H + 0.3, (R + 0.4) * sin(rad(236)), 3.0 }, { (R + 0.4) * cos(rad(252)), H + 0.3, (R + 0.4) * sin(rad(252)), 2.6 } }

local function sdCyl(x, y, z)
  local r = sqrt(x * x + z * z)
  local Rr = R + 0.9 * sin(pi * max(0, min(1, y / H)))
  local dx, dy = r - (Rr - RR), abs(y - H / 2) - (H / 2 - RR)
  return min(max(dx, dy), 0) + sqrt(max(dx, 0) ^ 2 + max(dy, 0) ^ 2) - RR
end
local function sdf(x, y, z)
  local d = sdCyl(x, y, z)
  local dw = max(-(c1 * z - s1 * x), (c2 * z - s2 * x))   -- wedge (inside < 0)
  d = max(d, -dw)
  for _, h in ipairs(holes) do d = max(d, -(sqrt((x - h[1]) ^ 2 + (y - h[2]) ^ 2 + (z - h[3]) ^ 2) - h[4])) end
  for _, h in ipairs(bites) do d = max(d, -(sqrt((x - h[1]) ^ 2 + (y - h[2]) ^ 2 + (z - h[3]) ^ 2) - h[4])) end
  return d, dw
end

c:groundShadow(CX + 1.5, CY + 1.5, R + 2, R * KZ + 1.5)

local rind, paste = HP.mask(), HP.mask()
local V, info = {}, {}
for py = 0, 63 do for px = 0, 63 do
  local x = px + 0.5 - CX - 0.5
  local hit
  local yw = H + 4
  while yw > -4 do
    local z = (py - CY + yw) / KZ
    if abs(z) < R + 3 and sdf(x, yw, z) < 0 then hit = { yw, z } break end
    yw = yw - 0.04
  end
  if hit then
    local y, z = hit[1], hit[2]
    local e = 0.25
    local nx = sdf(x + e, y, z) - sdf(x - e, y, z)
    local ny = sdf(x, y + e, z) - sdf(x, y - e, z)
    local nz = sdf(x, y, z + e) - sdf(x, y, z - e)
    nx, ny, nz = A.norm(nx, ny, nz)
    local dl = nx * LW[1] + ny * LW[2] + nz * LW[3]
    local v = 0.1 + 0.9 * max(0, (dl + 0.2) / 1.2)
    local k = K(px, py)
    V[k] = v
    info[k] = { x = x, y = y, z = z, nx = nx, ny = ny, nz = nz, dl = dl }
    local dc = sdCyl(x, y, z)
    if dc > -0.9 then rind:set(px, py) else paste:set(px, py) end
  end
end end

-- AO: paste deep in the wedge corner (near the axis, low) and around hole rims
local bias = {}
paste:each(function(x, y) local k = K(x, y) local p = info[k]
  local rho = sqrt(p.x * p.x + p.z * p.z)
  if rho < 2.2 then bias[k] = -1 end
  for _, h in ipairs(holes) do if sqrt((p.x - h[1]) ^ 2 + (p.y - h[2]) ^ 2 + (p.z - h[3]) ^ 2) < h[4] + 0.3 then bias[k] = (bias[k] or 0) - 1 end end
  if p.y < 1.4 and abs(p.ny) < 0.5 then bias[k] = (bias[k] or 0) - 1 end
end)
local ptok, rtok = { r = { name = "paste" } }, { r = { name = "rind" } }
local pidx = X.tone(c, paste, V, PASTE, { cuts = { 0.12, 0.24, 0.42, 0.6, 0.78 }, bias = bias, tok = ptok })
local rbias = {}
rind:each(function(x, y) local p = info[K(x, y)]
  if p.y < 1.0 and p.ny < -0.3 then rbias[K(x, y)] = -1 end
  if p.ny < 0.35 and p.y < H - 1.2 and info[K(x, y - 1)] and info[K(x, y - 1)].ny > 0.5 then rbias[K(x, y)] = (rbias[K(x, y)] or 0) - 1 end end)
local ridx = X.tone(c, rind, V, RIND, { cuts = { 0.2, 0.34, 0.5, 0.66, 0.82 }, bias = rbias, tok = rtok })

-- rind: waxy specular streak on the drum's lit shoulder, bevel glint on the top rim, cool bounce lower-right
rind:each(function(x, y) local k = K(x, y) local p = info[k]
  local hx, hy, hz = A.norm(LW[1], LW[2] + 0.4, LW[3] + 1)
  local sp = max(0, p.nx * hx + p.ny * hy + p.nz * hz) ^ 30
  if sp > 0.55 and p.y > 2 and p.y < H - 2.5 then c:put(x, y, "#fff0b8", rtok) end
  if p.nx > 0.55 and p.nz > 0.2 and p.y > 1 and p.y < H - 2 and abs(p.ny) < 0.3 and not rind:has(x + 1, y) then c:put(x, y, "#8a4a52", rtok) end
end)
-- embossed maker's stamp on the top (ring + centre dot, lit lower lip)
local SX, SZ, SR = -7.5, -4, 3.6
rind:each(function(x, y) local k = K(x, y) local p = info[k]
  if p.ny > 0.92 then
    local d = sqrt((p.x - SX) ^ 2 + ((p.z - SZ) * 1.0) ^ 2)
    if abs(d - SR) < 0.55 then
      local up = (p.z - SZ) < 0
      c:put(x, y, up and RIND[max(1, (ridx[k] or 5) - 2)] or RIND[6], rtok)
    elseif d < 0.8 then c:put(x, y, RIND[max(1, (ridx[k] or 5) - 2)], rtok) end
  end
end)
-- paste: tiny pale curd flecks (aged crystals) on the lit face
paste:each(function(x, y) local k = K(x, y) local p = info[k]
  if (pidx[k] or 0) >= 4 and X.hash(x, y, 7) > 0.93 then c:put(x, y, "#fffbe6", ptok) end end)
-- separation: one darker row where rind meets a different-facing paste face
paste:each(function(x, y) local k = K(x, y)
  for _, d in ipairs{ { 0, -1 }, { -1, 0 } } do
    if rind:has(x + d[1], y + d[2]) and info[K(x + d[1], y + d[2])].ny > 0.8 and info[k].ny < 0.5 then
      c:put(x + d[1], y + d[2], RIND[max(1, (ridx[K(x + d[1], y + d[2])] or 4) - 1)], rtok) end
  end
end)
-- crumb from the bite
do local cx, cz = (R - 6) * cos(rad(232)), (R - 6) * sin(rad(232))
  local x, y = floor(CX + cx), floor(CY + cz * KZ - H + 0.5)
  c:put(x, y, PASTE[6], ptok) c:put(x + 1, y, PASTE[4], ptok) c:put(x + 1, y + 1, RIND[2], rtok) c:put(x + 2, y, RIND[3], rtok) end
A.save(c, NAME)
