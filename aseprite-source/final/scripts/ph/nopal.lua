-- ph/nopal : flat cactus paddle with areole grid and a budding baby pad
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

-- main pad: tall oval tapering to a narrow base
local pad = c:ellipse(31.5, 32, 15, 20)
pad:cut(c:poly({ {0, 38}, {17, 38}, {27, 57}, {0, 57} }))
pad:cut(c:poly({ {64, 38}, {46, 38}, {36, 57}, {64, 57} }))
pad:add(c:rrect(27, 46, 36, 55, 2))

-- baby pad budding off the upper right shoulder
local baby = c:ellipse(46, 12, 6, 7)

c:build{
  { "baby", baby, GV.ramp("#a4b86a"), { cres = 3, deep = 1 } },
  { "pad",  pad,  "moss", { gloss = { 21, 19 } } },
}

-- areoles: cream dots with tiny tan spines
local function areole(x, y)
  c:paint({ ".c.", "ccc", ".c." }, x - 1, y - 1, { c = "#f1ece0" })
  c:px(x - 2, y - 2, "#ecc58a"); c:px(x + 2, y - 2, "#ecc58a")
  c:px(x, y + 2, "#c9a96e")
end
for _, p in ipairs({
  {25, 22}, {33, 20}, {40, 24},
  {22, 31}, {31, 30}, {40, 32},
  {26, 39}, {35, 40},
  {31, 48},
}) do areole(p[1], p[2]) end
-- one bud areole on the baby pad
c:paint({ "c" }, 46, 10, { c = "#f1ece0" })
c:px(45, 9, "#ecc58a"); c:px(47, 9, "#ecc58a")

local t = c:save(O .. "aseprite/ph/nopal.aseprite", O .. "png/ph/nopal.png")
print(GV.report(t))
