local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function mir(pts, dx, dy)
  local r = {}
  for i, p in ipairs(pts) do r[i] = { 64 - p[1] + (dx or 0), p[2] + (dy or 0) } end
  return r
end

-- lower wings: drooping rounded lobes
local lwL = { {31,34},{24,35},{15,38},{10,42},{10,46},{14,49},{21,49},{27,46},{31,42} }
local lower = c:poly(lwL):add(c:poly(mir(lwL)))
-- upper wings: wide sail blades, tips reaching up and out (slight asymmetry)
local uwL = { {31,26},{24,22},{15,18},{9,18},{6,21},{7,27},{12,32},{20,36},{27,38},{31,37} }
local uwR = { {33,25},{40,20},{49,16},{55,16},{58,19},{58,26},{53,32},{45,37},{37,39},{33,38} }
local upper = c:poly(uwL):add(c:poly(uwR))

local body = c:ellipse(31.5, 40, 3.5, 9)
local head = c:ellipse(31.5, 30.5, 5, 3.5)
local ant = c:line({ {29,28},{27,25},{24,22},{22,21} }, 2):add(c:line({ {34,28},{36,25},{39,22},{41,21} }, 2))
ant:add(c:rrect(18, 18, 21, 21, 1)):add(c:rrect(42, 18, 45, 21, 1))

local p = c:build{
  { "ant",   ant,   GV.ramp("#44281c"), { flat = true } },
  { "lower", lower, GV.ramp("#8f7d70") },
  { "upper", upper, GV.ramp("#a38f80"), { stitch = { side = "lit" } } },
  { "body",  body,  GV.ramp("#6e5446") },
  { "head",  head,  GV.ramp("#5a4238") },
}

-- pale vein lines on the wings
local V = "#e6d2ae"
local function vein(pts) c:fill(c:line(pts, 1):clip(upper):cut(body:grow(1)), V) end
vein({ {27,34},{20,31},{14,28} })
vein({ {27,30},{20,26},{13,23} })
vein({ {37,35},{44,31},{50,28} })
vein({ {37,31},{44,25},{50,21} })
local function lvein(pts) c:fill(c:line(pts, 1):clip(lower):cut(upper:grow(1)):cut(body:grow(1)), V) end
lvein({ {26,42},{20,44},{14,45} })
lvein({ {37,42},{43,44},{49,45} })

-- two amber wing-tip dots (only warm accent)
local dot = { ".gg.", "gggg", "ggsg", ".ss." }
local leg = { g = "#e8a317", s = "#b8661a" }
c:paint(dot, 11, 21, leg); c:px(12, 22, "#fff1c8")
c:paint(dot, 50, 19, leg); c:px(51, 20, "#fff1c8")

c:seam({ {32,35},{32,48} })
c:eye(28, 30, true); c:eye(33, 30, true)

local t = c:save(O .. "aseprite/ph/creature-dimwing-moth.aseprite", O .. "png/ph/creature-dimwing-moth.png")
print(GV.report(t))
