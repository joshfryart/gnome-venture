local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cream = GV.ramp("#f8eed2", { shade = "#e3cfa6", deep = "#c49a6c", bounce = "#e8d4ae" })
local rail = GV.ramp("#968f96")
local parts = {
  { "rails", c:rect(10, 22, 53, 24):add(c:rect(10, 29, 53, 31)), rail, { gloss = false } },
  { "brails", c:rect(24, 34, 25, 52):add(c:rect(38, 34, 39, 52)), rail, { flat = true } },
}
local xs = { 11, 17, 23, 35, 41, 47 }
for i, x in ipairs(xs) do
  parts[#parts+1] = { "p" .. i, c:rrect(x, 16, x + 3, 34, 2):add(c:rect(x, 19, x + 3, 34)), cream, { gloss = { x + 1, 18 } } }
end
local slats = c:mask()
for i = 0, 4 do slats:add(c:rect(26, 36 + i * 4, 37, 38 + i * 4)) end
parts[#parts+1] = { "slats", slats, cream, { gloss = false } }
parts[#parts+1] = { "post", c:rrect(28, 14, 35, 37, 2), cream }
c:build(parts)
c:ground(31.5, 53, 14, 1.5)
local t = c:save(O .. "aseprite/ph/picket-fence-tee.aseprite", O .. "png/ph/picket-fence-tee.png")
print(GV.report(t))
