local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- body / foot: long low slug with a neck rising at the right
local body = c:rrect(6, 44, 54, 53, 4)
body:add(c:poly({ {4, 54}, {8, 47}, {14, 47}, {12, 54} }))
body:add(c:rrect(44, 28, 56, 52, 6))
body:add(c:ellipse(51, 32, 6, 5.5))
local stalkM = c:line({ {50, 30}, {48, 17} }, 2):add(c:line({ {54, 30}, {56, 17} }, 2))
local p = c:build{
  { "stalk", stalkM, GV.ramp("#c9b083"), { flat = true } },
  { "body", body, GV.ramp("#e0c9a0") },
  { "shell", c:ellipse(28, 32, 17, 17), GV.ramp("#a8703c", { shade = "#78471f" }), { gloss = false } },
}

-- spiral
c:fill(c:line({ {29, 33}, {33, 31}, {33, 35}, {29, 38}, {24, 36}, {22, 32}, {24, 27}, {29, 24}, {35, 24}, {39, 28}, {41, 33}, {39, 39} }, 2), "#5e2f1e")

-- shell gloss arc and dot
c:fill(c:line({ {16, 27}, {18, 23}, {22, 20}, {26, 18} }, 2), "#d9a660")
c:px(15, 31, "#fff1c8"); c:px(16, 25, "#fff1c8"); c:px(17, 24, "#fff1c8")

-- eyes on stalk tips
c:eye(45, 12); c:eye(54, 12)

-- smile
c:paint({ "m...m", ".mmm." }, 51, 36, { m = "#7a5a35" })

c:ground(30, 55, 25, 2)
local t = c:save(R .. "img-redraw-full/aseprite/games/snail-brown.aseprite", R .. "img-redraw-full/png/games/snail-brown.png")
print(GV.report(t))
