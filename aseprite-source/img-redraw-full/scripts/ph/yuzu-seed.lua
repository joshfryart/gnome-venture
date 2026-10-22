local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local flag = c:poly({ {40, 19}, {47, 7}, {52, 19} })
local crate = c:rrect(13, 18, 51, 55, 3)
local postL = c:rect(13, 18, 17, 55)
local postR = c:rect(47, 18, 51, 55)
local open = c:rrect(21, 28, 43, 48, 5)
local seed = c:ellipse(32, 40, 7, 7)
local leaf = c:poly({ {33, 33}, {36, 29}, {40, 28}, {39, 32}, {35, 34} })
local p = c:build{
  { "flag", flag, GV.ramp("#2f5a2a", { base = "#3f7a34" }), { gloss = false } },
  { "crate", crate, "wood", { gloss = { 20, 21 } } },
  { "postL", postL, GV.ramp("#a8582f"), { flat = true } },
  { "postR", postR, GV.ramp("#a8582f"), { flat = true } },
  { "open", open, GV.ramp("#f4f0e0"), { gloss = false } },
  { "seed", seed, GV.ramp("#f5cf6a", { shade = "#e8a317" }) },
  { "leaf", leaf, GV.ramp("#58a03e"), { flat = true } },
}
-- slat grooves (outside the opening)
for _, y in ipairs({ 23, 36, 51 }) do
  local g = c:rect(18, y, 46, y + 1):cut(open:grow(1))
  c:fill(g, "#8a4f2a")
end
c:fill(open:edge(), "#f5cf6a")
c:fill(c:rect(32, 31, 32, 33), "#2e5a2c")
for _, q in ipairs({ {14, 21}, {48, 21}, {14, 51}, {48, 51} }) do
  c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#ecc58a")
end
c:ground(32, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/yuzu-seed.aseprite", O .. "png/ph/yuzu-seed.png")
print(GV.report(t))
