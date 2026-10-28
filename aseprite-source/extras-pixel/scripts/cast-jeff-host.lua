-- Jeff host (Puzzles library header): Jeff v2 body and face, left arm raised in a wave, right arm resting. 64x64 sticker.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local ASE, PNG = D .. "extras-pixel/cast/", "/home/user/gnome-venture/game/assets/img/puzzles/cast/"

local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- body (same shape as jeff-v2): leaning a little, knob up, notch at the bottom
local body = c:poly({ {16, 25}, {45, 22}, {46, 50}, {18, 52} })
body:add(c:rrect(26, 14, 35, 26, 2)); body:add(c:ellipse(30.5, 12, 7.5, 6))
body:cut(c:ellipse(32, 53, 6, 4.5))

-- left arm: raised high, waving (bent at the elbow), open hand
local armL = c:line({ {18, 34}, {12, 28}, {10, 19} }, 4)
armL:add(c:ellipse(9, 15, 3.5, 3.5))                                  -- hand
armL:cut(body:grow(1))
-- right arm: short tab at the side
local armR = c:rrect(44, 36, 52, 42, 2); armR:add(c:ellipse(53, 39, 3, 4))
armR:cut(body:grow(1))

c:build{
  { "armL", armL, GV.ramp("#2cc97c"), { flat = true } },
  { "armR", armR, GV.ramp("#2cc97c"), { flat = true } },
  { "body", body, GV.ramp("#1fb86b"), { stitch = { side = "lit" } } },
}
-- fingers on the waving hand
c:paint({ "u.u" }, 7, 12, { u = "umber" })                         -- finger splits
c:paint({ "g", "g", ".", "g" }, 4, 8, { g = "#f5cf6a" }); c:paint({ "gg" }, 12, 7, { g = "#f5cf6a" })  -- wave ticks
c:button(29, 15)
c:seam({ {21, 47}, {25, 47} }); c:seam({ {39, 47}, {43, 47} })

-- face: jeff-v2 wide eyes, raised brow, big grin with a tooth row
c:eye(20, 28); c:eye(36, 27)
c:paint({ "uuuu" }, 36, 24, { u = "umber" })
c:paint({
  "u.........u",
  ".u.......u.",
  ".uccccccc u",
  "..uuuuuuu..",
}, 25, 38, { u = "umber", c = "#f1ece0" })

local t = c:save(ASE .. "jeff-host.aseprite", PNG .. "jeff-host.png")
print("jeff-host", GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
