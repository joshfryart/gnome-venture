-- Tiger Moth (boss, forest lair "Temple of the Tiger Moth"), level 16
-- Chibi tiger moth: big dusk fuzzy head, swept-up pointed orange forewings with
-- black tiger chevrons and cream spots, flame hindwings, feathery antennae and a
-- tiny gold temple roof as a crown. Gold stitched hem along the forewing edge.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-csa-3-lair-temple-of-the-tiger-moth"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function mir(pts)
  local r = {}
  for i, p in ipairs(pts) do r[i] = { 63 - p[1], p[2] } end
  return r
end

local orange = GV.ramp("#f08a24")             -- ember base (Part A)
local flame  = GV.R.flame
local gold   = GV.R.gold
local fur    = GV.R.dusk
local ruff   = GV.R.cream

-- forewings: swept-up sails with hooked pointed tips (claw-like, boss menace)
local fwL = { {30,26},{23,18},{14,11},{9,7},{7,8},{7,16},{9,24},{12,31},{17,36},{23,39},{29,39},{31,36} }
local fw = c:poly(fwL):add(c:poly(mir(fwL)))
-- hindwings: rounded flame lobes with a short spur, under the forewings
local hw = c:ellipse(19.5, 45, 9, 7):add(c:ellipse(43.5, 45, 9, 7))
hw:add(c:poly({ {12,47},{9,54},{17,51} })):add(c:poly(mir({ {12,47},{9,54},{17,51} })))
-- abdomen: striped orange, peeks out below the head
local body = c:ellipse(31.5, 46, 5, 9)
-- fuzzy chibi head
local head = c:ellipse(31.5, 30, 10.5, 8.5)
-- cream fur ruff (collar) between head and body
local collar = c:ellipse(31.5, 38, 8, 3)

-- feathery antennae: narrow fern leaves sweeping up and out
local antPts = { {27,22},{22,16},{17,10},{14,6},{18,5},{22,9},{26,15},{30,21} }
local ant = c:poly(antPts):add(c:poly(mir(antPts)))
-- temple roof crown: ridge finial, upturned eaves, red lintel
local roof = c:ascii({
  "........##........",
  ".......####.......",
  "#....########....#",
  "##.############.##",
  "##################",
  ".################.",
  "...############...",
  "....##########....",
}, 23, 14)

local p = c:build{
  { "ant",    ant,    fur, { flat = true } },
  { "hw",     hw,     flame },
  { "fw",     fw,     orange, { light = fw } },
  { "body",   body,   orange },
  { "collar", collar, ruff, { gloss = false } },
  { "head",   head,   fur },
  { "roof",   roof,   gold, { flat = true } },
}

-- antenna shafts (feathery leaf with a dark rib)
local SH = "#7b66b4"
c:fill(c:line({ {28,21},{23,15},{19,10},{16,6} }, 1):clip(p.ant.m), SH)
c:fill(c:line({ {35,21},{40,15},{44,10},{47,6} }, 1):clip(p.ant.m), SH)
-- roof ridge tiles and gloss
c:fill(c:rect(25, 18, 38, 18):clip(roof), "#b8661a")
c:px(31, 14, "#fff1c8"); c:px(30, 15, "#fff1c8"); c:px(27, 16, "#fff1c8")
-- red lintel under the eaves
c:fill(c:rect(26, 20, 37, 21):clip(roof), "#ae2a2a")
c:fill(c:rect(27, 21, 36, 21):clip(roof), "#6b1b2c")

-- tiger stripes: tapered black-plum wedges from the outer edge toward the body
local ST = "#35161f"
local keep = fw:copy():cut(head:grow(1)):cut(collar:grow(1)):shrink(1)
local function wedge(pts)
  c:fill(c:poly(pts):clip(keep), ST)
  c:fill(c:poly(mir(pts)):clip(keep), ST)
end
wedge({ {6,11},{6,18},{20,20} })
wedge({ {7,22},{9,29},{22,28} })
wedge({ {11,31},{15,37},{26,35} })
wedge({ {13,8},{18,11},{21,20} })
-- cream spots between the stripes (diamonds)
local CR = "#f8eed2"
local function cspot(x, y)
  c:paint({ ".c.", "ccc", ".c." }, x, y, { c = CR })
  c:paint({ ".c.", "ccc", ".c." }, 61 - x, y, { c = CR })
end
cspot(10, 18); cspot(13, 28); cspot(19, 32); cspot(18, 14)

-- hindwing spots (beans)
c:spot(c:ellipse(15, 44, 1.5, 1)); c:spot(c:ellipse(21, 48, 1.5, 1))
c:spot(c:ellipse(48, 44, 1.5, 1)); c:spot(c:ellipse(42, 48, 1.5, 1))
-- abdomen bands
for _, y in ipairs({ 44, 48, 52 }) do c:fill(c:rect(27, y, 36, y):clip(p.body.m):cut(collar:grow(1)), ST) end

-- gold stitched hem along the forewing trailing edge
c:seam({ {10,30},{14,34},{20,37},{27,37} })
c:seam({ {53,30},{49,34},{43,37},{36,37} })
-- collar seam with a button at its head
c:seam({ {25,38},{38,38} })
c:button(30, 37)

-- face: wide locked eyes, angry brows, small frown
c:eye(23, 28); c:eye(35, 28)
c:paint({ "bb....", ".bbbb.", "....bb" }, 22, 25, { b = "#a894dc" })
c:paint({ "....bb", ".bbbb.", "bb...." }, 36, 25, { b = "#a894dc" })
c:paint({ ".uu.", "u..u" }, 30, 34, { u = "#a894dc" })

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
