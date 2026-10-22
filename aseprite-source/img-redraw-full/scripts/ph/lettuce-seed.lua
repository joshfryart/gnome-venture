local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- crate
local back = c:rect(12, 31, 51, 54)
local slats = { c:rect(12, 31, 51, 36), c:rect(12, 39, 51, 44), c:rect(12, 47, 51, 52) }
-- leaf fan (frilly)
local leaf = c:ellipse(31.5, 19, 8, 14)
leaf:add(c:ellipse(22, 23, 7, 10)); leaf:add(c:ellipse(41, 23, 7, 10))
leaf:add(c:ellipse(17, 26, 4, 5)); leaf:add(c:ellipse(46, 26, 4, 5))
for _, b in ipairs({ {24,12,3}, {39,12,3}, {16,19,3}, {47,19,3}, {31.5,6,3} }) do leaf:add(c:ellipse(b[1], b[2], b[3])) end
leaf = leaf:shift(0, 6); leaf:cut(c:rect(0, 35, 63, 63))
local crate = back:copy()
c:build{
  { "back", back, GV.ramp("#5e2f1e") , { gloss = false } },
  { "s1", slats[1], GV.ramp("#d9a660"), { light = crate } },
  { "s2", slats[2], GV.ramp("#d9a660"), { light = crate } },
  { "s3", slats[3], GV.ramp("#d9a660"), { light = crate } },
  { "pl", c:rect(12, 31, 17, 54), GV.ramp("#a8582f"), { gloss = false } },
  { "pr", c:rect(46, 31, 51, 54), GV.ramp("#a8582f"), { gloss = false } },
  { "leaf", leaf, "moss" },
  { "tag", c:rrect(25, 39, 38, 45, 1), GV.ramp("#7b66b4"), { flat = true } },
}
c:fill(c:line({ {31, 33}, {31, 17} }, 1), "#2f5a2a")
c:fill(c:line({ {29, 32}, {22, 24} }, 1), "#2f5a2a")
c:fill(c:line({ {34, 32}, {41, 24} }, 1), "#2f5a2a")
for _, y in ipairs({ 35, 50 }) do
  c:paint({ "nn", "nn" }, 14, y, { n = "#5e2f1e" }); c:paint({ "nn", "nn" }, 48, y, { n = "#5e2f1e" })
end
c:paint({ "...u", "uuu." }, 29, 41, { u = "#3e2f66" })
local t = c:save(O .. "aseprite/ph/lettuce-seed.aseprite", O .. "png/ph/lettuce-seed.png")
print(GV.report(t))
