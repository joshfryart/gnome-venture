local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local D = -2 -- vertical offset to keep the halo inside the frame
local function pts(t) local r = {} for i, p in ipairs(t) do r[i] = { p[1], p[2] + D } end return r end

-- arched handle (with a notch on the right)
local handle = c:line(pts{ {19,30},{20,24},{24,19},{29,16},{34,15},{39,16},{43,19},{46,23} }, 3)
handle:add(c:line(pts{ {47,26},{48,30} }, 3))
local body = c:poly(pts{ {17,31},{51,31},{47,59},{21,59} })
local rim = c:rrect(14, 26 + D, 53, 34 + D, 3)
local scoop = c:poly(pts{ {9,46},{17,43},{19,48},{11,52} })
scoop:add(c:ellipse(17, 47 + D, 3, 3))
for _, q in ipairs({ {9,46},{9,47},{10,46},{10,50},{10,51} }) do scoop:del(q[1], q[2] + D) end
local chip = c:poly(pts{ {48,52},{54,53},{53,58},{47,57} })

c:build{
  { "handle", handle, GV.ramp("#d9a660"), { flat = true } },
  { "body",   body,   "wood" },
  { "rim",    rim,    GV.ramp("#d9a660") },
  { "scoop",  scoop,  GV.ramp("#d9a660") },
  { "chip",   chip,   "wood", { gloss = false } },
}
c:line(pts{ {20,25},{24,20},{29,17},{34,16},{39,17},{43,20} }, 1):each(function(x,y) c:px(x,y,"#ecc58a") end)
c:paint({ "rrr", "rrr", "rrr" }, 18, 28 + D, { r = "#5e2f1e" })
c:paint({ "rrr", "rrr", "rrr" }, 46, 28 + D, { r = "#5e2f1e" })
c:seam(pts{ {18,34},{50,34} })
c:line(pts{ {32,27},{36,32},{30,38},{37,46},{33,55} }, 2):each(function(x,y) c:px(x,y,"#2a1a10") end)

local t = c:save(O .. "aseprite/ph/broken-tide-pail-and-scoop.aseprite", O .. "png/ph/broken-tide-pail-and-scoop.png")
print(GV.report(t))
