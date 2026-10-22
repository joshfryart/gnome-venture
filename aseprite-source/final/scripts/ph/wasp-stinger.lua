-- ph/wasp-stinger : pale-amber thorn bowed left, point at top, open base lower left
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"

-- centreline: quadratic from base (26,54) bowing left to tip (31,8)
local function centre(t) return (1 - t) ^ 2 * 26 + 2 * t * (1 - t) * 6 + t * t * 31 end
local body, shade = c:mask(), c:mask()
local cl = {}
for y = 8, 54 do
  local t = (54 - y) / 46
  local cx = centre(t)
  local hw = 10.5 * (1 - t) ^ 0.85
  cl[y] = cx
  for x = 0, 63 do
    if math.abs(x + 0.5 - cx) <= math.max(hw, 0.6) then
      body:set(x, y)
      if x + 0.5 > cx + 1 then shade:set(x, y) end
    end
  end
end
-- open base: shallow notch cut into the bottom
body:cut(c:ellipse(26, 56, 6, 2.5)); shade:clip(body)

c:build{
  { "body",  body,  "#dcb06a", { pale = true, gloss = {18, 40} } },
  { "shade", shade, "#a5663a", { gloss = false, rim = false } },
}

-- cream stripe along the inner (left) curve
local stripe = c:mask()
local pts = {}
for y = 20, 49, 3 do pts[#pts + 1] = { cl[y] - 2.5 * (y - 12) / 42, y } end
stripe:add(c:line(pts, 2)):clip(body:shrink(2))
c:fill(stripe, "#f1ece0")

-- venom bands: curved ticks across the horn
for _, y in ipairs({ 19, 27, 35 }) do
  body:each(function(x, yy)
    if yy == y + math.floor((x - cl[y]) * 0.25 + 0.5) and body:has(x - 1, yy) and body:has(x + 1, yy) then
      c:px(x, yy, "#5e2f1e")
    end
  end)
end

c:ground(27, 57, 13, 2)
local t = c:save(O .. "aseprite/ph/wasp-stinger.aseprite", O .. "png/ph/wasp-stinger.png")
print(GV.report(t))
