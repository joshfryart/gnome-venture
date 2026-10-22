local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#b6814d")
local rail = GV.ramp("#c4925f")
local pale = GV.ramp("#f4f0e0")
local brace = GV.ramp("#8a4f2a")
local list = {
  { "postL", c:rrect(10, 20, 15, 48, 1), wood, { cres = 2 } },
  { "postR", c:rrect(48, 20, 53, 48, 1), wood, { cres = 2 } },
  { "capL",  c:rrect(9, 17, 16, 21, 1), "gold", { gloss = false, cres = 1 } },
  { "capR",  c:rrect(47, 17, 54, 21, 1), "gold", { gloss = false, cres = 1 } },
  { "rails", c:rect(16, 27, 47, 30):add(c:rect(16, 38, 47, 41)), rail, { cres = 1, gloss = false } },
}
for i, x in ipairs({ 17, 22, 27, 32, 37, 42 }) do
  local m = c:rrect(x, 22, x + 3, 30, 2):add(c:rect(x, 26, x + 3, 45))
  list[#list + 1] = { "p" .. i, m, pale, { cres = 1, deep = 0, gloss = { x + 1, 24 } } }
end
list[#list + 1] = { "brace", c:line({ { 18, 39 }, { 45, 28 } }, 3), brace, { flat = true } }
list[#list + 1] = { "latch", c:ellipse(44, 34, 1.5, 1.5), "gold", { flat = true } }
c:build(list)
c:ground(31.5, 49, 23, 1.5)
local t = c:save(O .. "aseprite/ph/picket-fence-gate.aseprite", O .. "png/ph/picket-fence-gate.png")
print(GV.report(t))
