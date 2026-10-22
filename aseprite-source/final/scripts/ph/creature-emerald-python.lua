local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function arc(cx, cy, rx, ry, a0, a1, n)
  local pts = {}
  for i = 0, n do
    local a = math.rad(a0 + (a1 - a0) * i / n)
    pts[#pts + 1] = { math.floor(cx + rx * math.cos(a) + 0.5), math.floor(cy + ry * math.sin(a) + 0.5) }
  end
  return pts
end
-- coil ring
local ring = c:ellipse(32, 44, 20, 10):cut(c:ellipse(34, 43, 8, 2.5))
-- belly stripe along the lower front of the coil
local belly = c:line(arc(32, 44, 16, 7, 25, 160, 24), 2)
belly:clip(ring)
-- neck rising from the left of the coil
local neck = c:line({ {18, 47}, {16, 41}, {16, 36}, {18, 31} }, 9)
-- head with snout bulge to the right
local head = c:ellipse(20, 24, 9.5, 8)
head:add(c:ellipse(27, 27, 7, 5))
local p = c:build{
  { "ring", ring, "moss", { stitch = { side = "lit" } } },
  { "belly", belly, GV.ramp("#f8eed2"), { flat = true, contact = false } },
  { "neck", neck, "moss", { contact = false } },
  { "head", head, "moss" },
}
-- back diamonds
local function dia(x, y)
  c:spot(c:poly({ {x, y - 3}, {x + 3, y}, {x, y + 3}, {x - 3, y} }), "#2f5a2a", "#4a8a3e")
end
dia(25, 50); dia(35, 51); dia(44, 49); dia(48, 42); dia(40, 37); dia(30, 37)
-- belly scutes on the neck
c:paint({ "c", "c", ".", "c", "c", ".", "c", "c" }, 20, 34, { c = "#f8eed2" })
-- tongue
c:paint({
  "rr....",
  "..rr.r",
  "....r.",
  "...r.r",
}, 32, 29, { r = "#d6322b" })
-- mouth
c:paint({ "m....m", ".mmmm." }, 24, 29, { m = "#2a1a10" })
-- eyes
c:eye(13, 19); c:eye(21, 19)
c:ground(32, 55, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-emerald-python.aseprite", O .. "png/ph/creature-emerald-python.png")
print(GV.report(t))
