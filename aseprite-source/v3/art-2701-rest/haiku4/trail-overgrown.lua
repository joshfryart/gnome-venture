-- trail-overgrown (32x32 trail map marker, Opus richness pass 3, built on opus2). Road kind "overgrown": the road is swallowed by
-- bramble and each stretch is slower; an axe in the satchel clears the way. A tall clumpy bramble thicket (dark
-- leaf clumps lit on their upper-left so it never melts into the green map) with thorny red-purple canes curling out
-- of its crown, ripe blackberries and one pink bramble flower; the dirt road runs in and vanishes into a dark gap
-- under it. Front right: a stump with an axe bitten into it, the way through.
-- quirk: a bramble cane has already wound itself round the axe handle and put out a leaf, as if to keep it.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-overgrown")
local HP = T.HP

local LF = { "#11282a", "#1a3c38", "#235442", "#2e6c4c", "#4c9658", "#8cc46a" } -- leaf deep..hi
local CANE = { "#4e1f3a", "#7a2f48", "#a8485a" }
local THORN = "#e2a0a0"
local DIRT = { "#7a5034", "#a5764a", "#c99a64", "#e2bd84" }

-- thicket: clumps, each lit on its own upper-left, back to front
local clumps = {
  { 8, 10, 5 }, { 16, 7, 5.5 }, { 24, 10, 5 }, { 5, 17, 4.5 }, { 23, 16, 3.5 },
  { 11, 14, 5 }, { 19, 13, 4.5 }, { 7, 22, 4.5 }, { 20, 20, 3.5 }, { 15, 17, 4 },
}
local all = HP.mask()
for i, k in ipairs(clumps) do
  local m = c:ellipse(k[1], k[2], k[3], k[3] * 0.9)
  m:clip(c:rect(1, 1, 30, 30))
  T.vol(c, m, LF, { bias = (i <= 3) and -0.3 or -0.2, k = 1.3 })
  -- dark seam where this clump overlaps those behind
  m:each(function(x, y) if all:has(x, y) and (not m:has(x + 1, y) or not m:has(x, y + 1)) then c:put(x, y, LF[1]) end end)
  all:add(m)
end
-- leaf flecks (serrated bramble leaves catching light)
for _, p in ipairs{ { 6, 8 }, { 14, 4 }, { 22, 7 }, { 3, 15 }, { 9, 12 }, { 18, 10 }, { 5, 20 }, { 13, 15 } } do
  c:put(p[1], p[2], LF[6]) c:put(p[1] + 1, p[2] + 1, LF[5])
end

-- serrated bramble leaf tips along the lit upper-left of the crown
all:each(function(x, y)
  if (not all:has(x, y - 1) or not all:has(x - 1, y)) and x < 22 and y < 16 and (x + y) % 3 == 0 then c:put(x, y, LF[5]) end
end)
-- leaf veins: little lit chevrons on a few clumps
for _, p in ipairs{ { 15, 6 }, { 24, 9 }, { 7, 21 } } do c:put(p[1], p[2], LF[6]) c:put(p[1] - 1, p[2] + 1, LF[5]) c:put(p[1] + 1, p[2] + 1, LF[4]) end

-- road running into a dark gap under the thicket
local gap = c:ellipse(12, 25, 4.5, 6) gap:clip(c:rect(0, 19, 31, 27))
gap:grow(1):cut(gap):each(function(x, y) if y < 25 and all:has(x, y) then c:put(x, y, LF[5]) end end) -- lit leafy arch
T.fill(c, gap, "#0f2622")
gap:each(function(x, y) if y >= 24 then c:put(x, y, "#1e3a2e") end end)
local road = c:poly{ { 11, 21 }, { 13, 21 }, { 17, 30 }, { 5, 30 } }
road:each(function(x, y)
  local h = DIRT[3]
  if y <= 22 then h = "#3e2c22" elseif y <= 24 then h = "#5a3c2a" elseif y <= 25 then h = DIRT[1] elseif y <= 26 then h = DIRT[2] end
  if y > 26 and not road:has(x - 1, y) then h = DIRT[4] end
  if y > 24 and not road:has(x + 1, y) then h = DIRT[2] end
  c:put(x, y, h)
end)
T.pt(c, { { 10, 28 }, { 14, 29 }, { 12, 27 } }, DIRT[2])
c:put(11, 28, DIRT[4])
-- grass creeping over the road edges
T.pt(c, { { 5, 29 }, { 6, 28 }, { 7, 27 }, { 16, 28 }, { 15, 26 } }, LF[4])

-- thorny canes curling out of the crown
local function cane(pts, thorns)
  c:line(pts, 1):each(function(x, y) c:put(x, y, CANE[2]) end)
  for _, t in ipairs(thorns) do c:put(t[1], t[2], THORN) end
end
cane({ { 9, 6 }, { 6, 3 }, { 3, 3 }, { 2, 5 }, { 3, 7 }, { 5, 7 } }, { { 7, 2 }, { 1, 4 }, { 4, 8 } })
cane({ { 20, 4 }, { 22, 1 }, { 25, 1 }, { 27, 3 } }, { { 21, 1 }, { 24, 0 + 2 }, { 28, 2 } })
cane({ { 2, 13 }, { 1, 11 } }, { { 0 + 2, 10 } })
c:put(6, 3, CANE[3]) c:put(23, 1, CANE[3])

-- blackberries: little clusters of three drupes, each with a glint; one cluster still red
local function berry(x, y, ripe)
  local a, b, g = "#2a1840", "#4a2a6a", "#b08ae0"
  if not ripe then a, b, g = "#9e2a3c", "#e8493b", "#ff9a7a" end
  c:put(x, y, b) c:put(x + 1, y, a) c:put(x - 1, y + 1, b) c:put(x, y + 1, a) c:put(x + 1, y + 1, a) c:put(x, y + 2, a)
  c:put(x, y, g)
end
berry(11, 9, true) berry(18, 11, true) berry(4, 17, false)
T.art(c, 4, {
  "................................",
  "...........................p....",
  "..........................pyp...",
  "...........................p....",
}, { p = "#ffc4d8", y = "#f5b82e" })

-- stump with an axe bitten into its top; the handle sticks up and out to the right, clear of the bramble
local stumpSide = c:rect(21, 25, 28, 29)
stumpSide:each(function(x, y)
  local h = "#864c33"
  if x == 21 then h = "#b97a4a" elseif x >= 27 then h = "#51302b" elseif (x == 23 or x == 25) then h = "#6a3c2c" end
  if (x == 22 and y == 27) or (x == 24 and y == 28) or (x == 26 and y == 26) then h = "#a06640" end -- bark plates
  if y == 29 then h = "#51302b" end
  c:put(x, y, h)
end)
c:put(20, 29, "#864c33") c:put(29, 29, "#51302b") -- root flare
local stumpTop = c:ellipse(24.5, 24.5, 4, 1.5)
T.fill(c, stumpTop, "#e8b982")
stumpTop:each(function(x, y) if not stumpTop:has(x, y + 1) or not stumpTop:has(x + 1, y) then c:put(x, y, "#c99a64") end end)
T.pt(c, { { 23, 24 }, { 24, 23 }, { 25, 23 } }, "#c99a64") -- growth rings
c:put(24, 24, "#a06640")                                   -- heart of the stump
-- handle: 2 px ash wood, lit top edge, from the head's poll up-right
c:line({ { 25, 18 }, { 29, 11 } }, 1):each(function(x, y) c:put(x, y, "#f0c890") end)
c:line({ { 26, 18 }, { 30, 12 } }, 1):each(function(x, y) c:put(x, y, "#b97a4a") end)
c:put(29, 11, "#864c33") c:put(30, 11, "#864c33") c:put(28, 14, "#d8a870")
-- steel bearded head bitten down into the stump top: narrow poll round the handle, concave beard flaring to a
-- bright bevelled edge on the left, mid cheek, dark back
T.art(c, 18, {
  ".......................ddd......",
  "......................dabcd.....",
  ".....................dEabcd.....",
  "....................dEabbcd.....",
  "...................dEEabbcd.....",
  "...................EEaabbccd....",
  "...................wwwwwwww.....",
}, { E = "#f4f6f8", a = "#d2d8e2", b = "#a2a9bc", c = "#6e748c", d = "#3a3c52", w = "#6a3c2c" })
c:put(24, 19, "#f4f6f8") -- glint on the poll

-- quirk: a bramble cane has wound itself round the axe handle
T.pt(c, { { 26, 15 }, { 28, 16 }, { 27, 14 }, { 29, 14 } }, CANE[2])
T.pt(c, { { 27, 16 } }, CANE[3])
T.pt(c, { { 25, 15 }, { 29, 16 } }, THORN)
c:put(30, 14, "#4c9658") -- a new leaf on the runaway cane

T.done(c)
