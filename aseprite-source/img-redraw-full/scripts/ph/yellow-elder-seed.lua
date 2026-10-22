local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin = GV.ramp("#a5663a", { rim = "#d9a660" })
local lidR = GV.ramp("#dcb06a")
local under = GV.ramp("#8a4f2a")
-- open lid tilted back: underside visible, then outer lid edge above
local lid = c:poly({ {16, 12}, {48, 12}, {51, 31}, {13, 31} })
local lidIn = c:poly({ {18, 18}, {46, 18}, {48, 31}, {16, 31} })
local p = c:build{
  { "lid", lid, lidR },
  { "under", lidIn, under, { gloss = false, rim = false } },
}
-- yellow elder flower clusters bulging out
local fl = GV.ramp("#f5cf6a", { shade = "#e8a317", deep = "#b8661a" })
local fm = c:ellipse(22, 30, 4, 3.5)
fm:add(c:ellipse(29.5, 27, 4, 4)); fm:add(c:ellipse(38, 28, 4, 3.5)); fm:add(c:ellipse(45, 31, 3.5, 3))
fm:add(c:ellipse(34, 23.5, 3.5, 3.5)); fm:add(c:rect(19, 30, 48, 34))
c:part(fm, fl)
-- flower centres
for _, q in ipairs({ {22, 30}, {29, 27}, {38, 28}, {45, 31}, {34, 23} }) do
  local x, y = q[1], q[2]
  c:px(x, y, "#b8661a"); c:px(x - 1, y, "#fff1c8"); c:px(x + 1, y, "#fff1c8"); c:px(x, y - 1, "#fff1c8"); c:px(x, y + 1, "#fff1c8")
end
-- box body
local box = c:part(c:rrect(12, 33, 52, 54, 3), tin)
c:seam({ {14, 36}, {50, 36} })
-- hinges
c:part(c:rect(14, 30, 18, 34), "#5e2f1e", { flat = true })
c:part(c:rect(46, 30, 50, 34), "#5e2f1e", { flat = true })
-- front latch
c:part(c:rrect(29, 41, 34, 46, 1), "gold")
c:px(31, 43, "#8a4a1c"); c:px(32, 44, "#8a4a1c")
-- seed pips peeking at the rim
c:paint({ "s..s..s.s", }, 24, 34, { s = "#5a3008" })
c:ground(32, 56, 19, 1.5)
local t = c:save(O .. "aseprite/ph/yellow-elder-seed.aseprite", O .. "png/ph/yellow-elder-seed.png")
print(GV.report(t))
