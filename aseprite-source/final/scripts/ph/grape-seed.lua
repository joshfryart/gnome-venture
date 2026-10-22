local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- squat jar with shoulders
local jar = c:rrect(13, 22, 50, 55, 9)
jar:add(c:rrect(18, 19, 45, 26, 4))
local neck = c:rrect(22, 14, 41, 21, 2)
local cork = c:rrect(24, 5, 39, 15, 3)

c:build{
  { "jar", jar, "glass", { gloss = false } },
  { "neck", neck, "glass", { gloss = false } },
  { "cork", cork, GV.ramp("#d9a660"), { gloss = { 27, 7 } } },
}
-- cork grain
c:px(31, 9, "#a8582f"); c:px(35, 12, "#a8582f"); c:px(28, 12, "#a8582f")
-- twine wrap on neck
c:seam({ {22, 18}, {41, 18} })
-- rim band
c:fill(c:rect(18, 22, 45, 23), "#8fcbd8")

-- stem + leaf inside
c:part(c:line({ {31, 26}, {32, 31} }, 2), GV.ramp("#2f5a2a"), { flat = true })
c:part(c:poly({ {33, 27}, {37, 24}, {41, 25}, {38, 29}, {34, 29} }), GV.ramp("#6a9a3a"), { flat = true })
-- grape bunch, back to front
local G = {
  { 26, 34, "#7b66b4" }, { 37, 34, "#3e2f66" },
  { 31.5, 39, "#3e2f66" }, { 24, 42, "#3e2f66" }, { 39, 42, "#7b66b4" },
  { 31.5, 47, "#7b66b4" },
}
for _, g in ipairs(G) do
  c:part(c:ellipse(g[1], g[2], 4.5, 4.5), GV.ramp(g[3]), { gloss = { math.floor(g[1]) - 2, g[2] - 2 }, contact = false })
end
-- glass gloss streak on lit left
c:fill(c:rect(17, 28, 18, 44), "#fff3c8")
c:fill(c:rect(17, 47, 18, 49), "#fff3c8")
c:px(21, 28, "#ffffff")

local t = c:save(O .. "aseprite/ph/grape-seed.aseprite", O .. "png/ph/grape-seed.png")
print(GV.report(t))
