-- Jeff trophy (tournament 1st, streaks, awards): holding a gold cup up high, happy eyes, open smile. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -6, 3
local body = K.jeffBody(c, dx, dy)
local armL = c:line({ {12, 38}, {8, 33} }, 4); armL:add(c:ellipse(9.5, 30, 3, 3)); armL:cut(body:grow(1))
local armR = c:line({ {37, 38}, {44, 34}, {47, 30} }, 4); armR:cut(body:grow(1))
-- cup: bowl with a rounded bottom, ring handles, stem, base
local cup = c:rrect(42, 7, 53, 13, 1); cup:add(c:ellipse(47.5, 13, 5.5, 5))
local hdl = c:ellipse(41.5, 12, 2.5, 3.5):add(c:ellipse(53.5, 12, 2.5, 3.5)); hdl:cut(c:ellipse(41.5, 12, 0.5, 1.5)); hdl:cut(c:ellipse(53.5, 12, 0.5, 1.5))
local stem = c:rect(47, 18, 49, 22); stem:add(c:rrect(43, 22, 53, 25, 1))
local fist = c:ellipse(48, 28, 3.5, 3)
c:build{
  K.jeffArm("armL", armL), K.jeffBodyPart(body), K.jeffArm("armR", armR),
  { "hdl", hdl, "gold", { flat = true } },
  { "stem", stem, "gold", {} },
  { "cup", cup, "gold", { gloss = { 44, 9 } } },
  K.jeffArm("fist", fist),
}
c:paint({ "..p..", ".ppp.", "ppppp", ".p.p." }, 46, 12, { p = "#8a5fd0" })   -- purple star on the cup
c:paint({ "g", "g" }, 38, 4 + 2, { g = "#f5cf6a" }); c:paint({ "gg" }, 55, 21, { g = "#f5cf6a" })  -- shine ticks
K.jeffFace(c, dx, dy, "custom", { eyes = "happy", brows = "up", mouth = "open" })
K.save(c, "jeff-trophy")
