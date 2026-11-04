-- ico-hedgehog (final pass, Opus). Side-on hedgehog walking right: a domed spine coat with a swept, saw-tooth rim
-- (reads at 16 px), slim pointed snout, button nose, tiny legs. Spines: per-pixel dome light on a 6-tone brown ramp,
-- then individual quills (dark root, pale tip) swept toward the tail. Face: 6-tone warm tan, AO under the spine fringe,
-- cool bounce under the chin. quirk: a curled autumn leaf is stuck on its spines.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, cos, sin, pi, sqrt = math.floor, math.max, math.min, math.cos, math.sin, math.pi, math.sqrt
local c = A.new("ico-hedgehog")
local SP   = { "#2a1622", "#46262a", "#683a2e", "#8c5434", "#b77a48", "#e8b882" }
local FACE = { "#6a3a32", "#9a6248", "#c98d66", "#e3b088", "#f5d2a8", "#fff0d2" }
local FOOT = { "#3e2424", "#6a3e32", "#9a6248" }
local LF   = { "#7a2a30", "#b8402e", "#e0702e", "#f5a23a", "#ffd56a" }
local INK, CR = A.INK, A.CREAM
local spT, faT, ftT, lfT = A.tok("spine"), A.tok("face"), A.tok("foot"), A.tok("leaf")

c:groundShadow(31, 51, 22, 2)

-- legs (behind body)
for _, fx in ipairs({ 16, 34 }) do
  local leg = c:rrect(fx, 44, fx + 4, 50, 1)
  leg:each(function(x, y)
    local t = (x == fx + 4 or y == 50) and 1 or (x == fx and 3 or 2)
    c:put(x, y, FOOT[t], ftT)
  end)
  c:put(fx + 1, 50, FOOT[3], ftT) c:put(fx + 3, 50, FOOT[3], ftT) -- toe split
end

-- face + belly (skin under the coat)
local face = c:poly{ { 30, 31 }, { 42, 31 }, { 50, 36 }, { 54, 40 }, { 55, 43 }, { 52, 45 }, { 44, 47 }, { 30, 47 } }
face:add(A.ell(30, 42, 14, 5))
local fn = A.dome(face, 5, 1.1, 1)
local spineCX, spineCY, RX, RY = 26, 36, 16, 11
local core = A.ell(spineCX, spineCY, RX, RY)
core:cut(c:rect(0, 45, 63, 63))
local fbias = {}
X.ao(fbias, face, core, 2, -1)
local fidx = A.shade(c, face, fn, FACE, { tok = faT, bias = fbias, amb = 0.1, wrap = 0.3 })
-- cool bounce under chin / belly
face:edge():each(function(x, y) if not face:has(x, y + 1) and x > 40 and x < 52 then c:put(x, y, "#a8708a", faT) end end)

-- spine coat: core dome + swept spikes (chunky, 3px+ at the base so the saw edge reads at 16 px)
local coat = core:copy()
local spikes = {}
local N = 10
for i = 0, N - 1 do
  local a = pi * (0.8 + i * (1.02 / (N - 1)))
  local da = 0.2
  local function at(ang, r) return spineCX + (RX + r) * cos(ang), spineCY + (RY + r) * sin(ang) end
  local bx0, by0 = at(a - da, -0.3)
  local bx1, by1 = at(a + da, -0.3)
  local ax, ay = at(a - 0.22, 5.0)
  coat:add(c:poly{ { bx0, by0 }, { ax, ay }, { bx1, by1 } })
  spikes[#spikes + 1] = { ax, ay, a }
end
coat:cut(c:rect(0, 46, 63, 63))
-- keep the forehead fringe from covering the eye
coat:cut(c:poly{ { 43, 28 }, { 52, 34 }, { 52, 48 }, { 40, 48 }, { 39.5, 37 } })
local cn = A.dome(coat, 7, 1.0, 1)
local sidx = A.shade(c, coat, cn, SP, { tok = spT, amb = 0.04, wrap = 0.2, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 },
  tilt = { 26, 34, 22, 0.12 } })
-- quills as overlapping shingles: 3 tiers, each a fan of quills swept to the tail; dark gap between quills,
-- pale quill tips on each tier's outer edge
coat:each(function(x, y)
  local dx, dy = (x + .5 - spineCX) / RX, (y + .5 - spineCY) / RY
  local r = sqrt(dx * dx + dy * dy)
  local a = math.atan(dy, dx)
  local tier = min(3, floor(r * 3.2))
  local ph = (a + r * 0.9) * 4.6 / pi * 2 + tier * 0.5
  local f = ph - floor(ph)
  local rt = r * 3.2 - floor(r * 3.2)
  if r > 1.02 then return end
  if f < 0.24 then A.step(c, sidx, SP, x, y, -1, spT)
  elseif rt > 0.78 and f > 0.5 and f < 0.75 and tier >= 2 then A.step(c, sidx, SP, x, y, 1, spT) end
end)
-- pale tips on the rim spikes
for _, p in ipairs(spikes) do
  for s = 0, 1 do
    local x, y = floor(p[1] - cos(p[3] - 0.2) * s * 1.2 + .5), floor(p[2] - sin(p[3] - 0.2) * s * 1.2 + .5)
    if coat:has(x, y) then A.step(c, sidx, SP, x, y, 1, spT) end
  end
end
-- coat skirt: deep row where it overhangs the belly / legs (ambient)
coat:each(function(x, y) if (face:has(x, y + 1) or y == 45) and not coat:has(x, y + 1) then c:put(x, y, SP[1], spT) end end)
X.ao({}, face, coat, 1, -1)
face:each(function(x, y) if coat:has(x, y - 1) and not coat:has(x, y) then A.step(c, fidx, FACE, x, y, -2, faT) end end)
-- glossy pop on the crown of the coat
c:put(19, 27, SP[6], spT) c:put(20, 27, SP[6], spT) c:put(18, 28, CR, spT)

-- ear
local ear = A.ell(41.5, 31.5, 1.6, 1.6)
ear:each(function(x, y) c:put(x, y, FACE[2], faT) end)
c:put(41, 31, FACE[5], faT) c:put(42, 31, "#d0707a", faT) c:put(41, 32, "#d0707a", faT) c:put(42, 32, "#9a4458", faT)
-- eye, nose, mouth, cheek
c:eyeSmall(46, 36)
for y = 40, 42 do for x = 53, 55 do c:put(x, y, INK) end end
A.unpaint(c, 55, 40)
c:put(56, 41, INK)
c:put(53, 40, CR)
c:put(49, 44, FACE[2], faT) c:put(50, 44, FACE[2], faT) c:put(51, 43, FACE[2], faT)
c:put(48, 41, "#f08a8a", faT) c:put(49, 41, "#f08a8a", faT)
-- face lit snout ridge
c:put(49, 37, FACE[6], faT) c:put(50, 37, FACE[6], faT)

-- quirk: curled autumn leaf speared on the spines (upper back)
local lp = A.frame(23.5, 26.5, 1, -0.3)
local leaf = A.pred(12, 16, 34, 36, function(x, y)
  local u, v = lp(x + .5, y + .5)
  if u < -7 or u > 7 then return false end
  local w = 3.4 * (1 - math.abs(u) / 7.3) ^ 0.8 * (1 + 0.25 * (1 - math.abs(u) / 7.3))
  return math.abs(v - 0.3 * u * 0) <= w
end)
leaf:shift(1, 1):cut(leaf):each(function(x, y) if coat:has(x, y) then c:put(x, y, SP[1], spT) end end)
local ln = X.pillow(leaf, 2)
local lidx = A.shade(c, leaf, ln, LF, { tok = lfT, amb = 0.15, wrap = 0.35, cuts = { 0.25, 0.45, 0.65, 0.82 } })
leaf:each(function(x, y)
  local u, v = lp(x + .5, y + .5)
  if math.abs(v) < 0.6 and u > -6.5 and u < 6 then c:put(x, y, LF[1], lfT) end
  for _, vu in ipairs({ -2, 1.5 }) do if math.abs(v - 0.55 * (u - vu)) < 0.5 and v < 0 and u > vu then c:put(x, y, LF[2], lfT) end end
end)
-- stalk sticking out
c:put(16, 29, "#7a3a1f", lfT) c:put(15, 29, "#7a3a1f", lfT) c:put(14, 30, "#7a3a1f", lfT)
c:put(21, 24, LF[5], lfT) c:put(22, 24, LF[5], lfT) c:put(21, 23, CR, lfT)

A.save(c, "ico-hedgehog")
