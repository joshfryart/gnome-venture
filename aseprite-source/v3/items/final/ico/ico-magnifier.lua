-- ico-magnifier (final, Opus). A round hand lens tilted on the diagonal: a polished brass torus rim (4 px) round a
-- clear sea-glass lens, a short steel ferrule, then a slim turned walnut handle with a rounded butt.
-- Material: per-pixel torus light on the rim (6 tones, bright outer lip upper-left, dark inner lip), glass lit as a
-- shallow dome (pale core, darker lower-right, bright rim crescent + two glare streaks), the rim's shadow inside the
-- lens upper-left (AO); steel ferrule with turned rings; walnut cylinder with long grain lines and a lit end cap.
-- quirk: a smudgy thumbprint on the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi, cos, sin, atan = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.cos, math.sin, math.atan
local c = A.new("ico-magnifier")
local BR = { "#5e2a1e", "#8f4a1f", "#c5772a", "#e8a536", "#f9cd5a", "#ffeaa0" }
local GL = { "#2f5d8a", "#3f7fab", "#5fa8c4", "#8fd0d6", "#bfeae2", "#e8fbf3" }
local ST = { "#2b2a46", "#47496d", "#6c7193", "#98a0bc", "#c6cde0", "#eef1f8" }
local WD = { "#2e1820", "#4e2a26", "#70402c", "#94593a", "#b8784c", "#d89c68" }
local SPEC = "#fffbe8"
local tR, tG, tS, tW = { r = { name = "rim" } }, { r = { name = "glass" } }, { r = { name = "ferrule" } }, { r = { name = "wood" } }
local CX, CY, RO, RI = 24.5, 24.5, 15.6, 11.4
local D = { 0.7071, 0.7071 }

-- handle (painted first; rim overlaps its neck)
local function axis(t) return CX + D[1] * t, CY + D[2] * t end
local hp = {}
for t = 15, 41, 0.5 do local x, y = axis(t) hp[#hp + 1] = { x, y } end
local function hw(f) local t = 15 + f * 26
  if t < 17.5 then return 2.2 end            -- neck
  if t < 23 then return 3.1 end              -- ferrule
  return 2.9 + (t - 23) / 18 * 0.6            -- handle, swelling slightly to the butt
end
local hm, hn, HT, HS = A.ptube(hp, hw)
local fe, wd, nk = HP.mask(), HP.mask(), HP.mask()
hm:each(function(x, y) local t = 15 + HT[K(x, y)] * 26
  if t < 17.5 then nk:set(x, y) elseif t < 23 then fe:set(x, y) else wd:set(x, y) end end)
local nidx = A.shade(c, nk, hn, BR, { amb = 0.05, wrap = 0.15, tok = tR })
local fidx = A.shade(c, fe, hn, ST, { amb = 0.05, wrap = 0.15, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, tok = tS })
local widx = A.shade(c, wd, hn, WD, { amb = 0.06, wrap = 0.2, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, tok = tW })
-- ferrule turned rings + AO where wood enters
fe:each(function(x, y) local t = 15 + HT[K(x, y)] * 26
  if abs(t - 20) < 0.5 then A.step(c, fidx, ST, x, y, -2, tS) end
  if t > 22.2 then A.step(c, fidx, ST, x, y, -1, tS) end end)
wd:each(function(x, y) local t = 15 + HT[K(x, y)] * 26 if t < 24.2 then A.step(c, widx, WD, x, y, -2, tW) end end)
-- walnut grain: long lines along the handle, offset across
wd:each(function(x, y) local k = K(x, y)
  local t, s = 15 + HT[k] * 26, HS[k]
  local g = s * 3.1 + sin(t * 0.7) * 0.35
  if abs(g - floor(g + .5)) < 0.17 and t > 25 and t < 39.5 and X.hash(floor(t / 3), floor(g + .5), 2) > 0.25 then
    A.step(c, widx, WD, x, y, -1, tW) end end)
-- specular streak on the handle + lit end cap
for t = 26, 35 do local x, y = axis(t) local px, py = floor(x - 1.5 + .5), floor(y + 0.0 + .5)
  if wd:has(px, py) then c:put(px, py, WD[6], tW) end end
do local x, y = axis(18.5) c:put(floor(x - 1.2), floor(y + .2), ST[6], tS) c:put(floor(x - 1.2), floor(y - .8), SPEC, tS) end

-- rim (torus)
local rm, rn, RR = HP.mask(), {}, {}
for y = floor(CY - RO) - 1, floor(CY + RO) + 1 do for x = floor(CX - RO) - 1, floor(CX + RO) + 1 do
  local dx, dy = x + .5 - CX, y + .5 - CY
  local r = sqrt(dx * dx + dy * dy)
  if r <= RO and r > RI then
    rm:set(x, y)
    local mid, hwr = (RO + RI) / 2, (RO - RI) / 2
    local sn = max(-0.95, min(0.95, (r - mid) / (hwr + 0.4)))
    rn[K(x, y)] = { dx / r * sn, dy / r * sn, sqrt(1 - sn * sn) }
    RR[K(x, y)] = r
  end
end end
local ridx = A.shade(c, rm, rn, BR, { amb = 0.06, wrap = 0.2, tok = tR })
-- glints on the rim's upper-left crown
for _, g in ipairs(A.glint(rm, rn, 60, 3)) do c:put(g[1], g[2], BR[6], tR) end
do local g = A.glint(rm, rn, 60, 1)[1] c:put(g[1], g[2], SPEC, tR) end
-- small screw where the neck meets the rim
local sx, sy = axis(RO - 0.6)
sx, sy = floor(sx), floor(sy)
A.map(c, { "hb", "bd" }, sx, sy, { h = BR[6], b = BR[3], d = BR[1] }, tR)

-- glass
local gm = HP.mask()
local gn = {}
for y = floor(CY - RI) - 1, floor(CY + RI) + 1 do for x = floor(CX - RI) - 1, floor(CX + RI) + 1 do
  local dx, dy = x + .5 - CX, y + .5 - CY
  local r = sqrt(dx * dx + dy * dy)
  if r <= RI then gm:set(x, y)
    local nx, ny = dx / (RI + 1) * 0.55, dy / (RI + 1) * 0.55
    gn[K(x, y)] = { nx, ny, sqrt(1 - nx * nx - ny * ny) } end
end end
local gbias = {}
-- rim shadow on the glass, upper-left inner band (AO)
gm:each(function(x, y) local dx, dy = x + .5 - CX, y + .5 - CY
  local r = sqrt(dx * dx + dy * dy)
  if r > RI - 1.6 and (dx + dy) < -3 then gbias[K(x, y)] = -2 end
  if r > RI - 1.0 and (dx + dy) >= -3 then gbias[K(x, y)] = -1 end end)
local gidx = A.shade(c, gm, gn, GL, { amb = 0.3, wrap = 0.4, cuts = { 0.2, 0.4, 0.58, 0.74, 0.9 }, bias = gbias, tok = tG })
-- bright refracted crescent on the lower-right inside edge (light passing through)
gm:each(function(x, y) local dx, dy = x + .5 - CX, y + .5 - CY
  local r = sqrt(dx * dx + dy * dy)
  if r > RI - 2.4 and r <= RI - 1.0 and (dx + dy) > 9 then c:put(x, y, GL[5], tG) end end)
-- glare streaks: two parallel diagonal strokes upper-left
local function streak(u0, u1, v, col)
  for u = u0, u1, 0.5 do
    local x = floor(CX + (-0.7071) * v + 0.7071 * u + .5)
    local y = floor(CY + (0.7071) * v + 0.7071 * u - 0.0 + .5)
    -- along the -45 deg direction (lower-left to upper-right): use perpendicular basis
    local ax, ay = CX - 4.6 + u * 0.7071 + v * 0.7071, CY - 4.6 - u * 0.7071 + v * 0.7071
    local px, py = floor(ax + .5), floor(ay + .5)
    if gm:has(px, py) then c:put(px, py, col, tG) end
  end
end
streak(-3.5, 3.5, 0, GL[6]) streak(-3.0, 3.0, 0.7, GL[6]) streak(-1.5, 1.5, 3.0, GL[6])
c:put(floor(CX - 6), floor(CY - 4), SPEC, tG)
-- quirk: thumbprint smudge, lower-right of the lens: concentric loops one tone down
local TX, TY = CX + 3.2, CY + 3.6
gm:each(function(x, y) local dx, dy = (x + .5 - TX) / 1.0, (y + .5 - TY) / 1.3
  local r = sqrt(dx * dx + dy * dy)
  if r < 3.6 and r > 0.6 and (r % 1.6) < 0.55 then A.step(c, gidx, GL, x, y, -1, tG) end end)

A.save(c, "ico-magnifier")
