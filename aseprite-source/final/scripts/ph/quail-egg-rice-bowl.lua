local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tall rice dome in a deep round-bottom bowl
local rice = c:ellipse(31.5, 31, 21, 19):clip(c:rect(0, 0, 63, 31))
local bowl = c:ellipse(31.5, 28, 24, 26):clip(c:rect(0, 28, 63, 63))
local p = c:build{
  { "rice", rice, GV.ramp("#f1ece0"), { gloss = { 17, 22 } } },
  { "eggA", c:ellipse(24, 21, 4.5, 6), GV.ramp("#e9d9b8") },
  { "eggB", c:ellipse(37, 18, 5, 6), GV.ramp("#f1ece0"), { gloss = false } },
  { "nori", c:rect(44, 18, 47, 27), GV.ramp("#2f5a2a"), { gloss = false } },
  { "bowl", bowl, GV.ramp("#d6c9b6") },
  { "band", c:rect(8, 28, 55, 31):clip(bowl), GV.ramp("#c9a96e"), { gloss = false, flat = true } },
}
-- rice grain dashes
local grains = { {14, 27}, {18, 25}, {26, 29}, {30, 26}, {41, 27}, {48, 28}, {45, 15}, {23, 15}, {29, 13}, {40, 29}, {12, 30}, {50, 24} }
for _, g in ipairs(grains) do c:px(g[1], g[2], "#fff3c8"); c:px(g[1] + 1, g[2], "#fff3c8") end
-- speckles on egg A
c:px(23, 19, "#7a4a1f"); c:px(26, 21, "#7a4a1f"); c:px(22, 23, "#7a4a1f"); c:px(25, 24, "#7a4a1f"); c:px(24, 26, "#7a4a1f")
-- yolk on halved egg B
c:part(c:ellipse(37, 18.5, 2, 2), "gold", { flat = true })
c:px(36, 17, "#fff1c8")
-- bowl dots and rim seam
for _, x in ipairs({ 20, 30, 40 }) do
  c:paint({ ".d.", "ddd", ".d." }, x, 40, { d = "#f5cf6a" })
end
c:seam({ { 9, 29 }, { 54, 29 } }, { free = false })
local t = c:save(D .. "img-redraw-full/aseprite/ph/quail-egg-rice-bowl.aseprite", D .. "img-redraw-full/png/ph/quail-egg-rice-bowl.png")
print(GV.report(t))
