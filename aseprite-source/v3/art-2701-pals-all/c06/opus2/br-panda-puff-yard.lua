-- Panda Puff (br-panda-puff), yard sprite 64x64. Opus second pass (art-2701-pals-all/c06/opus2), built on the Haiku pass.
-- Common, brewroot. "A fluffy bamboo fan who eats one stalk at a time, very slowly."
-- A sitting panda puff: cream-white fur with cool lilac shade and a scalloped fluffy edge, dark ears, drooping
-- eye patches, dark arms and legs, holding one green bamboo stalk (nodes, leaf sprig) up to its mouth.
-- Fixes vs Haiku: fur is white-cream with cool shadows (was peach), the patch-and-ear pattern reads as a
-- panda, the outline is a soft scalloped fluff instead of lumps, the stalk is held in a paw.
-- quirk: it eats very slowly: the stalk top has one small bite out of it and a single bamboo leaf is still
-- sticking out of its mouth, mid-chew.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("br-panda-puff-yard", 64)

local FUR  = { "#6a6084", "#9a92ae", "#c4bccc", "#e2dcde", "#f2eee8", "#fbf8f2" }
local DARK = { "#1e1826", "#2e2638", "#40364c", "#564a62", "#706480" }
local BAMB = { "#1f4a2a", "#2e6a34", "#4a8e3e", "#6eb04c", "#a2d06a", "#d4ec9a" }
local LEAF = { "#1f3b2e", "#2c6a3a", "#4a9a48", "#7cc45c" }
local BNC  = "#6a8aa8"

c:groundShadow(32, 58, 18, 2.5)

-- fluffy scalloped mask: ellipse plus small bumps along its edge
local function fluff(cx, cy, rx, ry, n, br, skip)
  local m = c:ellipse(cx, cy, rx, ry)
  for i = 0, n - 1 do
    local a = i / n * 2 * math.pi
    if not (skip and skip(a)) then
      m:add(c:ellipse(cx + math.cos(a) * rx, cy + math.sin(a) * ry, br, br))
    end
  end
  return m
end
local function furTex(I, T, seed)
  O.tex(c, I, T, FUR, function(x, y, i)
    local h = H(x, y, seed)
    if h > .9 and i >= 3 and i <= 5 then return -1 end -- fur tufts
  end)
end

-- legs (dark), sitting
for _, s in ipairs({ { 21, 54 }, { 42, 54 } }) do
  O.shade(c, c:ellipse(s[1], s[2], 6, 3.5), DARK, { sphere = { s[1] - 2, s[2] - 2, 7 }, amb = .3, wrap = .4, rim = true, cuts = { .25, .45, .65, .85 } })
  O.dots(c, { { s[1] - 2, s[2] }, { s[1], s[2] - 1 }, { s[1] + 2, s[2] } }, DARK[5]) -- toe pads
end
-- body
local body = fluff(32, 43, 15, 11, 14, 2)
local bI, bT = O.shade(c, body, FUR, { sphere = { 26, 37, 19 }, amb = .3, wrap = .4, sep = FUR[1], rim = true, bounce = BNC, bmax = 2 })
furTex(bI, bT, 3)
-- ears
for _, e in ipairs({ { 19, 14 }, { 43, 14 } }) do
  O.shade(c, c:ellipse(e[1], e[2], 4.5, 4), DARK, { sphere = { e[1] - 2, e[2] - 2, 5 }, amb = .3, wrap = .4, rim = true, cuts = { .25, .45, .65, .85 } })
end
-- head
local head = fluff(31, 26, 15, 11, 16, 1.6, function(a) return a > .3 and a < 2.8 end)
local hI, hT = O.shade(c, head, FUR, { sphere = { 25, 20, 19 }, amb = .32, wrap = .4, sep = FUR[1], rim = true })
furTex(hI, hT, 9)
-- drooping eye patches (sleepy, slow)
for _, p in ipairs({ { 23, 27, -1 }, { 39, 27, 1 } }) do
  local m = c:ellipse(p[1], p[2], 5, 4)
  m:add(c:ellipse(p[1] + p[3] * 2, p[2] + 2, 3, 2.5))
  O.shade(c, m, DARK, { R = 2, amb = .35, wrap = .45, cuts = { .25, .45, .65, .85 } })
end
c:eyeLocked(20, 24)
c:eyeLocked(37, 24)
-- nose + mouth
O.shade(c, c:ellipse(31, 32, 2, 1.2), DARK, { R = 1, amb = .4, cuts = { .25, .45, .65, .85 } })
O.dot(c, 30, 31, DARK[5])
O.dots(c, { { 31, 34 }, { 29, 35 }, { 30, 35 }, { 32, 35 }, { 33, 35 } }, P.ink)
c:cheek(17, 32) c:cheek(44, 32)

-- the bamboo stalk, held in the right paw, top end up at the mouth corner
local stalk = c:poly{ { 46, 60 }, { 50, 60 }, { 39, 32 }, { 35, 32 } }
local sb = {} stalk:each(function(x, y) if y == 52 or y == 43 then sb[K(x, y)] = -2 end if y == 51 or y == 42 then sb[K(x, y)] = 1 end end)
local sI, sT = O.shade(c, stalk, BAMB, { R = 1, amb = .3, wrap = .45, bias = sb, sep = BAMB[1], rim = true })
-- bite: a notch out of the top end
for _, p in ipairs({ { 35, 32 }, { 36, 32 }, { 35, 33 } }) do c.pix[p[2] * c.w + p[1]] = nil c.own[p[2] * c.w + p[1]] = nil end
O.mark(c, { { 37, 32 }, { 36, 33 }, { 36, 34 } }, "#e6eebc") -- pale bitten pith
-- leaf sprig off the stalk
O.shade(c, c:poly{ { 47, 47 }, { 55, 42 }, { 58, 40 }, { 53, 46 } }, LEAF, { R = 1, amb = .35, sep = LEAF[1], cuts = { .3, .55, .8 } })
O.shade(c, c:poly{ { 48, 49 }, { 56, 50 }, { 59, 52 }, { 53, 52 } }, LEAF, { R = 1, amb = .25, sep = LEAF[1], cuts = { .3, .55, .8 } })
-- arms (dark): right paw round the stalk, left paw resting on the belly
local ra, rn = O.tube({ { 44, 38 }, { 47, 41 }, { 46, 44 }, { 44, 46 } }, function(t) return 2.6 end)
O.shadeN(c, ra, rn, DARK, { amb = .3, wrap = .4, sep = DARK[1], cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 42, 45 }, { 43, 46 } }, DARK[5])
local la, ln = O.tube({ { 18, 38 }, { 17, 42 }, { 20, 46 }, { 25, 47 } }, function(t) return 2.6 end)
O.shadeN(c, la, ln, DARK, { amb = .3, wrap = .4, sep = DARK[1], rim = true, cuts = { .25, .45, .65, .85 } })

-- quirk: one leaf still sticking out of its mouth, mid-chew
O.shade(c, c:poly{ { 29, 35 }, { 24, 34 }, { 19, 35 }, { 24, 36 } }, LEAF, { R = 1, amb = .45, sep = LEAF[1], cuts = { .3, .55, .8 } })

O.done(c, "br-panda-puff-yard", function(c)
  -- slow chew: two small "munch" ticks by the cheek (un-outlined)
  for _, p in ipairs({ { 12, 28 }, { 11, 29 }, { 12, 31 }, { 11, 31 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], "#a2d06a") end
  end
end)
