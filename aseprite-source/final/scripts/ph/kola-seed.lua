local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tail = c:poly({ {28,47},{36,47},{33,50},{36,54},{28,54},{31,50} })
local nut = c:ellipse(31.5, 20, 9, 8.5)
local cap = c:ellipse(31.5, 17, 9.5, 5.5):cut(c:rect(0, 17, 63, 63))
local cone = c:poly({ {17,27},{47,27},{33,50},{30,50} })
local rim = c:rrect(15, 25, 48, 28, 1)
local p = c:build{
  { "tail", tail, GV.ramp("#dcb06a") },
  { "nut",  nut,  GV.ramp("#dcb06a") },
  { "cap",  cap,  "wood" },
  { "cone", cone, "#f1ece0", { light = cone:copy():add(rim) } },
  { "rim",  rim,  GV.ramp("#dcb06a") },
}
c:part(c:line({ {31,11},{31,9} }, 2), GV.ramp("#2f5a2a", {base="#3f7a34"}), { flat = true })
c:part(c:ellipse(35.5, 9, 3, 1.5), "moss", { flat = true })
c:fill(c:line({ {25,30},{31,47} }, 1), "#d6c9b6")
c:seam({ {16,26}, {47,26} })
c:paint({ "u....u", ".uuuu." }, 29, 20, { u = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/kola-seed.aseprite", O .. "png/ph/kola-seed.png")
print(GV.report(t))
