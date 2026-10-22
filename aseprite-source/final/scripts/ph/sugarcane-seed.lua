local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local burlap = GV.ramp("#c9a96e", { shade = "#9a6b3f" })

local cane = c:line({ {33, 31}, {50, 10} }, 7)
local leaf = c:poly({ {50, 9}, {58, 5}, {54, 12} })
local body = c:ellipse(32, 43, 19, 13)
local neck = c:poly({ {23, 32}, {41, 32}, {43, 24}, {21, 24} })
-- scalloped top of the ruffle
neck:add(c:ellipse(23, 24, 2.5, 2)); neck:add(c:ellipse(28, 23, 2.5, 2))
neck:add(c:ellipse(33, 23, 2.5, 2)); neck:add(c:ellipse(38, 23, 2.5, 2)); neck:add(c:ellipse(42, 24, 2, 2))
local string = c:rect(21, 30, 43, 31)
local tailL = c:line({ {24, 31}, {21, 35}, {20, 39} }, 2)
local tailR = c:line({ {40, 31}, {43, 35}, {44, 39} }, 2)
local patch = c:rrect(26, 41, 38, 51, 1)

local p = c:build{
  { "leaf", leaf, "#2f5a2a", { flat = true } },
  { "cane", cane, GV.ramp("#dcb06a", { shade = "#c4925f" }), { gloss = false } },
  { "body", body, burlap, { gloss = { 18, 38 } } },
  { "neck", neck, burlap, { gloss = false } },
  { "patch", patch, GV.ramp("#dcb06a"), { gloss = false } },
  { "string", string, "#8c4a1a", { flat = true } },
  { "tailL", tailL, "#8c4a1a", { flat = true } },
  { "tailR", tailR, "#8c4a1a", { flat = true } },
  { "knotL", c:rect(18, 38, 21, 41), "#8c4a1a", { flat = true } },
  { "knotR", c:rect(43, 38, 46, 41), "#8c4a1a", { flat = true } },
}
c:stitch(p.body.m)
-- cane node bands (perpendicular to the stalk)
for _, n in ipairs({ {39, 23}, {45, 16} }) do
  local x, y = n[1], n[2]
  for i = -3, 3 do
    c:px(x + i, y + i, "#c4925f"); c:px(x + i + 1, y + i, "#c4925f")
  end
end
-- fold lines in the gathered neck
for _, x in ipairs({ 27, 32, 37 }) do
  for y = 25, 29 do c:px(x + ((y % 2 == 0) and 0 or 0), y, "#9a6b3f") end
end
c:seam({ {27, 42}, {37, 42}, {37, 50}, {27, 50}, {27, 42} })
c:button(30, 29)
c:ground(32, 57, 17, 2.5, "#6a4528")
local t = c:save(D .. "img-redraw-full/aseprite/ph/sugarcane-seed.aseprite", D .. "img-redraw-full/png/ph/sugarcane-seed.png")
print(GV.report(t))
