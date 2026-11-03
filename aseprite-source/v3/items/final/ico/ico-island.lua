-- ico-island (final, Opus). A small sandy islet in a lagoon with one slim, leaning coconut palm.
-- Material: per-pixel lit 6-tone sand dome with grain specks, a dark wet-sand band at the waterline and the palm's
-- cast shadow; 6-tone lagoon with wave crests and a broken foam ring; trunk lit as a tube with ring scars (dark groove
-- + lit lip); five notched fronds with midribs and a dark heart where they meet the crown; glossy coconuts.
-- quirk: a message in a bottle has washed up on the shore.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_0.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("ico-island")
local SEA  = { "#1d3c6e", "#22609a", "#2c86b8", "#45abc8", "#7fd2d6", "#c4f2e6" }
local SAND = { "#7a4a30", "#a8703f", "#d39a58", "#e8bd78", "#f6d898", "#fff0c4" }
local BARK = { "#3e2326", "#5e3329", "#86502f", "#a8703f", "#c99358", "#e8bd82" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local NUT  = { "#3a2024", "#5a3226", "#7e4a2c", "#a86a3a" }
local FOAM = "#eafff6"

-- lagoon
local SX, SY, SRX, SRY = 32, 46, 24, 8
local sea = A.ell(SX, SY, SRX, SRY)
local sn = {}
sea:each(function(x, y) sn[K(x, y)] = { A.norm((x - SX) / SRX * 0.55, (y - SY) / SRY * 0.6, 1) } end)
local stok = { r = { name = "sea" } }
-- sand footprint (for wet sand / foam)
local IX, IY, IRX, IRY = 30, 43.5, 14, 6
local sand = A.ell(IX, IY, IRX, IRY)
local sbias = {}
A.X.ao(sbias, sea, sand, 2, -1)
local sidx = A.shade(c, sea, sn, SEA, { amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.42, 0.58, 0.76, 0.93 }, bias = sbias, tok = stok })
-- wave crests: short lit dashes with a dark trough under each
local crests = { { 12, 45, 3 }, { 15, 50, 4 }, { 22, 53, 3 }, { 47, 51, 4 }, { 52, 46, 3 }, { 40, 54, 3 }, { 10, 48, 2 } }
for _, w in ipairs(crests) do
  for i = 0, w[3] - 1 do
    if sea:has(w[1] + i, w[2]) and not sand:has(w[1] + i, w[2]) then c:put(w[1] + i, w[2], SEA[5], stok) end
    if sea:has(w[1] + i + 1, w[2] + 1) and not sand:has(w[1] + i + 1, w[2] + 1) then A.step(c, sidx, SEA, w[1] + i + 1, w[2] + 1, -1, stok) end
  end
  if sea:has(w[1], w[2] - 1) then c:put(w[1], w[2] - 1, SEA[5], stok) end
end
-- foam ring around the shore (broken)
local foam = sand:grow(1):cut(sand)
foam:each(function(x, y) if sea:has(x, y) and X.hash(x, y, 3) > 0.22 then c:put(x, y, FOAM, stok) end end)

-- sand dome
local nn = {}
sand:each(function(x, y)
  local u, v = (x - IX) / (IRX + 0.5), (y - IY) / (IRY + 0.5)
  local q = max(0.02, 1 - u*u - v*v)
  nn[K(x, y)] = { A.norm(u * 0.9, v * 1.2 - 0.25, sqrt(q) * 1.1) }
end)
local abias = {}
-- palm shadow falls lower-right on the sand
local shadow = A.ell(36, 42.5, 4.5, 1.6)
shadow:each(function(x, y) if sand:has(x, y) then abias[K(x, y)] = -2 end end)
-- wet band along the lower waterline
sand:each(function(x, y) if not sand:has(x, y + 2) and y > IY then abias[K(x, y)] = (abias[K(x, y)] or 0) - 2 end end)
local atok = { r = { name = "sand" } }
local aidx = A.shade(c, sand, nn, SAND, { amb = 0.12, wrap = 0.3, bias = abias, tok = atok })
-- grain specks
sand:each(function(x, y) local h = X.hash(x, y, 11)
  if sand:has(x, y + 2) and h > 0.9 then A.step(c, aidx, SAND, x, y, -1, atok)
  elseif sand:has(x, y + 2) and h < 0.05 then A.step(c, aidx, SAND, x, y, 1, atok) end end)

-- trunk (tube along a bezier, slim and leaning), ring scars
local CRX, CRY = 37, 15
local tp = { { 27, 43 }, { 26, 35 }, { 30, 24 }, { CRX, CRY + 1 } }
local btok = { r = { name = "bark" } }
local tm, tn, TT, TS, tidx, samp = A.stem(c, tp, function(t) return 2.3 - t * 0.7 end, BARK, { amb = 0.12, wrap = 0.25, tok = btok })
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
tm:each(function(x, y) local k = K(x, y)
  local d = (TT[k] * LEN + TS[k] * TS[k] * 1.2) % 3.0
  if d < 0.75 then c:put(x, y, BARK[max(1, (tidx[k] or 3) - 2)], btok)
  elseif d < 1.6 and TS[k] < 0.2 and (tidx[k] or 1) >= 3 then c:put(x, y, BARK[min(6, (tidx[k] or 3) + 1)], btok) end
end)
-- base flare dark where trunk enters the sand
for x = 24, 30 do if tm:has(x, 43) then c:put(x, 43, BARK[2], btok) end end

-- fronds: notched blades with midribs
local ltok = { r = { name = "frond" } }
local function frond(ax, ay, cx, cy, bx, by, w)
  local wfn = function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * math.sin(math.pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
  end
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, wfn, { fold = 0.5 })
  -- notches on the edge every ~3px
  local cut = HP.mask()
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) > 0.62 and T[k] > 0.25 and (T[k] * len + (S[k] > 0 and 1.5 or 0)) % 3.2 < 0.9 then cut:set(x, y) end end)
  m:cut(cut)
  local idx = A.toneN(c, m, n, LEAF, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = ltok })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.2 and T[k] < 0.92 then c:put(x, y, LEAF[S[k] <= 0 and 6 or 2], ltok) end
    if T[k] < 0.12 then c:put(x, y, LEAF[1], ltok) end
  end)
  return m
end
frond(36, 15, 25, 5, 13, 16, 2.6)
frond(36, 14, 31, 3, 22, 7, 2.3)
frond(38, 14, 47, 2, 54, 10, 2.6)
frond(38, 15, 52, 10, 56, 23, 2.6)
frond(37, 16, 43, 16, 43, 27, 2.4)
-- dark crown heart
for _, p in ipairs{ { 36, 15 }, { 37, 15 }, { 37, 16 }, { 36, 16 } } do c:put(p[1], p[2], LEAF[1], ltok) end
c:put(36, 14, "#5e3329", btok)

-- coconuts under the crown
local ntok = { r = { name = "nut" } }
for _, p in ipairs{ { 33.6, 18.6 }, { 36.4, 19.4 } } do
  local m = A.ell(p[1], p[2], 1.8, 1.8)
  local n = X.sphere(p[1], p[2], 1.8, m)
  A.shade(c, m, n, NUT, { amb = 0.1, wrap = 0.2, cuts = { 0.3, 0.55, 0.8 }, tok = ntok })
  c:put(floor(p[1] - 0.5), floor(p[2] - 0.5), "#d8a070", ntok)
end

-- quirk: message in a bottle washed up on the right shore (lying diagonally, cork up-right)
local B = { K = A.INK, g = "#5fc48c", G = "#3a8f6a", d = "#24544a", h = "#c4f2d6", p = "#fff0c4", P = "#e2c48a", o = "#b97a4a", O = "#864c33" }
A.map(c, {
  "........KK.",
  ".......KoOK",
  "..KKKKKKOK.",
  ".KhhgggGK..",
  "KhgpPpgGK..",
  "KgGPpPGdK..",
  ".KddddK....",
  "..KKKK.....",
}, 40, 42, B)

A.save(c, "ico-island")
