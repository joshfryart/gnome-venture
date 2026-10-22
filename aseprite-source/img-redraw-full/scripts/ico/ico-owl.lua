local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local feet = c:rrect(25, 46, 29, 51, 1):add(c:rrect(35, 46, 39, 51, 1))
local wings = c:poly({{19,26},{12,36},{14,45},{21,44}}):add(c:poly({{45,26},{52,36},{50,45},{43,44}}))
local body = c:ellipse(32, 34, 14, 14)
local tufts = c:poly({{17,24},{18,12},{28,20}}):add(c:poly({{47,24},{46,12},{36,20}}))
local p = c:build{
  { "feet", feet, "#d9a660", { flat = true } },
  { "wings", wings, "#8a4f2a" },
  { "tufts", tufts, "#8a4f2a" },
  { "body", body, "#b07a45", { light = body } },
  { "tummy", c:ellipse(32, 39.5, 8, 7.5), "#e9b98a" },
  { "discs", c:ellipse(25, 27, 6.5, 6.5):add(c:ellipse(39, 27, 6.5, 6.5)), "#f8eed2", { gloss = false } },
  { "beak", c:poly({{29,31},{36,31},{32.5,36}}), "#e8a317", { flat = true } },
}
c:eye(23, 25); c:eye(37, 25)
c:paint({ "u...u", ".u.u.", "..u.." }, 30, 40, { u = "#c47a52" })
local t = c:save(O .. "aseprite/ico/ico-owl.aseprite", O .. "png/ico/ico-owl.png")
print(GV.report(t))
