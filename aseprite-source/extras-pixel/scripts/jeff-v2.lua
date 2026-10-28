-- Jeff v2: bright-green jigsaw piece holding up a tiny purple puzzle piece, head tilted, happy. 64x64 sticker.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "extras-pixel/jeff/"

local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- body leaning a little to the left: knob up, notch at the bottom
local body = c:poly({ {16, 25}, {45, 22}, {46, 50}, {18, 52} })
body:add(c:rrect(26, 14, 35, 26, 2)); body:add(c:ellipse(30.5, 12, 7.5, 6))
body:cut(c:ellipse(32, 53, 6, 4.5))                                -- bottom notch

-- left arm: tab out to the side; right arm: bent forward, holding the little piece
local armL = c:rrect(10, 33, 19, 40, 2); armL:add(c:ellipse(10, 36.5, 3, 4.5))
armL:cut(c:rect(17, 26, 63, 63))
local armR = c:line({ {44, 38}, {49, 40}, {51, 43} }, 4)
armR:add(c:ellipse(50, 45, 3, 3))                                  -- hand
armR:cut(body:grow(1))

-- tiny purple puzzle piece, pinched in the right hand
local mini = c:rrect(47, 33, 53, 40, 1)
mini:add(c:ellipse(50, 31, 2.5, 2.5)); mini:add(c:ellipse(54, 36.5, 2, 2))
mini:cut(c:ellipse(50, 41, 2, 2))

c:build{
  { "armL", armL, GV.ramp("#2cc97c"), { flat = true } },
  { "armR", armR, GV.ramp("#2cc97c"), { flat = true } },
  { "body", body, GV.ramp("#1fb86b"), { stitch = { side = "lit" } } },
  { "mini", mini, GV.ramp("#8a5fd0"), { gloss = { 48, 35 } } },
}
c:button(29, 15)
c:seam({ {21, 47}, {25, 47} }); c:seam({ {39, 47}, {43, 47} })

-- face: eyes wide apart, one raised brow, big open grin with a cream tooth row
c:eye(20, 28); c:eye(36, 27)
c:paint({ "uuuu" }, 36, 24, { u = "umber" })                       -- raised brow over the right eye
c:paint({
  "u.........u",
  ".u.......u.",
  ".uccccccc u",
  "..uuuuuuu..",
}, 25, 38, { u = "umber", c = "#f1ece0" })

local t = c:save(OUT .. "jeff-v2.aseprite", OUT .. "jeff-v2.png")
print("jeff-v2", GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
