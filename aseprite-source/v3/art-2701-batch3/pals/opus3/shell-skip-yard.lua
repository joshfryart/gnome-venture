-- Shell Skip (ss-shell-skip), yard sprite 64x64. Opus richness pass (art-2701-batch3/pals/opus3), built on opus2.
-- Richness: fine growth lines following each whorl, brown flecks along the spiral band, rim light on the shell
-- crown and a cool violet bounce under it; pebbly carapace bumps and pale banded leg joints on the crab;
-- a barnacle hitch-hiking on the spire.
-- Wayfinder, common, Sunsprinkle. "Skips along the tideline, collecting small things."
-- A coral-pink hermit crab under a tall gold turban shell (spire up and right, coral spiral band,
-- groove lines where the whorls meet). Eyes up on stalks, mid-skip: one leg kicked up.
-- quirk: a frosted blue sea-glass bead held up proudly in its big claw; look closer and a tiny bubble is
-- trapped inside it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("shell-skip-yard", 64)

local SHL  = { "#5e2c26", "#8c4a2c", "#bd723a", "#e09c50", "#f3c473", "#fde2a4" }
local BAND = { "#7a4a36", "#a8744e", "#d2a272", "#ecc897", "#f8e2b6", "#fff4d6" }
local APER = { "#3a1a2e", "#55263c", "#73384a" }
local CRAB = { "#6a1e2e", "#a3383c", "#d2564a", "#ee7b5c", "#faa47c", "#ffcfa6" }
local GLAS = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee4dc", "#d4f6ee" }
local BARN = { "#7a6e78", "#b0a49e", "#d8cdbc", "#f2e8d2" }

c:groundShadow(32, 57, 19, 3)

-- legs (behind the body). Back legs under the shell, one front leg kicked up mid-skip
for _, L in ipairs({ { { 38, 46 }, { 42, 50 }, { 44, 53 }, { 45, 56 } }, { { 33, 47 }, { 35, 51 }, { 36, 53 }, { 37, 56 } },
                     { { 24, 47 }, { 23, 51 }, { 22, 54 }, { 20, 56 } }, { { 19, 46 }, { 15, 47 }, { 12, 49 }, { 10, 52 } } }) do
  local m, n = O.tube(L, function(t) return 1.3 - .3 * t end)
  O.shadeN(c, m, n, CRAB, { amb = .3, sep = CRAB[1], bounce = "#9a5a78", bmax = 2 })
end
O.dots(c, { { 43, 51 }, { 35, 51 }, { 22, 52 }, { 13, 48 } }, CRAB[2]) -- leg joints
O.dots(c, { { 42, 50 }, { 34, 50 }, { 23, 51 }, { 14, 47 } }, CRAB[6]) -- pale band above each joint

-- shell: body whorl, spire, tip
local main = c:ellipse(39, 32, 16, 14)
local spire = c:ellipse(47, 17, 8, 6)
local tip = c:ellipse(52, 9, 4, 3.5)
local shell = main:copy():add(spire):add(tip)
local idx, stok = O.shade(c, shell, SHL, { sphere = { 36, 24, 26 }, amb = .2, wrap = .35, rim = true, bounce = "#8a5a6e", bmax = 2 })
-- axial growth ribs: fine curved lines running across each whorl, from the suture toward the aperture
O.tex(c, idx, stok, SHL, function(x, y, i)
  local cx, cy, k = 41, 33, 6
  if tip:has(x, y) then cx, cy, k = 52, 9, 4 elseif spire:has(x, y) then cx, cy, k = 47, 18, 6 end
  local d = math.sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
  local a = (math.atan(y - cy, x - cx) / math.pi * k + d * .06) % 1
  if a < .1 and d > 4 and i >= 2 and i <= 5 then return -1 end
end)
-- pale spiral band running round each whorl
local function band(m, cx, cy, r0, r1, a0)
  m:each(function(x, y)
    local d = math.sqrt(((x - cx) / r0) ^ 2 + ((y - cy) / r1) ^ 2)
    if d > .55 and d < .78 and (y < cy + 1 or x > cx + 4) then
      local i = idx[K(x, y)]
      if i and c:get(x, y) then c.pix[y * c.w + x] = BAND[i] end
    end
  end)
end
band(main, 41, 33, 16, 14) band(spire, 47, 18, 8, 6)
-- whorl grooves: where the spire sits on the body, and the tip on the spire
spire:edge():each(function(x, y) if main:has(x, y) and y > 15 and x < 54 then O.mark(c, { { x, y } }, SHL[1]) end end)
tip:edge():each(function(x, y) if spire:has(x, y) and y > 8 and x < 55 then O.mark(c, { { x, y } }, SHL[1]) end end)
-- growth ribs
for _, r in ipairs({ { { 28, 25 }, { 27, 27 } }, { { 33, 20 }, { 32, 22 } }, { { 50, 38 }, { 51, 36 } }, { { 45, 43 }, { 46, 41 } } }) do
  O.mark(c, r, SHL[2])
end
O.dots(c, { { 30, 21 }, { 31, 21 }, { 45, 13 } }, SHL[6]) -- glossy pop
-- brown flecks along the band
O.mark(c, { { 47, 26 }, { 51, 30 }, { 52, 35 }, { 36, 21 }, { 42, 21 }, { 52, 17 }, { 41, 13 } }, SHL[2])
-- barnacle hitch-hiking on the spire
O.paintB = nil
for j, row in ipairs({ { 3, 1, 1, 3 }, { 4, 3, 3, 2 }, { 3, 2, 2, 1 } }) do
  for i2, t in ipairs(row) do O.dot(c, 41 + i2, 11 + j, BARN[t]) end
end
-- aperture: the dark mouth of the shell the crab sits in
local ap = c:ellipse(28, 40, 9, 7)
O.shade(c, ap, APER, { R = 2, amb = .1, wrap = .2, cuts = { .45, .7 } })

-- body / head peeking out
local head = c:ellipse(22, 41, 8, 6)
local hI, hT = O.shade(c, head, CRAB, { sphere = { 20, 38, 9 }, amb = .25, wrap = .35, sep = CRAB[1], rim = true, bounce = "#9a5a78" })
O.tex(c, hI, hT, CRAB, function(x, y, i) if y < 40 and H(x, y, 13) > .85 and i <= 5 then return 1 end end) -- pebbly carapace

-- big claw holding the quirk
local arm, an = O.tube({ { 16, 43 }, { 12, 43 }, { 10, 41 }, { 9, 38 } }, function(t) return 1.6 end)
O.shadeN(c, arm, an, CRAB, { amb = .3, sep = CRAB[1] })
local claw = c:ellipse(8, 34, 4, 4)
claw:cut(c:poly{ { 9, 34 }, { 13, 30 }, { 13, 35 } }) -- pincer gap
O.shade(c, claw, CRAB, { sphere = { 6, 32, 5 }, amb = .25, sep = CRAB[1] })
-- quirk: sea-glass bead in the pincer
local gl = c:ellipse(11.5, 30.5, 2.5, 2.5)
O.shade(c, gl, GLAS, { sphere = { 10, 29, 3 }, amb = .3, cuts = { .25, .5, .7, .88 } })
O.dot(c, 11, 29, GLAS[5])
O.dots(c, { { 13, 31 }, { 12, 32 } }, GLAS[4]) -- frosted edge
O.dot(c, 12, 30, "#e8fbf4") O.dot(c, 13, 30, GLAS[2]) -- the trapped bubble

-- eye stalks + locked eyes
for _, s in ipairs({ { { 19, 36 }, { 18, 33 }, { 17, 31 }, { 17, 29 } }, { { 25, 36 }, { 26, 33 }, { 27, 31 }, { 27, 29 } } }) do
  local m, n = O.tube(s, function(t) return 1 end)
  O.shadeN(c, m, n, CRAB, { amb = .35 })
end
c:eyeLocked(15, 24)
c:eyeLocked(25, 24)

-- face
c:cheek(15, 41) c:cheek(27, 41)
O.dots(c, { { 21, 39 }, { 22, 39 } }, CRAB[6]) O.dots(c, { { 21, 40 }, { 22, 40 } }, CRAB[2]) -- nose bump, lit top
O.dots(c, { { 18, 42 }, { 19, 43 }, { 20, 43 }, { 21, 43 }, { 22, 43 }, { 23, 43 }, { 24, 43 }, { 25, 42 } }, P.ink) -- grin
O.dots(c, { { 21, 44 }, { 22, 44 } }, "#c94f60")

O.done(c, "shell-skip-yard")
