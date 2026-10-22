local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local arch = c:ellipse(32, 35, 17, 24):cut(c:ellipse(32, 35, 13, 20)):cut(c:rect(0, 36, 63, 63))
local body = c:poly({ {12,36}, {53,36}, {48,58}, {17,58} })
local whole = body:copy():add(arch)
local p = c:build{
  { "handle", arch, GV.ramp("#d9a660"), { gloss = false } },
  { "body", body, "wood", { light = whole } },
  { "rim", c:rrect(10,32,54,38,2), GV.ramp("#8a4f2a"), { gloss = { 12, 33 } } },
  { "knot", c:ellipse(24,34,4), GV.ramp("#a8582f") },
}
local band1 = c:poly({ {13,42}, {52,42}, {51,45}, {14,45} })
local band2 = c:poly({ {15,50}, {50,50}, {49,53}, {16,53} })
c:fill(band1, "#e8a317"); c:fill(band2, "#e8a317")
c:fill(c:rect(14,42,51,42), "#f5cf6a"); c:fill(c:rect(15,50,49,50), "#f5cf6a")
for x = 15, 50, 6 do c:px(x, 47, "#5e2f1e"); c:px(x + 3, 55, "#5e2f1e") end
for x = 18, 48, 6 do c:px(x, 39, "#5e2f1e") end
local t = c:save(O .. "aseprite/ph/woven-basket.aseprite", O .. "png/ph/woven-basket.png")
print(GV.report(t))
