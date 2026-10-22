local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(6, 14, 57, 51, 4)
local flap = c:poly({ {6, 17}, {32, 40}, {58, 17} })
flap:add(c:rrect(6, 14, 57, 20, 4))
flap:clip(body)

local p = c:build{
  { "body", body, GV.ramp("#f1e2bd"), { gloss = false } },
  { "flap", flap, GV.ramp("#e9d29c"), { light = body, gloss = { 11, 17 } } },
}
-- lower side fold creases
c:line({ {7, 50}, {25, 36} }, 1)
c:fill(c:line({ {7, 50}, {25, 36} }, 1):clip(body):cut(flap), "#d6bb82")
c:fill(c:line({ {56, 50}, {38, 36} }, 1):clip(body):cut(flap), "#d6bb82")
-- V crease on flap edge
local vedge = flap:edge():cut(c:rect(0, 0, 63, 19))
c:fill(vedge, "#c9aa6a")
c:seam({ {9, 20}, {30, 38} }); c:seam({ {55, 20}, {34, 38} })

-- stamp
local stamp = c:rrect(44, 18, 54, 29, 1)
c:part(stamp, GV.ramp("#f1ece0"), { gloss = false, contact = false })
c:paint({
  "o.o.o.o.o.o",
}, 44, 18, { o = "#c97a3a" })
c:paint({
  "o.o.o.o.o.o",
}, 44, 29, { o = "#c97a3a" })
c:part(c:rect(46, 20, 52, 27), "moss", { flat = true })
c:paint({ "..g..", ".ggg.", "..u.." }, 47, 22, { g = "#c8d77a", u = "#4a8a3e" })

-- wax seal
local seal = c:ellipse(32, 38, 7, 7)
seal:add(c:ellipse(26, 41, 2, 2)); seal:add(c:ellipse(38, 35, 1.5, 1.5))
c:part(seal, "red", { gloss = { 28, 34 } })
local ring = c:ellipse(32, 38, 5, 5):edge()
c:fill(ring, "#b8452f")
c:paint({
  "..l..",
  ".lll.",
  "lluLl",
  ".lul.",
  "llull",
  ".lul.",
  "..u..",
}, 30, 35, { l = "#ff9158", u = "#ae2a2a", L = "#ff9158" })

c:ground(31.5, 54, 22, 1.5)
local t = c:save(O .. "aseprite/games/envelope.aseprite", O .. "png/games/envelope.png")
print(GV.report(t))
