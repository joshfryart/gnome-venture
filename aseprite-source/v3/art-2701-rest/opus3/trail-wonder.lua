-- trail-wonder (32x32 trail map marker, Opus richness pass 3). Landmark kind "wonder": a once-a-day mystery to
-- investigate (three stat-check approaches), with good finds. An ancient trilithon: two tapering slate standing stones
-- with flared, settled feet, layered strata and lichen, glowing teal runes, under a heavy lintel that has sagged a
-- little to the right and lost a chip off its end. Ivy trails over the left end and down the post; a fallen chunk
-- of slate lies at the right foot. Between the stones a swirling portal (cream core, teal and violet spiral arms)
-- lights the inner faces and spills onto the ground. Silhouette: a gate of stone with a bright swirl; the canted
-- lintel, ivy and rubble break up the old square outline.
-- quirk: a robin perches on the lintel, leaning right over the edge to peer down into the glow.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-wonder")
local floor, atan, sqrt, pi = math.floor, math.atan, math.sqrt, math.pi

local SL = { "#2a2a44", "#434866", "#5f6888", "#828dab", "#a8b3c8", "#d0d8e2" } -- slate deep..hi (violet -> cool cream)
local RUNE = { "#3fb8b8", "#8af0e2" }
local LICH = { "#9aa86a", "#c8cc84" }
local IVY = { "#1e4a3a", "#2f7048", "#58a052" }

-- portal (behind the stones): spiral rings, bright core
local gap = c:rect(9, 12, 22, 28)
local cx, cy = 15.5, 20
local PO = { "#2c1f4e", "#46337e", "#6a54b8", "#4ea8c8", "#7fe0d8", "#c8fbec", "#fff4d6" }
gap:each(function(x, y)
  local dx, dy = x - cx, (y - cy) * 0.8
  local r = sqrt(dx * dx + dy * dy)
  local th = atan(dy, dx)
  local base = 7 - floor(r / 1.45)
  local arm = floor(r * 0.55 + th / (2 * pi) * 2 + 10) % 2
  local i = base - (arm == 1 and 1 or 0)
  if i < 1 then i = 1 end
  if i > 7 then i = 7 end
  c:put(x, y, PO[i])
end)
-- motes drifting out of the swirl
T.pt(c, { { 11, 15 }, { 20, 25 } }, PO[6])

-- light spilt on the ground in front of the gate
for x = 9, 22 do c:put(x, 29, (x > 11 and x < 20) and "#8fe6d6" or "#5aa8b4") end
for x = 12, 19 do c:put(x, 30, "#5aa8b4") end
c:put(15, 30, "#8fe6d6") c:put(16, 30, "#8fe6d6")

-- standing stones: tapering, flared settled feet, lit from the upper left
local L = c:poly{ { 3, 10 }, { 9, 10 }, { 10, 27 }, { 11, 29 }, { 1, 29 }, { 2, 26 } }
local R = c:poly{ { 22, 12 }, { 28, 12 }, { 29, 27 }, { 30, 29 }, { 20, 29 }, { 21, 27 } }
T.vol(c, L, SL, { bias = 0.15 })
T.vol(c, R, SL, { bias = -0.05 })
-- strata: faint bedding lines across each stone (slate splits in layers)
for _, y in ipairs{ 14, 19, 24 } do
  L:each(function(x, yy) if yy == y and x > 2 and x < 9 and (x + y) % 4 ~= 0 then c:put(x, yy, SL[3]) end end)
  R:each(function(x, yy) if yy == y + 1 and x > 22 and x < 28 and (x + y) % 4 ~= 1 then c:put(x, yy, SL[2]) end end)
end
-- dark inner faces toward the portal, glow rim on them
L:each(function(x, y) if not L:has(x + 1, y) and y < 28 then c:put(x, y, (y % 3 == 0) and "#4ea8c8" or SL[2]) end end)
R:each(function(x, y) if not R:has(x - 1, y) and y < 28 then c:put(x, y, (y % 3 == 1) and "#7fe0d8" or SL[3]) end end)
-- foot shadow / settled into the ground
for x = 1, 11 do if L:has(x, 29) then c:put(x, 29, SL[1]) end end
for x = 20, 30 do if R:has(x, 29) then c:put(x, 29, SL[1]) end end
-- carved runes (glowing)
T.pt(c, { { 5, 15 }, { 6, 16 }, { 5, 17 }, { 6, 18 }, { 5, 21 }, { 6, 21 }, { 7, 21 }, { 6, 22 }, { 6, 23 } }, RUNE[2])
T.pt(c, { { 25, 16 }, { 25, 17 }, { 26, 17 }, { 25, 18 }, { 25, 21 }, { 26, 22 }, { 25, 23 }, { 26, 23 } }, RUNE[1])
-- lichen rosettes on the lit faces
T.pt(c, { { 4, 26 }, { 24, 27 }, { 27, 14 } }, LICH[1]) T.pt(c, { { 3, 26 }, { 24, 26 } }, LICH[2])
-- cracks
T.pt(c, { { 7, 25 }, { 8, 26 } }, SL[1])
T.pt(c, { { 27, 25 }, { 26, 26 } }, SL[2])

-- lintel: heavy slab, sagged 1 px to the right half, rounded left end, chipped right end
local lin = c:rrect(1, 5, 16, 10, 2):add(c:rrect(12, 6, 30, 11, 2))
lin:cut(c:poly{ { 29, 6 }, { 31, 6 }, { 31, 8 } })               -- chip off the end
T.vol(c, lin, SL, { bias = 0.25, k = 1.2 })
lin:each(function(x, y)
  if not lin:has(x, y + 1) then c:put(x, y, SL[1]) end
  if not lin:has(x, y - 1) and x > 2 and x < 29 then c:put(x, y, SL[6]) end
  if not lin:has(x, y - 2) and lin:has(x, y - 1) and x > 1 and x < 12 then c:put(x, y, SL[5]) end
end)
c:put(17, 5, SL[1]) -- notch where the slab sags
T.pt(c, { { 19, 7 }, { 19, 8 }, { 20, 9 }, { 20, 10 } }, SL[2]) -- crack
T.pt(c, { { 18, 7 } }, SL[5])                                     -- lit lip of the crack
T.pt(c, { { 28, 7 }, { 29, 8 } }, SL[3])                          -- fresh broken face
-- glow on the lintel underside above the portal
for x = 11, 20 do c:put(x, (x <= 16) and 10 or 11, "#3a6a8a") end
c:put(15, 10, "#4ea8c8") c:put(16, 10, "#4ea8c8")
-- strata line on the lintel
for x = 4, 26, 1 do if (x % 5) ~= 0 then c:put(x, (x <= 15) and 8 or 9, SL[4]) end end

-- ivy trailing over the left end of the lintel and down the post
T.art(c, 4, {
  "................................",
  "..lL............................",
  ".lLld...........................",
  "..dl.ll.........................",
  ".lLd............................",
  "..ld............................",
  "..lL............................",
  ".dLl............................",
  "..d.............................",
  ".lL.............................",
  "..d.............................",
}, { l = IVY[2], L = IVY[3], d = IVY[1] })

-- fallen chunk of slate at the right foot
T.art(c, 27, {
  "................................",
  "..........................hbbs..",
  ".........................hbbsd..",
  ".........................ddddd..",
}, { h = SL[6], b = SL[4], s = SL[3], d = SL[1] })

-- sparkles
T.art(c, 0, {
  "................................",
  "........................s.......",
  "..s....................sSs......",
  ".sSs....................s.......",
  "..s.............................",
}, { s = "#ffe38a", S = "#fff4d6" })

-- quirk: a robin on the lintel, leaning over to peer into the glow (cocked tail, round orange breast, eye + beak)
T.art(c, 1, {
  "..............aB................",
  "..........t..abbeg..............",
  "...........tabrrr...............",
  "............brrrd...............",
}, { a = "#c48a56", B = "#e0b07a", e = "#2b1c26", b = "#8a5636", t = "#5e3a2a", r = "#f07a48", d = "#b8402e", g = "#f5b82e" })

T.done(c)
