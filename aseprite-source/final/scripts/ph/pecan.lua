local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 35.5, 13, 16)
local cap = body:copy():clip(c:ellipse(31.5, 17, 17, 11))
local nr = GV.ramp("#8c4a1a")
c:build{
  { "stem", c:rect(30, 15, 32, 22), GV.ramp("#2e5a2c"), { flat = true } },
  { "nut", body, nr, { gloss = { 24, 31 } } },
  { "cap", cap, GV.ramp("#4a2c1e"), { gloss = false } },
}
local function groove(x, y0, y1)
  for y = y0, y1 do
    local col = c:get(x, y)
    if col ~= nr.gloss and col ~= nr.dot then c:px(x, y, "#5e2f1e") end
  end
end
groove(26, 30, 44); groove(32, 29, 46); groove(38, 30, 44)
c:line({ {26,46}, {29,48}, {34,48}, {37,46} }, 1)
c:paint({ "d..........d", ".dd......dd.", "...dddddd..." }, 26, 45, { d = "#5e2f1e" })
local t = c:save(O .. "aseprite/ph/pecan.aseprite", O .. "png/ph/pecan.png")
print(GV.report(t))
