-- Ffej pocket: Ffej (upside-down twin) strolls by looking innocent, one fist on his hip, the good eye
-- sliding sideways to a sewn-on pocket where a stolen gold piece pokes out. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -2, 0
local body = K.ffejBody(c, dx, dy)
-- left arm akimbo (elbow out, fist on the hip); right arm hangs by the pocket
local arms = c:line({ {17+dx, 26+dy}, {10+dx, 31+dy}, {14+dx, 37+dy} }, 5)
arms:add(c:line({ {46+dx, 36+dy}, {52+dx, 41+dy} }, 5)); arms:add(c:ellipse(53+dx, 43+dy, 3, 3))
arms:cut(body:shrink(1))
-- felt patch pocket on the lower right of the body
local pocket = c:rrect(36+dx, 29+dy, 47+dx, 39+dy, 1)
-- the stolen piece, sticking up out of the pocket mouth
local piece = c:rrect(39+dx, 22+dy, 47+dx, 31+dy, 1)
piece:add(c:ellipse(43+dx, 20+dy, 2.5, 2.5)); piece:add(c:ellipse(49+dx, 25.5+dy, 2, 2.5))
piece:cut(c:rect(0, 31+dy, 63, 63))
c:build{
  { "arms", arms, K.FFEJ_ARM, { flat = true } },
  { "body", body, K.FFEJ_BODY, { stitch = { side = "lit" } } },
  { "piece", piece, GV.ramp("#e8a317"), { gloss = { 39, 22 } } },
  { "pocket", pocket, GV.ramp("#8a5fd0"), { gloss = false, cres = 3, deep = 1 } },
}
c:seam({ {37+dx, 31+dy}, {46+dx, 31+dy} })                                   -- pocket hem
c:paint({ "u.u" }, 12+dx, 36+dy, { u = "umber" })                              -- knuckles on the hip
c:paint({ "u.u", ".u." }, 52+dx, 44+dy, { u = "umber" })                       -- dangling claw
K.ffejSeams(c, dx, dy)
K.ffejPatch(c, dx, dy)
-- good eye glancing down-right at the pocket, sly lifted brow, smug side smile
local ex = 32
c:eye(ex+dx, 22+dy)
c:fill(c:rect(ex+1+dx, 23+dy, ex+3+dx, 25+dy), "#f2e4c0"); c:fill(c:rect(ex+2+dx, 24+dy, ex+4+dx, 26+dy), "#2a1a10")
c:px(ex+2+dx, 24+dy, "#f2e4c0")
c:paint({ "...uu", ".uu..", "u...." }, ex-1+dx, 18+dy, { u = "umber" })
c:paint({ "........u", "u......u.", ".uuuuuu.." }, 22+dx, 30+dy, { u = "umber" })
c:paint({ "f" }, 27+dx, 32+dy, { f = "#c8d77a" })
c:paint({ "g.", ".g" }, 51+dx, 17+dy, { g = "#f5cf6a" })                       -- tiny glint off the loot
K.save(c, "ffej-pocket")
