-- ico-snowflake (final, Opus single pass). Six-armed ice crystal: slim main arms (5 px) each carrying two pairs of
-- angled side branches (3-4 px) and a diamond tip knob, around a faceted hexagonal centre plate. Material: every arm is a
-- faceted prism (lit upper-left plane, shaded lower-right plane, pale ridge core), bright glassy rim on the lit edges,
-- deep AO where branches leave the arm, a six-facet gem centre with a pale core, one cream glint + sparkle.
-- quirk: a tiny red knitted mitten hangs from the lower-right arm on a thread, as if someone lost it in the snow.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA9_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin, pi, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin, math.pi, math.atan
local c = A.new("ico-snowflake")
local ICE = { "#2a3f7a", "#3561a8", "#4a8fcc", "#74bde6", "#b2e2f4", "#e6f8ff" }
local itok, mtok = A.tok("ice"), A.tok("mitten")
local CX, CY, R = 31.5, 31.5, 22

-- segments: {ax, ay, bx, by, w0, w1, kind}
local segs = {}
for k = 0, 5 do
  local a = -pi / 2 + k * pi / 3
  local ux, uy = cos(a), sin(a)
  segs[#segs + 1] = { CX, CY, CX + ux * R, CY + uy * R, 2.3, 1.5, "arm" }
  for _, b in ipairs{ { 9.5, 5.5 }, { 15.5, 5.8 } } do
    for _, sd in ipairs{ -1, 1 } do
      local ba = a + sd * pi / 3
      local sx, sy = CX + ux * b[1], CY + uy * b[1]
      segs[#segs + 1] = { sx, sy, sx + cos(ba) * b[2], sy + sin(ba) * b[2], 1.55, 1.2, "br" }
    end
  end
end

local m, n, bias, ridge = HP.mask(), {}, {}, {}
local tips = {}
for k = 0, 5 do local a = -pi / 2 + k * pi / 3 tips[#tips + 1] = { CX + cos(a) * (R + 0.6), CY + sin(a) * (R + 0.6), a } end
for y = 2, 61 do for x = 2, 61 do
  local px, py = x + 0.0, y + 0.0
  local best, bs, bseg, bt, cnt = 1e9, 0, nil, 0, 0
  for _, s in ipairs(segs) do
    local d, sd, t = A.seg(px, py, s[1], s[2], s[3], s[4])
    local w = s[5] + (s[6] - s[5]) * t
    if d <= w then cnt = cnt + 1 end
    if d - w < best then best, bs, bseg, bt = d - w, sd, s, t end
  end
  -- diamond tip knobs
  local tipHit
  for _, tp in ipairs(tips) do
    local dx, dy = px - tp[1], py - tp[2]
    local ua, ub = dx * cos(tp[3]) + dy * sin(tp[3]), -dx * sin(tp[3]) + dy * cos(tp[3])
    if abs(ua) / 3.1 + abs(ub) / 2.6 <= 1 then tipHit = { ua, ub, tp[3] } end
  end
  local hexr = max(abs(px - CX) * 0.866 + abs(py - CY) * 0.5, abs(py - CY))
  local inHex = hexr <= 6.2
  if best <= 0 or tipHit or inHex then
    m:set(x, y)
    local key = K(x, y)
    if inHex then
      local ang = atan(py - CY, px - CX)
      local sec = floor((ang + pi) / (pi / 3)) -- 6 facets
      local fa = -pi + (sec + 0.5) * pi / 3
      if hexr < 2.6 then n[key] = { A.norm(-0.15, -0.2, 1) } ridge[key] = true
      else n[key] = { A.norm(cos(fa) * 1.1, sin(fa) * 1.1, 1) } end
      if hexr > 5.4 then bias[key] = (bias[key] or 0) end
    elseif tipHit then
      local ua, ub, a = tipHit[1], tipHit[2], tipHit[3]
      local vx, vy = -sin(a), cos(a)
      local sg = ub < 0 and -1 or 1
      if abs(ub) < 0.5 then ridge[key] = true end
      n[key] = { A.norm(vx * sg * 0.7 + cos(a) * 0.25 * (ua > 0 and 1 or -0.2), vy * sg * 0.7 + sin(a) * 0.25 * (ua > 0 and 1 or -0.2), 1) }
    else
      local s = bseg
      local vx, vy = s[3] - s[1], s[4] - s[2]
      local l = sqrt(vx * vx + vy * vy)
      local pxn, pyn = -vy / l, vx / l -- direction of +sd
      local w = s[5] + (s[6] - s[5]) * bt
      local sn = bs / (w + 0.3)
      if abs(bs) < 0.55 then ridge[key] = true n[key] = { A.norm(-0.1, -0.15, 1) }
      else
        local sg = sn < 0 and -1 or 1
        n[key] = { A.norm(pxn * sg * 0.95, pyn * sg * 0.95, 1) }
      end
      if cnt >= 2 and s[7] == "br" and bt < 0.4 then bias[key] = -1 end
    end
  end
end end
local idx = A.shade(c, m, n, ICE, { amb = 0.18, wrap = 0.35, bias = bias, tok = itok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- pale core along ridges (glass core)
for key in pairs(ridge) do
  local x, y = key % 1024 - 256, key // 1024 - 256
  local i = idx[key] or 4
  local ni = max(i, 5)
  idx[key] = ni c:put(x, y, ICE[ni], itok)
end
-- AO ring where arms meet the centre plate
m:each(function(x, y)
  local key = K(x, y)
  local hexr = max(abs(x - CX) * 0.866 + abs(y - CY) * 0.5, abs(y - CY))
  if hexr > 6.2 and hexr < 7.4 then A.step(c, idx, ICE, x, y, -2, itok) end
end)
-- bright glassy rim on lit (upper-left facing) edges
m:edge():each(function(x, y)
  if not m:has(x - 1, y) and not m:has(x, y - 1) then
    local key = K(x, y)
    if (idx[key] or 1) >= 3 then c:put(x, y, ICE[6], itok) idx[key] = 6 end
  end
end)
-- facet lines on the hex plate: darker spokes between facets on the shade half
for k = 0, 5 do
  local a = -pi + k * pi / 3
  for r = 3, 5 do
    local x, y = floor(CX + cos(a) * r + .5), floor(CY + sin(a) * r + .5)
    if a > -pi * 0.6 and a < pi * 0.4 then A.step(c, idx, ICE, x, y, -1, itok) end
  end
end
-- glint: cream 2x1 on the upper-left arm ridge + one cream sparkle off the upper-right
do
  local a = -pi / 2 - pi / 3 * 1 -- upper-left arm (k=5 equivalent)
  local x, y = floor(CX + cos(a) * 12 + .5), floor(CY + sin(a) * 12 + .5)
  c:put(x, y, A.CREAM, itok) c:put(x + 1, y, A.CREAM, itok)
  c:put(floor(CX - 1), floor(CY - 1), A.CREAM, itok)
end

-- quirk: lost red mitten hanging on a thread from the lower-right arm tip
do
  local a = -pi / 2 + 2 * pi / 3
  local tx, ty = floor(CX + cos(a) * (R + 1.5) + .5), floor(CY + sin(a) * (R + 1.5) + .5)
  local MP = { t = "#8f4a1f", c = "#fff4d6", s = "#d9c7b0", h = "#ff8a5c", R = "#e8493b", r = "#b52e3f", d = "#6e2038", g = "#f5b82e" }
  A.map(c, {
    "....t...",
    "....t...",
    "..cscsc.",
    "..ccccs.",
    "..sssss.",
    "h..hRRr.",
    "hhhRRRr.",
    ".hRRRRr.",
    ".hRRRRr.",
    ".RRRRrd.",
    "..Rrrd..",
    "...dd...",
  }, tx - 4, ty + 1, MP, mtok)
end
A.save(c, "ico-snowflake")
