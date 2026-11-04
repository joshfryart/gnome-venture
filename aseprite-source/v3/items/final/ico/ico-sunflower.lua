-- ico-sunflower (final, Opus, aR0_0). Face-on sunflower head on a slim curved stem with two heart-shaped leaves.
-- Head: back ring of petals (one step darker, peeking between) and a front ring of slim pointed petals, each
-- pillow-lit on a 6-tone gold ramp with a crease down the middle and a deep line where it overlaps the back ring.
-- Seed disc: low 6-tone brown dome, florets on the golden angle (dark pit + lit cap), a ring of ochre pollen
-- florets at the rim, AO on the petals where they tuck under the disc. Stem: 6-tone cylinder with a lit edge,
-- fine hairs and a dark collar under the head. Leaves: midrib, paired veins, dark base where they join the stem.
-- quirk: one petal has come loose and drifts down beside the stem.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-sunflower")
local PET  = { "#8f3f1f", "#c66a1c", "#e8961e", "#f8bf2c", "#ffdc5a", "#fff09a" }
local DISC = { "#2a1510", "#43231a", "#613522", "#7f4a2a", "#a0653a", "#c0864e" }
local POL  = { "#7a4a14", "#b0701c", "#d99a2a" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#1d4a3a", "#2a6442", "#3d814a", "#57a052", "#7cbc5e", "#a6d673" }
local SPEC = "#fff4d6"
local CX, CY = 32, 21
local ptokB, ptokF, dtok, stok, ltok = { r = { name = "petB" } }, { r = { name = "petF" } }, { r = { name = "disc" } },
  { r = { name = "stem" } }, { r = { name = "leaf" } }

-- leaf blade: quadratic A-C-B, heart-ish width, midrib + paired veins
local function leaf(ax, ay, cx, cy, bx, by, w)
  local wfn = function(t) if t > 0.985 then return -1 end
    local s = sin(pi * min(1, t * 0.96 + 0.04)) return max(0.4, w * s ^ 0.6 * (1 - 0.25 * t)) end
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, wfn, { fold = 0.45 })
  local bias = {}
  m:each(function(x, y) if T[K(x, y)] < 0.12 then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, LEAF, { amb = 0.12, wrap = 0.28, bias = bias, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = ltok })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k] local i = idx[k] or 3
    if abs(s) < 0.15 and t > 0.06 and t < 0.88 then c:put(x, y, LEAF[s <= 0 and min(6, i + 2) or max(2, i - 1)], ltok)
    elseif t > 0.15 and t < 0.82 and abs(s) > 0.3 and abs(s) < 0.78 then
      if (t * len - abs(s) * w * 1.2) % 3.4 < 0.9 then c:put(x, y, LEAF[s < 0 and min(6, i + 1) or max(1, i - 1)], ltok) end
    end end)
  return m
end

-- stem first; leaves and head on top
local sp = { { CX, CY + 8 }, { CX + 1, CY + 16 }, { CX - 3, CY + 22 }, { CX - 1, CY + 31 } }
local sm, sn, STt, SS = A.tube(sp, function(t) return 1.55 + t * 0.25 end)
local sb = {}
sm:each(function(x, y) local k = K(x, y) if STt[k] < 0.18 then sb[k] = -2 end end)
local sidx = A.shade(c, sm, sn, STEM, { amb = 0.12, wrap = 0.3, bias = sb, tok = stok })
-- fine hairs: lit pixels on the left edge every 3 rows
sm:edge():each(function(x, y) local k = K(x, y) if SS[k] < -0.5 and STt[k] > 0.25 and y % 3 == 0 then c:put(x, y, STEM[6], stok) end end)

local L1 = leaf(CX - 2, CY + 21, CX - 11, CY + 14, CX - 18, CY + 20, 4.4)
local L2 = leaf(CX - 1, CY + 26, CX + 8, CY + 20, CX + 15, CY + 25, 4.0)
-- dark base where leaves meet the stem
for _, p in ipairs({ { CX - 2, CY + 21 }, { CX - 2, CY + 20 }, { CX - 1, CY + 26 }, { CX - 1, CY + 25 } }) do c:put(p[1], p[2], STEM[1], stok) end

-- petals
local NP = 13
local function petal(a, rad, ln, wd)
  local ux, uy = cos(a), sin(a)
  local m = HP.mask()
  local cxp, cyp = CX + ux * rad, CY + uy * rad
  local R = ln + 1
  local n, Aa, Bb = {}, {}, {}
  for y = floor(cyp - R), floor(cyp + R) do for x = floor(cxp - R), floor(cxp + R) do
    local dx, dy = x + 0.5 - cxp, y + 0.5 - cyp
    local al = dx * ux + dy * uy            -- along (outward +)
    local ac = -dx * uy + dy * ux           -- across
    local tt = (al + ln) / (2 * ln)          -- 0 base .. 1 tip
    if tt >= 0 and tt <= 1 then
      local wv = wd * (sin(pi * min(1, tt * 0.9 + 0.1)) ^ 0.7) * (1 - 0.35 * tt)
      if tt > 0.8 then wv = wv * (1 - (tt - 0.8) / 0.2) ^ 0.6 + 0.2 end
      if abs(ac) <= wv then
        m:set(x, y) local k = K(x, y)
        local sc = max(-0.9, min(0.9, ac / (wv + 0.6)))
        local cup = 0.35 * sc
        local tip = (tt - 0.5) * 0.6
        n[k] = { A.norm(-uy * cup + ux * tip, ux * cup + uy * tip, 1) }
        Aa[k], Bb[k] = tt, sc
      end
    end
  end end
  return m, n, Aa, Bb
end
local back, front = HP.mask(), HP.mask()
local disc = HP.ellipse(CX - 0.5, CY - 0.5, 8.0, 8.0)
local function drawRing(off, rad, ln, wd, bstep, tok, all)
  for i = 0, NP - 1 do
    local a = (i + off) / NP * 2 * pi - pi / 2
    local m, n, T, S = petal(a, rad, ln, wd)
    m:cut(disc)
    local bias = {}
    m:each(function(x, y) local k = K(x, y) bias[k] = bstep if T[k] < 0.32 then bias[k] = bias[k] - 1 end end)
    local idx = A.shade(c, m, n, PET, { amb = 0.18, wrap = 0.35, bias = bias, tok = tok })
    m:each(function(x, y) local k = K(x, y)
      if abs(S[k]) < 0.14 and T[k] > 0.45 and T[k] < 0.9 then c:put(x, y, PET[max(1, (idx[k] or 3) - 1)], tok) end end)
    -- deep separation line against the neighbouring petals already drawn in this ring / back ring
    m:edge():each(function(x, y)
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        if all:has(x + d[1], y + d[2]) and not m:has(x + d[1], y + d[2]) then c:put(x, y, PET[2], tok) break end
      end end)
    all:add(m)
  end
end
drawRing(0.5, 11.8, 4.8, 2.4, -1, ptokB, back)
front:add(back)
drawRing(0, 12.2, 5.3, 2.6, 0, ptokF, front)

-- AO ring: petal pixels touching the disc
disc:grow(1):cut(disc):each(function(x, y) if front:has(x, y) then c:put(x, y, PET[1], ptokF) end end)

-- seed disc: low dome
local dn = A.dome(disc, CX - 0.5, CY - 0.5, 8.0, 4, 0.55)
local didx = A.shade(c, disc, dn, DISC, { amb = 0.1, wrap = 0.2, tok = dtok })
-- pollen ring at the rim
disc:edge():each(function(x, y) local k = K(x, y)
  local v = (didx[k] or 3) c:put(x, y, POL[v >= 4 and 3 or (v >= 2 and 2 or 1)], dtok) end)
-- florets on the golden angle: pit + lit cap
local GA = pi * (3 - sqrt(5))
for i = 1, 46 do
  local r = 1.05 * sqrt(i)
  if r < 6.6 then
    local a = i * GA
    local x, y = floor(CX - 0.5 + cos(a) * r + .5), floor(CY - 0.5 + sin(a) * r + .5)
    local k = K(x, y)
    if didx[k] then
      A.step(c, didx, DISC, x, y, -2, dtok)
      if disc:has(x - 1, y - 1) and (didx[K(x - 1, y - 1)] or 1) >= 3 then A.step(c, didx, DISC, x - 1, y - 1, 1, dtok) end
    end
  end
end
-- one waxy specular on the dome
c:put(CX - 4, CY - 5, DISC[6], dtok) c:put(CX - 3, CY - 5, SPEC, dtok)

-- quirk: a loose petal drifting down right of the stem
local qm, qn, QT, QS = petal(pi * 0.38, 0, 3.4, 1.8)
local qm3, qn3 = HP.mask(), {}
qm:each(function(x, y) local nx, ny = x - CX + 47, y - CY + 41 qm3:set(nx, ny) qn3[K(nx, ny)] = qn[K(x, y)] end)
A.shade(c, qm3, qn3, PET, { amb = 0.2, wrap = 0.35, tok = { r = { name = "loose" } } })

A.save(c, "ico-sunflower")
