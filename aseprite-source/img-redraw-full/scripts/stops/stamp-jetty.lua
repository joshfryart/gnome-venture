local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx, cy = 31.5, 31.5
local inner = c:ellipse(cx, cy, 20)
local ring = c:ellipse(cx, cy, 23):cut(c:ellipse(cx, cy, 19))
local water = c:rect(10, 40, 53, 55)
for _, x in ipairs({14, 21, 28, 35, 42, 49}) do water:add(c:ellipse(x, 40, 3.5, 2.5)) end
water:clip(c:ellipse(cx, cy, 19.5))
local posts = c:rect(18, 31, 20, 45):add(c:rect(25, 31, 27, 45)):add(c:rect(32, 31, 34, 45))
local deck = c:rrect(13, 27, 39, 32, 1)
local crane = c:line({ {35, 28}, {37, 15} }, 3)
local jib = c:line({ {37, 15}, {44, 18} }, 2)
local hook = c:line({ {44, 18}, {44, 23} }, 2):add(c:rect(42, 23, 43, 24))
c:build{
  { "disc", inner, "#f1ece0" },
  { "water", water, "water", { stitch = false } },
  { "posts", posts, GV.ramp("#8a4f2a"), { flat = true } },
  { "crane", crane, GV.ramp("#5e2f1e"), { flat = true } },
  { "jib", jib, GV.ramp("#5e2f1e"), { flat = true } },
  { "hook", hook, GV.ramp("#5e2f1e"), { flat = true } },
  { "deck", deck, "wood" },
  { "ring", ring, "wood" },
}
-- dashed stamp ring
local n = 0
for a = 0, 359, 4 do
  n = n + 1
  if n % 3 ~= 0 then
    local x = math.floor(cx + 21.3 * math.cos(math.rad(a)) + 0.5)
    local y = math.floor(cy + 21.3 * math.sin(math.rad(a)) + 0.5)
    c:px(x, y, "#5e2f1e")
  end
end
c:fill(c:rect(36, 29, 37, 30), "#f5cf6a")
c:seam({ {15, 28}, {37, 28} })
local t = c:save(O .. "aseprite/stops/stamp-jetty.aseprite", O .. "png/stops/stamp-jetty.png")
print(GV.report(t))
