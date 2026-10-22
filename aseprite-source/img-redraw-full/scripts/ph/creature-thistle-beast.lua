local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx, cy = 31.5, 32
-- spike ring: triangles, skipping the bottom arc where the feet stand
local spikes = c:mask()
local n = 14
for i = 0, n - 1 do
  local a = -math.pi / 2 + (i + 0.5) * 2 * math.pi / n
  local deg = math.deg(a) % 360
  if not (deg > 60 and deg < 120) then
    local h = 0.2
    local b1 = { cx + 13 * math.cos(a - h), cy + 11.5 * math.sin(a - h) }
    local b2 = { cx + 13 * math.cos(a + h), cy + 11.5 * math.sin(a + h) }
    local t  = { cx + 22 * math.cos(a), cy + 21 * math.sin(a) }
    spikes:add(c:poly({ b1, t, b2, { cx, cy } }))
  end
end
local feet = c:ellipse(25, 48, 5, 2.5):add(c:ellipse(38, 48, 5, 2.5))
local body = c:ellipse(cx, cy + 1, 15, 13.5)
local tuft = c:ellipse(cx, 21, 10, 6.5)
local bristles = c:mask()
local xs = { 24, 27.5, 31, 34, 37.5 }
local tops = { {21, 12}, {26, 10}, {31, 9}, {35, 9}, {40, 10}, {43, 13} }
local bases = { {25, 17}, {28, 16}, {31, 15}, {34, 15}, {37, 16}, {39, 17} }
for i = 1, 6 do bristles:add(c:line({ bases[i], tops[i] }, 2)) end
local p = c:build{
  { "spikes", spikes, GV.ramp("#3f7a34"), { gloss = false, contact = false, rim = true } },
  { "feet", feet, "#4a8a3e", { flat = true } },
  { "bristles", bristles, "#d9667f", { flat = true } },
  { "body", body, "moss", { stitch = { side = "lit" } } },
  { "tuft", tuft, "#4e3a8a", { gloss = { 25, 17 } } },
}
-- thistle bract seam where tuft meets body
c:seam({ {23, 26}, {40, 26} })
c:eye(23, 30); c:eye(35, 30)
c:paint({
  "m.........m",
  ".m.......m.",
  "..mmmmmmm..",
}, 26, 38, { m = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/creature-thistle-beast.aseprite", O .. "png/ph/creature-thistle-beast.png")
print(GV.report(t))
