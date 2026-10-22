local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local plus = c:rrect(8, 24, 56, 40, 4):add(c:rrect(24, 8, 40, 56, 4))
c:build{ { "hedge", plus, GV.ramp("#58a03e"), { gloss = false } } }
local D, L, G = "#7a5cc0", "#c3b2ea", "#b8d47c"
local dark  = { ".d.", "ddd", "ddd", "ddd", ".d." }
local lite  = { ".l.", "lll", "lll", ".l." }
local function tuft(x, y, isDark)
  if isDark then
    c:paint(dark, x, y, { d = D }); c:px(x, y + 1, "#a894dc")
    c:paint({ "ggg" }, x, y + 5, { g = G })
  else
    c:paint(lite, x, y, { l = L }); c:px(x + 2, y + 2, "#9a86d0")
    c:paint({ "ggg" }, x, y + 4, { g = G })
  end
end
-- horizontal arm: two staggered rows, alternating dark/light
local k = 0
for x = 9, 52, 4 do if x < 22 or x > 39 then k = k + 1
  tuft(x, 25, k % 2 == 1); tuft(x + 2, 32, k % 2 == 0) end end
-- vertical arm
k = 0
for y = 9, 52, 4 do if y < 22 or y > 39 then k = k + 1
  tuft(26, y, k % 2 == 1); tuft(33, y + 1, k % 2 == 0) end end
-- centre cluster
tuft(24, 25, false); tuft(28, 26, true); tuft(32, 25, false); tuft(36, 26, true)
tuft(26, 32, true); tuft(30, 33, false); tuft(34, 32, true)
local t = c:save(O .. "aseprite/ph/lavender-border-cross.aseprite", O .. "png/ph/lavender-border-cross.png")
print(GV.report(t))
