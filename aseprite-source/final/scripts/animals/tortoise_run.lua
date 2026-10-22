-- animals/tortoise_run : race-day scene, fence frame, two shells
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

-- sky and back meadow
c:bands(c:rect(0, 0, 63, 63), { "#f6e7c4", "#f2dcae", "#eccf9a", "#e6c288", "#dfb478" }, { dir = "v" })
c:fill(c:ellipse(31.5, 60, 40, 22), "#a4b86a")

local post = c:rect(5, 18, 8, 56):add(c:rect(56, 18, 59, 56))
local rails = c:rect(6, 25, 58, 27):add(c:rect(6, 37, 58, 39))
local mound = c:ellipse(32, 52, 30, 12):cut(c:rect(0, 0, 63, 41)):add(c:rect(0, 55, 63, 63))
local grey = c:ellipse(47.5, 49, 9, 8):cut(c:rect(0, 50, 63, 63)):add(c:rect(39, 49, 56, 50))
local ghead = c:ellipse(57.5, 47, 2.5, 2.5):add(c:rect(55, 47, 58, 49))
local gleg = c:rect(42, 51, 44, 53):add(c:rect(51, 51, 53, 53))
local green = c:ellipse(25.5, 52, 13.5, 12):cut(c:rect(0, 53, 63, 63)):add(c:rect(12, 52, 39, 54))
local head = c:ellipse(42, 50, 3.5, 3.5):add(c:rrect(37, 50, 42, 54, 1))
local legs = c:rect(15, 54, 18, 57):add(c:rect(32, 54, 35, 57))
local arc = c:line({ {9, 34}, {11, 32}, {14, 31}, {17, 32} }, 3)

c:build{
  { "rails", rails, "#b98a55", { gloss = false } },
  { "posts", post, "#9a6b3f", { gloss = false } },
  { "mound", mound, "#7ab55c", { gloss = false } },
  { "gleg", gleg, "#8b8f96", { flat = true } },
  { "ghead", ghead, "#c9c5bc" },
  { "grey", grey, "#8b8f96" },
  { "legs", legs, "#a4b86a", { flat = true } },
  { "green", green, "#6b8f3c" },
  { "head", head, "#a4b86a" },
  { "arc", arc, "#e46a9b", { gloss = false } },
}
-- scute lines
local sc = "#3f5a22"
c:fill(c:line({ {25.5, 42}, {25.5, 53} }, 2), sc)
c:fill(c:line({ {17, 46}, {19, 53} }, 2), sc)
c:fill(c:line({ {34, 46}, {32, 53} }, 2), sc)
c:fill(c:line({ {14, 47}, {37, 47} }, 1):clip(green:shrink(2)), sc)
-- grey shell rings
c:fill(c:line({ {47, 42}, {47, 50} }, 1), "#5b6470")
c:fill(c:line({ {40, 46}, {55, 46} }, 1):clip(grey:shrink(2)), "#5b6470")
-- flower dots on the arc
for _, p in ipairs({ {9, 33}, {13, 31}, {16, 31} }) do c:px(p[1], p[2], "#f6b8cf") end
-- eye
c:eye(41, 48, true)
c:eye(57, 45, true)
-- rail hem stitch
c:seam({ {7, 26}, {57, 26} })
c:seam({ {7, 38}, {57, 38} })

local t = c:save(O .. "aseprite/animals/tortoise_run.aseprite", O .. "png/animals/tortoise_run.png")
print(GV.report(t))
