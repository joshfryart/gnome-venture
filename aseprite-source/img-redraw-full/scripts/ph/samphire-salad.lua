local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R
-- spiky sprig fingers rising from the heap
local sprigA, sprigB = c:mask(), c:mask()
local tips = { {16, 14, 22, sprigA}, {24, 10, 27, sprigB}, {32, 8, 32, sprigA}, {40, 10, 37, sprigB}, {48, 14, 42, sprigA} }
for _, t in ipairs(tips) do
  local x, y, bx = t[1], t[2], t[3]
  t[4]:add(c:line({ {bx, 24}, {(x + bx) // 2, (y + 24) // 2 + 1}, {x, y + 1} }, 3)):add(c:poly({ {x - 1, y + 2}, {x + 1, y - 1}, {x + 2, y + 2} }))
end
local heap = c:ellipse(32, 27, 20, 9):cut(c:rect(0, 30, 63, 63))
local bowl = c:ellipse(32, 29, 24, 21):clip(c:rect(0, 30, 63, 50))
c:build{
  { "heap",  heap, GV.ramp("#a4b86a"), { gloss = false } },
  { "sprA",  sprigA, GV.ramp("#58a03e"), { gloss = false, cres = 2, deep = 1 } },
  { "sprB",  sprigB, "moss", { gloss = false, cres = 2, deep = 1 } },
  { "bowl",  bowl, GV.ramp("#f4f0e0"), { gloss = { 16, 34 } } },
  { "rim",   c:rrect(8, 27, 56, 31, 2), GV.ramp("#d6c9b6"), { gloss = false } },
}
-- croutons
for _, p in ipairs({ { 19, 24 }, { 42, 23 } }) do
  c:paint({ "gga", "gab", "abb" }, p[1], p[2], { g = R.gold.gloss, a = R.gold.base, b = R.gold.shade })
end
-- sprig nodes: tiny joints so they read as jointed samphire
for _, t in ipairs(tips) do c:px((t[1] + t[3]) // 2 + 1, (t[2] + 24) // 2 + 1, "#2f5a2a") end
c:seam({ { 10, 29 }, { 54, 29 } })
local t = c:save(O .. "aseprite/ph/samphire-salad.aseprite", O .. "png/ph/samphire-salad.png")
print(GV.report(t))
