-- Toadstool Tuck (mm-toadstool-tuck), yard sprite 64x64. Opus second pass (art-2701-batch3/pals/opus2).
-- Bloomcaller, common, Mistmoor. "Tucks under the fairy ring and counts to ninety-nine twice."
-- A red fly-agaric: big domed cap with raised cream warts, pale gill skirt under the brim, plump
-- cream stem with the face tucked right under the cap; one hand up, counting on its fingers.
-- quirk: a ring of tiny tan fairy-ring mushrooms round its feet.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("toadstool-tuck-yard", 64)

local CAP  = { "#5e1a2e", "#8e2436", "#c0333c", "#e5503f", "#f67c52", "#ffad78" }
local STEM = { "#8e7268", "#b5998a", "#d1b79f", "#e4cfb4", "#f0e1c6", "#f8eed8" }
local GILL = { "#8a5a5e", "#b98078", "#d9a593", "#ecc6ad" }
local WART = { "#c9ab94", "#e7d2b8", "#f7ead0", "#fff4d6" }
local TAN  = { "#6b4330", "#9a6a45", "#c79563", "#e3b982", "#f4d7a4" }

c:groundShadow(32, 57, 16, 3)

-- quirk, back row of the fairy ring (behind the stem)
local function mini(x, y, flip) -- domed cap 6 wide at (x..x+5, y..y+2), stem 2 wide under it
  O.shade(c, c:rect(x + 2, y + 3, x + 3, y + 4), STEM, { R = 1, amb = .45 })
  local cp = c:poly{ { x, y + 2 }, { x + 1, y }, { x + 4, y }, { x + 5, y + 2 } }
  O.shade(c, cp, TAN, { R = 1, amb = .35, cuts = { .25, .45, .65, .85 } })
  O.dots(c, { { x + 1, y + 2 }, { x + 2, y + 2 }, { x + 3, y + 2 }, { x + 4, y + 2 } }, TAN[2])
  O.dot(c, flip and x + 3 or x + 2, y + 1, TAN[5])
end
mini(7, 48) mini(51, 47, true)

-- stem: plump barrel, a touch wider at the foot
local stem = c:ellipse(32, 44, 11, 12)
stem:add(c:ellipse(32, 52, 12, 4))
stem:cut(c:rect(0, 57, 63, 63))
local sb = {}
stem:each(function(x, y) -- faint vertical fibres on the stem (material cue)
  if (x == 25 or x == 38) and y > 47 then sb[K(x, y)] = -1 end
end)
O.shade(c, stem, STEM, { R = 6, bias = sb, amb = .3, wrap = .4 })

-- arm down on the left, arm up on the right counting
local armL = c:ellipse(20.5, 48, 2.5, 3)
O.shade(c, armL, STEM, { R = 1, amb = .35, sep = STEM[2] })
local armR = O.tube({ { 42, 49 }, { 46, 47 }, { 47, 44 }, { 47, 41 } }, function(t) return 1.6 end)
O.shade(c, armR, STEM, { R = 1, amb = .4, sep = STEM[2] })
-- three fingers held up
O.dots(c, { { 46, 39 }, { 46, 38 }, { 48, 39 }, { 48, 38 }, { 47, 39 } }, STEM[5])
O.dots(c, { { 47, 40 }, { 46, 40 }, { 48, 40 } }, STEM[4])

-- gill skirt under the brim
local gill = c:ellipse(32, 31, 24, 3.5)
gill:cut(c:rect(0, 0, 63, 29))
O.shade(c, gill, GILL, { R = 2, amb = .45, cuts = { .3, .55, .78 } })
for x = 11, 53, 2 do O.dot(c, x, 31, GILL[2]) end

-- cap dome
local cap = c:ellipse(32, 27, 27, 18)
cap:cut(c:rect(0, 31, 63, 63))
cap:cut(c:rect(0, 30, 6, 30)) cap:cut(c:rect(57, 30, 63, 30))
local cb = {}
cap:each(function(x, y) if y >= 29 then cb[K(x, y)] = -1 end end) -- darker rolled brim
O.shade(c, cap, CAP, { sphere = { 26, 22, 28 }, bias = cb, amb = .16, wrap = .3 })
-- brim lip highlight line
for x = 10, 30 do if c:get(x, 28) then O.mark(c, { { x, 28 } }, CAP[4]) end end

-- raised warts (foreshortened toward the rim)
local warts = { { 22, 14, 2.5, 2 }, { 35, 12, 3, 2 }, { 45, 18, 2.5, 2 }, { 14, 22, 2, 1.5 },
                { 29, 21, 3, 2 }, { 51, 25, 1.5, 1.5 }, { 40, 25, 2, 1.5 }, { 20, 27, 1.5, 1 } }
for _, w in ipairs(warts) do
  local m = c:ellipse(w[1], w[2], w[3], w[4])
  O.shade(c, m, WART, { sphere = { w[1] - 1, w[2] - 1, w[3] + 1 }, amb = .35, cuts = { .3, .55, .8 } })
end
O.dots(c, { { 10, 18 }, { 56, 21 }, { 30, 9 } }, WART[2]) -- small flecks

-- face under the cap. The cap throws a shadow band over the top of the stem, and a lower lid
-- line in the stem shade frames each cream eye disc so it reads against the pale stem.
stem:each(function(x, y)
  if y <= 32 then O.mark(c, { { x, y } }, STEM[2]) elseif y <= 34 then O.mark(c, { { x, y } }, STEM[3]) end
end)
for _, ex in ipairs({ 24, 35 }) do
  O.dots(c, { { ex - 1, 37 }, { ex - 1, 38 }, { ex, 39 }, { ex + 5, 37 }, { ex + 5, 38 }, { ex + 4, 39 },
              { ex + 1, 40 }, { ex + 2, 40 }, { ex + 3, 40 } }, STEM[3])
  c:eyeLocked(ex, 35)
end
c:cheek(21, 42) c:cheek(41, 42)
-- nose: little warm button, lit tip, dark underside
O.dots(c, { { 31, 40 }, { 32, 40 } }, "#e0b09a")
O.dot(c, 31, 40, "#f2cdb5")
O.dots(c, { { 31, 41 }, { 32, 41 } }, "#a8746a")
-- counting mouth: small open "o"
O.dots(c, { { 30, 44 }, { 33, 44 } }, "#a8483a")
O.dots(c, { { 31, 44 }, { 32, 44 }, { 31, 45 }, { 32, 45 } }, "#6e2c2a")
O.dot(c, 32, 45, "#c94f60")

-- quirk, front row of the fairy ring
mini(3, 54) mini(13, 56) mini(45, 56, true) mini(55, 53, true)

O.done(c, "toadstool-tuck-yard")
