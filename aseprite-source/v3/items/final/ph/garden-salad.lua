-- garden-salad (final, Opus single pass). Turned wooden bowl (curved grain lines, pale end-grain lip, foot ring,
-- cool reflected light) heaped with frilly lettuce (midribs + veins), dark spinach leaves, glossy tomato wedges
-- with seed pockets and cucumber rounds (dark skin ring, pale seeded core); a slim wooden fork and spoon lean
-- out of the back. AO where the greens sit in the bowl and under each topping.
-- quirk: a small snail is making off over the bowl's rim.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_3.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, max, min, abs, sqrt, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin
local c = A.new("garden-salad")
local WD, LT, LF, RD = R.wood, R.lettuce, R.leaf, R.red

c:groundShadow(32, 55, 15, 2)

-- servers behind the heap (fork left-back, spoon right-back)
local tokS = { r = { name = "servers" } }
A.stem(c, { { 30, 30 }, { 28, 22 }, { 26, 16 }, { 24, 11 } }, function(t) return 1.1 end, WD, { tok = tokS })
A.map(c, {
  "w.w.w",
  "W.W.W",
  "WWWWW",
  ".dWd.",
}, 21, 7, { w = WD[6], W = WD[5], d = WD[3] }, tokS)
A.stem(c, { { 36, 30 }, { 38, 22 }, { 40, 16 }, { 42, 13 } }, function(t) return 1.1 end, WD, { tok = tokS })
local spoon = A.ell(43, 9.5, 2.6, 3.4)
A.shade(c, spoon, X.pillow(spoon, 2), WD, { tok = tokS, amb = 0.12, wrap = 0.3 })
c:put(42, 8, WD[1], tokS) c:put(43, 9, WD[2], tokS) c:put(42, 9, WD[3], tokS)

-- greens heap
local tokL = { r = { name = "greens" } }
local heap = HP.mask()
local function frill(cx, cy, rx, ry, ramp, seed, vein)
  local m = HP.mask()
  for y = floor(cy - ry) - 2, floor(cy + ry) + 2 do for x = floor(cx - rx) - 2, floor(cx + rx) + 2 do
    local a = math.atan(y - cy, x - cx)
    local wob = 1 + 0.13 * sin(a * 7 + seed)
    local u, v = (x - cx) / (rx * wob + 0.4), (y - cy) / (ry * wob + 0.4)
    if u*u + v*v <= 1 then m:set(x, y) end
  end end
  local n = A.blend(X.sphere(cx, cy, max(rx, ry), m), X.pillow(m, 2), 0.4)
  local bias = {}
  m:each(function(x, y) if y >= 33 then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, ramp, { amb = 0.1, wrap = 0.3, bias = bias, tok = tokL })
  -- seam against earlier leaves
  m:each(function(x, y) local k = K(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, -1 } } do
      local q = K(x + d[1], y + d[2])
      if heap.s[q] and not m.s[q] then c:put(x, y, ramp[max(1, (idx[k] or 3) - 2)], tokL) break end
    end
  end)
  -- ruffled lit edge on top, midrib + veins
  m:edge():each(function(x, y) if y < cy - 1 and X.hash(x, y, seed) < 0.5 then c:put(x, y, ramp[min(6, (idx[K(x, y)] or 3) + 1)], tokL) end end)
  if vein then
    for t = 0, floor(ry * 1.6) do local x, y = floor(cx + vein * t * 0.35 + .5), floor(cy + ry * 0.6 - t + .5)
      if m:has(x, y) then c:put(x, y, ramp[6], tokL)
        if t % 3 == 1 then
          if m:has(x - 1, y - 1) then c:put(x - 1, y - 1, ramp[5], tokL) end
          if m:has(x + 1, y - 1) then c:put(x + 1, y - 1, ramp[min(6, (idx[K(x + 1, y - 1)] or 3))], tokL) end
        end
      end
    end
  end
  heap:add(m)
  return m
end
frill(32, 24, 7, 5.5, LT, 1, 0.4)
frill(22, 28, 6.5, 5, LF, 2, nil)
frill(42, 28, 6.5, 5, LT, 3, -0.5)
frill(17, 32, 5, 3.5, LT, 4, 0.8)
frill(47, 32, 5, 3.5, LF, 5, nil)
frill(29, 31, 6, 4.5, LT, 6, -0.3)
frill(37, 32, 5.5, 4, LF, 7, nil)

-- tomato wedges: glossy skin arc + flesh with seed pockets
local tokT = { r = { name = "tomato" } }
local function wedge(x0, y0, flip)
  local rows = {
    "..ssss..",
    ".sSHSSs.",
    "sSfFFfSs",
    "sfgFgFfs",
    ".ffffff.",
  }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  A.map(c, rows, x0, y0, { s = RD[3], S = RD[4], H = RD[6], f = RD[5], F = "#ffa07a", g = "#f2d25a" }, tokT)
  for x = x0 + 1, x0 + 6 do if heap:has(x, y0 + 5) then c:put(x, y0 + 5, LF[1], tokL) end end
end
wedge(23, 21, false)
wedge(37, 24, true)
c:put(26, 22, A.CREAM, tokT)

-- cucumber rounds (tilted discs)
local tokC = { r = { name = "cuke" } }
local function cuke(x0, y0)
  A.map(c, {
    ".kkkk.",
    "kmpppk",
    "kpsCpk",
    "kpCspk",
    ".kKKk.",
  }, x0, y0, { k = "#3a7a3e", K = "#24544a", m = "#e8f6b0", p = "#c4e07a", s = "#f4f6d8", C = "#9cc860" }, tokC)
end
cuke(14, 26) cuke(30, 27) cuke(44, 27)

-- bowl: lower half-ellipse body, foot ring, end-grain lip
local tokB = { r = { name = "bowl" } }
local body = A.ell(32, 35, 21, 15):clip(c:rect(0, 35, 63, 63))
local foot = c:rrect(26, 49, 38, 52, 1)
local lip = A.ell(32, 35, 21, 2.2):clip(c:rect(0, 35, 63, 63))
local bn = A.blend(A.vcyl(body, 11, 53, 2, 0), X.sphere(32, 33, 21, body), 0.5)
local bias = {}
body:each(function(x, y) if y >= 46 then bias[K(x, y)] = -1 end end)
local fidx = A.shade(c, foot, A.vcyl(foot, 26, 38, 1, 0.3), WD, { amb = 0.08, wrap = 0.3, tok = tokB, bias = setmetatable({}, { __index = function() return -1 end }) })
local bidx = A.shade(c, body, bn, WD, { amb = 0.1, wrap = 0.3, bias = bias, tok = tokB })
-- turned grain: curved lines following the bowl's curvature
body:each(function(x, y) local k = K(x, y)
  local f = y - 0.012 * (x - 32) ^ 2
  local i = bidx[k] or 3
  if y > 38 and floor(f) % 4 == 0 and X.hash(x, y, 9) > 0.25 then c:put(x, y, WD[max(1, i - 1)], tokB)
  elseif y > 38 and floor(f) % 4 == 1 and X.hash(x, y, 4) > 0.75 and i < 6 then c:put(x, y, WD[i + 1], tokB) end
end)
-- lip: pale end grain band + dark rim row under the greens
lip:each(function(x, y) c:put(x, y, (x < 40) and WD[6] or WD[5], tokB) end)
for x = 11, 53 do if body:has(x, 35) then c:put(x, 35, WD[2], tokB) end end
-- greens AO just above the lip
heap:each(function(x, y) if y == 34 then c:put(x, y, LF[1], tokL) end end)
-- reflected cool light on the lower right of the bowl
body:edge():each(function(x, y) if x > 44 and y > 39 and y < 47 then c:put(x, y, "#8a6a8a", tokB) end end)
-- specular on the bowl shoulder
c:put(17, 40, WD[6], tokB) c:put(18, 40, A.CREAM, tokB) c:put(17, 41, WD[6], tokB)
-- foot shadow under the body
for x = 26, 38 do c:put(x, 49, WD[1], tokB) end

-- quirk: snail crossing the rim on the right
local tokN = { r = { name = "snail" } }
A.map(c, {
  "..ssss...",
  ".sSHhSs..",
  ".sHdDSs..",
  ".sSDDss.e",
  "bbbbbbbbb",
}, 47, 31, { s = "#a85a3a", S = "#d98a4a", H = "#ffc874", h = "#f2b84a", d = "#6e3a2a", D = "#8f4a2a", b = "#c8b8a0", e = A.INK }, tokN)
c:put(55, 34, "#c8b8a0", tokN) c:put(56, 33, "#c8b8a0", tokN) c:put(56, 32, A.INK, tokN)

A.save(c, "garden-salad")
