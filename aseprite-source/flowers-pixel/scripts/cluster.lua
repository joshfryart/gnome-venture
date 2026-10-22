-- Gnome Venture flower head: cluster (hydrangea-style dome of 15 florets), Stitched Toy.
-- Petals: neutral greys (runtime tint). Centre: fixed gold French-knot stitches, one per floret.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local OUT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0, close = 0 }

-- neutral grey ramp (no hue), dark-to-light kept apart so a multiply tint still shades
local GREY = { gloss = "#f4f4f4", dot = "#fbfbfb", rim = "#e4e4e4", base = "#cdcdcd",
               bounce = "#b0b0b0", shade = "#a3a3a3", deep = "#7a7a7a", pale = false }
local SPLIT = "#9a9a9a"  -- petal-split creases on each floret

-- floret centres in SVG order (back to front), svg units
local F = {
  {32,14},{21,19},{43,19},{32,26},{13,29},{51,29},{24,29},{40,29},
  {17,40},{47,40},{28,40},{36,40},{32,49},{22,50},{42,50},
}
local R = 6.8
local parts = {}
for i, p in ipairs(F) do
  local cx, cy = p[1] - 0.5, p[2] - 0.5
  local m = c:ellipse(cx, cy, R, R)
  parts[i] = c:part(m, GREY, { cres = 3, deep = 1 })
end

-- 4-petal floret creases: short 1 px plus-arms from the knot, only on that floret's own pixels
local function own(i, x, y) return c.own[c:key(x, y)] == parts[i] end
for i, p in ipairs(F) do
  local x0, y0 = p[1] - 1, p[2] - 1   -- knot top-left (2x2 at x0..x0+1, y0..y0+1)
  local arms = {
    {x0, y0 - 2}, {x0, y0 - 3},             -- up
    {x0 + 1, y0 + 3}, {x0 + 1, y0 + 4},     -- down
    {x0 - 2, y0 + 1}, {x0 - 3, y0 + 1},     -- left
    {x0 + 3, y0}, {x0 + 4, y0},             -- right
  }
  for _, a in ipairs(arms) do
    local k = c:key(a[1], a[2])
    if own(i, a[1], a[2]) and not c.gl.s[k] then c:px(a[1], a[2], SPLIT) end
  end
end

-- gold French knots (fixed colour group)
local centre = {}
local KNOT = { {0,0,"#f5cf6a"}, {1,0,"#e8a317"}, {0,1,"#e8a317"}, {1,1,"#b8661a"} }
for i, p in ipairs(F) do
  local x0, y0 = p[1] - 1, p[2] - 1
  for _, q in ipairs(KNOT) do
    local x, y = x0 + q[1], y0 + q[2]
    if own(i, x, y) then c:px(x, y, q[3]); centre[c:key(x, y)] = true end
  end
end

c:finish()

-- write full, petals-only and centre-only images + a 2-layer .aseprite
local pc = app.pixelColor
local function h2(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function img(filter)
  local im = Image(64, 64, ColorMode.RGB)
  im:clear(pc.rgba(0,0,0,0))
  for k, h in pairs(c.pix) do
    local x, y = c:xy(k)
    local f = filter(k)
    if f == "under" then h = SPLIT end -- petals layer: grey floret pit under each knot (no holes)
    if c:inside(x, y) and f then local r,g,b = h2(h) im:putPixel(x, y, pc.rgba(r,g,b,255)) end
  end
  return im
end
local full   = img(function() return true end)
local petals = img(function(k) return centre[k] and "under" or true end)
local cen    = img(function(k) return centre[k] end)
for _, d in ipairs({"png","aseprite"}) do pcall(function() app.fs.makeAllDirectories(OUT .. d) end) end
local function savePng(im, path) local s = Sprite(64,64,ColorMode.RGB) s.cels[1].image = im s:saveCopyAs(path) s:close() end
savePng(full,   OUT .. "png/cluster.png")
savePng(petals, OUT .. "png/cluster-petals.png")
savePng(cen,    OUT .. "png/cluster-centre.png")
local s = Sprite(64, 64, ColorMode.RGB)
s.layers[1].name = "petals"; s.cels[1].image = petals
local L2 = s:newLayer(); L2.name = "centre"
s:newCel(L2, s.frames[1], cen, Point(0,0))
s:saveAs(OUT .. "aseprite/cluster.aseprite"); s:close()
print(GV.report(GV.check(full)))
