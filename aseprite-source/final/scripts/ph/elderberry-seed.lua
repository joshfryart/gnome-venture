local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#c8ecdc", { rim = "#8fcbd8" })
local jar = c:rrect(15, 21, 48, 54, 8)
local neck = c:rect(22, 14, 41, 22)

local p = c:build{
  { "neck", neck, glass, { gloss = false } },
  { "jar",  jar,  glass },
  { "cork", c:rrect(21, 6, 42, 15, 2), GV.ramp("#d9a660", { shade = "#a8582f" }) },
}
-- lip ring of the jar mouth
c:fill(c:rect(22, 16, 41, 17), glass.shade)

-- stem + leaf
c:part(c:line({ {31, 32}, {31, 26} }, 2), "#2e5a2c", { flat = true })
c:part(c:ellipse(36, 26, 3.5, 2), GV.ramp("#58a03e"), { flat = true })
-- berry cluster (darker than jar)
local A, B = GV.ramp("#4e3a8a"), GV.ramp("#3e2f66")
local berries = { {31.5, 35, A}, {26, 40, B}, {38, 40, A}, {22, 47, A}, {32, 46, B}, {42, 47, B}, {27, 50, B}, {37, 51, A} }
for _, b in ipairs(berries) do
  c:part(c:ellipse(b[1], b[2], 4, 4), b[3], { gloss = false, contour = "#2a1a10" })
  c:px(math.floor(b[1]) - 1, b[2] - 2, A.gloss)
end
-- glass streak (lit side)
c:fill(c:rect(18, 27, 19, 40), "#f1fbf4")
c:fill(c:rect(18, 43, 19, 45), "#f1fbf4")
c:seam({ {22, 15}, {41, 15} })
c:ground(31.5, 56, 16, 1.5)
local t = c:save(O .. "aseprite/ph/elderberry-seed.aseprite", O .. "png/ph/elderberry-seed.png")
print(GV.report(t))
