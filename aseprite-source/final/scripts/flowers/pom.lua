local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx, cy = 31.5, 31.5
local function ring(n, rad, r, off)
  local list = {}
  for i = 0, n - 1 do
    local a = math.rad(off + i * 360 / n)
    list[#list + 1] = c:ellipse(cx + rad * math.cos(a), cy + rad * math.sin(a), r, r)
  end
  return list
end
local outer = ring(12, 17, 6.5, 0)
local middle = ring(8, 11, 6, 15)
local inner = ring(5, 5, 4.5, -90)
local whole = c:mask()
for _, m in ipairs(outer) do whole:add(m) end
local pet = GV.ramp("#e46a9b")
local mid = GV.ramp("#d85a8d")
local deepP = GV.ramp("#c9507f")
-- outer petals: paint in an order so lower-right petals sit on top
local order = { 7, 6, 8, 5, 9, 4, 10, 3, 11, 2, 12, 1 }
for idx, i in ipairs(order) do
  c:part(outer[i], pet, { light = whole, gloss = false })
end
local midAll = c:mask() for _, m in ipairs(middle) do midAll:add(m) end
for _, i in ipairs({ 6, 5, 7, 4, 8, 3, 1, 2 }) do
  c:part(middle[i], mid, { light = midAll, gloss = false })
end
local inAll = c:mask() for _, m in ipairs(inner) do inAll:add(m) end
for _, i in ipairs({ 4, 3, 5, 2, 1 }) do
  c:part(inner[i], deepP, { light = inAll, gloss = false })
end
c:part(c:ellipse(cx, cy, 3, 3), "#b8386b", { gloss = false })
-- enamel gloss on lit upper-left petals
c:paint({ ".gg", "g.." }, 15, 18, { g = pet.gloss })
c:paint({ "gg" }, 27, 11, { g = pet.gloss })
c:px(13, 26, pet.dot)
c:paint({ "g" , "g" }, 10, 30, { g = pet.gloss })
c:px(23, 24, mid.gloss); c:px(24, 23, mid.gloss)
c:px(29, 27, deepP.gloss)
local t = c:save(O .. "aseprite/flowers/pom.aseprite", O .. "png/flowers/pom.png")
print(GV.report(t))
