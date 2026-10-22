local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function arrow(cx, cy, w, h, ang)
  local a = math.rad(ang or 0)
  local raw = { {0,-h/2}, {w*0.32,-h*0.05}, {w/2,h*0.32}, {w*0.38,h/2}, {0,h*0.22},
                {-w*0.38,h/2}, {-w/2,h*0.32}, {-w*0.32,-h*0.05} }
  local pts = {}
  for i, p in ipairs(raw) do
    local x = p[1]*math.cos(a) - p[2]*math.sin(a)
    local y = p[1]*math.sin(a) + p[2]*math.cos(a)
    pts[i] = { math.floor(cx + x + 0.5), math.floor(cy + y + 0.5) }
  end
  return c:poly(pts)
end
local p = c:build{
  { "lstem", c:line({ {30,54}, {19,27} }, 2), "#4a8a3e", { flat = true } },
  { "rstem", c:line({ {34,54}, {45,30} }, 2), "#4a8a3e", { flat = true } },
  { "cstem", c:line({ {31,54}, {31,20} }, 3), "#7ab55c", { flat = true } },
  { "lleaf", arrow(16, 21, 15, 17, -30), "#7ab55c", { gloss = {12, 16} } },
  { "rleaf", arrow(47, 23, 15, 17, 28), "#6a9a3a", { gloss = {44, 18} } },
  { "cleaf", arrow(32, 13, 17, 19, 0), GV.ramp("#7ab55c", { rim = "#a4b86a" }), { gloss = {28, 9} } },
  { "band", c:rrect(26, 43, 37, 46, 1), "gold", { gloss = false } },
}
-- veins
c:line({ {19,27}, {14,17} }, 1); c:paint({ "v", "v", "v", "v" }, 15, 18, { v = "#2f5a2a" })
c:paint({ "v", "v", "v", "v", "v" }, 32, 9, { v = "#4a8a3e" })
c:paint({ "v", "v", "v", "v" }, 47, 19, { v = "#2f5a2a" })
c:seam({ {27, 44}, {37, 44} })
local t = c:save(O .. "aseprite/ph/kangkong.aseprite", O .. "png/ph/kangkong.png")
print(GV.report(t))
