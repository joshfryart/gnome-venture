-- creature-withered-aphid : a grey, papery aphid, dried out by blight and mean with it.
-- One shrivelled aphid in 3/4 profile facing left: big grey head, pear abdomen tipped up
-- at the back with two cornicle tubes, crinkled papery edge and crease lines, angry brow,
-- thin bent legs, antennae swept back (one gone limp). Stone family (#8b8f96 head, #c9c5bc paper body).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#c9c5bc")
local head_r = GV.ramp("#8b8f96")
local stalk = GV.ramp("#5b6470")

-- legs (behind body)
c:limb({ {19,44}, {15,48}, {14,53} })
c:limb({ {27,46}, {25,50}, {22,54} })
c:limb({ {36,46}, {39,50}, {38,54} })
c:limb({ {44,44}, {48,48}, {49,53} })

-- antennae: both sweep back over the body like an aphid's; the lower one has gone limp and droops
local antA = c:line({ {13,24}, {13,17}, {18,11}, {26,8} }, 2):add(c:rrect(26, 6, 29, 9, 1))
local antB = c:line({ {22,24}, {25,18}, {31,15}, {35,16}, {37,19} }, 2):add(c:rrect(36, 18, 39, 21, 1))

-- cornicles: two stiff tubes on the raised rump
local corn = c:line({ {45,29}, {47,21} }, 3):add(c:line({ {50,31}, {53,24} }, 3))

-- abdomen: pear, tipped up toward the rump, with a crinkled (shrivelled) top edge
local body = c:ellipse(36, 37, 14, 9.5)
body:add(c:ellipse(46, 33, 7, 6))
body:cut(c:poly({ {28,25}, {34,25}, {31,30} }))
body:cut(c:poly({ {36,25}, {42,25}, {39,30} }))
body:cut(c:poly({ {50,30}, {54,30}, {54,35} }))
body:cut(c:poly({ {48,44}, {52,40}, {52,45} }))

-- head: big, round, slightly squashed
local head = c:ellipse(17, 33, 10.5, 9.5)

local p = c:build{
  { "antA", antA, stalk, { flat = true } },
  { "antB", antB, stalk, { flat = true } },
  { "beak", c:line({ {13,41}, {11,45}, {11,47} }, 2), stalk, { flat = true } },
  { "corn", corn, head_r, { gloss = false } },
  { "body", body, paper },
  { "head", head, head_r },
}

-- creases: dry folds on the paper body (deep line with a lit fold on its upper-left side)
local inner = body:shrink(2):cut(head:grow(1))
local function crease(pts)
  local l = c:line(pts, 1):clip(inner)
  c:fill(l:shift(-1, 0):clip(inner):cut(l), paper.rim)
  c:fill(l, paper.deep)
end
crease({ {33,31}, {35,35}, {34,39}, {35,42} })
crease({ {40,30}, {42,34}, {41,38} })
crease({ {46,32}, {47,36}, {45,40} })

-- stitched join: collar seam where the head is sewn to the body
c:seam({ {27,26}, {29,30}, {29,36}, {28,42} })

-- face: angry brow over locked eyes, sour frown
c:eye(10, 31); c:eye(19, 31)
c:paint({ "aa...", "..aa.", "....a" }, 9, 27, { a = "#2a1a10" })
c:paint({ "...aa", ".aa..", "a...." }, 19, 27, { a = "#2a1a10" })
c:paint({ ".uuu.", "u...u" }, 13, 39, { u = "umber" })

c:ground(32, 55, 18, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-withered-aphid.aseprite", PNG .. "creature-withered-aphid.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
