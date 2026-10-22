local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rect(10, 14, 54, 56)
body:del(10, 14); body:del(11, 14); body:del(10, 15); body:del(54, 14); body:del(53, 14); body:del(54, 15)
local p = c:build{
  { "body", body, "cream" },
  { "flap", c:poly({ {10, 14}, {55, 14}, {32, 31} }), GV.ramp("#e8d8b0"), { gloss = { 20, 16 } } },
  { "win", c:rrect(18, 32, 46, 54, 6), GV.ramp("#d6322b"), { gloss = false, flat = true } },
}
c:part(c:rrect(20, 34, 44, 52, 5), GV.ramp("#f4f0e0"), { flat = true, contour = false, contact = false })
-- berries: pyramid, touching
local light = c:ellipse(32, 42, 13, 10)
local pos = { {32, 37, "red"}, {26.5, 42, "#ae2a2a"}, {37.5, 42, "#ae2a2a"},
              {21, 47.5, "red"}, {32, 47.5, "#ae2a2a"}, {43, 47.5, "red"} }
for i, b in ipairs(pos) do
  local ramp = b[3] == "red" and "red" or GV.ramp(b[3])
  c:part(c:ellipse(b[1], b[2], 3.5, 3.5), ramp, { gloss = { math.floor(b[1]) - 2, math.floor(b[2]) - 2 }, contact = false, rim = true })
end
-- stem and leaf above top berry
c:part(c:rect(31, 30, 32, 33), GV.ramp("#2e5a2a"), { flat = true, contour = false, contact = false })
c:part(c:ellipse(35.5, 31, 2.5, 1.5), GV.ramp("#58a03e"), { flat = true, contour = false, contact = false })
c:seam({ {12, 15}, {32, 30}, {52, 15} })
local t = c:save(O .. "aseprite/ph/gooseberry-seed.aseprite", O .. "png/ph/gooseberry-seed.png")
print(GV.report(t))
