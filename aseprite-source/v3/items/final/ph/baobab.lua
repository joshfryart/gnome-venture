-- baobab (aR3_3, final single pass). A young baobab: tall bottle trunk (slim neck, swelling belly, flared root foot)
-- under a crown of short knobbly branches that end in small palmate leaf tufts; one velvety fruit pod hangs on a
-- long thin stalk. Bark: per-pixel round-trunk light, 6-tone pinkish grey, wavy vertical fibre folds (dark groove +
-- lit lip), horizontal wrinkle creases at the neck, cool bounce on the shade side, AO under the crown fork and where
-- the roots meet the ground. Pod: pillow light, fuzzy velvet speckle. Ground shadow (it stands).
-- quirk: a tiny round gnome door with a gold knob is set into the root foot.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../_helpers/_aR3_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local NAME = "baobab"
local c = G.new2(NAME)

local BARK = { "#3e2e44", "#5e4a5a", "#836a72", "#a88a88", "#c9ab9c", "#e6d0b8" }
local BR   = { "#3a2a3a", "#584250", "#7a6066", "#9c807c", "#bea08e", "#dcc4aa" }
local LEAF = { "#1d4a3a", "#2a6644", "#3f8a4c", "#62aa52", "#8ec85e", "#c0e07e" }
local POD  = { "#4a4a3a", "#6e6c48", "#949058", "#b6b06c", "#d2cc8a", "#ece6b2" }
local BOUNCE, SPEC = "#8a86a8", "#fff4d6"
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }

local CX, TOP, FOOT = 32, 25, 53
c:groundShadow(CX + 1, FOOT + 1, 15, 2)

-- trunk profile: half width by row
local function hwAt(y)
  local u = (y - TOP) / (FOOT - TOP)               -- 0 top .. 1 foot
  local w = 3.4 + 6.4 * sin(min(1, u * 1.05) * pi * 0.62) ^ 1.6
  if u > 0.86 then w = w + (u - 0.86) / 0.14 * 3.2 end  -- root flare
  return w
end
local trunk, tn, TS = HP.mask(), {}, {}
for y = TOP, FOOT do
  local w = hwAt(y)
  local dw = (hwAt(y + 1) - hwAt(y - 1)) / 2
  local cx = CX + sin((y - TOP) * 0.12) * 0.4
  for x = floor(cx - w + 0.5), floor(cx + w - 0.5) do
    trunk:set(x, y)
    local s = max(-0.97, min(0.97, (x + 0.5 - cx) / (w + 0.3)))
    local nz = sqrt(1 - s * s)
    local k = K(x, y)
    tn[k] = { G.norm(s, -dw * 0.55 * nz, nz) }
    TS[k] = s
  end
end
-- root lobes: two small bumps at the foot
for _, r in ipairs{ { CX - 11, FOOT - 1, 2.6, 1.8 }, { CX + 11, FOOT - 1, 2.8, 1.8 } } do
  local m = c:ellipse(r[1], r[2], r[3], r[4])
  m:each(function(x, y) if y <= FOOT and not trunk:has(x, y) then trunk:set(x, y)
    local s = (x - r[1]) / (r[3] + 0.5) tn[K(x, y)] = { G.norm(s, -0.4, 0.8) } TS[K(x, y)] = s end end)
end

-- branches: short tapered knobbly limbs from the trunk top
local limbs = {
  { CX - 1, TOP + 2, CX - 13, TOP - 9, 2.4 },
  { CX + 1, TOP + 1, CX + 12, TOP - 11, 2.3 },
  { CX, TOP + 1, CX - 2, TOP - 15, 2.2 },
  { CX + 8, TOP - 7, CX + 17, TOP - 2, 1.5 },
}
local tufts = {}
local btok = { r = { name = "branch" } }
local limbMask = HP.mask()
local limbs_m = {}
for i, l in ipairs(limbs) do
  local m, n, T, S = X.cyl(l[1], l[2], l[3], l[4], function(t) return l[5] * (1 - t * 0.45) end)
  limbs_m[i] = { m = m, n = n, T = T, S = S }
  limbMask:add(m)
  tufts[#tufts + 1] = { l[3], l[4] }
end
for i, L in ipairs(limbs_m) do
  local bias = {}
  if i <= 3 then X.ao(bias, L.m, trunk, 1, -1) end
  if i >= 4 then X.ao(bias, L.m, limbs_m[2].m, 1, -1) end
  local idx = G.toneN(c, L.m, L.n, BR, { tok = btok, cuts = CUTS, bias = bias, amb = 0.1 })
  -- knobbly growth rings
  L.m:each(function(x, y) local k = K(x, y)
    if (floor(L.T[k] * 9 + 0.5) % 3 == 0) and abs(L.S[k]) < 0.6 and L.T[k] > 0.2 then c:put(x, y, BR[max(1, (idx[k] or 3) - 1)], btok) end end)
end

-- trunk light
local bias = {}
X.ao(bias, trunk, limbMask, 1, -1)
trunk:each(function(x, y) local k = K(x, y)
  if y <= TOP + 1 then bias[k] = (bias[k] or 0) - 1 end            -- fork shadow
  if y >= FOOT - 1 then bias[k] = (bias[k] or 0) - 1 end           -- ground AO
end)
local v = X.light(tn, { amb = 0.08, wrap = 0.25 })
local ttok = { r = { name = "trunk" } }
local idx = X.tone(c, trunk, v, BARK, { cuts = CUTS, bias = bias, tok = ttok })
-- vertical fibre folds (wavy), groove + lit lip on the light side
local folds = { -0.62, -0.18, 0.28, 0.66 }
trunk:each(function(x, y) local k = K(x, y)
  local s = TS[k]
  for fi, f in ipairs(folds) do
    local fs = f + sin(y * 0.35 + fi * 1.7) * 0.06
    local gap = 0.07 + (y - TOP) / (FOOT - TOP) * 0.03
    if abs(s - fs) < gap and y > TOP + 1 and y < FOOT - 1 then c:put(x, y, BARK[max(1, idx[k] - 2)], ttok)
    elseif s < fs and s > fs - gap * 2.4 and idx[k] >= 3 and y > TOP + 1 and y < FOOT - 1 then c:put(x, y, BARK[min(6, idx[k] + 1)], ttok) end
  end
end)
-- horizontal wrinkle creases at the neck
for _, cy in ipairs{ TOP + 5, TOP + 8 } do
  local w = hwAt(cy)
  for x = floor(CX - w + 2), floor(CX + w - 2) do
    local y = cy + floor(((x - CX) / w) ^ 2 * 1.2 + 0.5)
    if trunk:has(x, y) and (x + cy) % 4 ~= 0 then c:put(x, y, BARK[max(1, idx[K(x, y)] - 1)], ttok) end
  end
end
-- cool bounce along the lower-right edge of the belly
local rim = X.rim(tn)
trunk:edge():each(function(x, y) local k = K(x, y)
  if TS[k] > 0.8 and rim[k] > 0.55 and y > TOP + 8 and y < FOOT - 3 then c:put(x, y, BOUNCE, ttok) end end)
-- one soft sheen on the lit belly
c:put(CX - 6, TOP + 14, BARK[6], ttok) c:put(CX - 6, TOP + 15, BARK[6], ttok)

-- leaf tufts: little palmate whorls of 5 leaflets
local ltok = { r = { name = "leaf" } }
for ti, tf in ipairs(tufts) do
  local m = HP.mask()
  local leafs = {}
  for j = 0, 4 do
    local a = -pi / 2 + (j - 2) * 0.62 + (ti % 2) * 0.15
    local ux, uy = cos(a), sin(a)
    local lm = G.rell(tf[1] + ux * 2.6, tf[2] + uy * 2.6, ux, uy, 2.6, 1.25)
    m:add(lm) leafs[#leafs + 1] = { lm, ux, uy }
  end
  m:add(c:ellipse(tf[1], tf[2], 1, 1))
  local n = X.pillow(m, 1.5)
  local lb = {}
  for j, L in ipairs(leafs) do
    if j > 1 then X.ao(lb, L[1], leafs[j - 1][1], 1, -1) end
  end
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, bias = lb, amb = 0.15, wrap = 0.3 })
  -- midribs
  for _, L in ipairs(leafs) do for d = 1, 3 do
    local x, y = floor(tf[1] + L[2] * d + 0.5), floor(tf[2] + L[3] * d + 0.5)
    if m:has(x, y) then c:put(x, y, d == 1 and LEAF[2] or LEAF[3], ltok) end end end
  c:put(floor(tf[1] + .5), floor(tf[2] + .5), LEAF[1], ltok)
end

-- hanging velvet fruit pod on a long stalk from the left limb
local sx, sy = CX - 10, TOP - 6
local ptok = { r = { name = "pod" } }
for y = sy + 1, sy + 9 do c:put(sx - ((y - sy) > 4 and 1 or 0), y, "#5e4a3e", ptok) end
local pm, pn = G.oval(sx - 1.5, sy + 14, 2.6, 4.4, 0.12)
local pidx = G.toneN(c, pm, pn, POD, { tok = ptok, cuts = CUTS, amb = 0.1 })
pm:each(function(x, y) if X.hash(x, y, 4) > 0.8 and (pidx[K(x, y)] or 1) >= 3 then c:put(x, y, POD[(pidx[K(x, y)]) - 1], ptok) end end)
do local bx, by = G.specAt(pm, pn, 30) c:put(bx, by, POD[6], ptok) end

-- quirk: tiny round gnome door in the root foot
local dtok = { r = { name = "door" } }
local DX, DY = CX + 2, FOOT - 6
local door = {
  ".kkk.",
  "kwWwk",
  "kwWwk",
  "kwWgk",
  "kwWwk",
  "kwWwk",
}
G.map(c, DX, DY, door, { k = "#2b1c26", w = "#9a5a34", W = "#c27c44", g = "#ffd25a" }, dtok)
c:put(DX - 1, DY + 6, BARK[2], ttok) c:put(DX + 5, DY + 6, BARK[2], ttok)
for x = DX, DX + 4 do c:put(x, DY + 6, "#6a5a6a", dtok) end   -- worn step
G.save2(c, NAME)
