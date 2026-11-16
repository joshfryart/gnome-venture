-- trail-wonder (32x32 trail map marker, Opus second pass). Landmark kind "wonder": a once-a-day mystery to
-- investigate (three stat-check approaches), with good finds. An ancient trilithon: two tapering slate standing stones
-- under a heavy rounded lintel, glowing teal runes carved in the posts, and between them a swirling portal (cream core,
-- teal and violet spiral arms) that spills light on the ground; two cream sparkles. Silhouette: a gate of stone with
-- a bright swirl, not a box.
-- quirk: a robin perches on the lintel, peering down into the glow.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-wonder")
local floor, atan, sqrt, pi = math.floor, math.atan, math.sqrt, math.pi

local SL = { "#2e3048", "#464b68", "#636b8a", "#8590ac", "#aab4c8", "#d0d8e2" } -- slate deep..hi
local RUNE = { "#3fb8b8", "#8af0e2" }

-- portal (behind the stones): spiral rings, bright core
local gap = c:rect(9, 11, 22, 28)
local cx, cy = 15.5, 19.5
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

-- light spilt on the ground in front of the gate
for x = 9, 22 do c:put(x, 29, (x > 11 and x < 20) and "#8fe6d6" or "#5aa8b4") end
for x = 12, 19 do c:put(x, 30, "#5aa8b4") end

-- standing stones: tapering, rounded tops, lit from the upper left
local L = c:poly{ { 3, 10 }, { 9, 10 }, { 10, 29 }, { 2, 29 } }
local R = c:poly{ { 22, 10 }, { 28, 10 }, { 29, 29 }, { 21, 29 } }
T.vol(c, L, SL, { bias = 0.15 })
T.vol(c, R, SL, { bias = -0.05 })
-- dark inner faces toward the portal, glow rim on them
L:each(function(x, y) if not L:has(x + 1, y) then c:put(x, y, (y % 3 == 0) and "#4ea8c8" or SL[2]) end end)
R:each(function(x, y) if not R:has(x - 1, y) then c:put(x, y, (y % 3 == 1) and "#7fe0d8" or SL[3]) end end)
-- foot shadow
for x = 2, 10 do c:put(x, 29, SL[1]) end
for x = 21, 29 do c:put(x, 29, SL[1]) end
-- carved runes (glowing)
T.pt(c, { { 5, 14 }, { 6, 15 }, { 5, 16 }, { 6, 17 }, { 5, 20 }, { 6, 20 }, { 7, 20 }, { 6, 21 }, { 6, 22 } }, RUNE[2])
T.pt(c, { { 25, 14 }, { 25, 15 }, { 26, 15 }, { 25, 16 }, { 25, 20 }, { 26, 21 }, { 25, 22 }, { 26, 22 } }, RUNE[1])
-- chips and cracks
T.pt(c, { { 4, 24 }, { 4, 25 }, { 5, 26 } }, SL[2])
T.pt(c, { { 27, 25 }, { 26, 26 } }, SL[2])

-- lintel: heavy slab with rounded ends, a lit top, deep underside, one crack
local lin = c:rrect(1, 5, 30, 10, 2)
T.vol(c, lin, SL, { bias = 0.25, k = 1.2 })
lin:each(function(x, y)
  if y == 10 then c:put(x, y, SL[1]) end
  if y == 5 and x > 2 and x < 29 then c:put(x, y, SL[6]) end
  if y == 6 and x > 1 and x < 12 then c:put(x, y, SL[5]) end
end)
T.pt(c, { { 18, 6 }, { 18, 7 }, { 19, 8 }, { 19, 9 } }, SL[2])
-- glow on the lintel underside above the portal
for x = 11, 20 do c:put(x, 10, "#3a6a8a") end

-- sparkles
T.art(c, 0, {
  "................................",
  ".......................s........",
  "..s...................sSs.......",
  ".sSs...................s........",
  "..s.............................",
}, { s = "#ffe38a", S = "#fff4d6" })

-- quirk: a robin on the lintel, peering into the glow
T.art(c, 1, {
  ".............ab.................",
  "............abeg................",
  "..........bbbrr.................",
  "...........bbrr.................",
}, { a = "#b97a4a", e = "#2b1c26", b = "#8a5636", r = "#e8573f", g = "#f5b82e" })

T.done(c)
