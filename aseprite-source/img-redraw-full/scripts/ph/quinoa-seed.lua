local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paper = GV.ramp("#f4f0e0", { shade = "#dcb06a" })
local flapR = GV.ramp("#f1ece0", { shade = "#dcb06a" })
local plum = GV.ramp("#7a5cc0")
local p = c:build{
  { "env", c:rrect(21, 6, 43, 55, 2), paper },
  { "flap", c:poly({{21,7},{44,7},{32,25}}), flapR, { cres = 2 } },
  { "seal", c:ellipse(32, 25, 3.5, 3.5), plum },
  { "stalk", c:rect(31, 31, 32, 51), "#2e5a2c", { flat = true } },
  { "g1", c:ellipse(27.5, 34, 2.5, 3), plum, { flat = true } },
  { "g2", c:ellipse(36.5, 37, 2.5, 3), GV.ramp("#4e3a8a"), { flat = true } },
  { "g3", c:ellipse(27.5, 41, 2.5, 3), GV.ramp("#4e3a8a"), { flat = true } },
  { "g4", c:ellipse(36.5, 44, 2.5, 3), plum, { flat = true } },
}
c:paint({ "sss" }, 30, 30, { s = "#4e3a8a" })
-- seal stamp mark
c:px(32, 25, "#4e3a8a"); c:px(31, 24, "#a894dc")
-- address ticks
c:paint({ "ttt.ttt" }, 25, 51, { t = "#dcb06a" })
c:paint({ "ttt" }, 37, 53, { t = "#dcb06a" })
-- thread-gold stitched V along the flap fold
-- fold lines of the V flap
for i = 0, 17 do
  local y = 8 + i
  local xl = 22 + math.floor(i * 10 / 17 + 0.5)
  local xr = 42 - math.floor(i * 10 / 17 + 0.5)
  if y < 22 then c:px(xl, y, "#b07a45"); c:px(xr, y, "#b07a45") end
end
c:seam({ {24,8},{30,18} }, { free = true }); c:seam({ {40,8},{34,18} }, { free = true })
c:ground(32, 57, 13, 2)
local t = c:save(O .. "aseprite/ph/quinoa-seed.aseprite", O .. "png/ph/quinoa-seed.png")
print(GV.report(t))
