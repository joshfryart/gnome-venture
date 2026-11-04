-- pine-resin (final pass, Opus). A standing lump of raw pine resin: one tall teardrop (tip leaning left, where it
-- was pulled from the bark) fused with a rounder bead and a small drip at its foot. Translucent amber: per-pixel
-- pillow/sphere light on a 6-tone ramp, a warm transmitted glow inside the lower-right (light passing through),
-- darker amber where the beads fuse, a few trapped air bubbles, one big cream specular + a small one on the bead.
-- Ground shadow (it stands).
-- quirk: a single pine needle is trapped in the resin, poking out of the right side.
-- History: Sonnet draft replaced.
local NAME = "pine-resin"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local AMB  = { "#5a2212", "#8c3a12", "#bc5e16", "#e08a1e", "#f6b636", "#ffdc80" }
local NEED = { "#3e3a22", "#5e5a2c", "#86803c" }

c:groundShadow(32, 52, 16, 1.5)

-- main tear: round bottom, tapering curved tip
local TY, CY, R = 11, 39, 10.5
local main = HP.mask()
for y = TY, CY + 11 do
  local w, xc
  if y >= CY then w = R * sqrt(max(0, 1 - ((y - CY) / (R + 0.4)) ^ 2))
  else local t = (y - TY) / (CY - TY) w = R * t ^ 1.25 + 0.6 end
  local t = (y - TY) / (CY + 11 - TY)
  xc = 30 - 4.5 * (1 - t) ^ 2.2
  for x = floor(xc - w - 1), floor(xc + w + 1) do if abs(x - xc) <= w then main:set(x, y) end end
end
local bead = c:ellipse(42, 46, 5.6, 5.2)
local drip = c:ellipse(19.5, 48, 3.3, 2.8)
local m = main:copy():add(bead):add(drip)

-- normals: pillow over the union blended with each part's sphere
local np = X.pillow(m, 5)
local nm = A.body(main, 29, 39, 11, 5, 0.55)
local nb = X.sphere(41.6, 45.6, 6, bead)
local nd = X.sphere(19.2, 47.6, 3.6, drip)
local n = {}
m:each(function(x, y) local k = K(x, y)
  local s = (bead:has(x, y) and not main:has(x, y)) and nb[k] or (drip:has(x, y) and not main:has(x, y)) and nd[k] or nm[k] or np[k]
  local p = np[k]
  n[k] = { A.norm(s[1] * 0.7 + p[1] * 0.3, s[2] * 0.7 + p[2] * 0.3, s[3] * 0.7 + p[3] * 0.3) }
end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
-- transmitted glow: interior pixels lower-right of the bulb centre brighten
m:each(function(x, y) local k = K(x, y)
  local dx, dy = x - 32.5, y - 43
  local g = max(0, 1 - sqrt(dx * dx + dy * dy) / 7)
  local nn = n[k]
  v[k] = min(1, v[k] + 0.42 * g + 0.25 * max(0, nn[1] * 0.6 + nn[2] * 0.7) * g)
end)
local bias = {}
-- fuse seams: darker where the bead and drip meet the tear
X.ao(bias, bead, main, 1, -1)
X.ao(bias, drip, main, 1, -1)
local tok = { r = { name = "resin" } }
local idx = X.tone(c, m, v, AMB, { cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, bias = bias, tok = tok })
-- rim: 1px darker amber along the shaded outer edge (thick resin), cool-free
m:edge():each(function(x, y) local k = K(x, y) local nn = n[k]
  if nn[1] * 0.6 + nn[2] * 0.7 > 0.35 then A.step(c, idx, AMB, x, y, -1, tok) end end)

-- quirk: trapped pine needle, poking out of the right side
local ntok = { r = { name = "needle" } }
local p0x, p0y, p1x, p1y = 24, 33, 45, 27
for i = 0, 40 do local f = i / 40
  local x, y = floor(p0x + (p1x - p0x) * f + 0.5), floor(p0y + (p1y - p0y) * f + 0.5)
  if m:has(x, y) then
    local k = K(x, y) c:put(x, y, AMB[max(1, (idx[k] or 3) - 2)], tok)
  else c:put(x, y, f > 0.95 and NEED[2] or NEED[3], ntok) c:put(x, y + 1, NEED[1], ntok) end
end
-- needle's papery base sheath (inside, darker blob)
c:px(23, 33, AMB[1]) c:px(24, 34, AMB[2])

-- bubbles
for _, b in ipairs{ { 34, 22 }, { 26, 45 }, { 37, 37 }, { 43, 48 } } do
  c:px(b[1], b[2], AMB[6]) c:px(b[1] + 1, b[2] + 1, AMB[3])
end
-- speculars: big window glint upper left, small on the bead, sparkle
local CR = "#fff4d6"
for _, p in ipairs{ { 23, 30 }, { 23, 31 }, { 24, 29 }, { 23, 32 }, { 24, 30 } } do c:px(p[1], p[2], CR) end
c:px(25, 28, AMB[6]) c:px(22, 34, AMB[6])
c:px(39, 43, CR) c:px(40, 43, AMB[6])
c:px(25, 17, AMB[6]) c:px(25, 18, CR)

A.save(c, NAME)
