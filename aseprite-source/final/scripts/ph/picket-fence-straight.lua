local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "lr" }
local pale = GV.ramp("#f8eed2")
local rails = c:rect(0, 30, 63, 32):add(c:rect(0, 39, 63, 41))
local pk = c:mask()
for _, x in ipairs({ -2, 4, 10, 16, 42, 48, 54, 60 }) do
  pk:add(c:rect(x, 24, x + 3, 44)):add(c:rect(x + 1, 22, x + 2, 23))
end
local post = c:rect(25, 18, 38, 46)
local postcap = c:rect(23, 15, 40, 19)
local p = c:build{
  { "rails", rails, GV.ramp("#8b8f96"), { gloss = false } },
  { "pickets", pk, pale, { flat = true, rim = false } },
  { "post", post, pale, { cres = 3, deep = 1, rim = false } },
  { "postcap", postcap, GV.ramp("#d6c9b6"), { gloss = false } },
}
-- picket nail heads on rails
for _, x in ipairs({ -2, 4, 10, 16, 42, 48, 54, 60 }) do
  if x + 1 >= 0 then c:px(x + 1, 31, "#8b8f96"); c:px(x + 1, 40, "#8b8f96") end
end
c:seam({ {25, 20}, {38, 20} })
c:fill(c:rect(0, 45, 63, 46), "#6a4528")
local t = c:save(O .. "aseprite/ph/picket-fence-straight.aseprite", O .. "png/ph/picket-fence-straight.png")
print(GV.report(t))
