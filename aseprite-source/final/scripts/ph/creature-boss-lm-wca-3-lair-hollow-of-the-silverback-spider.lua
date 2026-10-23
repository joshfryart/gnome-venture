-- Silverback Spider (boss, rainforest lair "Hollow of the Silverback Spider"), level 30
-- Seen face-on in the round mouth of a hollow log: a dusk spider with a sewn-on
-- silver-grey saddle patch across its back (like a gorilla silverback), bone fangs,
-- angry silver brows. Eight bent lavender legs grip the rim and poke out past it.
-- Silver dragline and web threads are stitched across the dark hollow.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-wca-3-lair-hollow-of-the-silverback-spider"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function mir(pts)
  local r = {}
  for i, p in ipairs(pts) do r[i] = { 63 - p[1], p[2] } end
  return r
end

local wood   = GV.R.wood
local hollowR = GV.ramp("#3d2a1c")            -- soil (Part A), dark log interior
local moss   = GV.R.moss
local fur    = GV.R.dusk
local silver = GV.ramp("#c9c5bc")             -- stone (Part A) pale silver-grey
local bone   = GV.ramp("#f1ece0")             -- soil pale (Part A) for fangs
local SILV   = "#c9c5bc"

-- log end (round cross-section) and its dark hollow
local CX, CY = 31.5, 32
local log    = c:ellipse(CX, CY, 20, 20)
local hollow = c:ellipse(CX, CY + 1, 16, 15.5)
-- moss mat draped over the top of the log
local mossM = c:ellipse(CX, 13.5, 11, 3):cut(c:rect(0, 15, 63, 63))
mossM:add(c:rrect(21, 12, 42, 15, 2))
mossM:add(c:rrect(23, 15, 25, 17, 1)):add(c:rrect(38, 15, 40, 18, 1))

-- spider masks: big back with the silver saddle, chibi head in front
local abd  = c:ellipse(CX, 27, 12.5, 9)
local saddle = c:ellipse(CX, 27, 10, 5):cut(c:ellipse(CX, 19.5, 6, 4))
saddle:clip(abd:shrink(2))
local head = c:ellipse(CX, 40, 10.5, 7.5)
local fangs = c:ascii({ "##...##", "##...##", "##...##", ".#...#." }, 27, 46)

c:build{
  { "log",    log,    wood },
  { "hollow", hollow, hollowR, { flat = true, rim = false, gloss = false } },
  { "moss",   mossM,  moss, { gloss = false } },
}

-- growth ring on the cut face, between bark and hollow
local ring = c:ellipse(CX, CY + 0.5, 18, 18):edge():cut(hollow:grow(1)):cut(mossM:grow(1))
c:fill(ring, wood.shade)

-- eight bent legs: knee out over the rim, tip hooked past it
local L = {
  { {24,21}, {16,12}, {9,15} },     -- front pair, up and over the top rim
  { {21,28}, {10,25}, {8,31} },
  { {21,36}, {10,40}, {9,46} },
  { {25,44}, {17,50}, {14,54} },    -- rear pair, down past the bottom rim
}
local legM = c:mask()
for _, l in ipairs(L) do
  c:limb(l); c:limb(mir(l))
  legM:add(c:line(l, 2)):add(c:line(mir(l), 2))
end

local p = c:build{
  { "abd",    abd,    fur },
  { "saddle", saddle, silver, { gloss = { 25, 25 }, pale = false } },
  { "head",   head,   fur },
  { "fangs",  fangs,  bone, { flat = true, contour = false, contact = false } },
}

-- silver web threads across the open hollow: 2 on / 1 off "stitches"
local open = hollow:shrink(1):cut(legM:grow(1)):cut(abd:grow(1)):cut(head:grow(1))
local function thread(pts)
  local m = c:line(pts, 1):clip(open)
  local px = {}
  m:each(function(x, y) px[#px + 1] = { x, y } end)
  table.sort(px, function(a, b) if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
  for i, q in ipairs(px) do if i % 3 ~= 0 then c:px(q[1], q[2], SILV) end end
end
thread({ {CX, 33}, {17, 44} }); thread({ {CX, 33}, {46, 44} })
thread({ {CX, 33}, {17, 33} }); thread({ {CX, 33}, {46, 33} })
thread({ {12, 38}, {18, 47}, {24, 47} }); thread({ {51, 38}, {45, 47}, {39, 47} })

-- sewn-on saddle patch: gold seam down the spine with a button at its head
c:seam({ {31, 26}, {31, 31} })
c:button(30, 22)
-- old battle scar on the back, sewn shut
c:seam({ {37, 19}, {41, 23} })

-- face: wide locked eyes, angry silver brows, scowl
c:eye(24, 37); c:eye(35, 37)
c:paint({ "bb....", ".bbbb.", "....bb" }, 22, 34, { b = SILV })
c:paint({ "....bb", ".bbbb.", "bb...." }, 36, 34, { b = SILV })
c:paint({ ".uuu.", "u...u" }, 29, 43, { u = "#a894dc" })

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
