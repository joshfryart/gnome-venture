local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#a5663a")
local stone = GV.ramp("#968f96")
local eave = GV.ramp("#6a6070")
local doorR = GV.ramp("#8c4a1a")
c:build{
  { "walls", c:rect(10, 28, 54, 50), wood },
  { "roof",  c:poly({ {6, 29}, {15, 13}, {49, 13}, {58, 29} }), stone },
  { "eave",  c:rrect(6, 27, 57, 31, 1), eave },
  { "door",  c:rect(25, 35, 39, 50), doorR, { gloss = false } },
}
-- plank lines on walls (outside door)
for _, y in ipairs({ 38, 45 }) do
  for x = 11, 53 do if x < 25 or x > 39 then c:px(x, y, "#5e2f1e") end end
end
-- door X brace + centre post
local br = "#44281c"
c:fill(c:line({ {26, 36}, {38, 49} }, 2), br)
c:fill(c:line({ {38, 36}, {26, 49} }, 2), br)
c:fill(c:rect(31, 36, 33, 49), br)
c:fill(c:rect(26, 36, 38, 37), br)
c:fill(c:rect(26, 48, 38, 49), br)
-- roof shingle rows
for _, y in ipairs({ 17, 22 }) do
  local m = c:rect(6, y, 58, y):clip(c:poly({ {6, 29}, {15, 13}, {49, 13}, {58, 29} }):shrink(2))
  m:each(function(x, yy) if (x % 6) ~= 0 then c:px(x, yy, stone.shade) end end)
end
-- left tool: rake-ish spade
c:part(c:line({ {15, 49}, {13, 35} }, 2), "#5e2f1e", { flat = true })
c:part(c:rrect(10, 33, 16, 38, 1), stone, { flat = true })
-- right tool: hoe
c:part(c:line({ {49, 49}, {51, 34} }, 2), "#5e2f1e", { flat = true })
c:part(c:poly({ {48, 33}, {55, 32}, {54, 38} }), stone, { flat = true })
c:seam({ {8, 29}, {55, 29} })

c:ground(32, 51, 24, 1)
local t = c:save(O .. "aseprite/ph/tool_shed-1.aseprite", O .. "png/ph/tool_shed-1.png")
print(GV.report(t))
