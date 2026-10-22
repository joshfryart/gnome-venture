local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 41, 17, 14)
local band = c:rect(15, 31, 49, 34):clip(body)
local cream = GV.ramp("#f4f0e0")
local p = c:build{
  { "body", body, cream, { contour = "#74462a" } },
  { "band", band, "petal", { flat = true } },
  { "lid", c:rrect(20, 21, 44, 29, 4), GV.ramp("#f6b8cf") },
  { "knob", c:ellipse(32, 17.5, 3.5, 3), GV.ramp("#e46a9b") },
}
-- frangipani flower motif: five petals round a gold eye
local pet = c:mask()
for i = 0, 4 do
  local a = -math.pi / 2 + i * 2 * math.pi / 5
  pet:add(c:ellipse(32 + math.cos(a) * 4, 43 + math.sin(a) * 4, 2.5))
end
c:fill(pet, "#e46a9b")
pet:each(function(x, y) if (x - 32) + (y - 43) >= 5 then c:px(x, y, "#a8241f") end end)
c:fill(c:ellipse(32, 43, 1.5), "#e8a317")
c:px(30, 39, "#f6b8cf"); c:px(27, 41, "#f6b8cf")
c:paint({ ".llll.", "llllll", ".llll." }, 38, 47, { l = "#58a03e" })
c:seam({ {21, 30}, {43, 30} }, { free = true })
c:button(29, 27)
c:ground(32, 55.5, 15, 2)
local t = c:save(O .. "aseprite/ph/frangipani-seed.aseprite", O .. "png/ph/frangipani-seed.png")
print(GV.report(t))
