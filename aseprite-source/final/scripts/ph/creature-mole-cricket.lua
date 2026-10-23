-- creature-mole-cricket: a velvety soil-brown cricket bursting up out of a dirt mound,
-- front view, two broad toothed shovel claws raised either side of its hooded face.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local velvet = GV.ramp("#9a6b3f")   -- soil family: hood / pronotum (main colour)
local face   = GV.ramp("#c9a96e")   -- soil family: pale velvet face
local shovel = GV.ramp("#9a6b3f")   -- soil family: velvet shovel claws, same as the hood
local earth  = GV.ramp("#7a4a1f")   -- soil family: the mound it breaks through
local legR   = GV.ramp("#3d2a1c")

local function mir(pts) local r = {} for i, p in ipairs(pts) do r[i] = { 63 - p[1], p[2] } end return r end
local function mmask(m) local o = c:mask(); m:each(function(x, y) o:set(63 - x, y) end); return o end

-- shovel claw: a broad spade palm with four blunt digging fingers, gripping the rim of the hole
local function claw()
  return c:ascii({
    "x...x...x...x.....",
    "xx..xx..xx..xx....",
    ".xxx.xxx.xxx.xxx..",
    ".xxx.xxx.xxx.xxx..",
    "..xxx.xxx.xxx.xxx.",
    "..xxx.xxx.xxx.xxx.",
    "..xxxxxxxxxxxxxxxx",
    "..xxxxxxxxxxxxxxxx",
    "..xxxxxxxxxxxxxxxx",
    "..xxxxxxxxxxxxxxxx",
    "...xxxxxxxxxxxxxxx",
    "....xxxxxxxxxxxxx.",
    "......xxxxxxxxxx..",
    ".........xxxxx....",
  }, 7, 36)
end
local clawL = claw()
local clawR = mmask(clawL)

-- antennae: short, swept out from the hood crown, 4x4 clubs
c:limb({ {25, 20}, {21, 15}, {17, 13} })
c:limb(mir{ {25, 20}, {21, 15}, {17, 13} })

local mound = c:ellipse(31.5, 56, 24, 11):cut(c:rect(0, 57, 63, 90))
local head  = c:ellipse(31.5, 37, 11.5, 9.5)
local hood  = c:ellipse(31.5, 27, 13, 10):cut(c:rect(0, 32, 63, 63))
hood:add(c:rrect(18, 26, 45, 32, 3))

local p = c:build{
  { "clubL", c:rrect(14, 10, 17, 13, 1), legR, { flat = true } },
  { "clubR", c:rrect(46, 10, 49, 13, 1), legR, { flat = true } },
  { "head",  head, face, { light = head:copy():add(hood) } },
  { "hood",  hood, velvet },
  { "mound", mound, earth },
  { "clawL", clawL, shovel, { gloss = { 8, 39 } } },
  { "clawR", clawR, shovel, { gloss = { 46, 39 } } },
}

-- medial seam down the pronotum with a button at its crown
c:seam({ {31, 22}, {31, 31} })
c:button(30, 18)
-- face: locked eyes under the hood brim, little mandibles
c:eye(23, 34); c:eye(36, 34)
c:paint({ "m.....m", ".mm.mm.", ".m...m." }, 28, 41, { m = "#2a1a10" })
-- loose clods of dark earth on the mound
c:spot(c:ellipse(25.5, 50, 1.5, 1))
c:spot(c:ellipse(38, 52, 1.5, 1))
c:spot(c:ellipse(17, 53, 1, 1))

local t = c:save(D .. "final/aseprite/ph/creature-mole-cricket.aseprite", PNG .. "creature-mole-cricket.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
