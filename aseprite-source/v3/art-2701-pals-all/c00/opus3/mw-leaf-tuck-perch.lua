-- Leaf Tuck (mw-leaf-tuck), perch sprite 36x36. Opus richness pass (c00/opus3), hand-built at this size.
-- Richness pass: an extra tooth on the top and left lobes, side veins, a midrib on each heap leaf, the stem curling
-- out of the heap like a tail, a 2-tone vein on the fold and a dark crease where it bends.
-- A red maple leaf (three toothed lobes, midrib) sunk in a small heap of fallen leaves, 2x3 pill eyes.
-- quirk: the right lobe folded forward over the heap, pale underside up (tucking itself in).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mw-leaf-tuck-perch", 36)

local RED  = { "#4a1730", "#7a1f36", "#b52e3f", "#e0453a", "#f76f4a", "#ffa070" }
local UND  = { "#7a2e36", "#a8463e", "#d0684c", "#e98a5e", "#f6ad7a", "#ffd09a" }
local ORNG = { "#5c2a26", "#8f4a1f", "#c96a22", "#ec9a2c", "#f9c14e", "#ffe38a" }
local BRWN = { "#3e2526", "#5e3428", "#864c33", "#a86a40", "#c98a55", "#e8b982" }
local CRIM = { "#3e1530", "#6e2038", "#9a2a40", "#c43a44", "#e65a52", "#ff8a6c" }
local function pointed(ax, ay, bx, by, w)
  return O.tube({ { ax, ay }, { (2 * ax + bx) / 3, (2 * ay + by) / 3 }, { (ax + 2 * bx) / 3, (ay + 2 * by) / 3 }, { bx, by } },
    function(t) if t < .35 then return w * (.6 + .4 * t / .35) end return w * ((1 - t) / .65) ^ .8 end)
end

c:groundShadow(18, 32, 14, 1.5)
-- leaf: body + top lobe + left lobe + right lobe stub, one tooth on each
local leaf = c:ellipse(18, 17, 7, 6.5)
leaf:add((pointed(18, 14, 18, 2, 5)))
leaf:add((pointed(15, 16, 3, 11, 4.5)))
leaf:add((pointed(21, 16, 30, 10, 4)))
leaf:add(c:poly{ { 13, 9 }, { 11, 5 }, { 15, 7 } }):add(c:poly{ { 22, 8 }, { 25, 5 }, { 23, 10 } }):add(c:poly{ { 7, 16 }, { 3, 17 }, { 6, 14 } })
leaf:add(c:poly{ { 21, 6 }, { 23, 3 }, { 20, 4 } }):add(c:poly{ { 9, 11 }, { 7, 8 }, { 11, 10 } })
local lI, lT = O.shade(c, leaf, RED, { R = 4, amb = .2, wrap = .35, rim = true, bounce = "#6a3a6a", bmax = 1 })
O.tex(c, lI, lT, RED, function(x, y, i) if O.H(x, y, 11) > .95 and i >= 4 then return -1 end end)
O.mark(c, { { 18, 4 }, { 18, 5 }, { 18, 6 }, { 18, 7 }, { 18, 8 }, { 18, 9 }, { 18, 10 }, { 6, 13 }, { 7, 13 }, { 8, 14 }, { 9, 14 }, { 17, 7 }, { 16, 6 }, { 19, 7 }, { 20, 6 } }, RED[3])
-- stem tail curling out of the heap at the left
O.shadeN(c, select(1, O.tube({ { 8, 27 }, { 4, 27 }, { 2, 24 }, { 3, 21 } }, function(t) return .8 end)), select(2, O.tube({ { 8, 27 }, { 4, 27 }, { 2, 24 }, { 3, 21 } }, function(t) return .8 end)), BRWN, { amb = .35, wrap = .4, sep = BRWN[1] })

-- the heap
for _, h in ipairs({ { 4, 28, 14, 24, 3, BRWN }, { 32, 28, 22, 24, 3, ORNG }, { 9, 26, 20, 23, 3, ORNG },
                     { 6, 31, 17, 28, 2.6, CRIM }, { 30, 31, 19, 28, 2.6, RED }, { 13, 31, 24, 29, 2.4, BRWN } }) do
  local m, n = O.tube({ { h[1], h[2] }, { (2 * h[1] + h[3]) / 3, (2 * h[2] + h[4]) / 3 - 1 }, { (h[1] + 2 * h[3]) / 3, (h[2] + 2 * h[4]) / 3 - 1 }, { h[3], h[4] } },
    function(t) return h[5] * math.sin(math.pi * t) ^ .7 + .3 end)
  local I, T = O.shadeN(c, m, n, h[6], { amb = .25, wrap = .4, sep = h[6][1] })
  local L = math.max(math.abs(h[3] - h[1]), math.abs(h[4] - h[2]))
  for k = 2, L - 2 do
    local x, y = math.floor(h[1] + (h[3] - h[1]) * k / L + .5), math.floor(h[2] + (h[4] - h[2]) * k / L + .5)
    if c.own[y * c.w + x] == T then c.pix[y * c.w + x] = h[6][math.max(2, (I[K(x, y)] or 3) - 1)] end
  end
end
-- quirk: folded right lobe, pale underside
local fold, fn = O.tube({ { 24, 15 }, { 27, 18 }, { 28, 22 }, { 28, 27 } }, function(t)
  if t < .3 then return 3 + t / .3 end return 4 * ((1 - t) / .7) ^ .8 end)
O.shadeN(c, fold, fn, UND, { amb = .25, wrap = .4, sep = RED[2] })
O.dots(c, { { 26, 18 }, { 27, 20 }, { 27, 22 }, { 28, 24 } }, UND[6])
O.dots(c, { { 23, 14 }, { 24, 15 }, { 25, 16 } }, RED[2])
O.dots(c, { { 28, 21 }, { 29, 21 } }, UND[3])

-- face
c:eyeSmall(14, 14)
c:eyeSmall(20, 14)
O.dot(c, 12, 18, P.petal.base) O.dot(c, 23, 18, P.petal.base)
O.dots(c, { { 16, 19 }, { 17, 20 }, { 18, 20 }, { 19, 19 } }, P.ink)

O.shift(c, 0, -1)
O.done(c, "mw-leaf-tuck-perch")
