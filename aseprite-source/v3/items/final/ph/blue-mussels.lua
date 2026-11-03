-- blue-mussels (final, Opus single pass). Two slim blue mussels side by side: the back one closed (blue-black
-- periostracum, rounded bevel light, concentric growth rings from the pointed umbo, a bright sheen streak on the
-- dorsal ridge, the paired valve seam along the ventral edge, twisted gold-brown beard threads), the front one a
-- single open valve showing the pearly concave nacre (inverted light, iridescent bands, violet margin, adductor scar).
-- quirk: a tiny barnacle has settled near the closed mussel's broad end.
local NAME = "blue-mussels"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SHELL = { "#171a30", "#222848", "#2f3c6a", "#41558e", "#5d78b4", "#8fb0de" }
local NACRE = { "#3a3b6b", "#5f6599", "#8b95c4", "#b6c2e2", "#dbe2f4", "#f4f1fb" }
local MARGIN = { "#2a2350", "#46397a", "#6a58a6" }
local IRIS1, IRIS2 = "#e8c8e6", "#c6ecea"
local BYS = { "#4a3320", "#7a5630", "#a87c44", "#d0a868" }
local BARN = { "#5c5e74", "#8e8ea2", "#c4c2d0", "#ecebef" }

-- mussel outline in a local frame: pointed umbo at A, rounded broad end at B; dorsal side (v<0) fuller
local function shell(ax, ay, bx, by, Wm)
  local fr, L = A.frame(ax, ay, bx, by)
  local m, U, V, Wd = HP.mask(), {}, {}, {}
  for y = 0, 63 do for x = 0, 63 do
    local u, v = fr(x, y)
    local w
    if u >= -0.01 and u <= 1 then
      if u < 0.66 then w = Wm * (max(u, 0) / 0.66) ^ 0.72 else w = Wm * sqrt(max(0, 1 - ((u - 0.66) / 0.34) ^ 2)) end
      local lim = v < 0 and w * 1.08 or w * 0.74
      if abs(v) <= lim + 0.1 and w > 0.4 then
        m:set(x, y) local k = K(x, y) U[k], V[k], Wd[k] = u, v / max(lim, 0.6), w
      end
    end
  end end
  return m, U, V, fr, L
end

local m1, U1, V1, fr1, L1 = shell(12, 47, 37, 14, 8.2)
local m2, U2, V2, fr2, L2 = shell(25, 54, 49, 28, 7.4)
m1:cut(m2)

-- beard threads (byssus) from the closed mussel's ventral edge, drawn first so both shells overlap them
local btok = { r = { name = "byssus" } }
local bysm = HP.mask()
local threads = { { { 22, 40 }, { 25, 45 }, { 22, 50 }, { 20, 56 } }, { { 23, 39 }, { 27, 43 }, { 26, 49 }, { 27, 54 } }, { { 21, 41 }, { 21, 46 }, { 16, 49 }, { 14, 54 } } }
for ti, p in ipairs(threads) do
  for i = 0, 40 do local x, y = A.bez(p, i / 40) x, y = floor(x + 0.5), floor(y + 0.5)
    if not m1:has(x, y) and not m2:has(x, y) then
      -- twist: alternating light/dark segments along the thread
      local seg = floor(i / 3) % 2
      c:put(x, y, seg == 0 and BYS[3] or BYS[2], btok) bysm:set(x, y)
      if i % 7 == 0 then c:put(x, y, BYS[4], btok) end
    end
  end
end

-- closed mussel
local b1 = {}
X.ao(b1, m1, m2, 2, -1)
local n1 = X.pillow(m1, 5.5)
local t1 = { r = { name = "closed" } }
local i1 = A.shade(c, m1, n1, SHELL, { bias = b1, tok = t1, amb = 0.08, wrap = 0.22, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
m1:each(function(x, y) local k = K(x, y)
  local u, v = U1[k], V1[k]
  local d = sqrt((x - 12) ^ 2 + (y - 47) ^ 2)
  -- growth rings around the umbo
  if d > 7 and (d % 5.2) < 1 and abs(v) < 0.92 then A.step(c, i1, SHELL, x, y, -1, t1) end
  -- sheen streak on the dorsal ridge
  if v > -0.52 and v < -0.3 and u > 0.32 and u < 0.7 and not b1[k] then c:put(x, y, (u > 0.42 and u < 0.58) and SHELL[6] or SHELL[5], t1) end
  -- ventral seam: the second valve's lip, dark line then a thin lit lip
  if v > 0.7 and v <= 0.86 and u > 0.12 and u < 0.95 then c:put(x, y, SHELL[1], t1) end
  if v > 0.86 and u > 0.12 and u < 0.95 then c:put(x, y, SHELL[3], t1) end
end)
-- umbo tip: worn pale purple
c:put(13, 46, MARGIN[3], t1) c:put(14, 46, MARGIN[2], t1)

-- quirk: barnacle near the broad end (dorsal side)
local bx, by = 27, 19
local barn = { { 0, -1, 3 }, { -1, 0, 3 }, { 0, 0, 1 }, { 1, 0, 2 }, { 0, 1, 2 }, { -1, -1, 4 }, { 1, -1, 3 }, { -1, 1, 2 }, { 1, 1, 1 } }
local qt = { r = { name = "barnacle" } }
for _, p in ipairs(barn) do c:put(bx + p[1], by + p[2], BARN[p[3]], qt) end

-- open valve: rim, concave nacre, iridescence, adductor scar
local t2 = { r = { name = "open" } }
local inner = m2:shrink(2)
local rim = m2:copy():cut(inner)
local b2 = {}
local nC = X.pillow(inner, 4.5)
for k, n in pairs(nC) do nC[k] = { -n[1], -n[2], n[3] } end       -- concave: lit on the far (lower-right) wall
-- contact shadow on the nacre cast by the near (upper-left) rim
A.cast(b2, inner, rim, 1, 1, -1)
local i2 = A.shade(c, inner, nC, NACRE, { bias = b2, tok = t2, amb = 0.22, wrap = 0.35, cuts = { 0.14, 0.3, 0.48, 0.64, 0.82 } })
inner:each(function(x, y) local k = K(x, y)
  local u, v = fr2(x, y)
  local idx = i2[k] or 1
  local band = (u * 9 + v * 0.18) % 1
  if idx >= 4 and band < 0.14 then c:put(x, y, IRIS1, t2) elseif idx >= 3 and band > 0.5 and band < 0.6 then c:put(x, y, IRIS2, t2) end
end)
-- adductor scar near the broad end, pallial line just inside the margin
local am = A.rell(43, 37, 0.675, -0.736, 2.2, 1.4)
am:clip(inner):each(function(x, y) A.step(c, i2, NACRE, x, y, -1, t2) end)
inner:edge():each(function(x, y) local k = K(x, y) local u = U2[k] if u and u > 0.25 then c:put(x, y, MARGIN[2], t2) end end)
-- shell margin: violet-black lip, lit on the upper-left edge
rim:each(function(x, y) local k = K(x, y)
  local v = V2[k] or 0
  local outer = not m2:has(x - 1, y) or not m2:has(x, y - 1)
  local col
  if v < 0 then col = outer and SHELL[5] or SHELL[3] else col = outer and SHELL[2] or MARGIN[1] end
  c:put(x, y, col, t2)
end)
-- hinge at the umbo
c:put(26, 52, MARGIN[1], t2) c:put(27, 51, MARGIN[2], t2)
-- separation where the open valve overlaps the closed one
A.sep(c, m1, m2, SHELL[1], t1)
-- one pearl-white glint on the nacre
c:put(44, 40, NACRE[6], t2) c:put(45, 40, NACRE[6], t2)

A.save(c, NAME)
