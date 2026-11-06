-- ico-deer (final, Opus). A young stag, head and neck face-on: a tapering wedge of a head with a pale muzzle and
-- ink nose, big leaf-shaped ears, a cream throat patch, and slim branching antlers.
-- Material: fur = 6-tone per-pixel light with short fur ticks along the cheeks and a paler blaze, ear = pink inner
-- with a dark fold line; antler = 6-tone tube light with ring ridges at the burr and pale worn tips; AO where the
-- ears and antlers meet the skull.
-- quirk: a little red autumn leaf is snagged on the left antler.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-deer")
local FUR = { "#3a1e22", "#62342a", "#8e5232", "#b8743e", "#d89a58", "#f0c482" }
local CRM = { "#8a6458", "#bf9a82", "#e6cba8", "#fbead0" }
local ANT = { "#4a3226", "#76563c", "#a4835c", "#c9a87c", "#e6cfa4", "#faedcc" }
local PNK = { "#9a4a62", "#d07a8e", "#f2a6b4" }
local INK, CREAM = A.INK, A.CREAM
local tF, tA, tE, tM, tX = A.tok("fur"), A.tok("antler"), A.tok("ear"), A.tok("muzzle"), A.tok("bits")
local CX = 32

-- antlers (drawn first; head goes over the burrs)
local antM = HP.mask()
local function beam(pts, w0, w1)
  local m, n, T = A.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  m:cut(antM)
  local idx = A.shade(c, m, n, ANT, { tok = tA, amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  -- pale worn tips + ridges near the burr
  m:each(function(x, y) local t = T[K(x, y)]
    if t > 0.86 then A.step(c, idx, ANT, x, y, 1, tA) end
    if t < 0.12 and (x + y) % 3 == 0 then A.step(c, idx, ANT, x, y, -1, tA) end end)
  A.touch(m, antM):each(function(x, y) A.step(c, idx, ANT, x, y, -2, tA) end)
  antM:add(m)
  return m
end
for _, sd in ipairs{ -1, 1 } do
  local function P(x, y) return { CX + sd * x, y } end
  beam({ P(5, 19), P(9, 13), P(12, 9), P(13, 3) }, 1.9, 1.2)          -- main beam, curling up
  beam({ P(8.5, 14), P(12, 13.5), P(16, 12), P(18, 8) }, 1.4, 1.0)    -- outer tine
  beam({ P(11.5, 9.5), P(9, 7.5), P(7.5, 5), P(7.5, 2.5) }, 1.25, 0.95) -- inner tine
end

-- ears: leaf shapes pointing out and slightly up
local earM = HP.mask()
for _, sd in ipairs{ -1, 1 } do
  local m, n, T, S = A.blade(CX + sd * 7, 22, CX + sd * 13, 18.5, CX + sd * 20, 19.5,
    function(t) return 3.6 * sin(pi * min(1, 0.12 + t * 0.9)) ^ 0.7 end, { fold = 0.35 })
  local idx = A.shade(c, m, n, FUR, { tok = tE, amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  -- pink inner ear with a dark fold along its lower edge
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k] * sd
    if t > 0.15 and t < 0.85 and abs(s + 0.1) < 0.45 - abs(t - 0.5) * 0.4 then
      c:put(x, y, (s > 0.15) and PNK[1] or ((s < -0.15) and PNK[3] or PNK[2]), tE)
    end end)
  earM:add(m)
end

-- head: skull + tapering face to a narrow muzzle; neck below
local head = A.ell(CX, 25, 9.5, 8.5)
head:add(c:poly{ { CX - 9.3, 25 }, { CX + 9.8, 25 }, { CX + 4.6, 40 }, { CX - 4.1, 40 } })
head:add(A.ell(CX + 0.25, 40, 4.3, 3.6))
local neck = c:poly{ { CX - 5.5, 34 }, { CX + 6, 34 }, { CX + 9.5, 52 }, { CX - 9, 52 } }
neck:cut(head)
-- neck (behind head): darker, AO under the jaw
local nn = X.pillow(neck, 4)
local nb = {}
X.ao(nb, neck, head, 2, -1)
neck:each(function(x, y) local k = K(x, y) nb[k] = (nb[k] or 0) - 1 end)
local nidx = A.shade(c, neck, nn, FUR, { bias = nb, tok = A.tok("neck"), amb = 0.08, wrap = 0.25, tilt = { CX, 48, 10, 0.15 }, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- cream throat patch with a lit edge
local throat = A.ell(CX + 0.5, 49, 3.6, 3):clip(neck)
local tidx = A.shade(c, throat, A.ellN(throat, CX, 48, 5, 4), CRM, { tok = tM, amb = 0.2, cuts = { 0.3, 0.55, 0.78 } })
-- fur ticks down the neck
neck:each(function(x, y) if not throat:has(x, y) and y > 44 and X.hash(x, y, 5) > 0.84 and neck:has(x, y + 1) then A.step(c, nidx, FUR, x, y, -1, tF) end end)

-- head fur light: rounded profile + forehead dome
local hn = X.pillow(head, 5)
local hb = {}
X.ao(hb, head, earM, 1, -1)
X.ao(hb, head, antM, 1, -1)
local hidx = A.shade(c, head, hn, FUR, { bias = hb, tok = tF, amb = 0.1, wrap = 0.3, tilt = { CX, 30, 14, 0.18 }, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- paler blaze down the forehead
head:each(function(x, y) if y > 20 and y < 36 and abs(x - CX - 0.25 + (y - 28) * 0.02) < (y < 28 and 1.2 or 0.7) then A.step(c, hidx, FUR, x, y, 1, tF) end end)
-- fur ticks on the cheeks
head:each(function(x, y)
  if y > 27 and y < 38 and abs(x - CX) > 4 and X.hash(x, y, 9) > 0.8 then A.step(c, hidx, FUR, x, y, -1, tF) end end)

-- muzzle: pale cream, ink nose with a cream glint, mouth line
local muz = A.ell(CX + 0.25, 39.5, 4, 3.2)
local midx = A.shade(c, muz, A.ellN(muz, CX - 0.5, 38.5, 5, 4), CRM, { tok = tM, amb = 0.15, cuts = { 0.28, 0.52, 0.76 } })
A.map(c, {
  ".KKKK.",
  "KcKKKK",
  ".KKKK.",
  "..KK..",
  ".K..K.",
}, CX - 2, 37, { K = INK, c = CREAM }, tX)

-- eyes: 2x3 ink pills with a cream glint upper-left, a dark lid row above
for _, ex in ipairs{ CX - 6, CX + 5 } do
  A.map(c, { "dd", "cK", "KK", "KK" }, ex, 27, { K = INK, c = CREAM, d = FUR[2] }, tX)
end

-- quirk: a red autumn leaf snagged on the left antler's outer tine
A.map(c, {
  "...hR..",
  "..hRRr.",
  ".hRrRrd",
  "hRRrrd.",
  ".Rrdd..",
  "s.d....",
}, CX - 18, 8, { R = "#f07a2e", h = "#ffb85c", r = "#c8501e", d = "#7a2e1e", s = "#864c33" }, tX)

A.save(c, "ico-deer")
