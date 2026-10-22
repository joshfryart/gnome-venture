local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pages = c:rrect(16, 50, 51, 56, 2)
local cover = c:rrect(14, 8, 52, 53, 4):add(c:rect(14, 8, 18, 53))
local spine = c:rrect(10, 8, 17, 56, 2)
local plate = c:rrect(22, 15, 46, 30, 3)
local starPts = {}
for i = 0, 9 do
  local a = -math.pi / 2 + i * math.pi / 5
  local r = (i % 2 == 0) and 8 or 3.8
  starPts[#starPts + 1] = { 39.5 + r * math.cos(a), 42 + r * math.sin(a) }
end
c:build{
  { "pages", pages, "cream", { gloss = false, cres = 2 } },
  { "cover", cover, GV.ramp("#b07a10") },
  { "spine", spine, GV.ramp("#44281c"), { cres = 3 } },
  { "plate", plate, "cream", { gloss = false, cres = 2 } },
  { "star", c:poly(starPts), GV.ramp("#f5cf6a"), { cres = 3 } },
}
-- page lines on the bottom edge
for x = 20, 48, 3 do c:px(x, 53, "#c9a96e") end
-- wave on the plate
c:paint({
  ".ww.....ww.....ww.",
  "w..w...w..w...w..w",
  "....w.w....w.w....",
  ".....w......w.....",
}, 25, 21, { w = "#2f6290" })
-- corner caps on the cover
c:paint({ "..gg", ".ggg", "gggg" }, 48, 9, { g = GV.R.gold.base })
c:seam({ {18, 10}, {18, 54} }, { free = true })
local t = c:save(B .. "aseprite/ph/guide-sea.aseprite", B .. "png/ph/guide-sea.png")
print(GV.report(t))
