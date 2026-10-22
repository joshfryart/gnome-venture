local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- nut body: plump, rounded, slight point at bottom
local nut = c:ellipse(31.5, 38, 17, 15)
nut:add(c:poly({ {24, 48}, {31.5, 55}, {39, 48} }))
-- cap: wide dome with a curved bottom
local cap = c:ellipse(31.5, 26, 21, 13):cut(c:rect(0, 30, 63, 63))
cap:add(c:ellipse(31.5, 28, 21, 4))
local stalk = c:rrect(30, 8, 33, 16, 1)

local p = c:build{
  { "stalk", stalk, "wood" },
  { "nut",   nut,   GV.ramp("#c68a4a") },
  { "cap",   cap,   GV.ramp("#7e5430"), { gloss = { 18, 19 } } },
}

-- crosshatch scales on the cap (diamond grid), skipping gloss area
local sc = "#5e3b1c"
p.cap.m:each(function(x, y)
  if y >= 17 and y <= 30 then
    local a, b = (x + y) % 6, (x - y) % 6
    if (a == 0 or b == 0) and not (x < 24 and y < 22) then
      local inside = p.cap.m:has(x-2, y) and p.cap.m:has(x+2, y) and p.cap.m:has(x, y+2) and p.cap.m:has(x, y-2)
      if inside then c:px(x, y, sc) end
    end
  end
end)

-- seam along the cap's lower edge
c:seam({ {14, 30}, {22, 31}, {31, 32}, {41, 31}, {49, 30} })

c:ground(31.5, 56, 18, 2)
local t = c:save(O .. "aseprite/games/crop-nut.aseprite", O .. "png/games/crop-nut.png")
print(GV.report(t))
