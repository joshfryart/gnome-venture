local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- bell silhouette: rounded dome, straight-ish waist, flared skirt with scalloped hem
local function bell(x0, x1, y0, y1)
  local w = x1 - x0
  local cx = (x0 + x1) / 2
  local h = y1 - y0
  local dome = c:ellipse(cx, y0 + w * 0.22, w * 0.24, w * 0.22)
  local body = c:poly({
    { math.floor(cx - w * 0.24), math.floor(y0 + w * 0.22) },
    { math.floor(cx + w * 0.24) + 1, math.floor(y0 + w * 0.22) },
    { math.floor(cx + w * 0.25) + 1, math.floor(y0 + h * 0.66) },
    { x1 + 1, y1 },
    { x0, y1 },
    { math.floor(cx - w * 0.25), math.floor(y0 + h * 0.66) },
  })
  body:add(dome)
  -- flared petal tips at the hem
  local n = 4
  for i = 0, n - 1 do
    local tx = x0 + (i + 0.5) * (w / n)
    body:add(c:ellipse(tx, y1, w / n / 2, 2))
  end
  return body
end

local small = bell(37, 55, 16, 36)
local big = bell(7, 41, 6, 45)
local rim = c:ellipse(24, 45, 14, 2)

local p = c:build{
  { "small", small, GV.ramp("#2f6290") },
  { "sclap", c:rect(45, 39, 47, 41), "gold", { flat = true } },
  { "big", big, GV.ramp("#5a86b8"), { gloss = { 16, 13 } } },
  { "rim", rim, GV.ramp("#2a3c6c"), { flat = true, contact = false } },
  { "bclap", c:rrect(22, 50, 25, 53, 1), "gold", { flat = true } },
}
-- clapper threads
c:fill(c:rect(46, 38, 46, 38), "#e8a317")
c:fill(c:rect(23, 48, 24, 49), "#e8a317")
local t = c:save(D .. "img-redraw-full/aseprite/flowers/bell.aseprite", D .. "img-redraw-full/png/flowers/bell.png")
print(GV.report(t))
