local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- centreline of the wavy S, radius tapering from tail to neck
local P = { {13,46,1.5}, {16,42,2.5}, {20,38,3.5}, {24,36,4}, {28,38,4.5}, {32,40,4.5},
            {36,38,4.5}, {39,34,4.5}, {42,30,4.5}, {44,27,4.5} }
local body, spine = c:mask(), c:mask()
for i = 1, #P - 1 do
  local a, b = P[i], P[i+1]
  for t = 0, 1, 0.1 do
    local x = a[1] + (b[1]-a[1])*t
    local y = a[2] + (b[2]-a[2])*t
    local r = a[3] + (b[3]-a[3])*t
    body:add(c:ellipse(x, y, r, r))
    if i >= 2 and not (i == 2 and t < 0.6) then
      spine:add(c:ellipse(x - 0.5, y - math.min(2, r*0.45), 1, 0.5))
    end
  end
end
body:add(c:poly({ {10,50}, {14,44}, {15,48} }))   -- tail fin

local head = c:ellipse(45.5, 22, 7, 6.5)
head:add(c:poly({ {40,24}, {54,25}, {51,30}, {44,30} }))   -- jaw / snout
local crest = c:poly({ {38,18}, {40,12}, {44,16} }):add(c:poly({ {43,15}, {46,11}, {49,15} }))

local p = c:build{
  { "crest", crest, GV.ramp("#5a3f9a"), { flat = true } },
  { "body",  body,  GV.ramp("#7a5cc0") },
  { "head",  head,  GV.ramp("#7a5cc0"), { light = head:copy():add(body) } },
}
spine:clip(p.body.m)
c:fill(spine, "#c3b2ea")
-- open mouth line and fangs
c:paint({ "mmmmmmmmmm" }, 43, 27, { m = "#2a1a10" })
c:paint({ "ff..ff.ff",
          "ff..ff.f.",
          ".f...f..." }, 44, 28, { f = "#fff3c8" })
c:paint({ "g.g", "g.g" }, 39, 24, { g = "#3e2f66" })   -- gill slits
c:eye(45, 18, true)
c:ground(30, 47, 10, 1.5)
local t = c:save(O .. "aseprite/ph/creature-reef-eel-lord.aseprite", O .. "png/ph/creature-reef-eel-lord.png")
print(GV.report(t))
