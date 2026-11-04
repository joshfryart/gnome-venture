-- ico-fork (final, Opus): garden hand fork standing upright. Turned ash handle with a hang hole, steel ferrule
-- with a pressed groove, three slim forged tines (outer pair sweeping out from a curved crossbar).
-- Material: wood grain streaks + paler butt, cylinder-lit steel with bevel lip, specular streak and one glint,
-- AO row on the wood under the ferrule and where the tines leave the crossbar.
-- quirk: a pink earthworm has draped itself over the right tine.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sin, pi, max, min, abs, floor = math.sin, math.pi, math.max, math.min, math.abs, math.floor
local c = A.new("ico-fork")
local WOOD  = { "#4a2a26", "#6e3f2e", "#93593a", "#b97a4a", "#d69c63", "#efc78d" }
local STEEL = { "#383a56", "#565977", "#7c809c", "#a6abc2", "#cfd4e4", "#eef0f6" }
local WORM  = { "#7d2c5e", "#b04a72", "#df7090", "#f59aae", "#ffc8d4" }
local MC = { 0.3, 0.47, 0.62, 0.77, 0.9 }
local wtok, stok = { r = { name = "wood" } }, { r = { name = "steel" } }

-- handle (painted first; ferrule laps over its top)
local hm, hn, hT, hS, hidx = A.tube(c, { { 32, 36 }, { 32, 43 }, { 32, 49 }, { 32, 54 } },
  function(t) return 3.0 + 0.7 * sin(pi * min(1, t * 1.1)) end, WOOD, { tok = wtok, cuts = MC, amb = 0.04, wrap = 0.18 })
hm:each(function(x, y) local k = K(x, y)
  local s, t = hS[k], hT[k]
  -- two wavering grain streaks + a small knot
  local g1 = abs(s + 0.36 + 0.07 * sin(t * 9)) < 0.13 and t < 0.7
  local g2 = abs(s - 0.12 - 0.08 * sin(t * 7 + 1.3)) < 0.12 and t > 0.25
  if (g1 or g2) and t > 0.05 and t < 0.9 then A.step(c, hidx, WOOD, x, y, -1, wtok) end
  if y <= 37 then A.step(c, hidx, WOOD, x, y, -2, wtok) end         -- AO under the ferrule
  if t > 0.97 and s < 0.3 then A.step(c, hidx, WOOD, x, y, 1, wtok) end -- paler worn butt
end)
-- hang hole: dark eye with a lit far wall
for _, p in ipairs{ { 31, 50 }, { 32, 50 }, { 31, 51 }, { 32, 51 } } do c:put(p[1], p[2], A.INK, wtok) end
c:put(32, 52, WOOD[2], wtok) c:put(33, 51, WOOD[3], wtok) c:put(31, 52, WOOD[5], wtok)

-- tines: outer pair first, centre tine + neck over them
local function tw(base) return function(t)
  if t > 0.86 then return max(0.55, base * 0.85 * (1 - (t - 0.86) / 0.16) + 0.25) end
  return base - 0.25 * t end end
local lm, ln, lT, lS, lidx = A.tube(c, { { 31, 28 }, { 22, 29 }, { 18, 22 }, { 18, 10 } }, tw(2.15), STEEL, { tok = stok, cuts = MC, amb = 0.04, wrap = 0.18 })
local rm, rn, rT, rS, ridx = A.tube(c, { { 33, 28 }, { 42, 29 }, { 46, 22 }, { 46, 10 } }, tw(2.15), STEEL, { tok = stok, cuts = MC, amb = 0.04, wrap = 0.18 })
local cm, cn, cT, cS, cidx = A.tube(c, { { 32, 31 }, { 32, 22 }, { 32, 15 }, { 32, 8 } }, tw(2.2), STEEL, { tok = stok, cuts = MC, amb = 0.04, wrap = 0.18 })
local nm, nn, nT, nS, nidx = A.tube(c, { { 32, 32 }, { 32, 30.5 }, { 32, 29 }, { 32, 27.5 } }, function(t) return 3.0 - t * 0.6 end, STEEL, { tok = stok, cuts = MC, amb = 0.04, wrap = 0.18 })
-- AO where the outer tines join the neck / centre tine
local core = cm:copy():add(nm)
A.sep(c, lm, lidx, STEEL, core, -2, stok) A.sep(c, rm, ridx, STEEL, core, -2, stok)
-- specular streak on the lit flank of each tine
local function streak(m, T, S, idx, t0, t1)
  m:each(function(x, y) local k = K(x, y)
    if T[k] > t0 and T[k] < t1 and S[k] < -0.25 and S[k] > -0.75 and idx[k] >= 4 then c:put(x, y, STEEL[6], stok) end end)
end
streak(cm, cT, cS, cidx, 0.2, 0.75) streak(lm, lT, lS, lidx, 0.55, 0.85) streak(rm, rT, rS, ridx, 0.6, 0.8)

-- ferrule: squared steel collar, groove + lit lip, dark top row where the neck enters
local fm = c:rect(27, 31, 37, 37)
fm:cut(c:rect(27, 31, 27, 31)):cut(c:rect(37, 31, 37, 31)):cut(c:rect(27, 37, 27, 37)):cut(c:rect(37, 37, 37, 37))
local fidx = A.shade(c, fm, A.vcyl(fm, 32, 5), STEEL, { amb = 0.04, wrap = 0.18, cuts = MC, tok = stok })
for x = 27, 37 do
  A.step(c, fidx, STEEL, x, 31, -1, stok)
  A.step(c, fidx, STEEL, x, 34, -2, stok)
  A.step(c, fidx, STEEL, x, 35, 1, stok)
  A.step(c, fidx, STEEL, x, 37, -1, stok)
end
c:put(30, 32, A.CREAM, stok) c:put(30, 33, STEEL[6], stok)   -- glint on the collar

-- quirk: earthworm draped over the right tine (front loop, dangling tail with a curled tip)
local wt = { r = { name = "worm" } }
local wm, wn, wT, wS, widx = A.tube(c, { { 43, 16 }, { 45.5, 12.5 }, { 50, 13 }, { 49.5, 21 } },
  function(t) return t > 0.92 and 0.7 or 1.0 end, WORM, { tok = wt, cuts = { 0.25, 0.45, 0.65, 0.85 }, amb = 0.05, wrap = 0.2 })
wm:each(function(x, y) local k = K(x, y)
  if floor(wT[k] * 16) % 3 == 1 and wS[k] > -0.4 then A.step(c, widx, WORM, x, y, -1, wt) end end)
A.sep(c, rm, ridx, STEEL, wm, -3, stok)          -- contact shadow on the tine under the worm
for _, p in ipairs{ { 48, 22 }, { 47, 22 } } do c:put(p[1], p[2], WORM[2], wt) end   -- curled tail tip
c:put(45, 12, WORM[5], wt)
A.save(c, "ico-fork")
