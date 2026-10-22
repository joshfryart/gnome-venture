local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local fur = GV.ramp("#dcb06a")
local petal = GV.ramp("#e46a9b")

-- ears
local earL = c:ellipse(22, 34, 11, 11)
local earR = c:ellipse(58, 34, 11, 11)
-- body
local body = c:ellipse(40, 100, 33, 24):clip(c:rect(0, 76, 79, 99))
-- head
local head = c:ellipse(40, 54, 21, 18)
-- muzzle
local muz = c:ellipse(40, 63, 12, 8)
-- petal cap: dome with scalloped petal lobes along the brim
local cap = c:ellipse(40, 41, 20, 12):cut(c:rect(0, 42, 79, 99))
cap:add(c:rrect(19, 38, 61, 43, 2))
for _, x in ipairs({ 23, 31.5, 40, 48.5, 57 }) do cap:add(c:ellipse(x, 44, 4, 2.5)) end
cap:add(c:ellipse(40, 27, 3, 3)) -- bud stalk base merges

local p = c:build{
  { "earL", earL, fur },
  { "earR", earR, fur },
  { "body", body, "water" },
  { "head", head, fur },
  { "muz",  muz,  GV.ramp("#f8eed2"), { pale = true } },
  { "cap",  cap,  petal },
}
-- inner ears (pink lining, visible beside the cap)
c:part(c:ellipse(21, 32, 7, 7):cut(cap), "petal", { flat = true })
c:part(c:ellipse(59, 32, 7, 7):cut(cap), "petal", { flat = true })

-- collar V
c:part(c:line({ { 30, 78 }, { 40, 89 }, { 50, 78 } }, 3), GV.ramp("#256a80"), { flat = true })

-- leaf and bud on the cap
c:part(c:poly({ { 43, 31 }, { 50, 26 }, { 57, 25 }, { 53, 31 }, { 46, 33 } }), GV.ramp("#9c2a1e"), { flat = true })
c:part(c:ellipse(40, 26, 3.5, 3.5), GV.ramp("#9c2a1e"), { gloss = { 38, 24 } })

-- brim seam
c:seam({ { 21, 41 }, { 59, 41 } })
c:button(38, 77)

-- nose
c:part(c:ellipse(40, 59.5, 3.5, 2.5), GV.ramp("#d9667f"), { flat = true })
-- eyes
c:eye(29, 49); c:eye(46, 49)
-- smile
c:paint({ "m.....m", ".mm.mm.", "...m..." }, 37, 64, { m = "#4a2c1a" })
-- whiskers
c:paint({ "w.........", ".www......", "....www..." }, 17, 61, { w = "#4a2c1a" })
c:paint({ ".........w", "......www.", "...www...." }, 53, 61, { w = "#4a2c1a" })

local t = c:save(O .. "aseprite/ph/npc-petalpin-greenfinger.aseprite", O .. "png/ph/npc-petalpin-greenfinger.png")
print(GV.report(t))
