local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local handle = c:ellipse(46, 35, 8, 9):cut(c:ellipse(46, 35, 4.5, 5.5)):cut(c:rect(0, 0, 41, 63))
local body = c:rrect(15, 24, 43, 52, 8):cut(c:rect(0, 0, 63, 27)):add(c:rect(15, 24, 43, 30))
body:add(c:ellipse(29, 24, 14, 4))
local tea = c:ellipse(29, 24, 12, 2.5)
local p = c:build{
  { "foot",   c:rrect(22, 50, 36, 56, 2), GV.ramp("#b9a98c") },
  { "handle", handle, GV.ramp("#d6c9b6") },
  { "body",   body, "cream" },
  { "tea",    tea, GV.ramp("#e0b45a"), { gloss = false, contact = false } },
}
-- band near base
c:fill(c:rect(17, 44, 41, 45):clip(body), "#d6c9b6")
c:fill(c:rect(17, 46, 41, 46):clip(body), "#b9a98c")
-- blossom cluster
local puffs = { {24, 21, 3.5}, {30, 19, 4}, {36, 21, 3.5} }
for _, b in ipairs(puffs) do
  local m = c:ellipse(b[1], b[2], b[3])
  c:part(m, GV.ramp("#fff3c8"), { flat = true })
end
c:px(24, 21, "#e8a317"); c:px(30, 19, "#e8a317"); c:px(36, 21, "#e8a317")
c:px(23, 20, "#f5cf6a"); c:px(29, 18, "#f5cf6a"); c:px(35, 20, "#f5cf6a")
c:seam({ {15, 28}, {43, 28} })
local t = c:save(O .. "aseprite/ph/meadowsweet-tea.aseprite", O .. "png/ph/meadowsweet-tea.png")
print(GV.report(t))
