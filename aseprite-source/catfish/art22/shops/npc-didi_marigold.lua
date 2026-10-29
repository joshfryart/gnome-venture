-- npc-didi_marigold.lua : Didi Marigold, keeper of Spice Bazaar Pets (Spicepeak, CSA). Cat Fish pet shops (art22).
-- A kindly red panda auntie (Himalayan foothills folk), marigold shawl over a teal kurta, a marigold tucked by
-- her ear, hugging a felt yarn ball with a little bell for your cat. 80x100 bust, same build as the ph/npc-* set.
-- Run: AppRun -b --script npc-didi_marigold.lua  -> ../out/npc-didi_marigold.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local RUST  = GV.ramp("#c4572a")   -- red panda fur (ember family)
local DARK  = GV.ramp("#5e2f1e")   -- dark legs / ear backs (wood deep)
local CREAM = "cream"
local KURTA = GV.ramp("#2f8f8a")   -- teal kurta (water family, greener)
local SHAWL = GV.ramp("#e8a317")   -- marigold shawl (gold)
local YARN  = GV.ramp("#e46a9b")   -- petal yarn ball

-- shapes
local back  = c:ellipse(39.5, 46, 35, 35)
local coat  = c:ellipse(39.5, 100, 34, 29)
-- shawl: drapes over both shoulders and falls in a V to the chest
local shawl = c:ellipse(39.5, 100, 34, 29):clip(c:rect(0, 70, 79, 99))
shawl:cut(c:poly({ {19, 100}, {31, 73}, {48, 73}, {60, 100} }))
local earL  = c:poly({ {14, 40}, {16, 24}, {19, 21}, {23, 22}, {31, 34} })
local earR  = c:poly({ {65, 40}, {63, 24}, {60, 21}, {56, 22}, {48, 34} })
local innL  = c:poly({ {18, 36}, {19, 27}, {21, 25}, {26, 33} })
local innR  = c:poly({ {61, 36}, {60, 27}, {58, 25}, {53, 33} })
local head  = c:ellipse(39.5, 51, 23, 19)
-- the red panda's cream lower face: muzzle and cheek ruffs as one felt piece (tear stripes cut it later)
local muzzle = c:ellipse(39.5, 61, 10, 6.5):add(c:ellipse(24, 60, 6.5, 5)):add(c:ellipse(55, 60, 6.5, 5))
muzzle:add(c:rect(24, 58, 55, 62)):clip(c:ellipse(39.5, 51, 22, 19))
local browL = c:rrect(29, 43, 33, 44, 0)
local browR = c:rrect(46, 43, 50, 44, 0)
local nose  = c:ellipse(39.5, 57.5, 3, 2)
local ball  = c:ellipse(39.5, 84, 11, 10)
local pawL  = c:ellipse(28, 88, 4.5, 4)
local pawR  = c:ellipse(51, 88, 4.5, 4)
local bell  = c:ellipse(49.5, 76.5, 4, 4)

local p = c:build{
  { "back",  back,  GV.ramp("#c3b2ea"), { flat = true } },
  { "coat",  coat,  KURTA, { stitch = { side = "lit" } } },
  { "shawl", shawl, SHAWL },
  { "earL",  earL,  DARK, { gloss = false, contact = false } },
  { "earR",  earR,  DARK, { gloss = false, contact = false } },
  { "innL",  innL,  CREAM, { flat = true, contact = false } },
  { "innR",  innR,  CREAM, { flat = true, contact = false } },
  { "head",  head,  RUST, { gloss = { 24, 40 } } },
  { "muzzle", muzzle, CREAM, { gloss = false, light = c:ellipse(39.5, 51, 23, 19) } },
  { "browL", browL, CREAM, { flat = true, contact = false, contour = false } },
  { "browR", browR, CREAM, { flat = true, contact = false, contour = false } },
  { "nose",  nose,  GV.ramp("#4a2c1a"), { gloss = { 38, 57 }, contact = false } },
  { "ball",  ball,  YARN, { gloss = { 33, 81 } } },
  { "bell",  bell,  "gold", { gloss = { 47, 77 }, contact = false } },
  { "pawL",  pawL,  DARK, { gloss = false } },
  { "pawR",  pawR,  DARK, { gloss = false } },
}

-- tear marks: the red panda's rust stripe from each eye down through the cream, splitting muzzle from ruff
c:fill(c:line({ { 31, 54 }, { 30, 58 }, { 30, 62 } }, 2):clip(p.muzzle.m), RUST.base)
c:fill(c:line({ { 48, 54 }, { 49, 58 }, { 49, 62 } }, 2):clip(p.muzzle.m), RUST.base)
c:px(30, 63, RUST.shade); c:px(31, 63, RUST.shade); c:px(49, 63, RUST.shade); c:px(50, 63, RUST.shade)

-- yarn wraps on the ball (shade lines, 1 px) and the loose thread curling off to the right
c:fill(c:line({ { 31, 79 }, { 38, 76 }, { 44, 77 } }, 1):clip(p.ball.m):cut(p.bell.m), YARN.shade)
c:fill(c:line({ { 30, 85 }, { 39, 81 }, { 49, 83 } }, 1):clip(p.ball.m), YARN.shade)
c:fill(c:line({ { 33, 91 }, { 40, 88 }, { 47, 90 } }, 1):clip(p.ball.m), YARN.shade)
c:fill(c:line({ { 55, 90 }, { 58, 93 }, { 56, 96 }, { 59, 99 } }, 1), YARN.rim)
-- bell slot
c:fill(c:rect(48, 78, 51, 78), "#7a3a14"); c:px(49, 79, "#7a3a14"); c:px(50, 79, "#7a3a14")

-- toe beans on the paws (cream dots) so they read as hugging hands
for _, q in ipairs({ { 26, 86 }, { 28, 85 }, { 51, 85 }, { 53, 86 } }) do c:px(q[1], q[2], "#e9b98a") end

-- marigold blossom tucked by her right ear (lower-right of the ear, over the head edge)
c:paint({
  "...rrr...",
  ".rroooor.",
  ".roggoor.",
  "rogyygoor",
  "roggyogor",
  "rooggooor",
  ".roooorr.",
  ".rrooorr.",
  "...rrr...",
}, 54, 33, { r = "#b8452f", o = "#f08a24", g = "#f5cf6a", y = "#fff1c8" })

-- shawl: gold thread hem along its inner edges, and a little button pin on the left shoulder
c:seam({ { 30, 75 }, { 21, 98 } })
c:seam({ { 49, 75 }, { 58, 98 } })
c:button(13, 81)
-- kurta neckline
c:fill(c:poly({ { 33, 73 }, { 46, 73 }, { 40, 78 } }):clip(p.coat.m):cut(p.shawl.m):cut(p.ball.m):cut(p.bell.m), KURTA.deep)

-- face
c:fill(c:rect(30, 43, 32, 43):add(c:rect(47, 43, 49, 43)), "#f8eed2")
c:eye(29, 48); c:eye(46, 48)
c:paint({ "u...u", ".uuu." }, 38, 61, { u = "umber" })
c:px(39, 60, "#4a2c1a"); c:px(40, 60, "#4a2c1a")

local t = c:save(OUT .. "npc-didi_marigold.aseprite", OUT .. "npc-didi_marigold.png")
print(GV.report(t))
assert(t.semi == 0)
