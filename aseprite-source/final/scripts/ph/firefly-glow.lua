local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- wings: tilted rounded lobes (upper big, lower small)
local lw = c:ellipse(19, 24, 12, 11):add(c:ellipse(22, 37, 8, 6))
local rw = c:ellipse(44, 24, 12, 11):add(c:ellipse(41, 37, 8, 6))
local body = c:rrect(28, 22, 35, 44, 3)
local tail = c:ellipse(31.5, 46, 5, 6)
local head = c:ellipse(31.5, 18, 6, 5)

c:limb({ { 29, 15 }, { 26, 10 }, { 24, 8 } })
c:limb({ { 34, 15 }, { 37, 10 }, { 39, 8 } })
local W = GV.ramp("#3f93b2")
c:build{
  { "lwing", lw,   W },
  { "rwing", rw,   W },
  { "body",  body, GV.R.leg },
  { "tail",  tail, GV.ramp("#fff1c8", { rim = "#f5cf6a", shade = "#f5cf6a", deep = "#e8a317", bounce = "#f5cf6a" }) },
  { "head",  head, "dusk" },
}
-- antenna clubs
c:paint({ ".cc.", "cccc", "cccc", ".cc." }, 22, 5, { c = "#54447f" })
c:paint({ ".cc.", "cccc", "cccc", ".cc." }, 38, 5, { c = "#54447f" })
c:px(23, 5, "#7b66b4"); c:px(39, 5, "#7b66b4")
-- wing veins
local V = "#8fcbd8"
c:fill(c:line({ { 26, 26 }, { 18, 22 }, { 12, 22 } }, 1):clip(lw:shrink(2)), V)
c:fill(c:line({ { 26, 30 }, { 18, 30 } }, 1):clip(lw:shrink(2)), V)
c:fill(c:line({ { 37, 26 }, { 45, 22 }, { 51, 22 } }, 1):clip(rw:shrink(2)), V)
c:fill(c:line({ { 37, 30 }, { 45, 30 } }, 1):clip(rw:shrink(2)), V)
-- body segment bands
c:fill(c:rect(29, 30, 34, 30), "#3e2f66"); c:fill(c:rect(29, 35, 34, 35), "#3e2f66")
-- eyes
c:eye(28, 16, true); c:eye(33, 16, true)
local t = c:save(D .. "img-redraw-full/aseprite/ph/firefly-glow.aseprite", D .. "img-redraw-full/png/ph/firefly-glow.png")
print(GV.report(t))
