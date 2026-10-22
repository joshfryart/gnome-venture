local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local podA, podB = GV.ramp("#3f93b2"), GV.ramp("#256a80")
c:build{
  { "base", c:rrect(12, 22, 52, 56, 3), "stone" },
  { "lid", c:rrect(11, 11, 53, 24, 3), GV.ramp("#c9c5bc") },
  { "hinge", c:rect(47, 21, 53, 26), GV.ramp("#5b6470"), { flat = true } },
  { "frame", c:rrect(16, 27, 48, 54, 2), podA, { flat = true } },
  { "card", c:rect(18, 29, 46, 52), GV.ramp("#f4f0e0"), { flat = true, contact = false } },
}
c:fill(c:rect(31, 30, 32, 51), "#2e5a2c")
local function pod(cx, cy, r, tilt)
  local m = c:poly({ {cx - 2 + tilt, cy - 5}, {cx + 3 + tilt, cy - 5}, {cx + 4, cy}, {cx + 3 - tilt, cy + 5}, {cx - 2 - tilt, cy + 5}, {cx - 3, cy} })
  m:add(c:ellipse(cx + 0.5, cy, 3.5, 4.5))
  c:part(m, r, { flat = true, contact = false })
end
pod(31, 34, podA, 0)
for _, y in ipairs({ 40, 46 }) do
  pod(24, y, podA, -1)
  pod(38, y, podB, 1)
end
c:part(c:ellipse(28.5, 51, 2.5, 1.5), GV.ramp("#58a03e"), { flat = true, contact = false })
-- tin details
c:seam({ {13, 24}, {51, 24} })
c:button(30, 22)
c:fill(c:rect(15, 14, 15, 18), "#ece8de")
local t = c:save(D .. "img-redraw-full/aseprite/ph/sesame-seed.aseprite", D .. "img-redraw-full/png/ph/sesame-seed.png")
print(GV.report(t))
