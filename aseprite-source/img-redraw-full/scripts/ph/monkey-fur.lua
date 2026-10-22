local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pelt = c:poly({ {16,18},{22,18},{25,10},{29,17},{32,9},{35,17},{39,10},{42,18},{48,18},
  {49,24},{57,22},{55,28},{58,33},{50,34},{50,45},{52,51},{47,50},{45,58},{41,51},{37,58},{33,51},{29,58},{25,51},{21,58},{19,50},{12,51},{14,45},{14,34},{6,33},{9,28},{7,22},{15,24} })
c:build{
  { "pelt", pelt, GV.ramp("#f08a24"), { stitch = { side = "lit" } } },
}
local function curl(x, y)
  c:paint({ ".tt.", "t..t", "t...", ".t.." }, x, y, { t = "#b8452f" })
end
curl(21, 24); curl(35, 27); curl(26, 38); curl(40, 39)
c:paint({ "t.t.t", ".t.t." }, 22, 46, { t = "#b8452f" })
c:paint({ "t.t.t", ".t.t." }, 34, 46, { t = "#b8452f" })
local t = c:save(O .. "aseprite/ph/monkey-fur.aseprite", O .. "png/ph/monkey-fur.png")
print(GV.report(t))
