local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local OUT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- quill fan: triangles radiating from (40,52), tips on r28
local cx, cy = 40, 52
local function quill(a, half, r0, r1)
  local ra, rb = math.rad(a - half), math.rad(a + half)
  local rt = math.rad(a)
  return c:poly({
    { cx + r0 * math.cos(ra), cy - r0 * math.sin(ra) },
    { cx + r1 * math.cos(rt), cy - r1 * math.sin(rt) },
    { cx + r0 * math.cos(rb), cy - r0 * math.sin(rb) },
  })
end
local dark, lite = c:mask(), c:ellipse(40, 52, 22, 20)
local n = 14
for i = 0, n - 1 do
  local a = 180 - i * 180 / (n - 1)
  local q = quill(a, 10, 14, 30.5)
  if i % 2 == 0 then lite:add(q) else dark:add(q) end
end
-- dark quills sit behind; extend them slightly between the light ones
for i = 0, n - 2 do
  local a = 180 - (i + 0.5) * 180 / (n - 1)
  dark:add(quill(a, 8, 14, 27))
end

local jacket = c:ellipse(40, 102, 34, 26)
local bib = c:poly({ {26, 82}, {54, 82}, {59, 100}, {21, 100} })
local face = c:ellipse(40, 56, 17, 16):add(c:ellipse(40, 50, 18, 7))

-- headband arc
local band = {}
for t = 0, 10 do
  local u = t / 10
  local x = (1-u)^2 * 21 + 2*(1-u)*u * 40 + u^2 * 59
  local y = (1-u)^2 * 41 + 2*(1-u)*u * 33 + u^2 * 41
  band[#band+1] = { math.floor(x + 0.5), math.floor(y + 0.5) }
end

local p = c:build{
  { "disc",   c:ellipse(40, 50, 36), "moss", { solid = true } },
  { "jacket", jacket, GV.ramp("#a5663a", { shade = "#8c4a1a" }), { stitch = true } },
  { "bib",    bib, GV.ramp("#f8eed2") },
  { "lapelL", c:line({ {28, 80}, {32, 86} }, 2), GV.ramp("#f8eed2"), { flat = true } },
  { "lapelR", c:line({ {52, 80}, {48, 86} }, 2), GV.ramp("#f8eed2"), { flat = true } },
  { "qdark",  dark, GV.ramp("#44281c"), { gloss = false } },
  { "quills", lite, GV.ramp("#8c4a1a") },
  { "face",   face, GV.ramp("#f8eed2") },
  { "band",   c:line(band, 3), GV.ramp("#d9667f"), { flat = true } },
  { "bead",   c:ellipse(54, 37, 3), GV.ramp("#9c2a1e") },
}

-- bib seams
c:seam({ {27, 85}, {23, 99} })
c:seam({ {53, 85}, {57, 99} })

-- nose
c:fill(c:ellipse(40, 62, 3.5, 2.5), "#2a1a10")
c:px(38, 60, "#7a6050")
-- eyes
c:eye(30, 47); c:eye(46, 47)
-- smile
c:paint({ "u.......u", ".uu...uu.", "...uuu..." }, 36, 66, { u = "umber" })

local t = c:save(OUT .. "aseprite/ph/npc-cricket-hollowell.aseprite", OUT .. "png/ph/npc-cricket-hollowell.png")
print(GV.report(t))
