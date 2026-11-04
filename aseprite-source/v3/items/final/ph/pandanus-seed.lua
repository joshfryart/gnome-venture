-- pandanus-seed (final, aC31_5, Opus single pass; replaces the Sonnet draft). Two pandanus keys (the woody wedge
-- drupes the fruit breaks into) on a torn scrap of a pandanus strap leaf (keeled, spiny margin, ragged torn ends,
-- cool rim). Keys: pale fibrous wedge base with stringy fibre lines, domed orange-red woody cap with a dark hex
-- facet ring and stigma dot, specular, contact shadow on the leaf. The right key has germinated: a short pale
-- shoot from the cap opening into a fan of four keeled, spiny strap leaves - the pandanus leaf shape in miniature.
-- quirk: the seedling already stands on three tiny stilt roots, like a grown pandanus tree.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local norm = G.norm
local c = G.new2("pandanus-seed")

local OLD   = { "#183832", "#244f3a", "#33693f", "#4a8445", "#6aa050", "#93bf66" }
local NEW   = { "#1d4a36", "#2b6a40", "#3f8a46", "#5aa84c", "#82c45a", "#b4de7c" }
local CAP   = { "#4e1a1e", "#7e2a22", "#ae4224", "#d6602a", "#f08a3c", "#ffbe6c" }
local FIB   = { "#7a5e3a", "#a48256", "#c8a674", "#e2c896", "#f2e2b8", "#fff4d6" }
local SHOOT = { "#6a7a44", "#93a85a", "#bccf7a", "#e0ecaa" }
local ROOT  = { "#8a6c4a", "#c4a478", "#ecd8aa" }
local COOL, SPEC = "#3e6f78", "#fff6dc"

-- torn strap-leaf scrap lying across the bottom
local lm, ln, LT, LS = G.blade(6, 52, 30, 43, 58, 47, function(t) return 5.6 end, { fold = 0.45 })
-- ragged torn ends
lm:each(function(x, y) local k = K(x, y)
  local t = LT[k]
  local j = X.hash(floor(LS[k] * 4), 1, 7) * 0.05
  if t < 0.025 + j or t > 0.965 - j then lm.s[k] = nil end
end)
-- keys (wedges): cx, cy, half length, half width, angle toward the narrow fibrous base
local keys = { { 19, 45.5, 5.2, 3.6, 0.35 }, { 39, 44, 5.4, 3.8, pi * 0.62 } }
for _, s in ipairs(keys) do s.m, s.n, s.U = G.drop(s[1], s[2], s[3], s[4], s[5], 0.7) end
local allK = HP.mask() for _, s in ipairs(keys) do allK:add(s.m) end
local lb = {}
X.ao(lb, lm, allK, 1, -1) G.cast(lb, lm, allK, 1, 2, -1) G.cast(lb, lm, allK, 2, 2, -1)
local ltok = { r = { name = "leaf" } }
local lid = G.toneN(c, lm, ln, OLD, { tok = ltok, bias = lb, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
lm:each(function(x, y) local k = K(x, y)
  if lb[k] then return end
  if abs(LS[k]) < 0.12 then c:put(x, y, OLD[max(1, lid[k] - 2)], ltok)             -- keel groove
  elseif LS[k] > -0.35 and LS[k] < -0.2 then c:put(x, y, OLD[min(6, lid[k] + 1)], ltok) end   -- lit keel shoulder
  if abs(abs(LS[k]) - 0.6) < 0.08 and X.hash(x, y, 2) > 0.4 then c:put(x, y, OLD[max(1, lid[k] - 1)], ltok) end -- parallel veins
end)
local rim = X.rim(ln)
lm:edge():each(function(x, y) local k = K(x, y) if not lb[k] and LS[k] > 0.6 then c:put(x, y, COOL, ltok) end end)
-- spines on both margins (pointing toward the leaf tip, right)
lm:edge():each(function(x, y) local k = K(x, y)
  if abs(LS[k]) > 0.7 and LT[k] > 0.08 and LT[k] < 0.9 and x % 4 == 1 then
    local dy = LS[k] > 0 and 1 or -1
    if not lm:has(x + 1, y + dy) and not lm:has(x, y + dy) then c:put(x, y + dy, OLD[5], ltok) end
  end
end)

-- a key: fibrous wedge base + woody cap
local function key(s, i)
  local tok = { r = { name = "key" .. i } }
  local id = {}
  local v = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  s.m:each(function(x, y) local k = K(x, y)
    local u = s.U[k].u                                -- +1 = narrow fibrous base, -1 = cap end
    local R = u < -0.15 and CAP or FIB
    local j = 1 for jj, cut in ipairs({ 0.2, 0.36, 0.52, 0.68, 0.84 }) do if v[k] >= cut then j = jj + 1 end end
    if u >= -0.15 and abs(s.U[k].v) * 7 % 2 < 0.5 then j = j - 1 end      -- stringy fibres along the wedge
    if u > -0.25 and u < -0.08 then R, j = CAP, j - 2 end                  -- dark facet ring where cap meets fibre
    j = max(1, min(6, j)) id[k] = j
    c:put(x, y, R[j], tok)
  end)
  -- stigma dot on the cap
  local sx, sy = floor(s[1] - cos(s[5]) * s[3] * 0.62 + .5), floor(s[2] - sin(s[5]) * s[3] * 0.62 + .5)
  c:put(sx, sy, CAP[1], tok)
  local bx, by = G.specAt(s.m, s.n, 30)
  if bx then c:put(bx, by, SPEC, tok) end
end
key(keys[1], 1)

-- seedling (behind the germinated key's cap): pale shoot, then a fan of strap leaves
key(keys[2], 2)
local SX, SY = 38, 29
local stm, stn = G.tube({ { 41, 39 }, { 40, 36 }, { 38.5, 33 }, { SX, SY } }, function(t) return 1.3 - t * 0.2 end)
local shtok = { r = { name = "shoot" } }
G.toneN(c, stm, stn, SHOOT, { tok = shtok, cuts = { 0.25, 0.5, 0.75 } })
local stok = { r = { name = "sprout" } }
local function strap(cx, cy, bx, by, w)
  local m, n, T, S = G.blade(SX, SY, cx, cy, bx, by, function(t) return w * (1 - t ^ 2.4) * min(1, t * 5 + 0.3) + 0.3 end, { fold = 0.65 })
  local id = G.toneN(c, m, n, NEW, { tok = stok, amb = 0.14, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.18 and T[k] < 0.85 and T[k] > 0.08 then c:put(x, y, NEW[max(1, id[k] - 2)], stok) end end)
  m:edge():each(function(x, y) local k = K(x, y)
    if S[k] > 0.55 and T[k] > 0.2 and T[k] < 0.8 and X.hash(x, y, 5) > 0.55 then
      for _, d in ipairs{ { 1, 0 }, { 0, 1 } } do
        if not m:has(x + d[1], y + d[2]) and not c:get(x + d[1], y + d[2]) then c:put(x + d[1], y + d[2], NEW[5], stok) break end
      end
    end
  end)
  return m
end
-- back leaves first, front last
strap(29, 15, 15, 12, 2.0)
strap(46, 14, 55, 13, 2.0)
strap(37, 16, 33, 5, 2.1)
strap(45, 23, 53, 25, 1.6)
-- AO where the fan meets the shoot
c:put(SX, SY, SHOOT[1], shtok) c:put(SX + 1, SY, NEW[1], stok)

-- quirk: three tiny stilt roots splaying from the shoot down onto the leaf
local rtok = { r = { name = "roots" } }
for _, r in ipairs{ { { 39, 33 }, { 35, 36 }, { 33, 40 } }, { { 39, 34 }, { 37, 37 }, { 36, 39 } }, { { 40, 34 }, { 44, 37 }, { 46, 40 } } } do
  local pm = G.path(r)
  pm:each(function(x, y) c:put(x, y, ROOT[2], rtok) end)
  c:put(r[1][1], r[1][2], ROOT[3], rtok)
  local e = r[#r] c:put(e[1], e[2], ROOT[1], rtok)
end

-- the cap split open where the shoot comes out
c:put(40, 40, CAP[1]) c:put(42, 40, CAP[1]) c:put(41, 40, SHOOT[1], shtok)

G.save2(c, "pandanus-seed")
