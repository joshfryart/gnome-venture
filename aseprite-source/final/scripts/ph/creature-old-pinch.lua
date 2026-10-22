local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local legR = GV.ramp("#b79775")
local shellR = GV.ramp("#8f7060")
local plateR = GV.ramp("#a38f80")
local creamR = GV.ramp("#f8eed2")
-- legs: splayed fan
local legsL = c:line({ {20, 38}, {15, 45}, {13, 48} }, 4):add(c:line({ {27, 41}, {24, 50} }, 4))
local legsR = c:line({ {44, 38}, {49, 45}, {51, 48} }, 4):add(c:line({ {37, 41}, {40, 50} }, 4))
legsL:add(legsR)
-- claws: arm + open pincer with V notch
local function claw(sx)
  local function X(x) return sx < 0 and x or 63 - x end
  local arm = c:line({ {X(17), 31}, {X(14), 26}, {X(13), 23} }, 4)
  local pin = c:ellipse(X(12), 19, 6, 5.5)
  pin:cut(c:poly({ {X(11), 12}, {X(17), 12}, {X(19), 15}, {X(12.5), 20} }))
  pin:add(arm)
  return pin
end
local clawL, clawR = claw(-1), claw(1)
local shell = c:ellipse(31.5, 35, 18, 11)
local plate = c:ellipse(31.5, 30, 13, 5.5)
local mouth = c:ellipse(31.5, 37.5, 3.5, 3)
local p = c:build{
  { "legs", legsL, legR },
  { "clawL", clawL, shellR },
  { "clawR", clawR, shellR },
  { "shell", shell, shellR, { stitch = { side = "lit" } } },
  { "plate", plate, plateR },
  { "mouth", mouth, creamR, { gloss = false, pale = true } },
}
-- cream ticks on claws
c:paint({ "c..", ".c.", "..c" }, 8, 20, { c = "#e6d2ae" })
c:paint({ "..c", ".c.", "c.." }, 53, 20, { c = "#e6d2ae" })
-- mouth hole
c:paint({ "h...h", ".hhh." }, 30, 37, { h = "#2a1a10" })
-- seam along shell rim
c:seam({ {16, 39}, {22, 42}, {31, 43}, {41, 42}, {47, 39} })
c:eye(23, 26); c:eye(36, 26)
c:ground(31.5, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-old-pinch.aseprite", O .. "png/ph/creature-old-pinch.png")
print(GV.report(t))
