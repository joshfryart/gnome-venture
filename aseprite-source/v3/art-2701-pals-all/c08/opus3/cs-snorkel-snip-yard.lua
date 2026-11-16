-- Snorkel Snip (cs-snorkel-snip), yard sprite 64x64. Opus richness pass (c08/opus3), built on c08/opus2.
-- Common, seedkeeper. "Snorkels the reef with a shell in each hand and no plan at all."
-- A round pink reef pal on teal flippers, dive mask pushed up on its brow, orange snorkel from its grin.
-- Richness: hue-shifted 6-tone ramps (violet shadows, peach lights), soft skin with pores and wet glints, ribbed
-- flippers with pale blade edges, mask frame with a buckle and a diagonal glass reflection, snorkel with a lit
-- stripe and dark bands, scallop with ribs plus concentric colour bands, whelk with whorl ridges and a glossy lip.
-- quirk: the snorkel is blowing a little string of bubbles out of its top.
-- closer look: a strand of green seaweed is snagged on the snorkel (no plan at all), and a water drip on its chin.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local H = O.H
local c = O.canvas("cs-snorkel-snip-yard", 64)

local PINK  = { "#4c1f4c", "#8c3064", "#c44c7c", "#ec7896", "#ffa6b2", "#ffd8d0" }
local BELLY = { "#e47890", "#f8a2b0", "#ffcec8", "#fff0e2" }
local TEAL  = { "#173a52", "#1d6474", "#2a9496", "#4cc2ae", "#8ae6c4", "#d0f6dc" }
local ORNG  = { "#6e2a26", "#b0441e", "#dc6c26", "#f59a38", "#ffc868", "#ffeaa8" }
local SCAL  = { "#64323e", "#a2564a", "#d4806a", "#f0aa86", "#ffd2aa", "#fff0d6" }
local WHLK  = { "#46385e", "#76608a", "#a890aa", "#d2bcc4", "#eee0da", "#fff4e4" }
local GLASS = { "#2a4a7a", "#3a86b0", "#8bc4ea", "#b9e2f5" }
local WEED  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local BNC = "#6e5aa4"

c:groundShadow(32, 58, 17, 2.5)

-- flippers: ribbed blades, pale toe edge
for _, s in ipairs({ { 22, -1 }, { 42, 1 } }) do
  local f = c:ellipse(s[1] + s[2] * 2, 56, 6.5, 2)
  f:add(c:ellipse(s[1], 54, 3.5, 2.5))
  local fI, fT = O.shade(c, f, TEAL, { R = 2, amb = .25, sep = TEAL[1], rim = true, bounce = "#2a4a7a", bmax = 2 })
  O.tex(c, fI, fT, TEAL, function(x, y, i)
    local d = (x - s[1]) * s[2]
    if d >= 2 and d % 3 == 0 and y >= 55 then return -1 end      -- ribs
    if d >= 6 and y == 55 then return 1 end                      -- pale blade edge
  end)
end

-- arms (behind body), raised up and out
for _, d in ipairs({ -1, 1 }) do
  local m, n = O.tube({ { 32 + d * 10, 40 }, { 32 + d * 16, 38 }, { 32 + d * 19, 33 }, { 32 + d * 20, 27 } }, function(t) return 2.2 - t * .4 end)
  O.shadeN(c, m, n, PINK, { amb = .25, sep = PINK[2], rim = true, bounce = BNC, bmax = 2 })
end

-- body
local body = c:ellipse(32, 41, 14, 13)
local bI, bT = O.shade(c, body, PINK, { sphere = { 27, 35, 17 }, amb = .27, wrap = .35, sep = PINK[1], rim = true, bounce = BNC, bmax = 2 })
-- soft skin: pore speckles in the mid tones, a few pale wet glints in the light
O.tex(c, bI, bT, PINK, function(x, y, i)
  local h = H(x, y, 11)
  if h > .93 and i >= 3 and i <= 5 then return -1 end
  if h < .03 and i >= 4 and y < 40 then return 1 end
end)
-- belly
local bel = c:ellipse(32, 47, 8, 6)
local eI, eT = O.shade(c, bel, BELLY, { R = 3, amb = .45, cuts = { .3, .6, .85 } })
-- faint belly creases (soft folds)
O.tex(c, eI, eT, BELLY, function(x, y, i) if (y == 50 or y == 52) and math.abs(x - 32) < 5 - (y - 50) and i >= 2 then return -1 end end)

-- dive mask pushed up on the brow: strap + frame + glass
local strap = c:rect(18, 29, 46, 30)
strap:clip(body)
local sI, sT = O.shade(c, strap, TEAL, { R = 1, amb = .3 })
O.tex(c, sI, sT, TEAL, function(x, y) if x % 3 == 0 then return -1 end end) -- strap weave
-- buckle on the left strap
O.flat(c, c:rect(20, 29, 21, 30), "#d98322", "buckle") O.dot(c, 20, 29, "#ffe38a")
local frame = c:rrect(24, 25, 40, 31, 2)
O.shade(c, frame, TEAL, { R = 1, amb = .3, sep = TEAL[1], rim = true })
for _, gx in ipairs({ 26, 33 }) do
  local g = c:rect(gx, 27, gx + 4, 29)
  O.shade(c, g, GLASS, { R = 1, amb = .5, cuts = { .3, .55, .8 } })
  -- diagonal reflection streak
  O.dots(c, { { gx, 27 }, { gx + 1, 27 }, { gx + 3, 27 }, { gx + 2, 28 } }, "#e4f6ff")
  O.dot(c, gx + 4, 29, GLASS[2])
end
O.dot(c, 32, 26, TEAL[2]) O.dot(c, 32, 30, TEAL[2]) -- nose bridge of the frame

-- snorkel: mouthpiece at the grin, tube up the right side of the head
local tm, tn = O.tube({ { 39, 46 }, { 46, 46 }, { 48, 40 }, { 48, 14 } }, function(t) return 1.6 end)
local tI, tT = O.shadeN(c, tm, tn, ORNG, { amb = .3, sep = ORNG[1], rim = true, bounce = "#7a3a5a", bmax = 2 })
local tip = c:rrect(46, 11, 50, 14, 1)
O.shade(c, tip, TEAL, { R = 1, amb = .35, sep = TEAL[1] })
O.dots(c, { { 47, 11 }, { 48, 11 } }, TEAL[6])
O.flat(c, c:rect(37, 45, 40, 47), TEAL[3], "mouthpiece")
O.dot(c, 37, 45, TEAL[5]) O.dot(c, 40, 47, TEAL[2])
-- dark bands on the tube
O.mark(c, { { 47, 24 }, { 48, 24 }, { 49, 24 }, { 47, 33 }, { 48, 33 }, { 49, 33 } }, ORNG[2])
O.mark(c, { { 47, 25 }, { 47, 34 } }, ORNG[3])

-- closer look: seaweed strand snagged on the snorkel, draped over and trailing down the right
do
  local wm, wn = O.tube({ { 46, 19 }, { 50, 17 }, { 53, 22 }, { 52, 28 } }, function(t) return t < .15 and .9 or (1.1 - t * .5) end)
  local wI, wT = O.shadeN(c, wm, wn, WEED, { amb = .3, cuts = { .3, .55, .8 } })
  O.dot(c, 53, 25, WEED[2]) O.dot(c, 52, 22, WEED[4])
end

-- left hand: scallop shell (ribbed fan with colour bands)
do
  local cx, cy = 12, 20
  local fan = c:ellipse(cx, cy, 6, 5.5)
  fan:cut(c:rect(cx - 7, cy + 2, cx + 7, cy + 7))
  fan:add(c:poly{ { cx - 6, cy + 1 }, { cx + 6, cy + 1 }, { cx + 1, cy + 6 }, { cx - 1, cy + 6 } })
  local ears = c:rect(cx - 3, cy + 5, cx + 3, cy + 7)
  O.shade(c, ears, SCAL, { R = 1, amb = .3, sep = SCAL[1] })
  local fI, fT = O.shade(c, fan, SCAL, { sphere = { cx - 2, cy - 3, 8 }, amb = .25, wrap = .4, sep = SCAL[1], rim = true, bounce = BNC })
  O.tex(c, fI, fT, SCAL, function(x, y, i)
    local a = math.atan(x - cx, cy + 7 - y)
    local k = math.floor(a * 7 + 100.5)
    if k % 2 == 0 and y < cy + 5 then return -1 end                          -- grooves
    local r = math.sqrt((x - cx)^2 + (y - cy - 7)^2)
    if math.abs(r - 8.5) < .5 and i >= 3 then return -1 end                  -- growth band
    if math.abs(r - 5) < .5 and i >= 3 then return -1 end
  end)
  O.shade(c, c:ellipse(cx + 1, cy + 8, 2.5, 2), PINK, { R = 1, amb = .3, sep = PINK[1] })
  O.dot(c, cx, cy + 7, PINK[5])
end

-- right hand: spiral whelk
do
  local cx, cy = 53, 19
  local sh = c:ellipse(cx, cy + 1, 4.5, 5)
  sh:add(c:poly{ { cx - 2, cy - 3 }, { cx + 1, cy - 9 }, { cx + 3, cy - 3 } })
  sh:add(c:poly{ { cx - 1, cy + 4 }, { cx + 1, cy + 9 }, { cx + 3, cy + 4 } })
  local sI2, sT2 = O.shade(c, sh, WHLK, { sphere = { cx - 2, cy - 2, 7 }, amb = .42, wrap = .4, sep = WHLK[1], rim = true, bounce = BNC })
  -- whorl ridges: dark line with a lit crest below it
  O.mark(c, { { cx - 1, cy - 4 }, { cx, cy - 4 }, { cx + 1, cy - 4 }, { cx - 3, cy - 1 }, { cx - 2, cy - 1 }, { cx - 1, cy - 1 },
              { cx, cy - 1 }, { cx + 1, cy }, { cx + 2, cy + 1 } }, WHLK[2])
  O.mark(c, { { cx, cy - 3 }, { cx - 2, cy }, { cx - 1, cy }, { cx, cy } }, WHLK[6])
  O.mark(c, { { cx, cy - 7 }, { cx + 1, cy - 6 } }, WHLK[3])
  -- aperture lip on the right, glossy pink
  O.flat(c, c:rect(cx + 2, cy + 2, cx + 3, cy + 5), "#f5809f", "lip")
  O.dot(c, cx + 2, cy + 2, "#ffc4d8") O.dot(c, cx + 3, cy + 5, "#c94f84")
  -- brown bands
  O.mark(c, { { cx - 3, cy + 2 }, { cx - 2, cy + 3 }, { cx - 1, cy + 3 }, { cx, cy + 3 } }, "#a06058")
  O.mark(c, { { cx - 3, cy + 4 }, { cx - 2, cy + 5 } }, "#c08a7a")
  O.shade(c, c:ellipse(cx - 1, cy + 8, 2.5, 2), PINK, { R = 1, amb = .3, sep = PINK[1] })
end

-- face
c:eyeLocked(23, 34)
c:eyeLocked(36, 34)
c:cheek(20, 41) c:cheek(42, 41)
-- grin pulled to the snorkel side, with a pale tooth
O.dots(c, { { 27, 44 }, { 28, 45 }, { 29, 45 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 45 }, { 34, 45 }, { 35, 45 }, { 36, 44 } }, P.ink)
O.dots(c, { { 29, 46 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 46 } }, PINK[2])
O.dot(c, 31, 46, PINK[3])
-- snub nose bump between the eyes
O.dots(c, { { 31, 41 }, { 32, 41 } }, PINK[3]) O.dot(c, 31, 40, PINK[6])
-- water drip on the chin
O.dot(c, 26, 49, "#b9e2f5") O.dot(c, 26, 50, "#8bc4ea")

O.shift(c, 0, -1)
O.done(c, "cs-snorkel-snip-yard", function(c)
  local function bub(x, y, r)
    if r == 1 then
      for _, d in ipairs({ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } }) do c:put(x + d[1], y + d[2], "#3a86b0") end
      c:put(x, y, "#e4f6ff")
    else
      for _, d in ipairs({ { 0, -1 }, { 1, -1 }, { -1, 0 }, { 2, 0 }, { -1, 1 }, { 2, 1 }, { 0, 2 }, { 1, 2 } }) do c:put(x + d[1], y + d[2], "#3a86b0") end
      c:put(x, y, "#e4f6ff") c:put(x + 1, y, "#b9e2f5") c:put(x, y + 1, "#b9e2f5") c:put(x + 1, y + 1, "#8bc4ea")
    end
  end
  bub(52, 6, 2) bub(56, 3, 1) bub(45, 4, 1)
end)
