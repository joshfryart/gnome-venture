local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local mound = c:ellipse(31.5, 49, 22, 8)
local top = c:ellipse(31.5, 46, 17, 4)
local light = mound:copy():add(top)

local parts = {
  { "mound", mound, GV.ramp("#7a4a1f") },
  { "top", top, GV.ramp("#9a6b3f"), { light = light, gloss = false } },
}
-- four young sprouts in a gentle arc, each a round bud with a tiny centre crease
local dark = GV.ramp("#4f9436")
local buds = { {18.5, 39, "moss"}, {27.5, 36, dark}, {36.5, 36, "moss"}, {45.5, 39, dark} }
for i, b in ipairs(buds) do
  local stem = c:rect(math.floor(b[1]), b[2] + 3, math.floor(b[1]) + 1, 46)
  parts[#parts + 1] = { "stem" .. i, stem, "leaf", { flat = true } }
end
for i, b in ipairs(buds) do
  local m = c:ellipse(b[1], b[2], 4, 4)
  parts[#parts + 1] = { "bud" .. i, m, b[3] }
end
c:build(parts)
-- crease line at the top of each bud (two leaves opening)
for _, b in ipairs(buds) do
  local x = math.floor(b[1] + 0.5)
  local y = math.floor(b[2] - 4.5 + 0.5)
  c:px(x, y, GV.R.leaf.deep or "#2f5a2a"); c:px(x, y + 1, GV.R.leaf.deep or "#2f5a2a")
end
-- a few pebbles in the soil
c:px(17, 51, "#c9a96e"); c:px(44, 52, "#c9a96e"); c:px(30, 54, "#c9a96e")

local t = c:save(O .. "aseprite/ph/stage-herb-2.aseprite", O .. "png/ph/stage-herb-2.png")
print(GV.report(t))
