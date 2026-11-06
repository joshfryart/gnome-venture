-- firefly-glow (B3, Opus single pass). A slim firefly beetle on the diagonal, head up-left, its lantern lit.
-- Parts: pink-red pronotum shield with the dark central spot (the Photinus tell), small dark head with glossy eyes,
-- umber wing covers with pale yellow margins, splayed smoky membrane wings with veins, segmented emissive lantern
-- (light from inside: bright core, darker segment grooves), glow spill on the wing covers, thin jointed legs.
-- quirk: one antenna curls into a little spiral.
local NAME = "firefly-glow"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local ELY  = { "#1f1620", "#2f2028", "#45302f", "#5f4434", "#7f5e42", "#a47e58" }
local MARG = { "#9a7434", "#d8b85a", "#f2dc8a" }
local WING = { "#4e5878", "#6f7c9e", "#97a6c4", "#bccae0", "#dfe8f4" }
local GLOW = { "#5a6a1e", "#8ea62a", "#c2d83a", "#e2f05c", "#f4fa9c", "#fefee2" }
local PRO  = { "#5e1c34", "#9c3440", "#cf5a48", "#ee8658", "#ffb27a", "#ffd8a8" }
local HEAD = { "#22171f", "#3a2830", "#5a4048", "#7e626a" }
local LEG  = { "#2f2229", "#5a4248", "#86686c" }

local ux, uy = 0.53, 0.85                       -- body axis, head -> tail
local ANG = atan(uy, ux)
local px, py = uy, -ux                          -- across (+ = upper-right side)
local CX, CY = 31, 32
local function P(t, s) return CX + ux * t + px * s, CY + uy * t + py * s end

-- legs (behind everything): thin, jointed, tips flick back
local ltok = A.tok("legs")
for _, L in ipairs{ { -9, 1 }, { -3, 1 }, { 3, 1 }, { -9, -1 }, { -3, -1 }, { 3, -1 } } do
  local t0, sd = L[1], L[2]
  local ax, ay = P(t0, sd * 3)
  local bx, by = P(t0 - 1 + (t0 > 0 and 3 or 0), sd * 8.5)
  local cx2, cy2 = P(t0 + 3 + (t0 > 0 and 4 or 0), sd * 10.5)
  for i = 0, 12 do local f = i / 12
    local x, y = ax + (bx - ax) * f, ay + (by - ay) * f
    c:put(floor(x + .5), floor(y + .5), LEG[2], ltok) end
  for i = 0, 8 do local f = i / 8
    local x, y = bx + (cx2 - bx) * f, by + (cy2 - by) * f
    c:put(floor(x + .5), floor(y + .5), f < 0.2 and LEG[3] or LEG[1], ltok) end
end

-- membrane wings, splayed
local wtok = A.tok("wings")
for _, sd in ipairs{ -1, 1 } do
  local wx, wy = P(4, sd * 5.2)
  local m, n = A.oval(wx, wy, 10, 3.3, ANG - sd * 0.42, 0.6)
  local idx = A.toneN(c, m, n, WING, { tok = wtok, cuts = { 0.2, 0.42, 0.62, 0.82 }, amb = 0.25, wrap = 0.4 })
  -- two veins along the wing
  local a = ANG - sd * 0.42
  for _, off in ipairs{ -0.9, 1.1 } do
    for d = -7, 8 do
      local x = wx + cos(a) * d - sin(a) * off
      local y = wy + sin(a) * d + cos(a) * off
      local xi, yi = floor(x + .5), floor(y + .5)
      if m:has(xi, yi) then A.step(c, idx, WING, xi, yi, -1, wtok) end
    end
  end
end

-- lantern abdomen: emissive, bright core toward the tail
local gtok = A.tok("lantern")
local ax0, ay0 = P(9.5, 0)
local am = A.oval(ax0, ay0, 7.6, 4.9, ANG, 1)
local gidx = {}
am:each(function(x, y)
  local dx, dy = x - ax0, y - ay0
  local u = (dx * ux + dy * uy) / 8.1
  local v = (dx * px + dy * py) / 5.4
  local core = 1 - sqrt((u - 0.25) ^ 2 * 0.9 + (v + 0.12) ^ 2 * 1.3)
  local i = 1 + floor(max(0, core) * 7.2)
  -- segment grooves across the lantern
  local seg = (u * 8.1 + 30) % 3.0
  if seg < 0.9 and u < 0.7 then i = i - 1 end
  if v > 0.6 then i = i - 1 end                                       -- shade rim lower-right
  i = max(1, min(6, i))
  gidx[K(x, y)] = i
  c:put(x, y, GLOW[i], gtok)
end)

-- wing covers (elytra)
local etok = A.tok("elytra")
local ely = {}
for j, sd in ipairs{ -1, 1 } do
  local ex, ey = P(-1.5, sd * 3.0)
  local m, n = A.oval(ex, ey, 10.5, 3.5, ANG - sd * 0.1, 0.8)
  ely[j] = m
  local b = {}
  X.ao(b, m, c:rect(0, 0, 0, 0), 1, 0)
  local idx = A.toneN(c, m, n, ELY, { tok = etok, bias = b, cuts = A.CUTS, amb = 0.12, wrap = 0.3 })
  -- pale outer margin
  m:edge():each(function(x, y)
    local dx, dy = x - ex, y - ey
    local s = (dx * px + dy * py) * sd
    if s > 1.2 then c:put(x, y, (idx[K(x, y)] or 3) >= 4 and MARG[3] or MARG[2], etok) end
  end)
  -- glow spill near the lantern
  m:each(function(x, y)
    if am:grow(2):has(x, y) and not am:has(x, y) and (x - ex) * ux + (y - ey) * uy > 3 then
      local i = idx[K(x, y)] or 3
      c:put(x, y, i >= 4 and "#b0b04a" or "#7a7a34", etok)
    end
  end)
  -- one glossy streak
  local gx, gy = A.specAt(m, n, 40)
  if gx then c:put(gx, gy, ELY[6], etok) c:put(gx + 1, gy + 1, ELY[5], etok) end
end
-- suture line between covers
for t = -11, 8 do
  local x, y = P(t, 0)
  local xi, yi = floor(x + .5), floor(y + .5)
  if ely[1]:has(xi, yi) or ely[2]:has(xi, yi) then c:put(xi, yi, ELY[1], etok) end
end

-- pronotum shield
local ptok = A.tok("pronotum")
local pxc, pyc = P(-12.5, 0)
local pm, pn = A.oval(pxc, pyc, 3.8, 5.8, ANG, 0.7)
local pidx = A.toneN(c, pm, pn, PRO, { tok = ptok, cuts = A.CUTS, amb = 0.15, wrap = 0.3 })
pm:each(function(x, y)
  local dx, dy = x - pxc, y - pyc
  local u, v = dx * ux + dy * uy, dx * px + dy * py
  if abs(v) < 1.6 and u > -2.6 and u < 2.8 then c:put(x, y, (v < -0.6 and u < 0) and HEAD[3] or HEAD[1], ptok) end
end)
-- AO where pronotum overlaps the covers
pm:grow(1):each(function(x, y)
  if not pm:has(x, y) and (ely[1]:has(x, y) or ely[2]:has(x, y)) then
    local dx, dy = x - pxc, y - pyc
    if dx * ux + dy * uy > 0 then c:put(x, y, ELY[1], etok) end
  end
end)

-- head
local htok = A.tok("head")
local hx, hy = P(-17.2, 0)
local hm, hn = A.oval(hx, hy, 2.2, 3.0, ANG, 0.8)
A.toneN(c, hm, hn, HEAD, { tok = htok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.1, wrap = 0.3 })
for _, sd in ipairs{ -1, 1 } do
  local ex, ey = P(-17.6, sd * 2.4)
  local xi, yi = floor(ex + .5), floor(ey + .5)
  c:put(xi, yi, "#3a3450", htok) c:put(xi, yi - 1, "#9a9ac0", htok)
end

-- antennae: segmented, one curls (quirk)
local atok = A.tok("antenna")
local function seg(pts)
  local n = 0
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local st = max(abs(b[1] - a[1]), abs(b[2] - a[2])) * 2
    for k = 0, st do local f = k / max(1, st)
      local x, y = floor(a[1] + (b[1] - a[1]) * f + .5), floor(a[2] + (b[2] - a[2]) * f + .5)
      if not hm:has(x, y) then n = n + 1 c:put(x, y, (n % 4 < 2) and LEG[2] or LEG[1], atok) end
    end
  end
end
do
  local x0, y0 = P(-19, -1.2)
  local x1, y1 = P(-24, -4) local x2, y2 = P(-27.5, -9)
  seg({ { x0, y0 }, { x1, y1 }, { x2, y2 } })
  local r0, r1 = P(-19, 1.2)
  local q1x, q1y = P(-23, 5)
  local q2x, q2y = P(-26, 8.5)
  seg({ { r0, r1 }, { q1x, q1y }, { q2x, q2y } })
  -- spiral loop at the tip
  local cxs, cys = q2x - 0.5, q2y - 2.0
  local prev
  for k = 0, 40 do
    local a = pi * 0.5 + k / 40 * 2 * pi * 1.05
    local r = 2.2 - k / 40 * 1.2
    local x, y = floor(cxs + cos(a) * r + .5), floor(cys + sin(a) * r + .5)
    c:put(x, y, LEG[k % 8 < 4 and 2 or 1], atok)
  end
end

-- one glow sparkle off the lantern
local sx, sy = P(17, 8)
c:sparkle(floor(sx + .5), floor(sy + .5))

A.save(c, NAME)
