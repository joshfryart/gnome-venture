local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(14, 12, 50, 54, 3)
local flap = c:poly({ {14, 12}, {51, 12}, {32, 30} }):clip(body)
local frame = c:rrect(21, 33, 43, 51, 5)
local win = c:rrect(23, 35, 41, 49, 3)
local seed = c:ellipse(32, 43, 5.5, 5)
c:build{
  { "body", body, "#f1ece0" },
  { "flap", flap, "#dcb06a", { gloss = false } },
  { "frame", frame, "#7ab55c", { gloss = false, contact = false } },
  { "win", win, "#f4f0e0", { gloss = false, cres = 2, deep = 1 } },
  { "seed", seed, "moss", { gloss = { 29, 40 } } },
}
c:part(c:line({ {32, 37}, {32, 35} }, 2), "#2f5a2a", { flat = true, contact = false })
c:part(c:ellipse(36, 36, 2.5, 1.5), "#58a03e", { flat = true, contact = false })
c:part(c:ellipse(32, 26, 2, 2), "wood", { flat = true, contact = false })
c:seam({ {15, 13}, {32, 29}, {49, 13} })
local t = c:save(D .. "img-redraw-full/aseprite/ph/heilala-seed.aseprite", D .. "img-redraw-full/png/ph/heilala-seed.png")
print(GV.report(t))
