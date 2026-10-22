local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(21, 9, 43, 55, 2)
local flap = c:poly({ {21, 9}, {44, 9}, {32.5, 27} })
local stamp = c:rect(33, 45, 41, 53)
-- fluffy tuft: core disc plus spiky ray tips
local tuft = c:ellipse(32, 27, 5, 5)
for _, d in ipairs({ {0,-7},{6,-4},{7,2},{4,6},{-4,6},{-7,2},{-6,-4} }) do
  tuft:add(c:ellipse(32 + d[1], 27 + d[2], 1.5, 1.5))
end
local p = c:build{
  { "body", body, GV.ramp("#f1ece0"), { cres = 3, deep = 1 } },
  { "flap", flap, GV.ramp("#dcb06a", { rim = "#d9a660" }), { gloss = false } },
  { "stamp", stamp, GV.ramp("#f6b8cf"), { flat = true } },
  { "tuft", tuft, "red", { gloss = { 29, 24 } } },
}
-- stamp border + tiny flower print
c:fill(stamp:copy():cut(c:rect(34, 46, 40, 52)), "#e46a9b")
c:paint({ ".r.", "rgr", ".r." }, 36, 48, { r = "#dd3a2a", g = "#f5cf6a" })
-- address lines
c:fill(c:rect(25, 37, 39, 37), "#c9a96e")
c:fill(c:rect(25, 41, 35, 41), "#c9a96e")
c:fill(c:rect(25, 45, 30, 45), "#c9a96e")
-- flap seams
c:seam({ {23, 11}, {30, 23} })
c:seam({ {42, 11}, {35, 23} })
-- stamens radiating + centre
for _, d in ipairs({ {0,-4},{4,-2},{4,2},{0,4},{-4,2},{-4,-2} }) do
  c:px(32 + d[1], 27 + d[2], "#f5cf6a")
end
c:fill(c:rect(32, 27, 33, 28), "#fff3c8")
local t = c:save(O .. "aseprite/ph/pohutukawa-seed.aseprite", O .. "png/ph/pohutukawa-seed.png")
print(GV.report(t))
