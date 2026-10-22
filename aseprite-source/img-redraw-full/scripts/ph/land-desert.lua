local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

local tile = c:rrect(3, 3, 60, 60, 7)
-- warm sky bands
c:bands(tile, { "#fbe3a0", "#f8d985", "#f5cf6a", "#f5cf6a" })
c:outline(tile)

local function band(f, top)
  local m = c:mask()
  for x = 3, 60 do local t = math.floor(f(x) + 0.5) for y = t, 60 do m:set(x, y) end end
  return m:clip(tile)
end

-- sun
c:part(c:ellipse(48, 14, 5), GV.ramp("#f8dc7a"), { outline = false, gloss = false, contour = false, rim = false })
c:px(46, 12, "#fff3c8"); c:px(45, 13, "#fff3c8")

local far = band(function(x) return 38 - 2.5 * math.sin(x / 9 + 1.0) end)
c:part(far, GV.ramp("#dcb06a"), { outline = false, gloss = false })
local near = band(function(x) return 47 - 2.5 * math.sin(x / 8 + 3.4) end)
c:part(near, "gold", { outline = false, gloss = false })

-- saguaro
local cac = c:rrect(20, 20, 26, 50, 3)
cac:add(c:rrect(11, 28, 15, 40, 2)):add(c:rect(13, 37, 21, 40))
cac:add(c:rrect(28, 25, 31, 36, 2)):add(c:rect(25, 33, 30, 36))
c:part(cac, GV.ramp("#58a03e"), { gloss = { 21, 24 } })
for y = 26, 44 do if y % 3 ~= 0 then c:px(22, y, "#7ab55c") end end
for y = 31, 37 do if y % 3 ~= 0 then c:px(12, y, "#7ab55c") end end

-- rock with pale cone
c:part(c:poly({ {39, 52}, {43, 43}, {47, 52} }), GV.ramp("#d6c9b6"), { gloss = false })
c:part(c:ellipse(49.5, 51, 5, 3.5), GV.ramp("#a9a3a9"), { gloss = false })

-- edge stitch
c:stitch(tile)

local t = c:save(O .. "aseprite/ph/land-desert.aseprite", O .. "png/ph/land-desert.png")
print(GV.report(t))
