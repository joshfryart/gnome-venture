-- ico-daisy (final, Opus). One oxeye daisy seen face-on, head tilted a touch: a ring of slim cream petals around a
-- domed golden disc, on a slim curved stem with one toothed leaf.
-- Material: petals = per-pixel light on a rounded strip, cool-lavender shade, a crease groove down each petal, AO
-- ring where petals tuck under the disc and a dark line where petals overlap; disc = 6-tone sphere with floret dots
-- and one bright specular; stem = tube light; leaf = midrib and veins.
-- quirk: "loves me not": one petal has come loose and is drifting down past the leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, atan = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.atan
local c = A.new("ico-daisy")
local PT = { "#5e4f86", "#8e80b4", "#beb4d8", "#e2dcec", "#f6f1ec", "#fffbf2" }
local DS = { "#7a3414", "#b0581a", "#d9841e", "#f2ad2c", "#ffd45a", "#fff09e" }
local GR = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local tP, tD, tS, tL = A.tok("petal"), A.tok("disc"), A.tok("stem"), A.tok("leaf")

local HX, HY = 30, 22        -- head centre
local SQ = 0.86              -- vertical squash (slight tilt back)

-- stem: slim tube curving down from under the head
local sp = { { HX + 1, HY + 6 }, { HX + 3, HY + 16 }, { HX - 1, HY + 25 }, { HX + 2, HY + 34 } }
local sm, sn = A.tube(sp, function(t) return 1.45 end)
local sidx = A.shade(c, sm, sn, GR, { tok = tS, amb = 0.1, cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 } })

-- leaf: toothed lance from the stem out to the right-down
local lm, ln, LT, LS = A.blade(HX + 2, HY + 26, HX + 12, HY + 20, HX + 20, HY + 15,
  function(t) local w = 3.3 * sin(pi * min(1, t * 1.05)) ^ 0.8 return w + ((floor(t * 9) % 2 == 1 and t > 0.25 and t < 0.9) and 0.7 or 0) end, { fold = 0.5 })
lm:cut(sm)
local lb = {}
X.ao(lb, lm, sm, 1, -1)
local lidx = A.shade(c, lm, ln, GR, { bias = lb, tok = tL, amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- midrib (lit line) and side veins (dark ticks)
lm:each(function(x, y)
  local k = K(x, y) local t, s = LT[k], LS[k]
  if abs(s) < 0.16 and t > 0.08 and t < 0.92 then c:put(x, y, GR[5], tL)
  elseif t > 0.15 and t < 0.85 and abs(s) > 0.3 and abs(s) < 0.7 and abs(((t * 6) - s * 0.9 * (s > 0 and 1 or -1)) % 1 - 0.5) < 0.09 then A.step(c, lidx, GR, x, y, -1, tL) end
end)

-- petals: 15 slots round the disc, one missing (lower-right) -> it is the drifting petal
local N = 15
local petals = {}
local headM = HP.mask()
local order = {}
for i = 0, N - 1 do order[#order + 1] = i end
for _, i in ipairs(order) do
  local a = -pi / 2 + i * 2 * pi / N + 0.08
  if i ~= 5 then
    local ux, uy = cos(a), sin(a) * SQ
    local L = 11.5 + ((i % 2 == 0) and 0.6 or -0.6)
    local m = HP.mask()
    local n = {}
    local T, S = {}, {}
    for y = floor(HY - 20), floor(HY + 20) do for x = floor(HX - 22), floor(HX + 22) do
      local dx, dy = x - HX, (y - HY) / SQ
      local along = dx * cos(a) + dy * sin(a)
      local across = -dx * sin(a) + dy * cos(a)
      local t = (along - 4) / L
      if t >= 0 and t <= 1 then
        local w = 2.75 * (t < 0.15 and (0.7 + t * 2) or 1)
        if t > 0.62 then w = w * sqrt(max(0, 1 - ((t - 0.62) / 0.38) ^ 2)) + 0.2 end
        if abs(across) <= w then
          m:set(x, y)
          local sn = across / (w + 0.6)
          -- slight cup: tip curls up toward viewer, crease along the middle
          local nx = -sin(a) * sn * 0.9 + cos(a) * (0.15 - t * 0.35)
          local ny = (cos(a) * sn * 0.9 + sin(a) * (0.15 - t * 0.35)) * SQ
          n[K(x, y)] = { A.norm(nx, ny, 1) }
          T[K(x, y)], S[K(x, y)] = t, sn
        end
      end
    end end
    petals[#petals + 1] = { m = m, n = n, T = T, S = S, i = i }
  end
end
-- paint back to front: petals in alternating layers (odd under, even over) so overlaps read
table.sort(petals, function(p, q) local a, b = p.i % 2, q.i % 2 if a ~= b then return a > b end return p.i < q.i end)
for _, p in ipairs(petals) do
  local m = p.m:copy()
  local b = {}
  -- AO near the disc (inner end of each petal)
  m:each(function(x, y) if p.T[K(x, y)] < 0.18 then b[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, p.n, PT, { bias = b, tok = tP, amb = 0.2, wrap = 0.35, tilt = { HX, HY, 18, 0.12 }, cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 } })
  -- crease groove down the middle of the petal
  m:each(function(x, y) local k = K(x, y) if abs(p.S[k]) < 0.14 and p.T[k] > 0.2 and p.T[k] < 0.85 then A.step(c, idx, PT, x, y, -1, tP) end end)
  -- dark separation where this petal lies over an earlier one
  A.touch(m, headM):each(function(x, y) A.step(c, idx, PT, x, y, -2, tP) end)
  headM:add(m)
  p.idx = idx
end

-- disc: domed golden centre
local DR = 6.2
local dm = A.ell(HX, HY, DR, DR * SQ + 0.3)
local dn = X.sphere(HX, HY, DR, dm)
local didx = A.shade(c, dm, dn, DS, { tok = tD, amb = 0.06, wrap = 0.2, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 } })
-- floret dots: a spiral grid of darker pips
dm:each(function(x, y)
  local r, th = A.polar(x, y, HX, HY)
  if r > 1.5 and r < DR - 0.6 and (floor(th * 2.2 + r * 0.9) % 2 == 0) and (x + y) % 2 == 0 then A.step(c, didx, DS, x, y, -1, tD) end
end)
-- dark ring where the disc sits on the petals (petal side)
A.touch(headM, dm):each(function(x, y) if not dm:has(x, y) then c:put(x, y, PT[1], tP) end end)
c:put(HX - 2, HY - 3, DS[6], tD) c:put(HX - 3, HY - 3, DS[6], tD) c:put(HX - 2, HY - 2, "#fff4d6", tD)

-- quirk: the loose petal, drifting down at a slant past the leaf
local fp = A.capsule(HX - 11, HY + 27, HX - 6, HY + 31, 1.4)
local fn = {}
fp:each(function(x, y) local q = max(-0.9, min(0.9, ((x - (HX - 8.5)) * -0.62 + (y - (HY + 29)) * 0.78) / 2)) fn[K(x, y)] = { A.norm(q * 0.62, -q * 0.78 + 0.1, 1) } end)
local fidx = A.shade(c, fp, fn, PT, { tok = A.tok("loose"), amb = 0.2, wrap = 0.3, cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 } })

A.save(c, "ico-daisy")
