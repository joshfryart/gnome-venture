-- ph/wattle-fence-cross : plus-shaped woven wattle crossing with a dark round hub post
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

local wood = GV.ramp("#a5663a")   -- wood family
local post = GV.ramp("#44281c")   -- wood family, deep

-- one combined plus mask so the junction reads as one woven rail on top
local plus = c:rrect(9, 27, 55, 36, 1):add(c:rrect(27, 9, 36, 55, 1))
c:build{
  { "rails", plus, wood, { gloss = { 14, 29 } } },
}

-- woven ticks: dark diagonal strokes with light twins, along each arm
local dark, lite = "#5e2f1e", "#dcb06a"
local function hticks(x)   -- on the horizontal rail, 4 wide x 7 tall
  c:fill(c:line({ {x, 29}, {x + 3, 34} }, 1), dark)
  c:fill(c:line({ {x + 1, 29}, {x + 4, 34} }, 1), dark)
end
local function htwin(x)
  c:fill(c:line({ {x, 29}, {x + 3, 34} }, 1), lite)
end
local function vticks(y)
  c:fill(c:line({ {29, y}, {34, y + 3} }, 1), dark)
  c:fill(c:line({ {29, y + 1}, {34, y + 4} }, 1), dark)
end
local function vtwin(y)
  c:fill(c:line({ {29, y}, {34, y + 3} }, 1), lite)
end
for _, x in ipairs({ 12, 44 }) do hticks(x) end
for _, x in ipairs({ 19, 51 }) do htwin(x) end
for _, y in ipairs({ 12, 44 }) do vticks(y) end
for _, y in ipairs({ 19, 51 }) do vtwin(y) end

-- centre post
c:build{
  { "post", c:ellipse(31.5, 31.5, 5.5, 5.5), post, { gloss = { 29, 29 } } },
}
c:fill(c:ellipse(30, 30, 1.5, 1.5), "#a5663a")
c:px(29, 29, "#dcb06a")

local t = c:save(O .. "aseprite/ph/wattle-fence-cross.aseprite", O .. "png/ph/wattle-fence-cross.png")
print(GV.report(t))
