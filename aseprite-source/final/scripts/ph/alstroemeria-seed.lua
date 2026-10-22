local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({ {13,16}, {51,16}, {51,57}, {13,57} })
local flap = c:poly({ {13,18}, {17,10}, {47,10}, {51,18}, {51,21}, {32,28}, {13,21} })
local label = c:rrect(18, 29, 46, 50, 5)
local petals = c:mask()
for i = 0, 4 do
  local a = -math.pi/2 + i * 2*math.pi/5
  petals:add(c:ellipse(32 + math.cos(a)*4.5, 37 + math.sin(a)*4.5, 3, 3))
end
local stem = c:rect(31, 42, 32, 48)
local leaf = c:poly({ {33,46}, {38,42}, {39,43}, {35,47} })
local p = c:build{
  { "body",  body,  "water", { stitch = true } },
  { "flap",  flap,  GV.ramp("#22607e") },
  { "label", label, "cream" },
  { "stem",  stem:add(leaf), "moss", { flat = true } },
  { "petals", petals, "petal" },
  { "centre", c:ellipse(31.5, 36.5, 2, 2), "gold", { flat = true } },
}
for _, x in ipairs({ 24, 31, 38 }) do
  c:part(c:ellipse(x + 0.5, 53.5, 2, 1.5), "wood", { flat = true })
end
c:seam({ {14,22}, {32,29}, {50,22} })
local t = c:save(O .. "aseprite/ph/alstroemeria-seed.aseprite", O .. "png/ph/alstroemeria-seed.png")
print(GV.report(t))
