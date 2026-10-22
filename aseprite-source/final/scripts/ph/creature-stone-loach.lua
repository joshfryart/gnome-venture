local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fin = GV.ramp("#5f6a62")
local body = c:poly({ {13,31},{20,29},{27,28},{34,29},{41,28},{47,26},{51,26},{54,28},{56,31},{56,34},{54,36},{51,38},
  {44,39},{34,38},{26,37},{19,36},{13,35} })
local tail = c:poly({ {16,31},{11,25},{13,32},{11,40},{16,35} })
local dors = c:poly({ {23,30},{26,23},{29,27},{31,22},{35,30} }):add(c:poly({ {39,30},{43,23},{47,28} }))
local pec = c:poly({ {41,37},{39,43},{46,38} })
local p = c:build{
  { "tail", tail, fin, { flat = true } },
  { "dorsal", dors, fin, { flat = true } },
  { "pec", pec, fin, { flat = true } },
  { "body", body, GV.ramp("#8d9a90"), { gloss = { 30, 31 } } },
}
-- whiskers (barbels) drooping from the snout
c:part(c:line({ {53,36},{55,40} }, 2), "#6e7685", { flat = true })
c:part(c:line({ {51,37},{52,42} }, 2), "#6e7685", { flat = true })
-- wavy back stripe
local st = c:line({ {16,32},{22,31},{28,30},{34,31},{40,30},{46,28},{50,28} }, 1)
c:fill(st, "#5f6a62")
-- mottle diamonds
local dia = { ".x.", "xxx", ".x." }
for _, d in ipairs({ {19,33},{26,34},{33,33},{40,34},{46,33},{37,35} }) do
  c:spot(c:ascii(dia, d[1], d[2]), "#5f6a62")
end
-- mouth
c:px(55, 34, "#4a2c1a"); c:px(54, 35, "#4a2c1a")
c:eye(48, 30, true)
local t = c:save(O .. "aseprite/ph/creature-stone-loach.aseprite", O .. "png/ph/creature-stone-loach.png")
print(GV.report(t))
