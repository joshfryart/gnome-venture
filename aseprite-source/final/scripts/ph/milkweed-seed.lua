local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- silk tuft strands (behind packet)
local tuft = c:line({ {30, 20}, {27, 15}, {23, 12} }, 2)
tuft:add(c:line({ {32, 20}, {32, 13}, {33, 10} }, 2))
tuft:add(c:line({ {34, 20}, {38, 15}, {42, 12} }, 2))
tuft:add(c:ellipse(22, 11.5, 3, 2)); tuft:add(c:ellipse(33, 9.5, 3, 2)); tuft:add(c:ellipse(43, 11.5, 3, 2))

local packet = c:rrect(14, 18, 50, 55, 3)
local flap = c:poly({ {14, 18}, {51, 18}, {32, 36} }):clip(packet)
local seal = c:ellipse(32, 34, 3)
local label = c:rect(20, 42, 44, 48)

local p = c:build{
  { "tuft", tuft, GV.ramp("#fffaf0", { shade = "#d6c9b6", rim = "#fff3c8" }), { flat = true } },
  { "packet", packet, "cream" },
  { "flap", flap, GV.ramp("#d6c9b6"), { gloss = false } },
  { "label", label, GV.ramp("#6a4528"), { gloss = false } },
  { "seal", seal, GV.ramp("#8a2a1a"), { gloss = { 31, 32 } } },
}
c:seam({ {16, 20}, {29, 33} }); c:seam({ {35, 33}, {48, 20} })
-- tiny seed glyph on label
c:paint({ ".f.", "fgf", ".f." }, 24, 44, { f = "#f1ece0", g = "#c9a96e" })
c:paint({ "fffffffffff" }, 29, 45, { f = "#c9a96e" })
local t = c:save(O .. "aseprite/ph/milkweed-seed.aseprite", O .. "png/ph/milkweed-seed.png")
print(GV.report(t))
