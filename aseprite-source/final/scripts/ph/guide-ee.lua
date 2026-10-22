-- ph/guide-ee : upright blue guidebook, dark spine, cream label, gold star seal
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function star(cx, cy, R, r)
  local p = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local rr = (i % 2 == 0) and R or r
    p[#p + 1] = { cx + math.cos(a) * rr, cy + math.sin(a) * rr }
  end
  return c:poly(p)
end
local spineR = GV.ramp("#2f6290", { shade = "#2a3c6c", deep = "#1f2a50" })
c:build{
  { "pages", c:rect(44, 11, 50, 53), "cream", { gloss = false } },
  { "cover", c:rrect(15, 8, 47, 55, 3), "water", { gloss = { 20, 34 } } },
  { "spine", c:rrect(10, 8, 18, 55, 2), spineR, { gloss = false } },
  { "label", c:rrect(22, 15, 41, 29, 2), GV.ramp("#f4f0e0"), { gloss = false } },
  { "star",  star(37, 45, 7, 3), "gold", { gloss = false } },
}
c:fill(c:rect(25, 20, 38, 21), "#4a2c1a")
c:fill(c:rect(25, 24, 33, 25), "#4a2c1a")
c:seam({ {14, 18}, {14, 53} }, { free = true })
c:button(12, 11)
c:px(36, 42, "#fff1c8"); c:px(35, 44, "#fff1c8")
c:ground(31.5, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/guide-ee.aseprite", O .. "png/ph/guide-ee.png")
print(GV.report(t))
