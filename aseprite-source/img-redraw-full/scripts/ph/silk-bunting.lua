local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local silk = GV.ramp("#f1ece0", { shade = "#dcb06a", deep = "#b07a45", bounce = "#f5b860" })
local function cy(x) local u = (x - 32) / 23; return 18 + 9 * (1 - u * u) end
local pts = {}
for x = 9, 55, 2 do pts[#pts + 1] = { x, math.floor(cy(x) + 0.5) } end
local parts = { { "cord", c:line(pts, 2), silk, { flat = true, contact = false } } }
local flags = {
  { 12, 14, "red", true }, { 22, 17, "gold", false }, { 32, 20, "#3f8fb0", true },
  { 42, 17, "moss", false }, { 52, 13, "petal", false },
}
local tops = {}
for i, f in ipairs(flags) do
  local x0, x1 = f[1] - 3, f[1] + 3
  local y0, y1 = math.floor(cy(x0)) + 2, math.floor(cy(x1)) + 2
  local tipy = math.floor(cy(f[1])) + f[2]
  local m = c:poly({ { x0, y0 }, { x1 + 1, y1 }, { f[1] + 1, tipy }, { f[1] - 1, tipy } })
  parts[#parts + 1] = { "p" .. i, m, f[3], { gloss = f[4] and nil or false } }
  tops[i] = { x0, y0, x1, y1 }
end
c:build(parts)
for _, t in ipairs(tops) do c:seam({ { t[1] + 2, t[2] + 2 }, { t[3] - 2, t[4] + 2 } }) end
c:button(7, 16); c:button(53, 16)
local t = c:save(O .. "aseprite/ph/silk-bunting.aseprite", O .. "png/ph/silk-bunting.png")
print(GV.report(t))
