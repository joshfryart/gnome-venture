-- loach-scale (final, Opus single pass aC21_1). One cycloid fish scale, tilted: a squarish crenulated anterior edge
-- (upper-left) with radii grooves fanning from the focus, fine concentric growth rings (circuli), and a rounded
-- posterior field (lower-right) stained olive-gold with dark loach mottling.
-- Material: shallow-dish per-pixel light on a 6-tone pearl ramp, an iridescent teal/rose sheen band, specular streak,
-- cool bounce on the lower-right rim, groove shadows with lit lips. quirk: a tiny water droplet clings near the rim.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.atan
local c = A.new("loach-scale")
local PEARL = { "#3e4a6a", "#5b6c8e", "#7f93b0", "#a7bccf", "#cfe0e6", "#f2f7ee" }
local OLIVE = { "#3c3326", "#5e5232", "#86763c", "#ad9a4c", "#cfbe6e", "#ece09a" }
local TEAL, ROSE, BOUNCE = "#8fd6cf", "#d9b0d6", "#8a7fb8"
local SPOT = "#463826"

-- local frame: u along anterior->posterior (down-right), v across
local CX, CY = 32, 31
local F = A.frame(CX, CY, 0.5, 0.87)
local HL, HW = 24, 16
local m, n, U, V = HP.mask(), {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local u, v = F.UV(x, y)
  local a, b = u / HL, v / HW
  local p = (a < 0) and 2.5 or 2.0          -- squarish front, round back
  local q = abs(a) ^ p + abs(b) ^ 2.2
  -- posterior narrows a little (teardrop)
  if a > 0 then q = abs(a) ^ 2 + (abs(b) / (1 - 0.18 * a)) ^ 2.2 end
  if q <= 1 then
    m:set(x, y) U[K(x, y)], V[K(x, y)] = a, b
  end
end end
-- crenulations: notches on the anterior edge where the radii end
local FOC_U = 0.25                                   -- focus sits a little behind the centre
local fx, fy = F.W(FOC_U * HL, 0)
local radii = { -0.84, -0.42, 0.0, 0.42, 0.84 }
local function ang(x, y) return atan(y - fy, x - fx) end
local back = atan(-F.uy, -F.ux)                     -- direction toward the anterior edge
local edge = m:edge()
edge:each(function(x, y)
  local a = U[K(x, y)]
  if a < -0.5 then
    local d = ang(x, y) - back
    for _, r in ipairs(radii) do if abs(d - r * 0.95) < 0.07 then m.s[K(x, y)] = nil end end
  end
end)
-- shallow dish with a rolled rim: pillow + slight overall tilt toward the light
local pn = X.pillow(m, 3.5, 0.7)
m:each(function(x, y) local k = K(x, y) local nn = pn[k]
  n[k] = { A.norm(nn[1] * 0.9 - 0.05, nn[2] * 0.9 - 0.08, nn[3]) } end)
local bias = {}
-- posterior pigment field
local post = HP.mask()
m:each(function(x, y) local k = K(x, y) if U[k] > 0.32 + 0.25 * V[k] ^ 2 then post:set(x, y) end end)
local front = m:copy():cut(post)
local fi = A.shade(c, front, n, PEARL, { amb = 0.12 })
local pi_ = A.shade(c, post, n, OLIVE, { amb = 0.1 })
-- groove: circuli (rings around the focus) on the pearl field
front:each(function(x, y) local k = K(x, y)
  local d = sqrt((x - fx) ^ 2 + (y - fy) ^ 2)
  local r = d % 3.6
  if d > 5 and r < 0.55 then A.step(c, fi, PEARL, x, y, -1) end
end)
-- radii: dark grooves from focus to the notches, lit lip beside
for _, r in ipairs(radii) do
  local a = back + r * 0.95
  local ca, sa = math.cos(a), math.sin(a)
  for t = 4, 30, 0.5 do
    local x, y = floor(fx + ca * t + .5), floor(fy + sa * t + .5)
    if front:has(x, y) then
      c:put(x, y, PEARL[max(1, fi[K(x, y)] - 2)])
      local lx, ly = floor(fx + ca * t - sa * 1 + .5), floor(fy + sa * t + ca * 1 + .5)
      if front:has(lx, ly) and fi[K(lx, ly)] >= 3 and (lx ~= x or ly ~= y) then c:put(lx, ly, PEARL[min(6, fi[K(lx, ly)] + 1)]) end
    end
  end
end
-- boundary between pearl and pigment: dark row (where they meet)
post:each(function(x, y) if front:has(x - 1, y) or front:has(x, y - 1) then c:put(x, y, OLIVE[2]) end end)
-- loach mottling: irregular dark spots on the posterior field
for _, s in ipairs{ { 0.62, -0.35 }, { 0.78, 0.15 }, { 0.5, 0.4 }, { 0.88, -0.1 }, { 0.6, 0.0 } } do
  local x, y = F.W(s[1] * HL, s[2] * HW)
  x, y = floor(x + .5), floor(y + .5)
  for _, d in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 } } do if post:has(x + d[1], y + d[2]) then c:put(x + d[1], y + d[2], SPOT) end end
end
-- iridescent sheen band across the lit front field
front:each(function(x, y) local k = K(x, y)
  local s = U[k] + 0.55 * V[k]
  if fi[k] >= 4 and s > -0.42 and s < -0.36 then c:put(x, y, TEAL) end
  if fi[k] >= 4 and s > -0.36 and s < -0.31 then c:put(x, y, ROSE) end
end)
-- specular streak along the rolled upper-left rim
local sx, sy = A.specAt(front, n, 30)
for i = -2, 1 do local x, y = sx + i, sy - i if front:has(x, y) then c:put(x, y, PEARL[6]) end end
c:put(sx, sy, "#fffbea")
-- cool bounce on the lower-right rim
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.55 and V[k] > 0.2 then c:put(x, y, BOUNCE) end end)
-- focus dot
c:put(floor(fx + .5), floor(fy + .5), PEARL[2])

-- quirk: a water droplet near the rim
local dx, dy = F.W(-0.1 * HL, -0.62 * HW) dx, dy = floor(dx + .5), floor(dy + .5)
A.map(c, { ".ab.", "abbc", "bbcd", ".cd." }, dx - 1, dy - 1, { a = "#f4fbff", b = "#c4eaf2", c = "#8cc8dc", d = "#5f8fb8" })
A.save(c, "loach-scale")
