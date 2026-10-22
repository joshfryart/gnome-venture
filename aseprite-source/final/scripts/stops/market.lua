local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon" }

local posts = c:rect(12, 20, 14, 34):add(c:rect(32, 20, 34, 34))

local awn = c:poly({ {10, 20}, {14, 10}, {32, 10}, {36, 20} })
for i = 0, 3 do awn:add(c:ellipse(13.25 + i * 6.5, 20, 3.5, 3)) end

c:build{
  { "posts", posts, "wood", { flat = true } },
  { "awning", awn, "red" },
}
-- cream stripes (fan-shaped), skip gloss area roughly by painting under detail rules
local cream = GV.ramp("#f1ece0")
for i = 0, 3 do
  local xb = 13.25 + i * 6.5
  local xt = 16.5 + i * 4.5
  if i % 2 == 1 then
    local s = c:poly({ {xt - 2.5, 10}, {xt + 2.5, 10}, {xb + 4, 21}, {xb - 4, 21} })
    s:add(c:ellipse(xb, 20, 3.5, 3)):clip(awn)
    c:fill(s, cream.base)
    c:fill(s:copy():cut(s:shift(-1, -1)), cream.shade)
  end
end
c:seam({ {10, 20}, {36, 20} })

local counter = c:rect(10, 30, 36, 36)
local fruitA = c:ellipse(16, 27, 3, 3)
local fruitB = c:ellipse(22.5, 27, 3, 3)
local basket = c:poly({ {27, 26}, {35, 26}, {33, 31}, {29, 31} })
c:build{
  { "counter", counter, GV.ramp("#a8582f") },
  { "fruitA", fruitA, "red", { flat = true } },
  { "fruitB", fruitB, "gold", { flat = true } },
  { "basket", basket, GV.ramp("#d9a660"), { flat = true } },
}
c:fill(c:rect(11, 33, 35, 33), "#8a4f2a")
c:paint({ "w.w.w" }, 29, 28, { w = "#b07a45" })
c:px(15, 26, "#ffc27a"); c:px(21, 26, "#fff1c8")

local t = c:save(O .. "aseprite/stops/market.aseprite", O .. "png/stops/market.png")
print(GV.report(t))
