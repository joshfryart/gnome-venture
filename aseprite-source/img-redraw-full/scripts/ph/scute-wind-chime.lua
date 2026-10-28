local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local silk = GV.ramp("#f1ece0", { shade = "#dcb06a", deep = "#b07a45", bounce = "#f5b860" })
local dark = GV.ramp("#8a4f2a", { rim = "#d9a660", deep = "#5e2f1e" })
local warm = GV.ramp("#a8582f", { rim = "#d9a660", deep = "#5e2f1e" })
local function hex(x, y, a, b) -- pointy-top hexagon, half-width a, half-height b
  local q = math.floor(b / 2)
  return c:poly({ {x - a, y - q}, {x + 0.5, y - b}, {x + a + 1, y - q}, {x + a + 1, y + q + 1},
                  {x + 0.5, y + b + 1}, {x - a, y + q + 1} })
end
local sc = { {12, 32, dark}, {22, 43, warm}, {32, 49, dark}, {42, 38, warm}, {52, 29, dark} }
local parts = {
  { "loop", c:ellipse(32.5, 9, 4, 3):cut(c:ellipse(32.5, 9, 1.5, 1)), silk, { flat = true, contact = false } },
}
for i, s in ipairs(sc) do
  local top = s[1] == 32 and 36 or s[2] - 6
  parts[#parts + 1] = { "st" .. i, c:rect(s[1], 18, s[1] + 1, top), silk, { flat = true, contact = false, solid = false } }
end
parts[#parts + 1] = { "bar", c:rrect(9, 12, 55, 18, 2), "wood" }
for i, s in ipairs(sc) do
  parts[#parts + 1] = { "sc" .. i, hex(s[1], s[2], 3, 6), s[3], { gloss = { s[1] - 2, s[2] - 3 } } }
end
parts[#parts + 1] = { "clap", c:ellipse(32.5, 31, 3.5, 3.5), "gold", { gloss = { 31, 29 } } }
for i, s in ipairs(sc) do
  parts[#parts + 1] = { "kn" .. i, c:rrect(s[1] - 1, s[2] - 8, s[1] + 2, s[2] - 6, 1), silk, { flat = true, contact = false } }
end
c:build(parts)
for _, s in ipairs(sc) do
  local ring = hex(s[1], s[2], 1, 4):edge()
  ring:each(function(x, y)
    c:px(x, y, ((x - s[1]) + (y - s[2]) <= 0) and "#d9a660" or "#5e2f1e")
  end)
  c:paint({ ".s.", "sss", ".s." }, s[1] - 1 + (s[1] % 1), s[2] - 1, { s = "#b07a45" })
end
c:seam({ {12, 15}, {53, 15} })
c:button(30, 13)
local t = c:save(O .. "aseprite/ph/scute-wind-chime.aseprite", O .. "png/ph/scute-wind-chime.png")
print(GV.report(t))
