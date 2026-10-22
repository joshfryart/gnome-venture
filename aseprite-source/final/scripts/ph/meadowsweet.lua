local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tips = { {15,25}, {22,19}, {32,17}, {42,19}, {49,25} }
local stems = c:mask()
for _, t in ipairs(tips) do stems:add(c:line({ {32,50}, t }, 3)) end
local leafR = GV.ramp("#58a03e")
local creamR = GV.ramp("#f6e8c8", { gloss = "#fff3c8", rim = "#f5b860" })
-- side puffs (3 overlapping circles each), centre puff bigger
local function puff(x, y)
  local m = c:ellipse(x, y - 2, 3.5, 3)
  m:add(c:ellipse(x - 3, y + 1, 3, 3))
  m:add(c:ellipse(x + 3, y + 1, 3, 3))
  return m
end
local pl = puff(15, 23); pl:add(puff(49, 23))
local pm = puff(22, 18); pm:add(puff(42, 18))
local pc = c:ellipse(32, 15, 5.5, 4.5); pc:add(c:ellipse(28, 18, 3, 3)); pc:add(c:ellipse(36, 18, 3, 3))
local tails = c:line({ {30,49}, {25,56} }, 3):add(c:line({ {34,49}, {39,56} }, 3))
local p = c:build{
  { "stems", stems, leafR, { light = stems } },
  { "outer", pl, creamR, { gloss = false } },
  { "mid",   pm, creamR, { gloss = false } },
  { "centre", pc, creamR },
  { "tails", tails, "#b8452f", { flat = true } },
  { "wrap",  c:rrect(24, 43, 40, 50, 2), "red" },
}
-- tiny florets texture on puffs
for _, q in ipairs({ {14,21},{17,25},{21,16},{24,20},{41,16},{44,20},{48,21},{51,25},{30,13},{34,16},{28,19} }) do
  c:px(q[1], q[2], creamR.shade)
end
c:seam({ {25, 48}, {39, 48} })
c:button(30, 44)
local t = c:save(O .. "aseprite/ph/meadowsweet.aseprite", O .. "png/ph/meadowsweet.png")
print(GV.report(t))
