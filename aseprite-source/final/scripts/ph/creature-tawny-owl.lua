local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tufts = c:poly({{16,24},{18,8},{29,19}}):add(c:poly({{48,24},{46,8},{35,19}}))
local feet = c:rrect(24,50,29,56,1):add(c:rrect(35,50,40,56,1))
local body = c:ellipse(32,36,17,16.5)
local chest = c:ellipse(32,41.5,10,10.5):clip(body)
local wings = c:poly({{13,30},{18,29},{21,36},{20,46},{16,51},{13,45},{12,37}})
wings:add(c:poly({{51,30},{46,29},{43,36},{44,46},{48,51},{51,45},{52,37}}))
local discs = c:ellipse(24,23,7.5,7):add(c:ellipse(40,23,7.5,7))
local rims = c:ellipse(24,23,4):add(c:ellipse(40,23,4))
local p = c:build{
  { "tufts", tufts, "#8a4f2a" },
  { "feet",  feet,  "#d9a660", { flat = true } },
  { "body",  body,  "#a8582f", { stitch = { side = "lit" } } },
  { "chest", chest, "#d9a660", { gloss = false } },
  { "wings", wings, "#8a4f2a", { gloss = false } },
  { "discs", discs, "#f8eed2", { gloss = false } },
  { "rims",  rims,  "gold", { gloss = false, rim = false } },
}
c:part(c:poly({{30,28},{35,28},{32.5,33}}), "gold", { flat = true })
-- chest bean markings
c:paint({ "u.u", ".u." }, 27, 40, { u = "#8a4f2a" })
c:paint({ "u.u", ".u." }, 34, 40, { u = "#8a4f2a" })
c:paint({ "u.u", ".u." }, 30, 45, { u = "#8a4f2a" })
c:eye(22,21); c:eye(38,21)
c:paint({ "u.u.u", "u.u.u" }, 24, 55, { u = "#b8661a" })
c:paint({ "u.u.u", "u.u.u" }, 35, 55, { u = "#b8661a" })
c:ground(32, 58, 14, 1.5)
local t = c:save(O .. "aseprite/ph/creature-tawny-owl.aseprite", O .. "png/ph/creature-tawny-owl.png")
print(GV.report(t))
