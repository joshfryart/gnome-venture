-- Badge medals (silver / bronze): a V ribbon at the top and a jigsaw-piece disc below with the place number.
-- Run with BADGE=silver|bronze in the environment, or it does both. Silver borrows stone, bronze borrows wood.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV

local function badge(name, hex, digit)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local ribL = c:poly({ {18, 8}, {28, 8}, {36, 30}, {27, 32} })
  local ribR = c:poly({ {36, 8}, {46, 8}, {37, 32}, {28, 30} })
  local disc = c:ellipse(31.5, 42, 14, 14)
  disc:add(c:ellipse(31.5, 27, 4.5, 4))                               -- knob up (under the ribbon)
  disc:add(c:ellipse(15, 42, 4, 4.5)); disc:add(c:ellipse(48, 42, 4, 4.5))  -- tabs
  disc:cut(c:ellipse(31.5, 57, 4.5, 4))                               -- notch bottom
  local ring = disc:shrink(3):cut(disc:shrink(5))
  local r = GV.ramp(hex, { dot = "#fff3c8" })   -- no pure white on pale silver
  c:build{
    { "ribL", ribL, "red", { gloss = false } },
    { "ribR", ribR, GV.ramp("#b8452f"), { gloss = false, contour = false } },
    { "disc", disc, r, { gloss = { 22, 33 } } },
  }
  c:fill(ring:cut(c:rect(0, 0, 63, 30)):cut(c:rect(22, 30, 41, 35)), r.shade)   -- groove all round, skipping the ribbon tip
  c:seam({ {22, 11}, {26, 22} }); c:seam({ {41, 11}, {37, 22} })
  c:paint(digit, 28, 36, { u = "umber", l = r.gloss })
  c:button(29, 30)
  K.save(c, name)
end

local two = {
  ".uuuuu..",
  "uu...uu.",
  "l....uu.",
  "....uu..",
  "...uu...",
  "..uu....",
  ".uu.....",
  "uuuuuuu.",
  "l.......",
}
local three = {
  ".uuuuu..",
  "uu...uu.",
  "l....uu.",
  "...uuu..",
  ".....uu.",
  "l....uu.",
  "uu...uu.",
  ".uuuuu..",
  "........",
}
badge("badge-silver", "#c9d0da", two)
badge("badge-bronze", "#b8622a", three)
