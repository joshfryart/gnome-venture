-- Stupa Snug (sp-stupa-snug), yard sprite 64x64. Opus richness pass (c06/opus3), built on c06/opus2.
-- Uncommon, rootwarden. "Sits snug under a white dome and keeps the prayer flags tidy."
-- A dusk-violet pal sitting snug under a whitewashed stupa dome worn like a big hat: gold rim band, square
-- harmika box, a gold spire with stacked rings. Prayer flags (blue, white, red, green, yellow) on two strings
-- from the spire to either side give a clear triangle silhouette.
-- Richness: limewash dome with a ring of lotus-petal mouldings round the top and grey rain streaks running
-- down it, an embossed gold rim band, soft fur strokes on the violet body, twisted flag strings, each flag
-- with a printed block (wind-horse print) and a frayed bottom edge, red harmika band with gold studs.
-- quirk: it is tidying the flags: one hand is up straightening the last (crooked) flag on the right string.
-- Closer look: a little butter lamp burns at its feet.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sp-stupa-snug-yard", 64)

local VIO  = { "#2e2448", "#45346a", "#614a92", "#8066b4", "#a48ad0", "#cab6e8" }
local DOME = { "#7a6e86", "#a49aa8", "#c8c0c4", "#e2dcd6", "#f2ede4", "#fbf7ee" }
local GOLD = { "#7a3e1c", "#c4741f", "#f0aa2a", "#ffd866", "#fff0b0" }
local RED  = { "#6e1a24", "#a8283a", "#d8464a" }
local FLAG = { { "#2c4e9a", "#4a7ad0" }, { "#d6d0cc", "#f6f2ea" }, { "#a8283a", "#e04a4a" }, { "#2c7a44", "#4eae5a" }, { "#d89a1e", "#f8d050" } }
local STR  = "#7a5a46"
local STR2 = "#b08a64"
local H = O.H
local BNC  = "#4c6a8a"

c:groundShadow(32, 58, 17, 2.5)

-- prayer flag strings, from the spire down to each side (drawn first: behind the dome)
local function bz(a, b, cc, t) local u = 1 - t return u*u*a[1] + 2*u*t*b[1] + t*t*cc[1], u*u*a[2] + 2*u*t*b[2] + t*t*cc[2] end
local S = { { { 31, 8 }, { 16, 13 }, { 3, 24 } }, { { 33, 8 }, { 48, 13 }, { 61, 24 } } }
for _, s in ipairs(S) do
  local seen, n = {}, 0
  for i = 0, 80 do local x, y = bz(s[1], s[2], s[3], i / 80) x, y = math.floor(x + .5), math.floor(y + .5)
    if not seen[K(x, y)] then seen[K(x, y)] = true n = n + 1 O.dot(c, x, y, (n % 3 == 0) and STR2 or STR) end end
end
-- flags: 3x4 cloth squares hanging under the string, in order blue white red green yellow
local function flag(x, y, k, tilt)
  local f = FLAG[k]
  for j = 1, 5 do for i = 0, 2 do
    local xx = x + i + ((tilt and j >= 3) and 1 or 0)
    O.dot(c, xx, y + j, (i == 0 and j <= 2) and f[2] or f[1 + ((i + j) % 2 == 0 and 1 or 0)])
  end end
  O.dot(c, x, y + 1, f[2])
  -- printed block in the middle, frayed notch at the bottom
  local dx = tilt and 1 or 0
  O.dot(c, x + 1 + dx, y + 3, k == 2 and "#a49aa8" or f[1]) O.dot(c, x + 1 + dx, y + 2, k == 2 and "#a49aa8" or f[1])
  c.pix[(y + 5) * c.w + x + 1 + dx] = nil c.own[(y + 5) * c.w + x + 1 + dx] = nil
end
local function hang(s, ts, tiltLast)
  for n, t in ipairs(ts) do
    local x, y = bz(s[1], s[2], s[3], t)
    x, y = math.floor(x + .5), math.floor(y + .5)
    flag(x - 1, y, ((n - 1) % 5) + 1, tiltLast and n == #ts)
  end
end
hang(S[1], { .3, .46, .62, .78, .94 }, false)
hang(S[2], { .3, .46, .62, .78, .94 }, true)

-- the pal, sitting
for _, fx in ipairs({ 24, 40 }) do
  O.shade(c, c:ellipse(fx, 55, 4.5, 2.5), VIO, { R = 2, amb = .22, wrap = .3, bounce = BNC, bmax = 2 })
end
local body = c:ellipse(32, 44, 14, 11.5)
local vI, vT = O.shade(c, body, VIO, { sphere = { 27, 40, 17 }, amb = .26, wrap = .35, sep = VIO[1], rim = true, bounce = BNC, bmax = 2 })
-- soft fur: short 2 px strokes, darker on the shade side, lighter crowns in the light; face kept clean
O.tex(c, vI, vT, VIO, function(x, y, i)
  if ((x - 31.5) / 11)^2 + ((y - 43) / 6)^2 < 1 then return 0 end
  local h = H(x, y // 2, 13)
  if h > .82 and i <= 4 and i >= 2 then return -1 end
  if h < .1 and i >= 4 and i <= 5 then return 1 end
end)

-- the dome worn like a snug hat
local dome = c:ellipse(32, 34, 15, 14)
dome:cut(c:rect(0, 35, 63, 63))
local dI, dT = O.shade(c, dome, DOME, { sphere = { 26, 24, 19 }, amb = .3, wrap = .4, rim = true })
O.tex(c, dI, dT, DOME, function(x, y, i)
  -- lotus-petal moulding ring round the top of the dome: lit petal crowns, dark dents, a groove under them
  local r = math.sqrt((x - 32)^2 + ((y - 34) * 15 / 14)^2)
  if y < 31 and r >= 9.5 and r < 11.5 then
    if r >= 10.6 then return (x % 4 == 1) and -3 or -2 end
    if x % 4 == 1 then return -2 end
    return 1
  end
end)
-- grey rain streaks running down from the moulding (different lengths)
for _, st in ipairs({ { 20, 27, 31 }, { 24, 25, 29 }, { 39, 25, 32 }, { 43, 27, 30 }, { 46, 29, 32 }, { 35, 25, 27 } }) do
  for y = st[2], st[3] do if c.own[y * c.w + st[1]] == dT then c.pix[y * c.w + st[1]] = (y == st[3]) and DOME[3] or DOME[2] end end
end
-- gold rim band, with a red lower edge where it sits on the pal
local rim = c:rect(16, 33, 48, 35)
rim:add(c:rect(17, 36, 47, 36))
local rb = {} rim:each(function(x, y) if y == 36 then rb[K(x, y)] = -3 end if x % 4 == 0 and y == 34 then rb[K(x, y)] = -1 end end)
O.shade(c, rim, GOLD, { R = 1, amb = .3, wrap = .45, bias = rb, sep = GOLD[1], cuts = { .22, .42, .62, .82 } })
-- embossed studs along the gold band
for x = 18, 46, 4 do O.mark(c, { { x, 34 } }, GOLD[5]) O.mark(c, { { x + 1, 34 } }, GOLD[2]) end
O.dots(c, { { 18, 36 }, { 22, 36 }, { 26, 36 }, { 30, 36 }, { 34, 36 }, { 38, 36 }, { 42, 36 }, { 46, 36 } }, RED[2])
-- harmika (square box) and spire with rings
local hm = c:rect(28, 16, 36, 20)
O.shade(c, hm, DOME, { R = 1, amb = .3, wrap = .4, sep = DOME[1] })
O.flat(c, c:rect(29, 18, 35, 18), RED[2], "harmika band")
O.dots(c, { { 30, 18 }, { 33, 18 } }, GOLD[4])
local sp = c:poly{ { 29, 15 }, { 35, 15 }, { 33, 6 }, { 31, 6 } }
local sb = {} sp:each(function(x, y) if y % 2 == 0 then sb[K(x, y)] = -1 end end)
O.shade(c, sp, GOLD, { R = 1, amb = .3, wrap = .45, bias = sb, sep = GOLD[1], cuts = { .22, .42, .62, .82 } })
O.shade(c, c:ellipse(32, 4, 1.5, 1.5), GOLD, { sphere = { 31, 3, 2 }, amb = .35, cuts = { .22, .42, .62, .82 } })
O.dot(c, 32, 2, GOLD[4])

-- closer look: a butter lamp burning at its feet (gold cup, wick, flame)
local cup = c:poly{ { 9, 54 }, { 15, 54 }, { 14, 56 }, { 10, 56 } }
O.shade(c, cup, GOLD, { R = 1, amb = .35, wrap = .4, cuts = { .25, .45, .65, .85 } })
O.mark(c, { { 10, 54 }, { 11, 54 }, { 12, 54 } }, "#fff0b0") O.mark(c, { { 13, 54 }, { 14, 54 } }, GOLD[4])
O.pat(c, 11, 51, { ".a.", "aba", ".a." }, { a = "#f8a030", b = "#fff0b0" }, "flame")
-- face under the rim
c:eyeLocked(24, 39)
c:eyeLocked(35, 39)
O.dots(c, { { 30, 47 }, { 31, 48 }, { 32, 48 }, { 33, 47 } }, P.ink)
c:cheek(21, 46) c:cheek(41, 46)
-- left arm resting on the belly
O.shade(c, c:ellipse(19, 49, 2.5, 2), VIO, { R = 1, amb = .3, sep = VIO[1] })

-- quirk: right hand up, straightening the last flag on the right string
local arm, an = O.tube({ { 44, 46 }, { 51, 42 }, { 56, 36 }, { 57, 31 } }, function(t) return 1.7 end)
O.shadeN(c, arm, an, VIO, { amb = .3, wrap = .4, sep = VIO[1] })
O.shade(c, c:ellipse(57, 30, 2, 2), VIO, { sphere = { 56, 29, 3 }, amb = .35, sep = VIO[1] })

O.done(c, "sp-stupa-snug-yard", function(c)
  -- tidy marks: two little straightening ticks beside the hand
  for _, p in ipairs({ { 61, 30 }, { 62, 31 }, { 60, 33 }, { 61, 34 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], GOLD[4]) end
  end
end)
