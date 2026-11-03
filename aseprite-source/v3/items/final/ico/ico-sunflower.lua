-- ico-sunflower (final, Opus). Face-on sunflower head on a slim curved stem with two heart-shaped leaves.
-- Head: two rings of slim pointed petals (back ring darker and offset), each pillow-lit 6-tone gold with a
-- crease line down the middle; seed disc is a low dome, 6-tone brown, florets laid on the golden angle
-- (dark pits + lit caps), a ring of orange pollen florets at the rim, AO on the petals where they tuck under.
-- Stem: 6-tone cylinder with fine hairs; leaves have a midrib, paired veins and a dark base where they join.
-- quirk: one petal has come loose and is drifting down beside the stem.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-sunflower")
local PET = { "#8f3f1f", "#c76a1c", "#e8961e", "#f8bf2c", "#ffdc5a", "#fff09a" }
local DSK = { "#2a1714", "#43251c", "#613722", "#814d2a", "#a46a36", "#c98a4a" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STM = { "#1d4a3a", "#2a6342", "#3a7d48", "#55994f", "#79b75c", "#a2d071" }
local ptok, dtok, ltok, stok = { r = { name = "petal" } }, { r = { name = "disc" } }, { r = { name = "leaf" } }, { r = { name = "stem" } }
local CX, CY = 30, 21
local DR = 7.3

-- stem (drawn first; leaves and head overlap it)
local sp = { { CX + 1, CY + 6 }, { CX + 2, CY + 16 }, { CX + 5, CY + 24 }, { CX + 3, CY + 34 } }
local sm, sn, STt, SS = A.tube(sp, function(t) return 1.55 + t * 0.25 end)
local sb = {}
X.ao(sb, sm, c:ellipse(CX, CY, 15, 15), 2, -1)
local sidx = A.shade(c, sm, sn, STM, { amb = 0.08, wrap = 0.25, bias = sb, tok = stok })
-- fine hairs: lit flecks on the lit side
sm:each(function(x, y) local k = K(x, y)
  if SS[k] < -0.5 and X.hash(x, y, 3) > 0.72 then A.step(c, sidx, STM, x, y, 1, stok) end end)

-- leaves: blade along quadratic bezier, heart-ish (wide near base)
local function leaf(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, W * sin(pi * min(1, t ^ 0.75)) ^ 0.8)
  end, { fold = 0.45 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.1 then bias[k] = -1 end end)
  local idx = A.shade(c, m, n, LEAF, { amb = 0.2, wrap = 0.35, bias = bias, tok = ltok })
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    if abs(s) < 0.17 and t > 0.04 and t < 0.88 then c:put(x, y, LEAF[s <= 0 and 6 or 3], ltok) end
    for _, vt in ipairs({ 0.28, 0.5, 0.7 }) do
      local d = (t - vt) * len - abs(s) * 2.6
      if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.82 then
        c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
    end
  end)
  return m
end
local lm1 = leaf(CX + 2, CY + 20, CX - 7, CY + 13, CX - 15, CY + 24, 4.0)
local lm2 = leaf(CX + 5, CY + 27, CX + 13, CY + 19, CX + 17, CY + 29, 3.6)
-- stem in front of the leaf joints: repaint a short stretch with a dark contact row on the leaves
local sfront = sm:copy()
sfront:each(function(x, y) if not ((y >= CY + 18 and y <= CY + 30)) then sfront.s[K(x, y)] = nil end end)
A.shade(c, sfront, sn, STM, { amb = 0.08, wrap = 0.25, tok = stok })
A.touch(lm1:copy():add(lm2):cut(sfront), sfront):each(function(x, y) c:put(x, y, LEAF[1], ltok) end)

-- petals
local function ring(n, r0, r1, wid, phase, ramp, bump)
  local all = HP.mask()
  for i = 0, n - 1 do
    local a = phase + i * 2 * pi / n
    local ux, uy = cos(a), sin(a)
    local L = (r1 - r0) / 2
    local mx, my = CX + ux * (r0 + L), CY + uy * (r0 + L)
    local pm = HP.mask()
    -- pointed petal: ellipse with the outer tip pinched
    local R = math.ceil(L) + 2
    for y = floor(my) - R, floor(my) + R do for x = floor(mx) - R, floor(mx) + R do
      local dx, dy = x - mx, y - my
      local al = dx * ux + dy * uy
      local ac = -dx * uy + dy * ux
      local f = (al + L) / (2 * L)                    -- 0 at base, 1 at tip
      local w = wid * sin(pi * min(1, max(0, f)) ^ 0.8) ^ 0.9
      if f >= 0 and f <= 1 and abs(ac) <= w then pm:set(x, y) end
    end end
    pm:cut(all)
    local n2 = {}
    pm:each(function(x, y)
      local dx, dy = x - mx, y - my
      local al = dx * ux + dy * uy
      local ac = -dx * uy + dy * ux
      local f = (al + L) / (2 * L)
      local w = wid * sin(pi * min(1, max(0, f)) ^ 0.8) ^ 0.9 + 0.5
      local sc = max(-0.95, min(0.95, ac / w))
      -- across: rounded; along: cupped up toward the tip
      local tx = -uy * sc * 0.9 + ux * (f - 0.5) * 0.5
      local ty = ux * sc * 0.9 + uy * (f - 0.5) * 0.5
      n2[K(x, y)] = { A.norm(tx, ty, 1) }
    end)
    local bias = {}
    pm:each(function(x, y) local dx, dy = x - CX, y - CY
      if sqrt(dx * dx + dy * dy) < DR + 2.2 then bias[K(x, y)] = -1 end end)
    if bump then for k in pairs(n2) do bias[k] = (bias[k] or 0) + bump end end
    local idx = A.shade(c, pm, n2, ramp, { amb = 0.16, wrap = 0.35, bias = bias, tok = ptok })
    -- separation line where this petal meets earlier ones in the ring
    A.touch(pm, all):each(function(x, y) A.step(c, idx, ramp, x, y, -2, ptok) end)
    -- crease down the middle of each petal
    pm:each(function(x, y)
      local dx, dy = x - mx, y - my
      local ac = -dx * uy + dy * ux
      local al = dx * ux + dy * uy
      if abs(ac) < 0.5 and al > -L * 0.2 and al < L * 0.5 and X.hash(x, y, 2) > 0.4 then A.step(c, idx, ramp, x, y, -1, ptok) end
    end)
    all:add(pm)
  end
  return all
end
local back = ring(12, DR - 1, 16.2, 2.5, pi / 12, PET, -1)
local front = HP.mask()
do
  -- front ring painted over back ring (cut nothing; later wins)
  front = ring(12, DR - 1, 12.8, 2.4, 0, PET, 0)
end
-- dark separation where front petals overlap the back ring
A.touch(back:copy():cut(front), front):each(function(x, y)
  local dx, dy = x - CX, y - CY
  if sqrt(dx*dx + dy*dy) > DR + 1 then c:put(x, y, PET[2], ptok) end end)

-- seed disc: low dome
local dm = c:ellipse(CX, CY, DR, DR)
local dn = X.sphere(CX - 0.3, CY - 0.3, DR * 1.05, dm)
local didx = A.shade(c, dm, dn, DSK, { amb = 0.05, wrap = 0.2, tok = dtok, cuts = { 0.2, 0.4, 0.62, 0.8, 0.93 } })
-- pollen ring at the rim
dm:edge():each(function(x, y) local k = K(x, y)
  local a = math.atan(y - CY, x - CX)
  if X.hash(x, y, 9) > 0.35 then c:put(x, y, (a > -2.6 and a < 0.4) and PET[3] or PET[2], dtok) end end)
-- golden-angle florets: dark pit with a lit cap above-left
local GA = pi * (3 - sqrt(5))
for i = 1, 60 do
  local r = 1.15 * sqrt(i)
  if r < DR - 1.6 then
    local a = i * GA
    local x, y = floor(CX + cos(a) * r + .5), floor(CY + sin(a) * r + .5)
    if dm:has(x, y) then
      A.step(c, didx, DSK, x, y, -2, dtok)
      if dm:has(x - 1, y - 1) and X.hash(x, y, 4) > 0.45 then A.step(c, didx, DSK, x - 1, y - 1, 1, dtok) end
    end
  end
end
-- dome specular
c:put(CX - 3, CY - 4, DSK[6], dtok) c:put(CX - 2, CY - 4, "#e0b070", dtok)

-- quirk: a loose petal drifting beside the stem (lower left)
do
  local pm, pn = A.oval(CX - 9, CY + 33, 3.0, 1.4, -0.5, 0.7)
  local idx = A.shade(c, pm, pn, PET, { amb = 0.12, wrap = 0.3, tok = ptok })
  c:put(CX - 10, CY + 33, PET[6], ptok)
end
A.save(c, "ico-sunflower")
