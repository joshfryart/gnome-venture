local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local CX, CY = 31.5, 31.5
local INK = "#8a4234"
local function ring(r0, r1) return c:ellipse(CX, CY, r1, r1):cut(c:ellipse(CX, CY, r0, r0)) end
local p = c:build{
  { "paper", c:ellipse(CX, CY, 22, 22), "cream" },
}
-- dotted outer ring: 2 on / 2 off around r 20
local dots = ring(19, 20.5)
dots:each(function(x, y)
  local a = math.atan(y - CY, x - CX)
  local seg = math.floor((a + math.pi) / (2 * math.pi) * 64)
  if seg % 2 == 0 then c:px(x, y, INK) end
end)
-- solid ring and thin inner ring
c:fill(ring(15.5, 17.5), INK)
c:fill(ring(13, 14), INK)
-- tree
c:build{
  { "trunk", c:rect(30, 33, 33, 41):add(c:rect(26, 40, 37, 42)), "wood", { gloss = false } },
  { "crown", c:ellipse(31.5, 26, 8, 7.5), "moss" },
}
-- branch forks into the crown
c:fill(c:line({ { 31, 34 }, { 27, 31 } }, 2), "#a8582f")
c:fill(c:line({ { 32, 34 }, { 36, 30 } }, 2), "#a8582f")
-- fruits
local F = { r = "#dd3a2a", g = "#ff9158", d = "#ae2a2a" }
for _, f in ipairs({ { 26, 24 }, { 34, 22 }, { 31, 28 } }) do
  c:paint({ "gr.", "rrd", ".d." }, f[1], f[2], F)
  c:px(f[1] + 2, f[2], "#4a8a3e")
end
local t = c:save(O .. "aseprite/stops/stamp-orchard.aseprite", O .. "png/stops/stamp-orchard.png")
print(GV.report(t))
