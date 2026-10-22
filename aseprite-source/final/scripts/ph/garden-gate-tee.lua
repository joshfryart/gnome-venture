local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pale = GV.ramp("#f4f0e0")
local post = GV.ramp("#d6c9b6")

local function picket(x, y0, y1)
  -- 4 px wide picket with a pointed top
  return c:poly({ {x, y0 + 2}, {x + 2.5, y0 - 0.5}, {x + 5, y0 + 2}, {x + 5, y1 + 1}, {x, y1 + 1} })
end

local parts = {
  { "railH", c:rect(10, 20, 53, 22):add(c:rect(10, 28, 53, 30)), "stone" },
  { "railV", c:rect(28, 31, 29, 52):add(c:rect(34, 31, 35, 52)), "stone", { flat = true } },
}
local px = { 10, 18, 41, 48 }
for i, x in ipairs(px) do
  parts[#parts + 1] = { "pk" .. i, picket(x, 13, 35), pale, { gloss = { x + 1, 16 } } }
end
for i, y in ipairs({ 35, 40, 45, 50 }) do
  parts[#parts + 1] = { "sl" .. i, c:rect(25, y, 38, y + 2), pale, { gloss = false } }
end
parts[#parts + 1] = { "post", c:poly({ {25, 14}, {31.5, 9}, {39, 14}, {39, 34}, {25, 34} }), post }
c:build(parts)
-- inner pale panel on the post
c:part(c:rect(28, 16, 35, 31), pale, { contact = false })
local t = c:save(O .. "aseprite/ph/garden-gate-tee.aseprite", O .. "png/ph/garden-gate-tee.png")
print(GV.report(t))
