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
local CX, CY = 31.5, 33
local log    = c:ellipse(CX, CY, 20, 19)
local hollow = c:ellipse(CX, CY + 1, 14, 13)
-- moss mat draped over the top of the log
local mossM = c:ellipse(CX, 15.5, 13, 3.5):cut(c:rect(0, 17, 63, 63))
mossM:add(c:rrect(19, 14, 44, 18, 2))
mossM:add(c:rrect(22, 17, 25, 20, 1)):add(c:rrect(38, 17, 40, 21, 1))

-- spider masks
local abd  = c:ellipse(CX, 29, 11, 8.5)
local saddle = c:ellipse(CX, 27, 8, 5):cut(c:rect(0, 31, 63, 63))
saddle:add(c:rrect(24, 27, 39, 30, 2))
local head = c:ellipse(CX, 40, 10.5, 7.5)
local fangs = c:ascii({ "##..##", "##..##", "##..##", ".#..#." }, 28, 46)
-- silver tufts (spiky boss crest) on the back of the abdomen
local tufts = c:ascii({
  "#.....#.....#",
  "##...###...##",
  "###.#####.###",
}, 25, 18)

c:build{
  { "log",    log,    wood },
  { "hollow", hollow, hollowR, { flat = true, rim = false, gloss = false } },
  { "moss",   mossM,  moss, { gloss = false } },
}

-- growth ring on the cut face, between bark and hollow
local ring = c:ellipse(CX, CY + 0.5, 17, 16):edge():cut(hollow:grow(1)):cut(mossM:grow(1))
c:fill(ring, wood.shade)

-- silver web threads across the hollow: 2 on / 1 off "stitches"
local function thread(pts)
  local m = c:line(pts, 1):clip(hollow:shrink(1))
  local i = 0
  local px = {}
  m:each(function(x, y) px[#px + 1] = { x, y } end)
  table.sort(px, function(a, b) if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
  for _, p in ipairs(px) do
    if i % 3 ~= 2 then c:px(p[1], p[2], SILV) end
    i = i + 1
  end
end
thread({ {CX, 34}, {20, 25} }); thread({ {CX, 34}, {43, 25} })
thread({ {CX, 34}, {19, 39} }); thread({ {CX, 34}, {44, 39} })
thread({ {CX, 34}, {22, 45} }); thread({ {CX, 34}, {41, 45} })

-- eight bent legs: knee out over the rim, tip hooked past it
local L = {
  { {24,26}, {15,15}, {7,17} },     -- front pair, up and over the top rim
  { {23,30}, {11,26}, {6,32} },
  { {23,36}, {11,38}, {7,45} },
  { {25,42}, {16,49}, {13,56} },    -- rear pair, down past the bottom rim
}
for _, l in ipairs(L) do c:limb(l); c:limb(mir(l)) end

local p = c:build{
  { "tufts",  tufts,  silver, { flat = true } },
  { "abd",    abd,    fur },
  { "saddle", saddle, silver, { gloss = { 27, 24 } } },
  { "fangs",  fangs,  bone, { flat = true } },
  { "head",   head,   fur },
}

-- dragline: silver thread from the moss down to the back
c:px(31, 19, SILV); c:px(31, 20, SILV)

-- sewn-on saddle patch: gold seam along its lower hem with a button
c:seam({ {25, 30}, {38, 30} })
c:button(30, 28)

-- face: wide locked eyes, angry silver brows, scowl
c:eye(24, 37); c:eye(35, 37)
c:paint({ "bb....", ".bbbb.", "....bb" }, 22, 34, { b = SILV })
c:paint({ "....bb", ".bbbb.", "bb...." }, 36, 34, { b = SILV })
c:paint({ ".uuuu.", "u....u" }, 29, 43, { u = "#a894dc" })

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
