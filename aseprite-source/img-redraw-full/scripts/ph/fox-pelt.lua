local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function S(pts) local r = {} for i, p in ipairs(pts) do r[i] = { math.floor(32 + (p[1] - 32) * 0.74 + 0.5), math.floor(32 + (p[2] - 32) * 0.74 + 0.5) } end return r end
local pelt = c:poly(S{ {14,16},{22,14},{27,17},{32,14},{37,17},{42,14},{50,16},{59,22},{59,28},{45,34},{58,44},{56,49},{46,52},{18,52},{8,49},{6,44},{19,34},{5,28},{5,22} })
local tail = c:ellipse(32, 47, 4, 5)
local p = c:build{
  { "tail", tail, "water" },
  { "pelt", pelt, "water", { stitch = { side = "lit" } } },
}
local dk = "#2f6290"
-- paw tips
c:paint({ "ddd", "dd." }, 12, 22, { d = dk }); c:paint({ "ddd", ".dd" }, 49, 22, { d = dk })
c:paint({ "dd.", "ddd" }, 13, 43, { d = dk }); c:paint({ ".dd", "ddd" }, 48, 43, { d = dk })
-- S-curl fur marks
c:paint({ ".dd", "d..", ".d.", "..d", "dd." }, 23, 25, { d = dk })
c:paint({ ".dd", "d..", ".d.", "..d", "dd." }, 37, 29, { d = dk })
c:paint({ ".dd..dd", "d..dd.." }, 29, 38, { d = dk })
local t = c:save(O .. "aseprite/ph/fox-pelt.aseprite", O .. "png/ph/fox-pelt.png")
print(GV.report(t))
