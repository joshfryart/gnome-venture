-- Snorkel Snip (cs-snorkel-snip), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from the
-- Haiku first pass (../haiku). Common, seedkeeper. "Snorkels the reef with a shell in each hand and no plan at all."
-- A round pink reef pal on teal flippers, dive mask pushed up on its brow, orange snorkel from its grin.
-- Fixes: the gold balls now read as shells (ribbed peach scallop in one hand, cream spiral whelk in the other),
-- the snorkel is a real J-tube with a mouthpiece, flippers replace the pink nubs, 6-tone sphere light.
-- quirk: the snorkel is blowing a little string of bubbles out of its top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-snorkel-snip-yard", 64)

local PINK  = { "#5e2048", "#9a3462", "#cc4f7e", "#ef7a9a", "#ffa9bc", "#ffd6de" }
local TEAL  = { "#173f4f", "#1f6a72", "#2f9a94", "#4fc4b0", "#8ae6c8", "#c8f7e2" }
local ORNG  = { "#7a2e1c", "#b8481f", "#e0702a", "#f59a3a", "#ffc46a", "#ffe6a8" }
local SCAL  = { "#6e3a3a", "#a85a4a", "#d8846a", "#f2ad8a", "#ffd2b2", "#fff0dc" }
local WHLK  = { "#4e3a5e", "#7e6488", "#ad94ac", "#d4bfc8", "#efe0dc", "#fff4e8" }
local GLASS = { "#2a4a7a", "#3a86b0", "#8bc4ea", "#b9e2f5" }
local BNC = "#7a4f9a"

c:groundShadow(32, 58, 17, 2.5)

-- flippers
for _, s in ipairs({ { 22, -1 }, { 42, 1 } }) do
  local f = c:ellipse(s[1] + s[2] * 2, 56, 6.5, 2)
  f:add(c:ellipse(s[1], 54, 3.5, 2.5))
  local fi = O.shade(c, f, TEAL, { R = 2, amb = .25, sep = TEAL[1] })
  O.mark(c, { { s[1] + s[2] * 4, 56 }, { s[1] + s[2] * 6, 56 } }, TEAL[2]) -- flipper ribs
end

-- arms (behind body), raised up and out
local arms = {}
for _, s in ipairs({ { -1 }, { 1 } }) do
  local d = s[1]
  local m, n = O.tube({ { 32 + d * 10, 40 }, { 32 + d * 16, 38 }, { 32 + d * 19, 33 }, { 32 + d * 20, 27 } }, function(t) return 2.2 - t * .4 end)
  arms[#arms+1] = { m, n }
  O.shadeN(c, m, n, PINK, { amb = .25, sep = PINK[2] })
end

-- body
local body = c:ellipse(32, 41, 14, 13)
local bI, bT = O.shade(c, body, PINK, { sphere = { 27, 35, 17 }, amb = .27, wrap = .35, sep = PINK[1], rim = true, bounce = BNC, bmax = 2 })
-- freckle speckles on the back
O.tex(c, bI, bT, PINK, function(x, y, i) if O.H(x, y, 11) > .955 and i >= 3 and y < 38 then return -1 end end)
-- belly
local bel = c:ellipse(32, 47, 8, 6)
O.shade(c, bel, { "#ef7a9a", "#ffa9bc", "#ffd6de", "#fff0ee" }, { R = 3, amb = .45, cuts = { .3, .6, .85 } })

-- dive mask pushed up on the brow: strap + glass
local strap = c:rect(18, 29, 46, 30)
strap:clip(body)
O.flat(c, strap, TEAL[2], "strap")
O.mark(c, { { 19, 29 }, { 20, 29 }, { 21, 29 } }, TEAL[3])
local frame = c:rrect(24, 25, 40, 31, 2)
O.shade(c, frame, TEAL, { R = 1, amb = .3, sep = TEAL[1] })
for _, gx in ipairs({ 26, 33 }) do
  local g = c:rect(gx, 27, gx + 4, 29)
  O.shade(c, g, GLASS, { R = 1, amb = .5, cuts = { .3, .55, .8 } })
  O.dots(c, { { gx, 27 }, { gx + 1, 27 } }, "#e4f6ff")
end

-- snorkel: mouthpiece at the grin, tube up the right side of the head
local tm, tn = O.tube({ { 39, 46 }, { 46, 46 }, { 48, 40 }, { 48, 14 } }, function(t) return 1.6 end)
O.shadeN(c, tm, tn, ORNG, { amb = .3, sep = ORNG[1] })
local tip = c:rrect(46, 11, 50, 14, 1)
O.shade(c, tip, TEAL, { R = 1, amb = .35 })
O.flat(c, c:rect(37, 45, 40, 47), TEAL[3], "mouthpiece")
O.dot(c, 37, 45, TEAL[5])
-- stripe bands on the tube
O.mark(c, { { 47, 24 }, { 48, 24 }, { 49, 24 }, { 47, 33 }, { 48, 33 }, { 49, 33 } }, ORNG[2])

-- left hand: scallop shell (ribbed fan)
do
  local cx, cy = 12, 20
  local fan = c:ellipse(cx, cy, 6, 5.5)
  fan:cut(c:rect(cx - 7, cy + 2, cx + 7, cy + 7))
  fan:add(c:poly{ { cx - 6, cy + 1 }, { cx + 6, cy + 1 }, { cx + 1, cy + 6 }, { cx - 1, cy + 6 } })
  local ears = c:rect(cx - 3, cy + 5, cx + 3, cy + 7)
  O.shade(c, ears, SCAL, { R = 1, amb = .3 })
  local fI, fT = O.shade(c, fan, SCAL, { sphere = { cx - 2, cy - 3, 8 }, amb = .25, wrap = .4, sep = SCAL[1], rim = true })
  -- radiating ribs (darker grooves)
  O.tex(c, fI, fT, SCAL, function(x, y, i)
    local a = math.atan(x - cx, cy + 7 - y)
    local k = math.floor(a * 7 + 100.5)
    if k % 2 == 0 and y < cy + 5 then return -1 end
  end)
  -- growth line
  O.mark(c, { { cx - 4, cy - 1 }, { cx - 3, cy }, { cx + 3, cy }, { cx + 4, cy - 1 } }, SCAL[3])
  -- gripping hand
  O.shade(c, c:ellipse(cx + 1, cy + 8, 2.5, 2), PINK, { R = 1, amb = .3, sep = PINK[1] })
end

-- right hand: spiral whelk
do
  local cx, cy = 53, 19
  local sh = c:ellipse(cx, cy + 1, 4.5, 5)
  sh:add(c:poly{ { cx - 2, cy - 3 }, { cx + 1, cy - 9 }, { cx + 3, cy - 3 } })
  sh:add(c:poly{ { cx - 1, cy + 4 }, { cx + 1, cy + 9 }, { cx + 3, cy + 4 } })
  local sI, sT = O.shade(c, sh, WHLK, { sphere = { cx - 2, cy - 2, 7 }, amb = .42, wrap = .4, sep = WHLK[1], rim = true })
  -- spiral whorl lines
  O.mark(c, { { cx - 1, cy - 4 }, { cx, cy - 4 }, { cx + 1, cy - 4 }, { cx - 3, cy - 1 }, { cx - 2, cy - 1 }, { cx - 1, cy - 1 },
              { cx, cy - 1 }, { cx + 1, cy }, { cx + 2, cy + 1 } }, WHLK[2])
  -- aperture (lip) on the right, glossy pink
  O.flat(c, c:rect(cx + 2, cy + 2, cx + 3, cy + 5), "#f5809f", "lip")
  O.dot(c, cx + 2, cy + 2, "#ffc4d8")
  -- brown bands
  O.mark(c, { { cx - 3, cy + 2 }, { cx - 2, cy + 3 }, { cx - 1, cy + 3 }, { cx, cy + 3 } }, "#a8705a")
  O.shade(c, c:ellipse(cx - 1, cy + 8, 2.5, 2), PINK, { R = 1, amb = .3, sep = PINK[1] })
end

-- face
c:eyeLocked(23, 34)
c:eyeLocked(36, 34)
c:cheek(20, 41) c:cheek(42, 41)
-- grin pulled to the snorkel side
O.dots(c, { { 27, 44 }, { 28, 45 }, { 29, 45 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 45 }, { 34, 45 }, { 35, 45 }, { 36, 44 } }, P.ink)
O.dots(c, { { 29, 46 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 46 } }, PINK[2])

O.shift(c, 0, -1)
-- bubbles out of the snorkel top (outlined small rings drawn after finish, un-outlined fill)
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
