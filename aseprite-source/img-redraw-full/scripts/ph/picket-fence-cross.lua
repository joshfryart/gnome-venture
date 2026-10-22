local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cream = GV.ramp("#f8eed2")
local rails = c:rect(6, 29, 57, 30):add(c:rect(6, 35, 57, 36))
rails:add(c:rect(29, 6, 30, 57)):add(c:rect(35, 6, 36, 57))
local list = { { "rails", rails, GV.ramp("#968f96"), { flat = true } } }
-- horizontal arm: upright pickets with pointed tops
for _, x in ipairs({ 6, 12, 18, 41, 47, 53 }) do
  local m = c:rect(x, 25, x + 3, 39):cut(c:rect(x, 25, x, 25)):cut(c:rect(x + 3, 25, x + 3, 25))
  m:cut(c:rect(x, 26, x, 26)):cut(c:rect(x + 3, 26, x + 3, 26)):set(x, 26):set(x + 3, 26)
  m:del(x, 25); m:del(x + 3, 25)
  list[#list + 1] = { "h" .. x, m, cream, { flat = true, rim = false } }
end
-- vertical arm: pickets lying across, pointed ends to the left
for _, y in ipairs({ 6, 12, 18, 41, 47, 53 }) do
  local m = c:rect(25, y, 39, y + 3)
  m:del(25, y); m:del(25, y + 3)
  list[#list + 1] = { "v" .. y, m, cream, { flat = true, rim = false } }
end
list[#list + 1] = { "post", c:rrect(25, 25, 38, 38, 1), cream }
local p = c:build(list)
for _, x in ipairs({ 6, 12, 18, 41, 47, 53 }) do for y = 27, 39 do c:px(x + 3, y, cream.shade) end end
for _, y in ipairs({ 6, 12, 18, 41, 47, 53 }) do for x = 26, 39 do c:px(x, y + 3, cream.shade) end end
c:paint({ "aaaa", "a..." }, 28, 28, { a = "#f5b860" })
c:px(31, 31, "#fff3c8")
local t = c:save(D .. "img-redraw-full/aseprite/ph/picket-fence-cross.aseprite", D .. "img-redraw-full/png/ph/picket-fence-cross.png")
print(GV.report(t))
