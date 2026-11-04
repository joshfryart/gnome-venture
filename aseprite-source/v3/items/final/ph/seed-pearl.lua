-- seed-pearl (D15 artist pass). A big lustrous seed pearl (pearl ramp with a pink sheen top-left and a mint bounce lower-right,
-- window specular) cradled in front of an upright scallop shell: radiating ribs lit as real ridges, scalloped rim, growth rings,
-- a hinge band with ears, two tiny seed pearls at its foot.
-- quirk: a hairline crack on top of the pearl, and a sprout with three leaves already pushing out of it.
local NAME = "seed-pearl"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_1.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new2(NAME)
local PX, PY, PR = 32, 46.5, 9
local OX, OY, OR, NR = 32, 54, 24, 10

-- shell fan mask + ridge normals
local fan, fn, fb = HP.mask(), {}, {}
for y = OY - OR - 3, OY + 1 do for x = OX - OR - 3, OX + OR + 3 do
  local dx, dy = x - OX + .0, y - OY + .0
  local r = sqrt(dx * dx + dy * dy)
  if dy <= 0 and r >= 2 then
    local th = atan(dy, dx)               -- -pi .. 0 across the top
    local p = (th + pi) / pi * NR
    local f = p - floor(p)
    local edge = OR - 2.4 + 2.6 * sin(pi * f) ^ 0.55
    if r <= edge then
      fan:set(x, y)
      local k = K(x, y)
      local slope = 0.95 * cos(pi * f)
      local tx, ty = -sin(th), cos(th)
      local nx = -slope * tx + 0.32 * dx / OR
      local ny = -slope * ty + 0.32 * dy / OR
      local l = sqrt(nx * nx + ny * ny + 1)
      fn[k] = { nx / l, ny / l, 1 / l }
      for _, rr in ipairs{ 8, 12.5, 17, 21.5 } do if abs(r - rr) < 0.55 and f > 0.12 and f < 0.88 then fb[k] = (fb[k] or 0) - 1 end end
      if r < 6 then fb[k] = (fb[k] or 0) - 1 end
    end
  end
end end
-- hinge band with ears
local hinge = c:poly{ {16, 55}, {19, 50}, {45, 50}, {48, 55} }
fan:add(hinge)
local pm = A.ell(PX, PY, PR, PR, 0)
X.ao(fb, fan, pm, 2, -1)
A.cast(fb, fan, pm, 1, 2, -1)
local ftok = { r = { name = "shell" } }
for k, _ in pairs(fn) do end
-- normals for hinge: flat-ish
hinge:each(function(x, y) local k = K(x, y) if not fn[k] then
  local t = (x - 32) / 15
  fn[k] = { t * 0.45, -0.3 + (y - 50) * 0.12, 0.85 }
end end)
A.toneN(c, fan, fn, R.coral, { bias = fb, tok = ftok, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, amb = 0.1, wrap = 0.3 })
-- hinge band lines and rim light on the hinge top
A.ln(c, 19, 50, 45, 50, R.coral[6], hinge)
A.ln(c, 17, 54, 47, 54, R.coral[2])
for _, x in ipairs{ 23, 27, 37, 41 } do c:px(x, 52, R.coral[2]) end
-- lit scalloped rim: pale lip on the upper-left half
fan:edge():each(function(x, y) end)
fan:each(function(x, y)
  if not fan:has(x - 1, y - 1) and y < OY - 4 and x < OX + 6 then c:px(x, y, R.coral[6]) end
end)

-- big pearl
local pn = X.sphere(PX - .4, PY - .4, PR, pm)
local pb = {}
A.cast(pb, HP.mask(), pm, 0, 0, 0)
local idx = A.toneN(c, pm, pn, R.pearl, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, amb = 0.08, wrap = 0.35 })
pm:each(function(x, y)
  local k = K(x, y) local n = pn[k] local i = idx[k]
  if not n or not i then return end
  if n[1] * 0.55 + n[2] * 0.8 > 0.5 and i <= 4 then c:px(x, y, R.mint[max(1, min(4, i - 1))])           -- cool bounce lower-right
  elseif n[1] * -0.6 + n[2] * -0.8 > 0.15 and (i == 3 or i == 4) and (x + y) % 2 == 0 then c:px(x, y, R.rose[i - 2]) end  -- rosy sheen
end)
-- iridescent arc across the belly
for t = 0, 1, 0.04 do
  local a = pi * (0.15 + 0.5 * t)
  local x, y = floor(PX + 1 + cos(a) * 6 + .5), floor(PY + 1.5 + sin(a) * 6 + .5)
  if pm:has(x, y) and (x + y) % 2 == 0 then c:px(x, y, R.mint[3]) end
end
-- window specular + glint
for _, p in ipairs{ {28,41}, {29,41}, {30,41}, {27,42}, {28,42}, {29,42}, {27,43} } do c:px(p[1], p[2], R.pearl[6]) end
c:px(26, 45, A.CREAM) c:px(32, 40, A.CREAM)
-- ambient dark rim at the pearl foot
for x = 27, 37 do local y = 55 if pm:has(x, y) then c:px(x, y, R.pearl[1]) end end

-- two tiny seed pearls at the foot of the shell
for _, q in ipairs{ {20.5, 52.5, 2.7}, {45, 53.2, 2.4} } do
  local m = A.ell(q[1], q[2], q[3], q[3], 0)
  c:fillMask(A.ell(q[1] + 1, q[2] + 1.2, q[3], q[3] * .8, 0), R.coral[1])
  local n = X.sphere(q[1] - .3, q[2] - .3, q[3], m)
  A.toneN(c, m, n, R.pearl, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, amb = 0.08, wrap = 0.3 })
  c:px(floor(q[1] - .7), floor(q[2] - 1), R.pearl[6])
end

-- crack in the pearl + sprout
for _, p in ipairs{ {32,37}, {32,38}, {33,39}, {32,40} } do c:px(p[1], p[2], R.pearl[1]) end
c:px(31, 38, R.pearl[2])
local sm, sn = A.tube({ {32, 38}, {32, 32}, {31, 28}, {32, 24} }, function(t) return 0.95 end)
A.toneN(c, sm, sn, R.fresh, { cuts = { 0.2, 0.4, 0.6, 0.8, 0.92 }, amb = 0.1, wrap = 0.3 })
A.leafE(c, 26.2, 28, 5.2, 2.9, 0.38, R.fresh, R.fresh[6])
A.leafE(c, 38.4, 26.6, 5, 2.8, -0.45, R.fresh, R.fresh[6])
A.leafE(c, 32, 21.4, 2, 3.4, 1.5708, R.fresh, R.fresh[6])
c:px(31, 29, R.fresh[2]); c:px(33, 28, R.fresh[2])
A.save2(c, NAME)
