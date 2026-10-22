local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f1ece0")
-- pouch body: plump round bottom, narrowing to a neck
local body = c:ellipse(31.5, 40, 16, 13)
body:add(c:poly({ {24, 22}, {40, 22}, {44, 32}, {20, 32} }))
-- gathered ruffle: flared lip with three bumps
local ruf = c:poly({ {20, 17}, {44, 17}, {38, 25}, {26, 25} })
ruf:add(c:ellipse(24, 17, 4, 3)); ruf:add(c:ellipse(31.5, 15, 4, 3)); ruf:add(c:ellipse(39, 17, 4, 3))
-- pennant tag and its cord
local cord = c:line({ {38, 24}, {43, 19} }, 2)
local tag = c:poly({ {45, 10}, {52, 20}, {40, 20} })
local p = c:build{
  { "cord", cord, "gold", { flat = true } },
  { "tag", tag, GV.ramp("#2e5a2c"), { gloss = false } },
  { "body", body, cloth, { stitch = { side = "lit" } } },
  { "ruffle", ruf, cloth, { gloss = {23, 16} } },
  { "band", c:rect(24, 24, 39, 26), "petal", { flat = true } },
  { "loopL", c:ellipse(27.5, 26, 2.5, 2), "petal", { flat = true } },
  { "loopR", c:ellipse(36, 26, 2.5, 2), "petal", { flat = true } },
  { "endL", c:line({ {29, 28}, {26, 33} }, 2), "petal", { flat = true } },
  { "endR", c:line({ {34, 28}, {37, 34} }, 2), "petal", { flat = true } },
  { "knot", c:rect(30, 25, 33, 28), "petal", { flat = true } },
  { "emblem", c:ellipse(31.5, 43, 7), GV.ramp("#e46a9b", {deep="#a8241f"}) },
  { "stem", c:rect(31, 34, 32, 37), "leaf", { flat = true } },
  { "leaf", c:ellipse(35.5, 35, 2.5, 1.5), GV.ramp("#58a03e"), { flat = true } },
}
-- ruffle fold lines
c:paint({ "f", "f", "f" }, 27, 19, { f = "#dcb06a" })
c:paint({ "f", "f", "f" }, 36, 19, { f = "#dcb06a" })
c:paint({ "f", "f" }, 31, 21, { f = "#dcb06a" })
-- bottom pinch dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 49, x + 1, 50), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/jackfruit-seed.aseprite", O .. "png/ph/jackfruit-seed.png")
print(GV.report(t))
