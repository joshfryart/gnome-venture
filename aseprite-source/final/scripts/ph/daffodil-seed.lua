local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- crate body (wood), with slat gaps
local body = c:rrect(12, 16, 51, 50, 2)
c:part(body, "wood")
local gaps = c:rect(13, 27, 50, 28):add(c:rect(13, 38, 50, 39)):clip(body)
c:fill(gaps, "#5e2f1e")
-- diagonal brace across the front
local brace = c:line({ {16, 47}, {47, 20} }, 3):clip(body:shrink(2))
c:part(brace, GV.ramp("#8a4f2a"), { gloss = false, cres = 1, deep = 0 })
-- top rim plank
c:part(c:rrect(10, 11, 53, 18, 2), GV.ramp("#d9a660"), { gloss = { 14, 13 } })
c:fill(c:rect(31, 12, 31, 17), "#8a4f2a")
-- cream label
c:part(c:rrect(22, 24, 41, 45, 3), "cream", { cres = 2, deep = 1 })
-- bulb
c:part(c:rect(31, 28, 32, 32), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:ellipse(35.5, 30.5, 2.5, 1.5), GV.ramp("#58a03e"), { flat = true })
c:part(c:ellipse(31.5, 37.5, 5.5, 5), "petal", { gloss = { 28, 34 } })
c:paint({ "u.u.u" }, 29, 41, { u = "#a8241f" })
-- nails
for _, p in ipairs({ {14, 20}, {49, 20}, {14, 47}, {49, 47}, {14, 32}, {49, 32} }) do
  c:px(p[1], p[2], "#2a1a10")
end
c:ground(31.5, 53, 19, 1.5)
local t = c:save(O .. "aseprite/ph/daffodil-seed.aseprite", O .. "png/ph/daffodil-seed.png")
print(GV.report(t))
