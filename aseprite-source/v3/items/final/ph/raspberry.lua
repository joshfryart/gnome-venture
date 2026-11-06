-- raspberry (final, Sonnet high). A slim, thimble-shaped raspberry hanging from a bronze-green cane: ~22 glossy drupelets, each a
-- lit bead (per-pixel light blended with the cone's own curvature, cast shadows between them, cool magenta bounce, bright pip
-- of specular), tapering to a rounded tip. A star of reflexed sepals sits over the shoulders with a contact shadow; one serrated
-- leaf with swept veins and a silvery torn-light rim hangs off the cane; two tiny thorns.
-- quirk: one drupelet has been plucked out and shows the pale pink receptacle cone underneath.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_5.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("raspberry")
local RB1 = { "#43102e", "#7a1840", "#aa1f49", "#d02d52", "#ee5b6c", "#ff9aa0" }
local RB2 = { "#4a112c", "#84193b", "#b5263f", "#da394a", "#f46b62", "#ffa896" }
local CORE = { "#7b3b52", "#a95a6c", "#d58a92", "#f0b8b4", "#fbd8c8", "#fff0de" }
local LEAF = { "#173a32", "#245640", "#337646", "#4d964c", "#76b45a", "#a4d07c" }
local SEP = { "#1d4234", "#2c5f3e", "#417f44", "#5f9f4a", "#89bb58", "#b6d77c" }
local CANE = { "#2e2a2a", "#4a3a34", "#6b5238", "#8f7040", "#b39450", "#d8bc78" }
local ltok = { r = { name = "leaf" } }

-- ===== berry layout: rows of drupelets on a leaning cone
local rows = {
  { 22.0, 3, 5.0 }, { 26.2, 4, 5.1 }, { 30.4, 4, 5.1 }, { 34.6, 4, 4.9 },
  { 38.7, 3, 4.8 }, { 42.7, 3, 4.4 }, { 46.4, 2, 4.2 }, { 49.6, 1, 0 } }
local AXX = 30
local function axisX(y) return AXX + (y - 22) * 0.12 end
local ds = {}
for ri, r in ipairs(rows) do
  local y, n, sp = r[1], r[2], r[3]
  local off = (ri % 2 == 0) and -sp * 0.25 or sp * 0.25
  for i = 1, n do
    local x = axisX(y) + (i - (n + 1) / 2) * sp + off
    local rad = ri <= 1 and 2.7 or (ri >= 7 and 2.4 or 3.0)
    ds[#ds + 1] = { x = x, y = y, r = rad, row = ri, i = i, n = n }
  end
end
-- the plucked one: row 4, rightmost
local pluck
for _, d in ipairs(ds) do if d.row == 4 and d.i == 4 then pluck = d end end

-- ===== cane + leaf (behind the berry)
local cm, cT, cS = A.stem(c, { { 30, 21 }, { 30, 15 }, { 35, 12 }, { 44, 11 } }, 1.5, 1.2, CANE, { 0.2, 0.4, 0.58, 0.78, 0.9 })
local cutTip = {}
cm:each(function(x, y) local k = K(x, y) if cT[k] and cT[k] > 0.94 then c:put(x, y, CANE[6]) end end)
-- thorns: small pale-tipped spikes
c:put(36, 10, CANE[2]) c:put(36, 9, CANE[5]) c:put(31, 17, CANE[2]) c:put(32, 17, CANE[5])
-- leaf: petiole then toothed blade
local lw = A.sawW(24, 5.0, { saw = 3.4, amp = 1.3, s0 = 0.18, s1 = 0.93, off = 0.1, k = 0.9, pw = 0.65 })
local lm, ln, LT, LS, llen, torn = A.tornBlade(c, 32, 14, 22, 6, 10, 11, lw, {
  ramp = LEAF, veins = { 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 }, sweep = 2.2, rib = 0.12, ribEnd = 0.96, fold = 0.45 })
-- silvery underside showing along the lower-right margin (leaf is folding)

-- ===== sepals (masks first so the drupelets can take their shade)
local sep = {}
local sepAll = HP.mask()
local sdef = {
  { 30, 21, 24, 21, 15, 26, 2.2 }, { 30, 21, 36, 22, 45, 27, 2.2 },
  { 30, 21, 23, 16, 17, 14, 2.0 }, { 30, 21, 37, 16, 43, 14, 2.0 }, { 30, 21, 31, 25, 33, 30, 2.0 } }
for _, s in ipairs(sdef) do
  local m, n, T, S, len = G.blade(s[1], s[2], s[3], s[4], s[5], s[6], function(t)
    if t > 0.98 then return -1 end
    return max(0.5, s[7] * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.5 * (1 - t * 0.35)) end, { fold = 0.4 })
  sep[#sep + 1] = { m = m, n = n, T = T, S = S }
  sepAll:add(m)
end
local capM = c:ellipse(30, 21, 3.4, 2.4)
sepAll:add(capM)

-- ===== drupelets, back to front
for _, d in ipairs(ds) do
  d.m = c:ellipse(d.x, d.y, d.r, d.r)
  if d == pluck then d.m = c:ellipse(d.x, d.y, d.r - 0.2, d.r - 0.2) end
end
local later = HP.mask()
local order = {}
for i = #ds, 1, -1 do order[#order + 1] = i end
local info = {}
for _, i in ipairs(order) do
  local d = ds[i]
  info[i] = { later = later:copy() }
  later:add(d.m)
end
local H = 30   -- body centre row for the bulge term
for i, d in ipairs(ds) do
  local vis = d.m:copy():cut(info[i].later)
  local hw = (d.n + 1) * 2.6 + 3
  local n = {}
  local sn = X.sphere(d.x - 0.5, d.y - 0.5, d.r, d.m)
  d.m:each(function(x, y) local k = K(x, y)
    local bx = (x - axisX(y)) / (hw + 4) * 1.1
    local by = (y - H) / 22 * 0.9
    local l = sn[k]
    n[k] = { G.norm(l[1] * 1.0 + bx, l[2] * 1.0 + by, l[3] * 1.15) }
  end)
  d.nn = n
  local bias = {}
  X.ao(bias, d.m, info[i].later, 1, -1) G.cast(bias, d.m, info[i].later, 1, 2, -1)
  X.ao(bias, d.m, sepAll, 1, -1) G.cast(bias, d.m, sepAll, 1, 2, -1)
  local ramp = (d.row % 2 == 0) and ((d.i % 2 == 0) and RB1 or RB2) or ((d.i % 2 == 0) and RB2 or RB1)
  if d == pluck then
    -- concave: flip the light so the hollow reads as a dent, pale pink cone
    local fn = {}
    d.m:each(function(x, y) local k = K(x, y) fn[k] = { G.norm(-n[k][1] * 0.8, -n[k][2] * 0.8, 1.2) } end)
    G.toneN(c, d.m, fn, CORE, { cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 }, bias = bias, amb = 0.1, wrap = 0.2 })
    -- drupelet-shaped pits left behind, upper rim in shade
    d.m:edge():each(function(x, y) end)
    c:put(floor(d.x + 1), floor(d.y + 1), CORE[6]) c:put(floor(d.x), floor(d.y + 1), CORE[5])
    d.m:each(function(x, y) if (x - d.x) ^ 2 + (y - d.y) ^ 2 > (d.r - 0.9) ^ 2 and (x - d.x) + (y - d.y) < 0 then c:put(x, y, CORE[1]) end end)
    -- the little pale fibres of the receptacle
    c:put(floor(d.x - 1), floor(d.y + 2), CORE[2])
  else
    local tok = { r = { name = "dr" .. i } }
    -- paint into the whole mask but only visible pixels show; paint vis
    G.toneN(c, vis, n, ramp, { cuts = { 0.15, 0.29, 0.44, 0.61, 0.8 }, bias = bias, tok = tok, amb = 0.05, wrap = 0.18 })
    -- cool magenta bounce on the lower-right rim
    local rim = X.rim(n)
    vis:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.86 and not bias[k] and d.m:has(x, y) then c:put(x, y, "#a02a66", tok) end end)
    -- specular: a pip + a faint trail
    local sx, sy = G.specAt(vis, n, 36)
    if sx then c:put(sx, sy, "#fff2ea", tok) if vis:has(sx + 1, sy) and d.r > 2.6 then c:put(sx + 1, sy, ramp[6], tok) end end
  end
end

-- tiny pale hairs: a few single pixels on the lit shoulders
for _, p in ipairs{ { 21, 25 }, { 23, 31 }, { 39, 24 }, { 25, 40 } } do end

-- ===== sepals on top
for si, s in ipairs(sep) do
  local bias = {}
  G.cast(bias, s.m, capM, 1, 1, -1)
  for sj = si + 1, #sep do X.ao(bias, s.m, sep[sj].m, 1, -1) end
  local tok = { r = { name = "sep" .. si } }
  G.toneN(c, s.m, s.n, SEP, { bias = bias, tok = tok, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.38, 0.56, 0.74, 0.88 } })
  s.m:each(function(x, y) local k = K(x, y)
    if abs(s.S[k]) < 0.13 and s.T[k] > 0.15 and s.T[k] < 0.8 and not bias[k] then c:put(x, y, SEP[6], tok) end end)
end
-- calyx button where the sepals meet the cane
local cn = X.sphere(29.6, 20.6, 3.0, capM)
G.toneN(c, capM, cn, SEP, { cuts = { 0.2, 0.38, 0.56, 0.74, 0.88 }, amb = 0.08, wrap = 0.2 })
c:put(29, 20, SEP[6]) c:put(31, 22, SEP[1])
-- base of the cane where it enters the calyx
A.save(c, "raspberry")
