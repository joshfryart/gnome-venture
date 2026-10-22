local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(10, 18, 53, 50, 1)
local flap = c:poly({ {10, 18}, {54, 18}, {32, 36} })
local p = c:build{
  { "body", body, "#f1ece0" },
  { "flap", flap, "#e8dcc0", { gloss = { 16, 20 } } },
}
-- flap shadow under the fold
local sh = c:line({ {13, 21}, {32, 37} }, 2):add(c:line({ {32, 37}, {51, 21} }, 2)):cut(flap)
c:fill(sh:clip(body), "#d9a660")
c:seam({ {11, 19}, {32, 35}, {52, 19} })
-- rye stalk
c:fill(c:rect(31, 40, 32, 49), "#2e5a2c")
local tan, brown = GV.ramp("#dcb06a"), GV.ramp("#a5663a")
local function grain(x, y, r)
  local m = c:ellipse(x, y, 2, 3)
  c:part(m, r, { flat = true, contact = false })
  m:edge():each(function(px, py) if (px - x) + (py - y) > -1 then c:px(px, py, r.deep) end end)
end
for _, y in ipairs({ 38, 42.5, 47 }) do
  grain(28.5, y, tan); grain(35.5, y, brown)
end
grain(32, 34.5, tan)
c:part(c:ellipse(39, 49, 3, 1.5), GV.ramp("#58a03e"), { flat = true, contact = false })
local t = c:save(O .. "aseprite/ph/rye-seed.aseprite", O .. "png/ph/rye-seed.png")
print(GV.report(t))
