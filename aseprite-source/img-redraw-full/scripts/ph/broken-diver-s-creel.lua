local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- arch handle: semi-ellipse centre (33,36), rx 17, ry 22
local function arc(a0, a1, step)
  local pts = {}
  for a = a0, a1, step do
    local r = math.rad(a)
    pts[#pts + 1] = { math.floor(32 - 17 * math.cos(r) + 0.5), math.floor(34 - 21 * math.sin(r) + 0.5) }
  end
  return pts
end
local hL = c:line(arc(0, 128, 8), 4)          -- left side over the peak, snapped end
local hR = c:line(arc(150, 180, 6), 4)        -- right stub rising from the rim
-- jagged snapped ends
hL:del(42, 16); hL:del(43, 17)
hR:del(44, 22); hR:del(45, 21)

local body = c:poly({ {11, 33}, {54, 33}, {48, 56}, {17, 56} })
body:cut(c:poly({ {44, 56}, {50, 50}, {50, 56} }))   -- chipped lower-right corner
local band1 = c:rect(10, 39, 56, 41):clip(body)
local band2 = c:rect(10, 47, 56, 49):clip(body)
local hatch = c:ellipse(26, 29, 4.5, 4.5)
local loose = c:poly({ {47, 53}, {54, 51}, {55, 54}, {48, 57} })

local p = c:build{
  { "handleL", hL, "wood" },
  { "handleR", hR, "wood" },
  { "body", body, "wood" },
  { "band1", band1, GV.ramp("#f5cf6a", { shade = "#e8a317" }), { flat = true } },
  { "band2", band2, GV.ramp("#f5cf6a", { shade = "#e8a317" }), { flat = true } },
  { "hatch", hatch, GV.ramp("#8a4f2a") },
  { "loose", loose, "wood", { gloss = false } },
}
-- weave texture: short vertical dashes between bands
for _, y in ipairs({ 35, 43, 51 }) do
  for x = 15, 52, 5 do
    if body:has(x, y) and body:has(x, y + 2) and not hatch:grow(1):has(x, y) and not hatch:grow(1):has(x, y + 2) then
      c:px(x, y, GV.R.wood.shade); c:px(x, y + 1, GV.R.wood.shade)
    end
  end
end
-- hatch rim ring + latch
c:px(26, 29, "#5e2f1e"); c:px(27, 29, "#5e2f1e"); c:px(26, 30, "#5e2f1e"); c:px(27, 30, "#5e2f1e")
-- zigzag crack on the body
c:fill(c:line({ {35, 34}, {31, 40}, {37, 47}, {33, 54} }, 2), "#2a1a10")
c:fill(c:line({ {42, 18}, {43, 19} }, 1), "#2a1a10")
local t = c:save(O .. "aseprite/ph/broken-diver-s-creel.aseprite", O .. "png/ph/broken-diver-s-creel.png")
print(GV.report(t))
