local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bodyR = GV.ramp("#3e2f66", { rim = "#7b66b4", gloss = "#a894dc", dot = "#d4c6f0", shade = "#291d4a", deep = "#2a1a10" })
local body = c:ellipse(31.5, 36, 16, 14)
body:add(c:ellipse(21, 46, 7, 7)); body:add(c:ellipse(31.5, 49, 7, 7)); body:add(c:ellipse(42, 46, 7, 7))
body:add(c:ellipse(31.5, 30, 15, 9))
local p = c:build{
  { "body", body, bodyR, { gloss = { 20, 28 } } },
}
-- lobe grooves
c:line({ {26,26}, {25,34}, {25,42}, {26,50} }, 1)
for _, pt in ipairs({}) do end
local function groove(pts)
  local m = c:line(pts, 1):clip(body:shrink(2))
  m:each(function(x, y) c:px(x, y, "#291d4a") end)
end
groove({ {26,26}, {25,34}, {25,42}, {27,52} })
groove({ {37,26}, {38,34}, {38,42}, {36,52} })
local p2 = c:build{
  { "calyx", c:ellipse(31.5, 23, 9, 3.5), "moss", { gloss = false } },
  { "stem",  c:line({ {31,22}, {32,17}, {34,13}, {36,10} }, 5), GV.ramp("#6a9a3a"), { gloss = false } },
  { "leaf",  c:poly({ {38,16}, {42,12}, {47,13}, {44,18}, {39,19} }), "leaf", { flat = true } },
  { "tip",   c:rrect(34, 7, 38, 10, 1), GV.ramp("#2f5a2a"), { flat = true } },
}
local t = c:save(O .. "aseprite/ph/bell-pepper.aseprite", O .. "png/ph/bell-pepper.png")
print(GV.report(t))
