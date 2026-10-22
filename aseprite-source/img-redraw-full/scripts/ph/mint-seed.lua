local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#c8ecdc", { rim = "#8fcbd8", pale = false })

local body = c:rrect(17, 22, 46, 52, 7)
local neck = c:rrect(23, 17, 40, 24, 2)
local jar = body:copy():add(neck)
local cork = c:rrect(22, 10, 41, 18, 2)
local leaf = c:poly({ { 24, 42 }, { 26, 36 }, { 31, 31 }, { 38, 28 }, { 40, 29 }, { 38, 35 }, { 33, 40 }, { 27, 43 } })

local p = c:build{
  { "jar",  jar,  glass, { gloss = false } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = false } },
  { "cork", cork, "wood" },
}
-- midrib
c:fill(c:line({ { 26, 41 }, { 31, 36 }, { 38, 30 } }, 1), "#2e5a2c")
-- seeds pile at the base
for _, s in ipairs({ { 23, 47 }, { 28, 48 }, { 33, 47 }, { 38, 48 }, { 26, 44 }, { 31, 44 }, { 36, 44 } }) do
  c:fill(c:rect(s[1], s[2], s[1] + 2, s[2] + 2), "#17361c")
  c:px(s[1], s[2], "#2f5a3a")
end
-- cork pits
c:px(27, 12, "#8a4f2a"); c:px(28, 12, "#8a4f2a"); c:px(35, 14, "#8a4f2a"); c:px(36, 14, "#8a4f2a")
-- vertical glass gloss strip
c:fill(c:rect(20, 27, 21, 38), "#fff3c8")
c:px(20, 41, "#ffffff")
c:seam({ { 23, 17 }, { 40, 17 } })
local t = c:save(O .. "aseprite/ph/mint-seed.aseprite", O .. "png/ph/mint-seed.png")
print(GV.report(t))
