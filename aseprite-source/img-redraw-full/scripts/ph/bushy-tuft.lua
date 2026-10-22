local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function S(t) for _,q in ipairs(t) do q[1]=math.floor(32+(q[1]-32)*0.9+0.5); q[2]=math.floor(32+(q[2]-32)*0.9+0.5) end return t end
local m = c:poly(S({ {11,17},{15,10},{20,15},{25,9},{30,14},{35,8},{40,14},{45,9},{50,15},{54,12},
  {53,21},{59,26},{51,32},{57,39},{55,47},{48,48},{46,55},{40,49},{35,55},{30,49},{25,55},{20,49},
  {16,54},{9,46},{15,39},{7,32},{14,26},{7,20} }))
local p = c:build{ { "clump", m, GV.ramp("#dcb06a"), { gloss = { 19, 18 } } } }
local function arc(pts) c:fill(c:line(S(pts), 2):clip(p.clump.m), "#5e2f1e") end
arc({ {18,25},{21,28},{21,31},{18,34} })
arc({ {32,23},{35,26},{35,30},{32,33} })
arc({ {24,41},{28,44},{33,44},{37,41} })
arc({ {44,28},{47,31},{46,35} })
local t = c:save(O .. "aseprite/ph/bushy-tuft.aseprite", O .. "png/ph/bushy-tuft.png")
print(GV.report(t))
