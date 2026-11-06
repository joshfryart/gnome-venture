-- rose-arch (final, Opus-style single pass). A slim rustic garden arch of weathered hazel poles (grain, knots, bevel
-- light) climbed by two wavering rose canes that wrap round the poles (behind where they turn away, in front where
-- they cross), with thorns, compound serrated leaves and seven spiral-petalled roses in red, pink and butter yellow,
-- plus two buds on short stems.
-- Material: cylinder-lit 6-tone wood with streak grain, per-pixel leaflets with midrib + veins, sphere-lit roses with
-- scalloped rim, spiral petal grooves and a cream specular.
-- quirk: a tiny bee hovers beside the crown rose.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, ceil, sqrt, max, min, abs, sin, cos, pi = math.floor, math.ceil, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "rose-arch" }
local W, LF, H = A.WOOD, A.LEAF, A.hash
local CANE = { "#3b2a2e", "#4f4a35", "#667a3e", "#86a047", "#a9c25a" }

c:groundShadow(15, 56, 5, 2)
c:groundShadow(49, 56, 5, 2)

-- beam centre line: left pole up, half ellipse over, right pole down
local raw = { { 15, 56 }, { 15, 28 } }
local pts = A.poly(raw, 0.5)
local n = 120
for i = 1, n do
  local a = pi + pi * i / n
  pts[#pts + 1] = { 32 + 17 * cos(a), 28 + 19 * sin(a) }
end
for _, p in ipairs(A.poly({ { 49, 28 }, { 49, 56 } }, 0.5)) do pts[#pts + 1] = p end
local bm, bn, BU, BS, total = A.sweep(pts, function() return 1.5 end)
local bidx = A.shade(c, bm, bn, W, { amb = 0.08, wrap = 0.25 })
bm:each(function(x, y)
  local k = K(x, y)
  local h = H(floor((BS[k] + 1) * 2.2), floor(BU[k] / 5), 8)
  if h > 0.74 then A.bump(c, bidx, W, x, y, -1) elseif h < 0.1 then A.bump(c, bidx, W, x, y, 1) end
end)
-- knots
for _, p in ipairs{ { 15, 44 }, { 49, 36 }, { 23, 12 } } do
  c:px(p[1], p[2], W[2]) c:px(p[1] + 1, p[2], W[1]) c:px(p[1], p[2] + 1, W[1]) c:px(p[1] - 1, p[2], W[4])
end
-- pole feet: pale cut end + soil
for _, x in ipairs{ 15, 49 } do
  for dx = -1, 1 do c:px(x + dx, 56, dx < 0 and W[3] or W[1]) end
  c:px(x - 3, 55, W[2]) c:px(x - 2, 55, W[3]) c:px(x + 2, 55, W[2]) c:px(x + 3, 55, W[1]) c:px(x - 2, 56, W[1]) c:px(x + 2, 56, W[1])
end

-- canes winding round the beam
local function cane(phi, u0, u1, amp)
  local out = {}
  local u = u0
  local j = 1
  while u <= u1 do
    local best
    for _, p in ipairs(pts) do if p.u >= u then best = p break end end
    if not best then break end
    local a = u * 0.42 + phi
    local off = amp * sin(a) * (0.55 + 0.45 * min(1, (u - u0) / 10))
    out[#out + 1] = { x = best[1] + best.px * off, y = best[2] + best.py * off, tx = best.tx, ty = best.ty, front = cos(a) > 0, u = u, px = best.px, py = best.py }
    u = u + 0.4
  end
  return out
end
local canes = { cane(0, 2, total - 9, 3.4), cane(pi, 12, total - 4, 3.4) }
for _, cn in ipairs(canes) do
  for pass = 1, 2 do
    for _, s in ipairs(cn) do
      local x, y = floor(s.x + 0.5), floor(s.y + 0.5)
      if (pass == 1 and not s.front) or (pass == 2 and s.front) then
        if s.front or not bm:has(x, y) then
          c:px(x, y, CANE[s.front and 4 or 3])
          if abs(s.tx) > abs(s.ty) then c:px(x, y + 1, CANE[s.front and 2 or 1]) else c:px(x + 1, y, CANE[s.front and 2 or 1]) end
        end
      end
    end
  end
  -- thorns
  local last = -99
  for _, s in ipairs(cn) do
    if s.front and s.u - last > 7.5 then
      local x, y = floor(s.x + s.px * 2 + 0.5), floor(s.y + s.py * 2 + 0.5)
      if not bm:has(x, y) then c:px(x, y, "#b8404a") last = s.u end
    end
  end
end

-- compound leaves along the canes
local function cluster(cx, cy, dx, dy)
  local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
  local mx, my = cx + dx * 3, cy + dy * 3
  c:line({ { floor(cx + 0.5), floor(cy + 0.5) }, { floor(mx + 0.5), floor(my + 0.5) } }, 1):each(function(x, y) c:px(x, y, LF[2]) end)
  A.leaflet(c, mx, my, cx + dx * 10, cy + dy * 10, 2.3, LF, { serr = true })
  for _, sg in ipairs{ 1, -1 } do
    local ca, sa = cos(sg * 1.05), sin(sg * 1.05)
    local sx, sy = dx * ca - dy * sa, dx * sa + dy * ca
    local bx, by = cx + dx * 2, cy + dy * 2
    A.leaflet(c, bx + sx * 1, by + sy * 1, bx + sx * 7, by + sy * 7, 1.9, LF, { serr = true, veins = false })
  end
end
local spots = {
  { 1, 22, -1 }, { 1, 70, 1 }, { 1, 130, 1 }, { 1, 190, -1 }, { 1, 230, 1 }, { 2, 35, 1 }, { 2, 95, -1 }, { 2, 150, -1 }, { 2, 205, 1 }, { 2, 240, -1 },
}
for _, sp in ipairs(spots) do
  local cn = canes[sp[1]]
  local s = cn[min(#cn, sp[2])]
  if s then
    local sg = sp[3]
    local dx, dy = s.px * sg, s.py * sg
    if s.y < 27 and dy < -0.25 then dx, dy = -dx, -dy end
    dy = dy + 0.25
    local l = sqrt(dx * dx + dy * dy)
    local tx, ty = s.x + dx / l * 10, s.y + dy / l * 10
    if tx >= 9 and tx <= 55 and ty >= 10 and ty <= 49 and s.y <= 46 then cluster(s.x, s.y, dx, dy) end
  end
end

-- roses and buds
local R = {
  { 32, 11, 4.6, A.EMBER, 0.2 }, { 20, 15.5, 3.8, A.PETAL, 1.1 }, { 44, 16, 3.6, A.YELLOW, 2.0 },
  { 14, 31, 4.1, A.EMBER, 0.7 }, { 50, 29, 4.2, A.PETAL, 1.6 }, { 16, 47, 3.5, A.YELLOW, 0.4 }, { 48, 45, 3.7, A.EMBER, 2.4 },
}
for _, r in ipairs(R) do
  local m = A.rose(c, r[1], r[2], r[3], r[4], { phi = r[5], sp = r[5] * 0.3 })
  A.contact(c, m, LF[1])
  c:px(floor(r[1] - r[3] * 0.45), floor(r[2] - r[3] * 0.55), "#fff6f2")
  if r[3] > 4 then c:px(floor(r[1] - r[3] * 0.45) + 1, floor(r[2] - r[3] * 0.55), "#fff6f2") end
end
A.bud(c, 10, 21, A.PETAL) c:px(11, 27, LF[2]) c:px(12, 28, LF[2])
A.bud(c, 54, 39, A.EMBER) c:px(53, 45, LF[2]) c:px(52, 46, LF[2])

-- bee
c:px(37, 8, A.INK)
c:px(38, 8, "#f5bf34") c:px(39, 8, A.INK) c:px(40, 8, "#f5bf34")
c:px(38, 9, "#d98322") c:px(39, 9, A.INK) c:px(40, 9, "#d98322")
c:px(41, 9, A.INK)
c:px(39, 7, "#e4f6ff") c:px(40, 7, A.CREAM) c:px(40, 6, "#cfe6f5")

A.fin(c, "rose-arch")
