-- trail-overgrown (32x32 trail map marker, Opus second pass). Road kind "overgrown": the road is swallowed by
-- bramble and each stretch is slower; an axe in the satchel clears the way. A tall clumpy bramble thicket (dark
-- leaf clumps lit on their upper-left so it never melts into the green map) with thorny red-purple canes curling out
-- of its crown, ripe blackberries and one pink bramble flower; the dirt road runs in and vanishes into a dark gap
-- under it. Front right: a stump with an axe bitten into it, the way through.
-- quirk: a bramble cane has already wound itself round the axe handle, as if to keep it.
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

-- road running into a dark gap under the thicket
local gap = c:ellipse(12, 25, 4.5, 6) gap:clip(c:rect(0, 19, 31, 27))
gap:grow(1):cut(gap):each(function(x, y) if y < 25 and all:has(x, y) then c:put(x, y, LF[5]) end end) -- lit leafy arch
T.fill(c, gap, "#0f2622")
gap:each(function(x, y) if y >= 24 then c:put(x, y, "#1e3a2e") end end)
local road = c:poly{ { 10, 24 }, { 14, 24 }, { 17, 30 }, { 5, 30 } }
road:each(function(x, y)
  local h = DIRT[3]
  if y <= 25 then h = DIRT[1] elseif y <= 26 then h = DIRT[2] end
  if not road:has(x - 1, y) and y > 26 then h = DIRT[4] end
  if not road:has(x + 1, y) then h = DIRT[2] end
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
  if y == 29 then h = "#51302b" end
  c:put(x, y, h)
end)
c:put(20, 29, "#864c33") c:put(29, 29, "#51302b") -- root flare
local stumpTop = c:ellipse(24.5, 24.5, 4, 1.5)
T.fill(c, stumpTop, "#e8b982")
T.pt(c, { { 23, 24 }, { 26, 24 }, { 24, 23 }, { 25, 25 } }, "#c99a64")
c:put(24, 24, "#b97a4a") c:put(25, 24, "#b97a4a")
-- handle: 2 px, lit top edge, from the head up-right
c:line({ { 25, 21 }, { 30, 13 } }, 1):each(function(x, y) c:put(x, y, "#f0c890") end)
c:line({ { 26, 21 }, { 30, 14 } }, 1):each(function(x, y) c:put(x, y, "#b97a4a") end)
c:put(30, 13, "#864c33")
-- steel head, bitten into the stump top
T.art(c, 20, {
  "................................",
  ".....................dabbd......",
  "....................daabbcd.....",
  "....................dabbccd.....",
  ".....................ddddd......",
}, { a = "#eef0f4", b = "#b6bccc", c = "#7a8098", d = "#3a3c52" })
-- quirk: a cane wound round the handle
T.pt(c, { { 27, 17 }, { 29, 18 }, { 28, 16 } }, CANE[2])
T.pt(c, { { 28, 19 } }, CANE[3])
T.pt(c, { { 26, 17 }, { 30, 18 } }, THORN)

T.done(c)
