local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local function strand(sign, w)
  local pts = {}
  for y = 11, 53 do
    local x = 32 - sign * 10.5 * math.cos(math.pi * (y - 12) / 20)
    pts[#pts + 1] = { math.floor(x + 0.5) - math.floor(w / 2), y - math.floor(w / 2) }
  end
  return c:line(pts, w)
end

local rungs = c:rect(22, 10, 42, 13):add(c:rect(22, 30, 42, 33)):add(c:rect(22, 50, 42, 53))
local blue = strand(1, 5)
local peach = strand(-1, 6)

c:build{
  { "rungs", rungs, GV.ramp("#f8eed2"), { gloss = false, cres = 1 } },
  { "blue",  blue,  GV.ramp("#3f93b2") },
  { "peach", peach, GV.ramp("#e9b98a", { shade = "#c47a52" }) },
}

local t = c:save(O .. "aseprite/ico/ico-dna.aseprite", O .. "png/ico/ico-dna.png")
print(GV.report(t))
