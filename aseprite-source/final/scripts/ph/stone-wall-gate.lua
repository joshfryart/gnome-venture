local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local rails = c:rect(16, 28, 47, 30):add(c:rect(16, 37, 47, 39))
local pickets = c:mask()
for _, x in ipairs({ 18, 24, 30, 36, 42 }) do
  pickets:add(c:rrect(x, 23, x + 3, 43, 1))
  pickets:add(c:poly({ {x, 24}, {x + 2, 21}, {x + 4, 24} }))
end
local brace = c:line({ {18, 38}, {44, 29} }, 2)
local postL = c:rrect(7, 21, 16, 45, 3)
local postR = c:rrect(47, 21, 56, 45, 3)
local capL = c:rrect(6, 17, 17, 21, 2)
local capR = c:rrect(46, 17, 57, 21, 2)

local p = c:build{
  { "pickets", pickets, GV.ramp("#d9a660") },
  { "rails", rails, GV.ramp("#c4925f", { rim = "#f0d49a" }), { light = pickets } },
  { "brace", brace, GV.ramp("#5e2f1e"), { flat = true } },
  { "postL", postL, "stone" },
  { "postR", postR, "stone" },
  { "capL", capL, GV.ramp("#c9c5bc") },
  { "capR", capR, GV.ramp("#c9c5bc") },
}
-- stone courses on posts
local mortar = GV.R.stone.shade
for _, post in ipairs({ { 7, 16 }, { 47, 56 } }) do
  local x0, x1 = post[1], post[2]
  for _, y in ipairs({ 28, 36 }) do
    for x = x0 + 2, x1 - 2 do c:px(x, y, mortar) end
  end
  local m = math.floor((x0 + x1) / 2)
  for y = 23, 27 do c:px(m, y, mortar) end
  for y = 29, 35 do c:px(m - 2, y, mortar) end
  for y = 37, 43 do c:px(m + 1, y, mortar) end
end
-- latch
c:part(c:ellipse(44, 34, 2, 2), "gold", { flat = true })
c:paint({ "hh" }, 41, 34, { h = "#7a3a14" })

c:ground(31.5, 49, 24, 1.5)
local t = c:save(O .. "aseprite/ph/stone-wall-gate.aseprite", O .. "png/ph/stone-wall-gate.png")
print(GV.report(t))
