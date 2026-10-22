local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- sagging cloth: band between upper curve and lower curve
local cloth = c:mask()
for x = 12, 51 do
  local u = (x - 31.5) / 19.5
  local top = math.floor(22 + 14 * (1 - u * u) + 0.5)
  local bot = math.floor(30 + 16 * (1 - u * u) + 0.5)
  for y = top, bot do cloth:set(x, y) end
end
local band = c:mask()
cloth:each(function(x, y)
  local u = (x - 31.5) / 19.5
  if y >= math.floor(22 + 14 * (1 - u * u) + 0.5) + 8 then band:set(x, y) end
end)
local top = cloth:copy():cut(band)

local cl = GV.ramp("#5a86b8", { shade = "#2f6290", deep = "#2a3c6c" })
local p = c:build{
  { "postL", c:rrect(6, 18, 11, 56, 1), "wood" },
  { "postR", c:rrect(52, 18, 57, 56, 1), "wood" },
  { "band", band, GV.ramp("#3f8fb0", { shade = "#2f6290", deep = "#2a3c6c" }), { light = cloth, gloss = false } },
  { "cloth", top, cl, { light = cloth, gloss = { 17, 27 } } },
}
-- post caps
c:fill(c:rect(6, 18, 11, 19), "#d9a660")
-- ropes from post tops to cloth ends
c:fill(c:line({ { 10, 20 }, { 13, 23 } }, 2), "#d9a660")
c:fill(c:line({ { 52, 20 }, { 50, 23 } }, 2), "#d9a660")
-- stars
local star = { "..g..", ".ggg.", "ggggg", ".ggg.", "..g.." }
c:paint(star, 22, 36, { g = "#f5cf6a" })
c:paint(star, 38, 36, { g = "#f5cf6a" })
c:px(24, 38, "#fff1c8"); c:px(40, 38, "#fff1c8")
-- hem stitch along the cloth's top seam with band
local pts = {}
for x = 14, 50, 2 do
  local u = (x - 31.5) / 19.5
  pts[#pts + 1] = { x, math.floor(22 + 14 * (1 - u * u) + 0.5) + 8 }
end
c:seam(pts)
c:ground(31.5, 57, 28, 1.5)
local t = c:save(O .. "aseprite/ph/starlight-hammock.aseprite", O .. "png/ph/starlight-hammock.png")
print(GV.report(t))
