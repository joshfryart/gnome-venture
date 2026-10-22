local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local puddle = c:ellipse(32, 36, 23, 16)
puddle:add(c:ellipse(16, 44, 8, 6)); puddle:add(c:ellipse(47, 45, 8, 6))
local eggR = GV.ramp("#d9f1e8", { rim = "#6fa98f" })
-- back to front (top eggs first so lower ones overlap them)
local eggs = {
  { 33, 25, 6.5, 1, 0 },
  { 21, 29, 6.5, 0, 1 },
  { 45, 32, 6.5, -1, 0 },
  { 17, 42, 5.5, 1, 1 },
  { 29, 40, 6.5, 0, 0 },
  { 41, 45, 5.5, -1, 1 },
}
local parts = { { "puddle", puddle, GV.ramp("#b8e0d0"), { gloss = false } } }
for i, e in ipairs(eggs) do
  parts[#parts + 1] = { "egg" .. i, c:ellipse(e[1], e[2], e[3], e[3]), eggR }
end
c:build(parts)
-- tadpole dots, slightly varied offsets and sizes
for i, e in ipairs(eggs) do
  local x, y = math.floor(e[1]) + e[4], math.floor(e[2]) + e[5]
  if e[3] > 6 then
    c:paint({ ".ddd.", "ddddd", "ddddd", ".ddd." }, x - 2, y - 1, { d = "#2b3a2b" })
  else
    c:paint({ ".dd.", "dddd", ".dd." }, x - 1, y - 1, { d = "#2b3a2b" })
  end
  c:px(x - 1, y - 1, "#4a5e48")
end
local t = c:save(O .. "aseprite/animals/item-frogspawn.aseprite", O .. "png/animals/item-frogspawn.png")
print(GV.report(t))
