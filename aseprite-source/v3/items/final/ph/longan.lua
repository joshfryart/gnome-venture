-- longan (final, Opus single pass). A small hanging bunch: a slim woody twig with a narrow wavy longan leaflet, three
-- thin pedicels and three round tan-ochre longan with air between them. Skin: 6-tone sphere light, leathery
-- lenticel speckle, faint dusty bloom on the lit cap, cool reflected light lower-right, dark calyx dimple + AO where
-- each pedicel meets its fruit, one soft specular each. Twig: bark grain, pale cut end.
-- quirk: the lowest fruit has a thumb-peeled window showing glassy pearl flesh and the glossy black "dragon eye" seed.
local NAME = "longan"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SKIN = { "#4a2c2a", "#76482e", "#a26c36", "#c8923e", "#e2b65a", "#f4d88e" }
local COOL = "#8a7a7e"
local BARK = { "#2e1c20", "#4e3026", "#70482e", "#946238", "#b8844c" }
local LEAF = { "#123a3c", "#1a5a4b", "#247b55", "#3a9c5f", "#64be6c", "#a2dc86" }
local PEARL = { "#9ea6b8", "#c8d0d6", "#e6ece6", "#f8f8ee" }
local SEED = { "#1c1218", "#3a2226", "#5e3a30" }

-- fruit: cx, cy, r
local F = { { 21.5, 37.5, 8 }, { 41.5, 35.5, 7.5 }, { 32.5, 51.5, 7.5 } }
-- twig from top, forking into pedicels
local btok = { r = { name = "twig" } }
local twig = { { 30, 9 }, { 31, 13 }, { 31, 17 }, { 31, 22 } }
local tm, tn = A.tube(twig, function(t) return 1.3 - 0.2 * t end, 60)
local ped = {
  { { 31, 21 }, { 28, 23 }, { 24, 26 }, { 22.5, 29.5 } },
  { { 31, 21 }, { 35, 23 }, { 40, 25 }, { 41.5, 28 } },
  { { 31, 21 }, { 31.5, 30 }, { 32, 38 }, { 32.5, 44 } },
}
local pm = HP.mask() local pn = {}
for _, p in ipairs(ped) do
  local m, n = A.tube(p, function(t) return 0.75 end, 60)
  pm:add(m) for k, v in pairs(n) do pn[k] = v end
end
-- fruit masks first (for AO on the stems)
local FM = {}
for i, f in ipairs(F) do FM[i] = (A.oval(f[1], f[2], f[3], f[3], 0, 1)) end
local allF = HP.mask() for _, m in ipairs(FM) do allF:add(m) end
pm:cut(allF)
X.tone(c, pm, X.light(pn, { amb = 0.15, wrap = 0.3 }), BARK, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = btok })
local tbias = {}
X.tone(c, tm, X.light(tn, { amb = 0.15, wrap = 0.3 }), BARK, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = btok, bias = tbias })
-- bark grain ticks and pale cut end
for _, q in ipairs{ { 31, 11 }, { 30, 15 }, { 31, 18 } } do c:put(q[1], q[2], BARK[2], btok) end
c:put(30, 8, BARK[5], btok) c:put(31, 8, BARK[4], btok)
-- leaflet off the twig to the upper right, slim and wavy-edged
local lm, ln, LT, LS, llen = A.blade(32, 14, 42, 9, 53, 14, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 3.4 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.75 + 0.35 * sin(t * 18))
end, { fold = 0.4 })
lm:cut(tm)
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { amb = 0.15, wrap = 0.3, tok = ltok })
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if abs(s) < 0.18 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local ph = (t * llen - abs(s) * 3) / 3.6
  local f = ph - floor(ph)
  if f < 0.22 and abs(s) > 0.25 and abs(s) < 0.75 and t > 0.08 and t < 0.85 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)

-- fruits (back to front: top two, then bottom)
for i, f in ipairs(F) do
  local cx, cy, r = f[1], f[2], f[3]
  local m, n = A.oval(cx, cy, r, r, 0, 1)
  local bias = {}
  -- calyx dimple AO at the top where the pedicel enters
  local tx, ty = floor(ped[i][4][1] + 0.5), floor(cy - r + 1.5)
  X.ao(bias, m, HP.mask():set(tx, ty - 1), 2, -1)
  local tok = { r = { name = "fruit" .. i } }
  local idx = A.shade(c, m, n, SKIN, { amb = 0.08, wrap = 0.3, bias = bias, tok = tok })
  -- cool bounce on the lower-right rim
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and idx[k] <= 2 then c:put(x, y, COOL, tok) end end)
  -- lenticel speckle (leathery dots) + dusty bloom flecks on the lit cap
  m:each(function(x, y) local k = K(x, y)
    local h = X.hash(x, y, i * 7)
    if idx[k] >= 3 and idx[k] <= 5 and h > 0.9 then c:put(x, y, SKIN[idx[k] - 1], tok)
    elseif idx[k] == 5 and h < 0.12 then c:put(x, y, SKIN[6], tok) end
  end)
  -- calyx dimple: dark dot + tiny ring
  c:put(tx, ty, SKIN[1], tok) c:put(tx - 1, ty, SKIN[2], tok) c:put(tx + 1, ty, SKIN[3], tok)
  -- soft specular (2x1)
  local sx, sy = A.specAt(m, n, 40)
  c:put(sx, sy, "#fff0c0", tok) c:put(sx + 1, sy, SKIN[6], tok)
  F[i].m, F[i].n, F[i].idx, F[i].tok = m, n, idx, tok
end
-- quirk: peeled window on the bottom fruit (front, lower-left), pearl flesh, black seed eye
do
  local f = F[3]
  local wm = A.oval(f[1] - 2.2, f[2] + 1.6, 4.2, 3.4, -0.4, 1)
  wm:clip(f.m)
  local wn = {}
  wm:each(function(x, y) wn[K(x, y)] = f.n[K(x, y)] end)
  local ptok = { r = { name = "flesh" } }
  X.tone(c, wm, X.light(wn, { amb = 0.3, wrap = 0.4 }), PEARL, { cuts = { 0.35, 0.55, 0.75 }, tok = ptok })
  -- torn peel lip: pale rind edge on the upper/right side of the window
  local lip = A.touch(f.m:copy():cut(wm), wm)
  lip:each(function(x, y) c:put(x, y, SKIN[6], f.tok) end)
  -- seed eye
  local ex, ey = floor(f[1] - 2), floor(f[2] + 2)
  for _, q in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 }, { -1, 0 }, { -1, 1 }, { 0, -1 }, { 0, 2 } } do
    if wm:has(ex + q[1], ey + q[2]) then c:put(ex + q[1], ey + q[2], (q[2] >= 1 and q[1] >= 0) and SEED[2] or SEED[1], ptok) end
  end
  c:put(ex, ey, "#f2eadc", ptok)                               -- glossy glint on the seed
  c:put(ex + 1, ey - 1 + 3, SEED[3], ptok)
end

A.save(c, NAME)
