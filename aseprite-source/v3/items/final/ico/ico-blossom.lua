-- ico-blossom (final, Opus). A cherry blossom face-on: five broad petals, each with the notched tip of a sakura
-- petal, overlapping in a pinwheel; a deep rose eye, a ring of stamens with gold anthers; one leaf behind.
-- Material: petals lit per pixel as shallow cups (6-tone pink, darker toward the heart, pale at the rims), fine
-- radial veins, contact shade where each petal tucks under its neighbour; leaf with midrib and veins.
-- quirk: a single dewdrop sits on the upper-right petal (glass: bright rim, pale core, tiny cast shade).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, cos, pi, atan = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi, math.atan
local c = A.new("ico-blossom")
local PK = { "#6e2450", "#a63a6e", "#d65d8c", "#f084a7", "#ffadc6", "#ffd8e4" }
local LF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local GO = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local EYE = { "#5a1840", "#8a2556", "#b8386a" }
local WATER = { "#3a86b0", "#8fd8dc", "#d8fbf2", "#fff4d6" }
local CX, CY = 32, 31

-- leaf behind, out to the lower right
local ltok = { r = { name = "leaf" } }
local lm, ln, LT, LS = A.blade(38, 37, 50, 44, 57, 53, function(t) return 4.2 * sin(pi * max(t, 0.03) ^ 0.75) end)
local lidx = A.shade(c, lm, ln, LF, { tok = ltok, amb = 0.08, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if abs(LS[k]) < 0.16 and LT[k] < 0.92 then c:put(x, y, LF[2], ltok) end
end)
for _, t in ipairs{ 0.35, 0.55, 0.75 } do   -- side veins angling to the tip
  lm:each(function(x, y) local k = K(x, y)
    local d = (LT[k] - t) * 26 - abs(LS[k]) * 4
    if abs(d) < 0.5 and abs(LS[k]) > 0.25 and abs(LS[k]) < 0.8 then A.step(c, lidx, LF, x, y, -1, ltok) end
  end)
end

-- petals: angle a, pinwheel overlap (each petal sits on top of the previous one's right edge)
local petals, owner = {}, {}
local R0 = -pi / 2 + 0.25
for i = 0, 4 do
  local a = R0 + i * 2 * pi / 5
  local ux, uy = cos(a), sin(a)
  local m = HP.mask()
  local n = {}
  local info = {}
  for y = 2, 61 do for x = 2, 61 do
    local dx, dy = x - CX, y - CY
    local u = dx * ux + dy * uy          -- along petal
    local v = -dx * uy + dy * ux         -- across
    -- obovate petal: narrow at the heart, widest near the tip
    if u > 0 and u < 20.5 then
      local tt = u / 20.5
      local w = 1.4 + 7.9 * sin(pi * min(1, tt * 0.82) ^ 1.3) ^ 0.85
      if tt > 0.8 then w = w * sqrt(max(0, 1 - ((tt - 0.8) / 0.2) ^ 3)) end
      -- pinwheel skew: petal leans one way
      local vs = v + (tt ^ 2) * 1.6
      local inside = abs(vs) <= w
      -- notch at the tip
      if inside and tt > 0.85 and abs(vs) < (tt - 0.85) * 15 then inside = false end
      if inside then
        m:set(x, y)
        local sv = vs / (w + 0.6)
        -- shallow cup: rims curl up (normals point inward) near the edges, heart sinks
        local nx = -sv * 0.55
        local nu = (tt < 0.25) and 0.45 or -0.18 * tt
        local wx, wy = ux * nu - uy * nx, uy * nu + ux * nx
        n[K(x, y)] = { A.norm(wx, wy, 1) }
        info[K(x, y)] = { tt, sv }
      end
    end
  end end
  petals[i + 1] = { m = m, n = n, info = info, a = a }
end
local ptok = { r = { name = "petal" } }
local pidx = {}
for i, p in ipairs(petals) do
  local bias = {}
  p.m:each(function(x, y) local k = K(x, y) local tt = p.info[k][1]
    if tt < 0.28 then bias[k] = -2 elseif tt < 0.42 then bias[k] = -1 end
    if tt > 0.72 then bias[k] = (bias[k] or 0) + 1 end
  end)
  local id = A.shade(c, p.m, p.n, PK, { tok = ptok, bias = bias, amb = 0.12, wrap = 0.35, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  for k, v in pairs(id) do pidx[k] = v owner[k] = i end
  -- radial veins (1 tone darker), three per petal
  p.m:each(function(x, y) local k = K(x, y) local tt, sv = p.info[k][1], p.info[k][2]
    if tt > 0.3 and tt < 0.78 then
      for _, vv in ipairs{ -0.42, 0.42 } do
        if tt < 0.66 and abs(sv - vv * (0.6 + tt * 0.5)) < 0.06 and owner[k] == i then A.step(c, pidx, PK, x, y, -1, ptok) end
      end
    end
  end)
end
-- contact shade: pixels of a petal next to the petal laid over it
for k, i in pairs(owner) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    local j = owner[K(x + d[1], y + d[2])]
    if j and j ~= i then
      -- i under j if j painted later, or petal 1 lies over petal 5 (pinwheel wrap)
      local under = (j > i and not (i == 1 and j == 5)) or (i == 5 and j == 1)
      if under then c:put(x, y, PK[1], ptok) pidx[k] = 1
        local k2 = K(x - d[1], y - d[2]) if owner[k2] == i and pidx[k2] and pidx[k2] > 2 then pidx[k2] = pidx[k2] - 1 c:put(x - d[1], y - d[2], PK[pidx[k2]], ptok) end end
    end
  end
end
-- rose heart
local eyeM = A.ellM(CX, CY, 4.6, 4.6)
eyeM:each(function(x, y) local d = sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  c:put(x, y, d < 2.0 and EYE[1] or (d < 3.6 and EYE[2] or EYE[3]), ptok) end)
-- stamens: filaments radiating from the heart, gold anthers at the ends
local stok = { r = { name = "stamen" } }
for i = 0, 9 do
  local a = -pi / 2 + i * 2 * pi / 10 + 0.12
  local L = (i % 2 == 0) and 7.4 or 6.0
  for r = 2, floor(L) - 1 do
    local x, y = floor(CX + cos(a) * r + 0.5), floor(CY + sin(a) * r + 0.5)
    c:put(x, y, r < 4 and "#f2c6d0" or "#fbe6e6", stok)
  end
  local ex, ey = floor(CX + cos(a) * L + 0.5), floor(CY + sin(a) * L + 0.5)
  c:put(ex, ey, GO[3], stok)
  c:put(ex + 1, ey, GO[2], stok) c:put(ex, ey + 1, GO[1], stok)
  if i == 7 or i == 9 then c:put(ex, ey, GO[4], stok) end
end
-- pistil
c:put(CX, CY, "#c4e07a", stok) c:put(CX - 1, CY, "#7cc35a", stok) c:put(CX, CY + 1, "#3f9150", stok)

-- quirk: dewdrop on the upper-right petal
local dx, dy = 42, 20
local dtok = { r = { name = "dew" } }
A.map(c, {
  ".rr.",
  "rpcr",
  "rppr",
  ".rr.",
}, dx, dy, { r = WATER[1], p = WATER[2], c = WATER[4] }, dtok)
c:put(dx + 1, dy + 2, WATER[3], dtok)
-- cast shade below-right of the drop
for _, q in ipairs{ { 4, 2 }, { 4, 3 }, { 3, 4 }, { 2, 4 } } do
  local k = K(dx + q[1], dy + q[2]) if owner[k] then c:put(dx + q[1], dy + q[2], PK[max(1, (pidx[k] or 3) - 2)], ptok) end
end
A.save(c, "ico-blossom")
