local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local foot = c:rrect(22, 51, 41, 56, 1)
local body = c:ellipse(31.5, 40, 20, 13.5)
local lid = c:ellipse(31.5, 28, 16, 10):cut(c:rect(0, 28, 63, 63))
local band = c:rrect(14, 26, 49, 30, 1)
local knob = c:ellipse(31.5, 16, 3.5, 3)
local p = c:build{
  { "foot", foot, "wood", { gloss = false } },
  { "body", body, "#f1ece0", { gloss = { 17, 36 } } },
  { "knob", knob, "#5e2f1e", { gloss = { 30, 15 } } },
  { "lid", lid, "#d9a660", { gloss = { 22, 21 } } },
  { "band", band, "#8a4f2a", { gloss = false } },
}
-- vanilla pod: diagonal pill, dark lower edge
local pod = c:line({ {21,47},{39,35} }, 5):clip(p.body.m:shrink(2))
c:fill(pod, "#8c4a1a")
c:fill(pod:copy():cut(pod:shift(-1, -1)), "#44281c")
c:fill(pod:copy():cut(pod:shift(1, 1)):clip(pod), "#b07a45")
-- pod cap (green stem end)
c:fill(c:rrect(40, 33, 43, 36, 1):clip(p.body.m:shrink(2)), "#2e5a2c")
c:px(41, 33, "#58a03e")
-- seeds speckles on pod
c:px(28, 43, "#44281c"); c:px(32, 40, "#44281c"); c:px(36, 38, "#44281c")
c:seam({ {16, 28}, {47, 28} }, { free = true })
c:button(29, 26)
local t = c:save(O .. "aseprite/ph/vanilla-seed.aseprite", O .. "png/ph/vanilla-seed.png")
print(GV.report(t))
