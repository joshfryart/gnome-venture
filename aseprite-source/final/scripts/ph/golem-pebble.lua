local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local pink = GV.ramp("#e46a9b", { rim = "#f6b8cf" })
local body = c:ellipse(32, 38, 23, 15):add(c:ellipse(32, 34, 19, 13))
local p = c:build{ { "pebble", body, pink, { gloss = { 19, 28 } } } }
local band = c:line({ {14, 44}, {18, 38}, {24, 34}, {32, 32}, {40, 34}, {46, 38}, {50, 44} }, 5):clip(body:shrink(2))
local inner = c:line({ {16, 44}, {19, 39}, {24, 36}, {32, 34}, {40, 36}, {45, 39}, {48, 44} }, 1):clip(band)
band:each(function(x, y)
  local v = c:get(x, y)
  if v == pink.shade or v == pink.deep or v == pink.bounce then c:px(x, y, "#d4a66a") else c:px(x, y, "#f0d49a") end
end)
inner:each(function(x, y) c:px(x, y, "#c66b50") end)
local t = c:save(O .. "aseprite/ph/golem-pebble.aseprite", O .. "png/ph/golem-pebble.png")
print(GV.report(t))
