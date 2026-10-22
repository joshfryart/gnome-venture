local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"
local tin = GV.ramp("#e2ddd0")
local lid = GV.ramp("#dcb06a")
local plateR = GV.ramp("#f4f0e0")
c:build{
  { "tin", c:rrect(13, 18, 50, 52, 4), tin, { gloss = false } },
  { "lid", c:rrect(12, 10, 51, 21, 3), lid, { gloss = { 17, 13 } } },
  { "plate", c:rrect(18, 25, 45, 48, 5), plateR, { gloss = { 21, 27 }, contour = "#f5cf6a" } },
}
c:seam({ {15, 19}, {48, 19} })
c:button(43, 13)
-- barley ear
local K = { k = "#f5cf6a", s = "#e8a317", o = "#b8661a", h = "#fff1c8" }
c:fill(c:line({ {31, 30}, {31, 46} }, 2), "#2e5a2c")
c:paint({ ".oo.", "ohko", "okko", "okso", "osso", ".oo." }, 30, 24, K)
for _, y in ipairs({ 29, 34, 39 }) do
  c:paint({ "oo...", "ohko.", "okkko", ".okso", ".osso", "..oo." }, 26, y, K)
  c:paint({ "...oo", ".okko", "okkko", "oksso", "osso.", ".oo.." }, 33, y, K)
end
-- leaf
c:paint({ "...oo", ".ogg.", "ogg..", "go..." }, 25, 44, { g = "#58a03e", o = "#2f5a2a" })
-- dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 50, x + 1, 51), "#8c4a1a") end
c:ground(31.5, 53, 17, 1.5)
local t = c:save(O .. "aseprite/ph/barley-seed.aseprite", O .. "png/ph/barley-seed.png")
print(GV.report(t))
