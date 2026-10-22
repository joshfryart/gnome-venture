local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- broad oval leaf with 5 scallops per side
local leaf = c:ellipse(31.5, 30, 17, 19)
for i = 0, 4 do
  local y = 15 + i * 7.5
  local w = math.sqrt(math.max(0, 1 - ((y - 30) / 20) ^ 2)) * 17
  leaf:add(c:ellipse(31.5 - w + 1, y, 4, 4))
  leaf:add(c:ellipse(31.5 + w - 1, y, 4, 4))
  -- notch between waves
  local yn = y + 3.75
  local wn = math.sqrt(math.max(0, 1 - ((yn - 30) / 20) ^ 2)) * 17
  if i < 4 then
    leaf:cut(c:ellipse(31.5 - wn - 1, yn, 2, 1.5))
    leaf:cut(c:ellipse(31.5 + wn + 1, yn, 2, 1.5))
  end
end
leaf:add(c:ellipse(31.5, 11, 4, 2))
leaf:cut(c:rect(0, 47, 63, 63)):add(c:ellipse(31.5, 46, 7, 2))
local stalk = c:rrect(30, 46, 33, 54, 1)

local p = c:build{
  { "stalk", stalk, GV.ramp("#a4b86a") },
  { "leaf", leaf, "moss", { gloss = { 20, 18 } } },
}
-- side veins (2px, up and out from the rib)
local inner = leaf:shrink(3)
for _, y in ipairs({ 22, 30, 38 }) do
  local v = c:line({ {31, y + 6}, {22, y}, {17, y - 3} }, 2)
  v:add(c:line({ {32, y + 6}, {41, y}, {46, y - 3} }, 2))
  c:fill(v:clip(inner), "#a4b86a")
end
-- pale thick midrib base to tip
local rib = c:rect(30, 12, 32, 50)
rib:add(c:rect(29, 40, 33, 50))
c:fill(rib:clip(leaf:copy():add(stalk)), "#c8d77a")
c:fill(c:rect(32, 12, 32, 50):clip(leaf), "#a4b86a")

local t = c:save(O .. "aseprite/ph/collard.aseprite", O .. "png/ph/collard.png")
print(GV.report(t))
