local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slumped belly: wide, flattened bottom, lumpy shoulders
local body = c:ellipse(31.5, 39, 21, 16):cut(c:rect(0, 54, 63, 63))
body:add(c:rrect(12, 44, 51, 53, 6))
body:add(c:ellipse(22, 31, 8, 6)); body:add(c:ellipse(41, 31, 8, 6))
local neck = c:rrect(26, 18, 37, 28, 2)
-- frayed flared top
local top = c:poly({ {21, 9}, {26, 9}, {29, 12}, {32, 9}, {35, 12}, {38, 9}, {43, 9}, {38, 19}, {26, 19} })
local burlap = GV.ramp("#c9a96e")
local p = c:build{
  { "body", body, burlap, { stitch = true } },
  { "neck", neck, burlap, { gloss = false } },
  { "top",  top,  burlap, { gloss = false } },
}
-- weave ticks
c:paint({ "w.w", ".w." }, 44, 44, { w = "#a8582f" })
c:paint({ "w.w", ".w." }, 18, 46, { w = "#a8582f" })
-- twine wraps + tail
local tw = GV.ramp("#8c4a1a")
c:part(c:rect(24, 20, 39, 21):add(c:rect(24, 23, 39, 24)), tw, { flat = true })
c:part(c:line({ {39, 24}, {43, 30} }, 2), tw, { flat = true })
c:part(c:rect(42, 30, 44, 32), tw, { flat = true })
-- front patch with onion
c:part(c:ellipse(31.5, 41, 9, 8), GV.ramp("#f4f0e0"), { gloss = false, rim = false })
c:part(c:ellipse(31.5, 42, 6, 5.5), "gold", { gloss = { 29, 39 } })
c:part(c:rect(31, 33, 32, 37), GV.ramp("#58a03e"), { flat = true })
c:px(30, 33, "#58a03e"); c:px(33, 34, "#58a03e")
c:paint({ "u..u" }, 30, 47, { u = "#b8661a" })
c:seam({ {14, 32}, {14, 50} })
local t = c:save(D .. "img-redraw-full/aseprite/ph/onion-seed.aseprite", D .. "img-redraw-full/png/ph/onion-seed.png")
print(GV.report(t))
