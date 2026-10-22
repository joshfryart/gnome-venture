local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local parts = {
  { "body", c:rrect(19, 12, 45, 56, 2), "#f1ece0" },
  { "flap", c:poly({ {19, 12}, {46, 12}, {32, 29} }), "#e8dcc0", { gloss = false } },
  { "wax",  c:ellipse(32, 28, 3), "#dd3a2a" },
  { "stalk", c:rect(31, 37, 32, 53), "#2e5a2c", { flat = true } },
}
local beans = { c:ellipse(31.5, 35, 1.5, 2) }
for i, y in ipairs({ 38, 43, 48 }) do
  beans[#beans + 1] = c:ellipse(28.5, y + 2.5, 1.5, 2.5)
  beans[#beans + 1] = c:ellipse(34.5, y + 2.5, 1.5, 2.5)
end
for i, b in ipairs(beans) do
  local col = (i % 2 == 0) and "#f4f0e0" or "#dcb06a"
  parts[#parts + 1] = { "bean" .. i, b, col, { flat = true } }
end
parts[#parts + 1] = { "leaf", c:ellipse(38, 52, 2.5, 1.5), "#58a03e", { flat = true } }
c:build(parts)
c:seam({ {20, 13}, {32, 27} }); c:seam({ {32, 27}, {44, 13} })
for i, b in ipairs(beans) do if i % 2 == 0 then
  local r = b:grow(1):cut(b)
  r:each(function(x, y) local v = true for j, o in ipairs(beans) do if o:has(x, y) then v = false end end
    if v then c:px(x, y, GV.C.umber) end end)
end end
local t = c:save(O .. "aseprite/ph/rice-seed.aseprite", O .. "png/ph/rice-seed.png")
print(GV.report(t))
