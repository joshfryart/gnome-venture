local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pink = GV.ramp("#e46a9b")
local leafL = c:poly({{30,24},{19,10},{22,7},{27,10},{33,22}})
local leafR = c:poly({{31,22},{38,9},{43,7},{45,11},{34,24}})
local radish = c:ellipse(32, 24, 9.5, 8.5):add(c:poly({{24,26},{40,26},{33,38},{31,38}}))
local p = c:build{
  { "leafL", leafL, "leaf", { cres = 2 } },
  { "leafR", leafR, "leaf", { cres = 2 } },
  { "radish", radish, pink },
  { "rim", c:rect(12, 33, 52, 36), GV.ramp("#8a4f2a"), { gloss = false } },
  { "front", c:rect(12, 36, 52, 56), "wood" },
  { "postL", c:rect(12, 36, 15, 56), GV.ramp("#8a4f2a"), { flat = true } },
  { "postR", c:rect(49, 36, 52, 56), GV.ramp("#8a4f2a"), { flat = true } },
}
-- leaf veins
c:fill(c:line({{27,14},{22,9}}, 1), "#4a8a3e"); c:fill(c:line({{37,14},{42,9}}, 1), "#4a8a3e")
-- slat lines
c:fill(c:rect(16, 42, 48, 43), "#5e2f1e")
c:fill(c:rect(16, 49, 48, 50), "#5e2f1e")
-- nails at the corners
for _, n in ipairs({ {13,38},{50,38},{13,52},{50,52} }) do
  c:paint({ "nn", "nN" }, n[1], n[2], { n = "#ecc58a", N = "#8a4f2a" })
end
-- radish notch ticks
c:px(28, 27, "#ae2a2a"); c:px(29, 28, "#ae2a2a"); c:px(36, 29, "#ae2a2a"); c:px(35, 30, "#ae2a2a")
c:ground(32, 57, 19, 2.5)
local t = c:save(O .. "aseprite/ph/radish-seed.aseprite", O .. "png/ph/radish-seed.png")
print(GV.report(t))
