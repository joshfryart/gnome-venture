local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon", bleed = "r" }
local pale = GV.ramp("#d6c9b6")
local grey = GV.ramp("#968f96")
-- mortar band behind the blocks (bleeds right)
local parts = {
  { "mortar", c:rect(34, 24, 63, 41), "#5b6470", { gloss = false } },
}
-- two staggered courses of dry stones running right
local top = { {38, 45}, {47, 54}, {56, 63} }
local bot = { {36, 41}, {43, 50}, {52, 59}, {61, 63} }
for i, b in ipairs(top) do
  parts[#parts + 1] = { "t" .. i, c:rrect(b[1], 25, b[2], 32, 2), (i % 2 == 1) and pale or grey, { gloss = false, cres = 2, deep = 1 } }
end
for i, b in ipairs(bot) do
  parts[#parts + 1] = { "b" .. i, c:rrect(b[1], 33, b[2], 40, 2), (i % 2 == 0) and pale or grey, { gloss = false, cres = 2, deep = 1 } }
end
-- big rounded end-stone capping the left
parts[#parts + 1] = { "endstone", c:rrect(12, 19, 37, 45, 6), "#7a7282", { cres = 3 } }
parts[#parts + 1] = { "endface", c:rrect(16, 23, 33, 41, 4), grey, { contact = false } }
local p = c:build(parts)
-- top glints on the blocks
for _, b in ipairs(top) do c:px(b[1] + 2, 26, "#c9c5bc"); c:px(b[1] + 3, 26, "#c9c5bc") end
for _, b in ipairs(bot) do if b[2] - b[1] > 3 then c:px(b[1] + 2, 34, "#c9c5bc") end end
c:ground(24.5, 47, 14, 1.5)
local t = c:save(B .. "img-redraw-full/aseprite/ph/stone-wall-end.aseprite", B .. "img-redraw-full/png/ph/stone-wall-end.png")
print(GV.report(t))
