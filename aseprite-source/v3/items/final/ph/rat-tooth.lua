-- rat-tooth (final D12_0, Sonnet high). One long curved rat incisor on the diagonal: pale ivory root with a hollow pulp
-- opening, a glossy orange-yellow enamel front (spec streak, faint growth ridges), a worn chisel tip with a pale dentin
-- bevel, the ivory side face showing on the inner curve. quirk: a loop of twine is wrapped round the root like a
-- trinket, one loose end dangling.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("rat-tooth")
local IV = { "#5e3f3a", "#8e6e62", "#bd9e84", "#dcc4a2", "#f0e0c2", "#fff4d6" }
local EN = { "#74321c", "#a84e1c", "#dc7a22", "#f4a032", "#fcc650", "#ffeaa0" }
local TW = { "#5a3820", "#8a5c30", "#bc8a4c", "#e6bb7c" }

local p = { { 17, 10 }, { 10, 30 }, { 22, 50 }, { 47, 52 } }
local function wfn(t) return (3.0 + 1.35 * sin(pi * t * 0.9)) * (1 - 0.66 * t ^ 2.2) end
local m, n, T, S, sm = A.tube(p, wfn)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 }
local function tone(k) local i = 1 for j, th in ipairs(cuts) do if v[k] >= th then i = j + 1 end end return i end
-- front (convex, outer curve = lower-left) vs side face
local front, idx = {}, {}
local len = 56
m:each(function(x, y) local k = K(x, y)
  local sg = A.sideSign(p, T[k], -1, 1)
  local f = S[k] * sg                     -- +1 = outer convex edge
  front[k] = f
  local edgeT = 0.22 + 0.035 * sin(f * 5)
  local isEn = f > -0.28 and T[k] > edgeT and T[k] < 0.93
  local i = tone(k)
  -- a pale ridge/rolled lip where enamel meets ivory
  if isEn then
    if abs(f + 0.28) < 0.2 then i = i - 1 end
    c:px(x, y, EN[A.clamp(i + 0, 1, 6)])
  else
    c:px(x, y, IV[A.clamp(i, 1, 6)])
  end
  idx[k] = isEn and 1 or 0
end)
-- growth ridges across the enamel (thin darker bands), a seam line down the enamel/side border
m:each(function(x, y) local k = K(x, y)
  if idx[k] == 1 then
    local ph = (T[k] * len + front[k] * 1.0) / 6.5
    if abs(ph - floor(ph + 0.5)) < 0.075 and front[k] > 0.05 and front[k] < 0.8 and T[k] > 0.3 and T[k] < 0.86 then
      c:px(x, y, EN[A.clamp(tone(k) - 1, 1, 6)])
    end
    if abs(front[k] + 0.28) < 0.09 and T[k] > 0.25 and T[k] < 0.9 then c:px(x, y, EN[2]) end
  end
end)
-- polished spec streak on the lit enamel (dashes along the length)
local sp = X.spec(n, 18)
m:each(function(x, y) local k = K(x, y)
  if idx[k] == 1 and sp[k] > 0.78 and T[k] > 0.3 and T[k] < 0.84 and front[k] > 0.1 then c:px(x, y, EN[6]) end
end)
-- cool reflected light on the side face's lower edge
m:each(function(x, y) local k = K(x, y)
  if idx[k] == 0 and front[k] < -0.7 and T[k] > 0.24 and T[k] < 0.88 then c:px(x, y, IV[2]) end
end)
-- chisel tip: pale dentin bevel + bright edge
m:each(function(x, y) local k = K(x, y)
  if T[k] >= 0.93 then c:px(x, y, front[k] > 0 and IV[4] or IV[5]) end
  if T[k] >= 0.965 then c:px(x, y, IV[6]) end
end)
-- the top face of the tip catches a light nick
-- hollow pulp opening at the root
local hole = c:ellipse(17, 9, 2.6, 1.3)
c:fillMask(hole, "#2e1a1c")
c:px(15, 9, "#4b2a26") c:px(16, 8, "#4b2a26") c:px(18, 10, "#6b3d32")
c:fillMask(c:rect(14, 7, 20, 7), IV[5])
c:px(15, 6, IV[6]) c:px(16, 6, IV[6])

-- twine wrapped round the root (diagonal turns), with a knot and a loose end
local wm = HP.mask()
m:each(function(x, y) local k = K(x, y) if T[k] > 0.12 and T[k] < 0.27 then wm:set(x, y) end end)
wm:each(function(x, y) local k = K(x, y)
  local ph = (T[k] * len + front[k] * 1.6) / 2.4
  local f = ph - floor(ph)
  if f < 0.72 then
    local i = 3
    if f < 0.14 then i = 4 end                  -- twist highlight
    if f > 0.55 then i = 2 end                  -- edge shade of each turn
    if front[k] > 0.55 then i = i - 1 end
    c:px(x, y, TW[A.clamp(i, 1, 4)])
  else
    c:px(x, y, IV[1])                            -- gap between turns: ambient dark
  end
end)
-- knot (right side, in the concave side) and loose end with a frayed tip
c:fillMask(c:rect(20, 19, 22, 20), TW[3])
c:px(20, 19, TW[4]) c:px(22, 20, TW[1]) c:px(21, 21, TW[2])
local tail = { { 22, 21 }, { 23, 23 }, { 22, 25 }, { 24, 27 }, { 25, 29 } }
A.pline(c, tail, TW[3])
c:px(23, 22, TW[2]) c:px(24, 24, TW[2])
c:px(25, 30, TW[4]) c:px(26, 30, TW[4]) c:px(24, 30, TW[2])
-- one small cream sparkle off the polished crown
c:sparkle(12, 36)
A.save(c, "rat-tooth")
