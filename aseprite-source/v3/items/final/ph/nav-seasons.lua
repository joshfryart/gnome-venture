-- nav-seasons (final, Opus single pass). A glossy sun (sphere light, warm 6-tone ramp, cream glint, cool-violet
-- bounce on the lower edge) with eight slim tapered rays, half hidden behind a puffy cloud built from three lit lobes
-- and a flat base (lobe separation lines, cool underside, bright upper rims, AO where the cloud covers the sun).
-- quirk: one red-orange autumn leaf tumbles past the cloud's lower left.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("nav-seasons")
local SUN  = { "#8f3a1f", "#c8611f", "#ea8a22", "#f5b02e", "#ffd45a", "#fff0a8" }
local RAY  = { "#a8481f", "#d8721f", "#f09a2a", "#fbc040", "#ffe27a", "#fff4bc" }
local CLD  = { "#5a6698", "#7d8fc0", "#a3b6dc", "#c8d8ee", "#e6eff8", "#fbfaf0" }
local LEAF = { "#6e2038", "#b52e3f", "#e0532e", "#f58a3a" }

local SX, SY, SR = 25, 25, 10
-- rays first (sun paints over their roots)
for i = 0, 7 do
  local a = i * pi / 4 + pi / 8
  local r0, r1 = SR + 1, SR + 8 - (i % 2) * 2
  local ux, uy = cos(a), sin(a)
  local p = { { SX + ux * r0, SY + uy * r0 }, { SX + ux * (r0 + (r1 - r0) / 3), SY + uy * (r0 + (r1 - r0) / 3) },
              { SX + ux * (r0 + 2 * (r1 - r0) / 3), SY + uy * (r0 + 2 * (r1 - r0) / 3) }, { SX + ux * r1, SY + uy * r1 } }
  local m, n = A.tube(p, function(t) return 1.7 * (1 - t) + 0.45 end)
  -- rays read as rounded ridges
  A.shade(c, m, n, RAY, { wrap = 0.35, amb = 0.15 })
end

-- sun disc
local sm = c:ellipse(SX, SY, SR, SR)
local sn = X.sphere(SX - 0.5, SY - 0.5, SR, sm)
local si = A.shade(c, sm, sn, SUN, { wrap = 0.2, amb = 0.06 })
-- cool-violet bounce on the lower-right rim
local rim = X.rim(sn)
sm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 then c:put(x, y, "#b04a5c") end end)
-- glossy specular + glint
c:put(20, 19, SUN[6]) c:put(21, 19, SUN[6]) c:put(20, 20, SUN[6]) c:put(19, 20, "#fffbe6") c:put(20, 18, "#fffbe6")

-- cloud: base + three lobes, later lobes in front
local lobes = { { 40, 37, 9 }, { 30, 42, 7 }, { 50, 43, 6 } }
local base = c:rrect(23, 42, 56, 51, 4)
local cm = base:copy()
local cn = X.pillow(base, 4, 1.1)
local owner = {}
base:each(function(x, y) owner[K(x, y)] = 0 end)
local lm = {}
for i, L in ipairs(lobes) do
  local m = c:ellipse(L[1], L[2], L[3], L[3])
  m:clip(c:rect(0, 0, 63, 51))
  local n = X.sphere(L[1] - 0.3, L[2] - 0.6, L[3], m)
  -- squash z so lobes look soft, not glassy
  for k, v in pairs(n) do n[k] = { A.norm(v[1] * 0.8, v[2], v[3] + 0.25) } end
  A.merge(cn, n)
  m:each(function(x, y) owner[K(x, y)] = i end)
  cm:add(m)
  lm[i] = m
end
-- bottom of the cloud sits in a cool shade
local bias = {}
cm:each(function(x, y) if y >= 50 then bias[K(x, y)] = -1 end end)
-- AO on the sun where the cloud overlaps it (sun pixels just above/left of the cloud)
A.cast(c, sm, si, SUN, cm, -1, -1, -2)
local ci = A.shade(c, cm, cn, CLD, { bias = bias, wrap = 0.45, amb = 0.12 })
-- lobe separation: edge of a lobe lying over an earlier lobe/base -> 2 tones down; bright lip just inside
A.adjust(c, cm, ci, CLD, function(x, y, i)
  local o = owner[K(x, y)]
  if o and o > 0 then
    local m = lm[o]
    for _, d in ipairs{ { 1, 0 }, { 0, 1 }, { 1, 1 } } do
      local nx, ny = x + d[1], y + d[2]
      if not m:has(nx, ny) and cm:has(nx, ny) and (owner[K(nx, ny)] or 0) < o and owner[K(nx, ny)] ~= nil then return -2 end
    end
  end
end)
-- bright rim on the top-left of each lobe
for i, L in ipairs(lobes) do
  lm[i]:edge():each(function(x, y)
    if owner[K(x, y)] == i and x < L[1] and y < L[2] - L[3] * 0.4 then c:put(x, y, CLD[6]) end
  end)
end

-- quirk: tumbling autumn leaf, lower-left
local lfm, lfn = A.oval(15.5, 46.5, 3.2, 1.8, -0.6, 1)
local li = A.shade(c, lfm, lfn, { LEAF[1], LEAF[2], LEAF[2], LEAF[3], LEAF[3], LEAF[4] }, { wrap = 0.3 })
A.ln(c, 13, 48, 18, 45, LEAF[2], lfm)                                   -- midrib
c:put(12, 49, "#864c33") c:put(11, 50, "#864c33")                       -- petiole
c:put(15, 46, LEAF[4])

A.save(c, "nav-seasons")
