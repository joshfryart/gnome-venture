local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local function mx(x) return 79 - x end
local function mpts(p) local r = {} for i, v in ipairs(p) do r[i] = { mx(v[1]), v[2] } end return r end

-- backdrop disc
local disc = c:ellipse(39.5, 50, 33)

-- wings: big upper lobe + smaller lower lobe, mirrored
local function wing(s)
  local f = s and mx or function(x) return x end
  local m = c:ellipse(f(19), 37, 12, 14)
  m:add(c:ellipse(f(21), 61, 9, 9))
  m:add(c:ellipse(f(25), 50, 6, 8))
  return m
end
local wingR = GV.ramp("#c3b2ea", { shade = "#7b66b4" })

-- antennae: stalk + feathered leaf
local stalkL = c:line({ {34, 39}, {30, 31} }, 2)
local leafPts = { {31, 31}, {32, 24}, {29, 18}, {21, 12}, {20, 22}, {25, 29} }
local leafL = c:poly(leafPts)
local stalkR = c:line(mpts({ {34, 39}, {30, 31} }), 2)
local leafR = c:poly(mpts(leafPts))
local antR = GV.ramp("#7a5cc0")

-- coat
local coat = c:ellipse(39.5, 101, 34, 27)
local coatR = GV.ramp("#a38f80", { shade = "#8f7060" })

-- scarf: tail, band, knot
local tail = c:poly({ {45, 80}, {52, 80}, {54, 97}, {44, 97} })
local band = c:line({ {24, 74}, {31, 78}, {39, 80}, {47, 78}, {55, 74} }, 6)
local knot = c:ellipse(48.5, 79, 4, 3.5)

-- face with fur tufts
local face = c:ellipse(39.5, 56, 16, 19)
face:add(c:ellipse(24.5, 61, 3, 3)); face:add(c:ellipse(54.5, 61, 3, 3))
face:add(c:ellipse(27, 68, 3, 3)); face:add(c:ellipse(52, 68, 3, 3))
face:add(c:ellipse(39.5, 37.5, 4, 2.5))

-- headband clipped to the head, 1 px overhang
local hb = c:line({ {23, 47}, {31, 44}, {39, 43}, {40, 43}, {48, 44}, {56, 47} }, 5)
hb:clip(face:grow(1))
local bead = c:ellipse(48.5, 44.5, 2.5)

local gold = "gold"
local p = c:build{
  { "disc",  disc,  "#b8d8d2", { gloss = false, stitch = false } },
  { "wingL", wing(false), wingR, { stitch = { side = "lit" } } },
  { "wingR", wing(true),  wingR, { stitch = { side = "lit" } } },
  { "stalkL", stalkL, antR, { flat = true } },
  { "stalkR", stalkR, antR, { flat = true } },
  { "leafL", leafL, antR },
  { "leafR", leafR, antR },
  { "coat",  coat,  coatR },
  { "tail",  tail,  gold },
  { "band",  band,  gold },
  { "knot",  knot,  gold },
  { "face",  face,  GV.ramp("#f8eed2") },
  { "hb",    hb,    gold, { gloss = false } },
  { "bead",  bead,  GV.ramp("#b07a10"), { gloss = { 47, 43 } } },
}

-- antenna feather ribs
local rib = antR.deep
c:fill(c:line({ {29, 29}, {23, 16} }, 1):clip(leafL), rib)
c:fill(c:line(mpts({ {29, 29}, {23, 16} }), 1):clip(leafR), rib)

-- wing eye-spots and beans
c:eye(14, 34); c:eye(mx(14) - 4, 34)
c:spot(c:ellipse(20, 63, 2, 1.5), "#7b66b4", "#a894dc")
c:spot(c:ellipse(mx(20), 63, 2, 1.5), "#7b66b4", "#a894dc")

-- face
c:eye(32, 51); c:eye(43, 51)
c:paint({ "u...u", ".uuu." }, 37, 61, { u = "umber" })

-- coat button + front seam
c:button(38, 86)
c:seam({ {39, 91}, {39, 99} })

-- scarf tail hem stitch and fringe
c:paint({ "h.hh.hh.h" }, 45, 94, { h = "#8a4a1c" })
for x = 45, 53, 2 do c:px(x, 97, GV.C.hole) end

local t = c:save(O .. "aseprite/ph/npc-nocturne.aseprite", O .. "png/ph/npc-nocturne.png")
print(GV.report(t))
