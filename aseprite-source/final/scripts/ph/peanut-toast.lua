local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- bread slice: two dome bumps over square shoulders, flat bottom
local slice = c:rrect(12, 22, 52, 53, 4)
slice:add(c:ellipse(22.5, 20, 10.5, 8))
slice:add(c:ellipse(41.5, 20, 10.5, 8))
slice:add(c:rect(14, 18, 50, 26))
-- bite notch at lower right
local bite = c:ellipse(52, 52, 5.5, 5.5)
slice:cut(bite)

local crumb = slice:shrink(3)
local spread = c:poly({ {17, 27}, {24, 24}, {33, 25}, {41, 23}, {46, 27}, {45, 34}, {47, 40}, {42, 45}, {33, 44}, {25, 47}, {18, 43}, {19, 35} }):closed(2)
spread:clip(crumb:shrink(1))

local p = c:build{
  { "crust",  slice,  "wood" },
  { "crumb",  crumb,  GV.ramp("#e8c58a"), { light = slice } },
  { "spread", spread, GV.ramp("#a8582f", { gloss = "#ecc58a", dot = "#fff3c8", rim = "#d9a660" }), { gloss = { 21, 28 } } },
}

-- crushed peanut beans
local pea = GV.ramp("#ecc58a")
for _, b in ipairs({ { 27, 31 }, { 37, 35 }, { 30, 40 }, { 40, 28 } }) do
  c:paint({ ".ab", "abb", "bc." }, b[1], b[2], { a = pea.gloss, b = pea.base, c = pea.shade })
end
-- crust toast speckles on crumb
c:px(17, 48, "#d9a660"); c:px(43, 48, "#d9a660"); c:px(22, 22, "#d9a660")

local t = c:save(O .. "aseprite/ph/peanut-toast.aseprite", O .. "png/ph/peanut-toast.png")
print(GV.report(t))
