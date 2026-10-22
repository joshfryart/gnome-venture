local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur   = GV.ramp("#a5663a")
local dark  = GV.ramp("#8c4a1a")
local tan   = GV.ramp("#dcb06a")
local tailR = GV.ramp("#6b3a24")
local tooth = GV.ramp("#f8eed2")
local p = c:build{
  { "tail",  c:rrect(11, 48, 52, 54, 3), tailR },
  { "earL",  c:ellipse(21, 15, 3.5), fur },
  { "earR",  c:ellipse(42, 15, 3.5), fur },
  { "body",  c:ellipse(31.5, 39, 15, 11), fur },
  { "belly", c:ellipse(31.5, 42, 9, 7), tan },
  { "footL", c:ellipse(22.5, 49, 5, 2.5), dark },
  { "footR", c:ellipse(40.5, 49, 5, 2.5), dark },
  { "pawL",  c:ellipse(23, 37, 3, 2.5), dark, { flat = true } },
  { "pawR",  c:ellipse(40, 37, 3, 2.5), dark, { flat = true } },
  { "head",  c:ellipse(31.5, 23, 12.5, 11.5), fur },
  { "muz",   c:ellipse(31.5, 28.5, 7, 4.5), tan },
  { "teeth", c:rect(28, 32, 35, 39), tooth, { gloss = false } },
}
-- inner ears
c:fill(c:ellipse(21, 15, 1.5), "#dcb06a")
c:fill(c:ellipse(42, 15, 1.5), "#dcb06a")
-- nose
c:fill(c:ellipse(31.5, 27, 2.5, 1.5), "#2a1a10")
c:px(30, 26, "#5e2a3a")
-- tooth split and tips
c:fill(c:line({ {31, 33}, {31, 38} }, 1), "#a38f80")
c:fill(c:line({ {32, 33}, {32, 38} }, 1), "#a38f80")
-- tail crosshatch scales
for _, q in ipairs{ {17,50},{21,50},{25,52},{29,50},{33,52},{37,50},{41,52},{45,50},{19,52},{43,52},{23,50},{27,52},{35,50},{39,52},{31,52},{47,52} } do
  if p.tail.m:has(q[1], q[2]) then c:px(q[1], q[2], "#4a2418") end
end
c:eye(22, 18); c:eye(37, 18)
-- brow: bossy
c:ground(31.5, 55, 19, 1.5)
local t = c:save(O .. "aseprite/ph/creature-beaver-foreman.aseprite", O .. "png/ph/creature-beaver-foreman.png")
print(GV.report(t))
