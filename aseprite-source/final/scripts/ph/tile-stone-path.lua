local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }
c:fill(c:rect(0, 0, 63, 63), "#6a6070")
local grey = GV.ramp("#968f96", { rim = "#c9c5bc", shade = "#5b6470" })
local cream = GV.ramp("#d6c9b6", { rim = "#f1ece0", shade = "#a89a8a" })
local o = { outline = false, contact = false, contour = false, gloss = false, cres = 2, deep = 0 }
local function stone(m, r) c:part(m, r, o) end
-- irregular flagstones: rounded boxes nudged with clipped corners
stone(c:rrect(3, 3, 28, 19, 4):cut(c:poly({{20,19},{29,19},{29,12}})), grey)
stone(c:rrect(32, 3, 60, 24, 5):cut(c:poly({{32,16},{32,25},{39,25}})), cream)
stone(c:rrect(3, 23, 22, 42, 4):add(c:rrect(18, 22, 26, 25, 2)), grey)
stone(c:rrect(26, 29, 46, 42, 4):add(c:rrect(30, 28, 44, 30, 2)), grey)
stone(c:rrect(50, 28, 60, 43, 3), grey)
stone(c:rrect(3, 46, 32, 60, 5):cut(c:poly({{24,46},{33,46},{33,52}})), cream)
stone(c:rrect(36, 46, 60, 60, 4):add(c:rrect(29, 53, 36, 60, 3)), grey)
-- gloss dash
c:fill(c:rect(6, 6, 9, 7), "#e4e0d8"); c:fill(c:rect(35, 6, 38, 7), "#fff3c8")
-- hairline cracks
local K = "#2a1a10"
local function crack(pts) for _, p in ipairs(pts) do c:px(p[1], p[2], "#4a3a48") end end
crack({{12,17},{13,16},{13,15},{14,14}})
crack({{44,8},{45,9},{45,10},{46,11}})
crack({{26,49},{27,50},{27,51},{28,52}})
crack({{53,37},{54,38},{54,39},{55,40}})
crack({{8,56},{9,55},{10,55},{11,54}})
crack({{37,33},{38,34},{38,35},{39,36}})
local t = c:save(O .. "aseprite/ph/tile-stone-path.aseprite", O .. "png/ph/tile-stone-path.png")
print(GV.report(t))
