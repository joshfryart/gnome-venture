local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pouch = c:ellipse(31.5, 40, 20, 15)
local neck  = c:poly({ {22, 21}, {42, 21}, {38, 28}, {26, 28} })
local frill = c:mask()
for i, x in ipairs({ 21.5, 27, 32.5, 38, 43.5 }) do
  local y = (i == 1 or i == 5) and 17 or 14
  frill:add(c:ellipse(x, y, 3, 3.5))
end
frill:add(c:poly({ {19, 17}, {46, 17}, {41, 22}, {24, 22} }))
local cord  = c:rect(22, 25, 42, 27)
local ends  = c:line({ {38, 27}, {41, 33}, {43, 39} }, 2):add(c:line({ {41, 27}, {46, 31}, {49, 36} }, 2))
local tass  = c:rect(42, 38, 45, 42):add(c:rect(48, 35, 51, 39))
local seed  = c:ellipse(28, 43, 7, 7)

local p = c:build{
  { "pouch", pouch, "wood", { stitch = true } },
  { "neck",  neck,  "wood", { gloss = false } },
  { "frill", frill, GV.ramp("#d9a660"), { gloss = false } },
  { "cord",  cord,  GV.ramp("#f5cf6a"), { flat = true } },
  { "ends",  ends,  GV.ramp("#f5cf6a"), { flat = true } },
  { "tass",  tass,  "gold", { flat = true } },
  { "seed",  seed,  "petal", { gloss = { 25, 39 } } },
}
-- gather lines on frill and neck
for _, x in ipairs({ 24, 30, 35, 41 }) do c:fill(c:rect(x, 15, x, 20), "#8a4f2a") end
c:paint({ "d......d", ".d....d." }, 28, 29, { d = "#8a4f2a" })
-- seed belly
c:paint({ "..bbbbb..", ".b.....b." }, 24, 48, { b = "#a8241f" })
-- sprout
c:fill(c:line({ {28, 38}, {28, 33} }, 2), "#2f5a2a")
c:fill(c:ellipse(31.5, 32, 2.5, 2), "#58a03e")
c:button(30, 24)
c:ground(32, 57, 17, 3)
local t = c:save(O .. "aseprite/ph/croton-seed.aseprite", O .. "png/ph/croton-seed.png")
print(GV.report(t))
