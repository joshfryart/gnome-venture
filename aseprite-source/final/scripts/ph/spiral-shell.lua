local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(30.5, 30.5, 19, 19)
local coil = c:ellipse(29.5, 29.5, 4, 4)
local lip = c:ellipse(44.5, 44, 8, 6)
local mouth = c:ellipse(45.5, 45, 5, 3)

local p = c:build{
  { "body", body, "gold", { gloss = { 18, 19 } } },
  { "coil", coil, GV.ramp("#d0862a"), { gloss = { 26, 26 } } },
  { "lip",  lip,  GV.ramp("#fff1c8"), { gloss = false } },
}
-- spiral whorl from the centre out to the rim (clockwise, 2 px arm)
local pts = {}
local cx, cy = 29.5, 29.5
for i = 0, 60 do
  local th = i / 60 * 2.1 * 2 * math.pi
  local r = 3 + th * 2.4
  if r > 17 then break end
  pts[#pts + 1] = { math.floor(cx + math.cos(th + 3.4) * r + 0.5), math.floor(cy + math.sin(th + 3.4) * r + 0.5) }
end
local arm = c:line(pts, 3):clip(body:shrink(2)):cut(lip)
c:fill(arm, "#b8661a")
c:fill(c:line(pts, 1):clip(body:shrink(2)):cut(lip), "#7a3a14")
-- ridge ticks along the outer whorl
c:fill(c:rect(13, 28, 14, 29), "#7a3a14")
c:fill(c:rect(29, 13, 30, 14), "#7a3a14")
c:fill(c:rect(45, 25, 46, 26), "#7a3a14")
-- aperture interior
c:fill(mouth, "#f5cf6a")
c:fill(c:rect(43, 46, 48, 46):clip(mouth), "#e8a317")

local t = c:save(D .. "img-redraw-full/aseprite/ph/spiral-shell.aseprite",
                 D .. "img-redraw-full/png/ph/spiral-shell.png")
print(GV.report(t))
