local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(13, 18, 50, 52, 3)
local lid = c:poly({{16,11},{48,11},{52,19},{12,19}})
local frame = c:rrect(18, 23, 45, 47, 6)
local win = frame:shrink(2)
local p = c:build{
  { "body", body, GV.ramp("#f1ece0") },
  { "lid", lid, GV.ramp("#968f96") },
  { "frame", frame, "water", { gloss = false } },
  { "win", win, GV.ramp("#f4f0e0"), { gloss = false, contact = false } },
  { "seed", c:ellipse(31.5, 36, 7), GV.ramp("#3f8fb0", { shade = "#256a80" }) },
  { "stalk", c:rect(31, 26, 32, 29), "moss", { flat = true } },
  { "leaf", c:ellipse(35, 25, 3, 2), GV.ramp("#58a03e"), { flat = true } },
}
c:seam({ {14, 18}, {49, 18} })
c:button(30, 13)
for _, x in ipairs({24, 30, 36}) do
  c:paint({ "bbb", "bbb", "bbb" }, x, 48, { b = "#2f6290" }); c:px(x, 48, "#8fcbd8")
end
local t = c:save(O .. "aseprite/ph/black-eyed-susan-seed.aseprite", O .. "png/ph/black-eyed-susan-seed.png")
print(GV.report(t))
