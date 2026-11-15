-- hazard (32x32 trail map marker, Opus third pass: replaces the road-sign triangle of ../opus2/).
-- A hand-made trail warning: two rough, sun-bleached planks nailed crooked across two stakes,
-- a big red "!" daubed over both (the bar runs over the plank seam, the dot drips), a red rag fluttering
-- from the tall stake, and a rockfall at its foot (a cracked boulder left, rubble right).
-- Light from the upper left (rim light on the top-left edges), cel shade on the lower right,
-- olive bounce from the grass on the rock bottoms. Material: wood grain, a knot, rough chipped
-- plank ends, iron nails, rope lashing, brush-streaked paint, cracked rock with lichen.
-- quirk: the red rag is an old red-and-cream striped sock, tied on by its cuff, toe flapping.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("hazard")

local W = { "#3f2333", "#5e3330", "#83492f", "#a8683c", "#cc9055", "#e8b878" } -- stake wood
local PL = { "#4e3236", "#7a5846", "#a6825e", "#c9a77c", "#e2c89c", "#f2e0b8" } -- bleached planks
local RD = { "#4e1630", "#7a2234", "#a8303a", "#d0443e", "#ec6a4c", "#ff9a72" } -- red paint / cloth
local CR = { "#c9ac88", "#ecdcbc", "#fbefd6" } -- sock cream shade, base, light
local S = { "#2e2438", "#4a3c4e", "#6a5a68", "#8e7c86", "#b4a2a6", "#d6c8c4" } -- warm rock
local BOUNCE = "#5f6a4e"
local LICHEN = { "#9aa84e", "#c8c86c" }
local ROPE = { "#8a6a3a", "#c9a46a", "#e6cc92" }
local NAIL = { "#5a5a78", "#c8c8d8" }
local function R(x0, y0, x1, y1, hex) for y = y0, y1 do for x = x0, x1 do c:put(x, y, hex) end end end
local function P(x, y, hex) c:put(x, y, hex) end
local function E(x, y) c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end

-- two stakes, 3 px, rim-lit left faces; the left one is tall (the rag is tied to it) with a
-- split slanted top, the right one is short with a sawn top showing end grain
for y = 2, 28 do P(5, y, W[5]) P(6, y, W[4]) P(7, y, W[2]) end
R(5, 2, 5, 7, W[6])
P(5, 1, W[6]) P(6, 1, W[4]) E(7, 2) P(7, 3, W[2])
P(6, 21, W[3]) P(6, 22, W[3]) P(7, 25, W[1])
for y = 6, 28 do P(24, y, W[5]) P(25, y, W[4]) P(26, y, W[2]) end
P(24, 6, W[6]) P(25, 6, "#efc98e") P(26, 6, W[4]) -- sawn end grain
P(25, 21, W[3]) P(25, 23, W[3])

T.grid(c, 8, 0, {
  "..........",
  "cHHcHH.c..",
  "cRRcRRHcH.",
  "cRRcRRRcRR",
  "csscssscRRt",
  ".......sRtt",
  "........tt.",
}, {
  c = CR[2], H = RD[5], R = RD[4], s = RD[3], t = CR[2],
})
P(8, 1, CR[3]) P(8, 2, CR[3]) P(11, 1, CR[3]) -- cuff and stripes catch the light
P(15, 1, CR[3]) P(11, 4, CR[1]) P(15, 4, CR[1]) P(8, 4, CR[1])
P(17, 5, RD[2]) P(18, 6, CR[1]) P(17, 6, CR[1]) P(19, 5, CR[1]) -- shaded heel side and toe
P(9, 1, RD[6]) -- pop
-- rope lashing the cuff to the stake
P(5, 2, ROPE[3]) P(6, 2, ROPE[1]) P(7, 3, ROPE[2]) P(5, 4, ROPE[2]) P(6, 3, ROPE[2])

-- a rough plank with a lit top edge, face, dark thickness strip, grain
local function plank(x0, x1, ys, seed)
  -- ys(x) = top row at column x
  for x = x0, x1 do
    local t = ys(x)
    P(x, t, PL[6]) P(x, t + 1, PL[5]) P(x, t + 2, PL[4]) P(x, t + 3, PL[4]) P(x, t + 4, PL[2])
  end
  P(x0, ys(x0) + 1, PL[6]) P(x0, ys(x0) + 2, PL[5]) -- pale end grain on the left (lit) end
  P(x1, ys(x1) + 1, PL[3]) P(x1, ys(x1) + 2, PL[3]) P(x1, ys(x1) + 3, PL[3]) -- shaded right end
end
-- top plank: left half one row higher than the right (nailed crooked)
local function ysA(x) return x <= 15 and 8 or 9 end
plank(4, 27, ysA)
E(4, 8) E(27, 13) P(27, 12, PL[2]) -- chipped corners
-- bottom plank: tilts the other way
local function ysB(x) return x <= 12 and 15 or 14 end
plank(5, 26, ysB)
E(26, 14) E(5, 19) P(5, 18, PL[2])
-- grain and a knot
R(6, 10, 10, 10, PL[3]) R(19, 11, 24, 11, PL[3]) R(8, 17, 11, 17, PL[3]) R(19, 16, 22, 16, PL[3])
P(9, 16, PL[2]) P(10, 16, PL[3]) P(8, 16, PL[3])
P(4, 9, PL[5])
-- iron nails at the plank ends
P(6, 10, NAIL[2]) P(6, 11, NAIL[1]) P(25, 11, NAIL[2]) P(25, 12, NAIL[1])
P(7, 17, NAIL[2]) P(7, 18, NAIL[1]) P(24, 16, NAIL[2]) P(24, 17, NAIL[1])
-- the planks cast a shadow on the stake below them
P(5, 20, W[2]) P(6, 20, W[1]) P(7, 20, W[1]) P(24, 19, W[2]) P(25, 19, W[1]) P(26, 19, W[1])

-- the daubed "!": a brushed wedge, a dot, a drip hanging off the bottom plank
-- painted after the planks were nailed up, so the bar runs straight over the gap between them
T.grid(c, 12, 8, {
  "..hHrs..",
  ".hHrrsd.",
  ".hrrrsd.",
  "..hrrsd.",
  "..hrrsd.",
  "...hrsd.",
  "...hrs..",
  "........",
  "........",
  "..hrrs..",
  "..hrsd..",
  "....s...",
  "....d...",
}, { h = RD[5], H = RD[6], r = RD[4], s = RD[3], d = RD[2] })
P(19, 10, RD[3]) P(12, 9, RD[5]) -- ragged brush edges


-- rockfall at the foot: hand-lit rocks (rim top-left, cel shade lower-right, grass bounce)
local function rock(m, rim)
  m:each(function(x, y)
    local ul = not m:has(x - 1, y) or not m:has(x, y - 1)
    local lr = not m:has(x + 1, y) or not m:has(x, y + 1)
    local lr2 = not m:has(x + 2, y) or not m:has(x, y + 2) or not m:has(x + 1, y + 1)
    local v = S[4]
    if lr then v = S[2] elseif lr2 then v = S[3] elseif ul then v = rim and S[6] or S[5] end
    if not m:has(x, y + 1) and m:has(x - 1, y) and m:has(x + 1, y) and x % 2 == 1 then v = BOUNCE end
    c:put(x, y, v)
  end)
  return m
end
local big = rock(c:ellipse(8, 25.5, 5, 3.5), true)
local r1 = rock(c:ellipse(22, 26.5, 4, 2.5))
local r2 = rock(c:ellipse(27.5, 28, 1.5, 1.5))
local r3 = rock(c:ellipse(18, 28.5, 1.5, 1.5))
T.seam(c, r1:copy():cut(r3), r3, S[1])
-- the boulder split when it came down: a jagged crack with a lit lip
P(9, 22, S[2]) P(9, 23, S[1]) P(8, 24, S[1]) P(9, 25, S[1]) P(9, 26, S[2]) P(8, 27, S[1])
P(10, 23, S[5]) P(10, 25, S[5])
P(5, 24, S[6]) P(6, 23, S[6]) -- pop
P(11, 27, LICHEN[1]) P(12, 26, LICHEN[2]) P(23, 25, LICHEN[2]) P(24, 25, LICHEN[1])
P(21, 25, S[5]) P(20, 26, S[5])
P(30, 25, S[4]) P(30, 24, S[5]) -- a loose pebble still rolling
P(3, 29, "#3f9150") P(13, 29, "#3f9150") P(14, 29, "#7cc35a") P(25, 29, "#3f9150")

T.done(c)
