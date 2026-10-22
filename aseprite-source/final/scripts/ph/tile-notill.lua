local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

-- soil fill
c:fill(c:rect(0, 0, 63, 63), "#44281c")

-- soft dark flecks
for _, f in ipairs({ { 12, 20, 4 }, { 44, 10, 3 }, { 16, 48, 4 }, { 52, 40, 3 }, { 6, 58, 4 }, { 36, 30, 3 }, { 56, 56, 3 }, { 30, 10, 3 } }) do
  c:fill(c:rect(f[1], f[2], f[1] + f[3] - 1, f[2]), "#2a1a10")
end

-- straw mulch dashes; thick ones have a lit top row, thin ones are the darker gold
local L, D = "#f5cf6a", "#e8a317"
local straws = {
  { 20, 46, 29, 43, 2 }, { 48, 4, 60, 5, 1 }, { 26, 18, 35, 19, 2 }, { 4, 39, 15, 40, 1 },
  { 44, 27, 56, 25, 2 }, { 30, 53, 42, 54, 1 }, { 9, 30, 21, 29, 2 }, { 40, 34, 50, 36, 1 },
  { 6, 9, 15, 7, 1 }, { 50, 47, 60, 49, 2 },
}
for _, s in ipairs(straws) do
  if s[5] == 2 then
    c:fill(c:line({ { s[1], s[2] + 1 }, { s[3], s[4] + 1 } }, 1), D)
    c:fill(c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1), L)
  else
    c:fill(c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1), D)
  end
end

-- tiny weed sprouts: two leaves on a stem, lit from the upper left
local sprout = { "g.G", "lgG", ".s." }
for _, p in ipairs({ { 24, 38 }, { 52, 30 }, { 8, 22 }, { 37, 45 }, { 18, 57 }, { 38, 12 } }) do
  c:paint(sprout, p[1], p[2], { l = "#c8d77a", g = "#7ab55c", G = "#4a8a3e", s = "#4a8a3e" })
end

local t = c:save(O .. "aseprite/ph/tile-notill.aseprite", O .. "png/ph/tile-notill.png")
print(GV.report(t))
