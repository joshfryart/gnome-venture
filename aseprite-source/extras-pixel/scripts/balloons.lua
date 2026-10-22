-- puzzles/balloons.gif : felt balloons rising past dusk mountains (Stitched Toy, scene mode)
-- 240x400, 24 frames x 70 ms, loops forever. Drawn on a 120x200 grid, written at 2x nearest.
-- Families: sky = dusk -> petal/ember bands; mountains = dusk (darkened); balloons = red, gold,
-- water, moss, petal, and a lilac borrowed from dusk (#8f6ac8 via GV.ramp). Strings = stone.
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT_ASE = D .. "extras-pixel/aseprite/balloons.aseprite"
local OUT_GIF = D .. "extras-pixel/png/balloons.gif"
local W, H, N, DUR = 120, 200, 24, 0.07
local floor, sin, pi = math.floor, math.sin, math.pi

local SKY = { "#291d4a", "#33255a", "#3e2f66", "#54447f", "#6e4f86", "#8f5a84", "#b0687e", "#cf7c78", "#e8987a" }
local MOUNT = GV.ramp("#2c2450")

-- stars: x, y, colour, twinkle period (divides 24), phase
local STARS = {
  {7,10,"#f2e4c0",8,0}, {20,21,"#c8ecdc",12,3}, {56,17,"#f2e4c0",6,2}, {83,8,"#f5cf6a",8,5},
  {108,30,"#f2e4c0",12,7}, {5,46,"#f2e4c0",8,4}, {38,40,"#f5cf6a",6,1}, {72,47,"#c8ecdc",8,2},
  {98,58,"#f2e4c0",6,4}, {14,78,"#c8ecdc",12,10}, {58,88,"#f2e4c0",8,6}, {115,84,"#f5cf6a",12,1},
  {30,104,"#f2e4c0",6,3}, {86,100,"#c8ecdc",8,1}, {104,112,"#f2e4c0",12,5}, {64,122,"#f5cf6a",8,3},
  {20,132,"#f2e4c0",12,8}, {44,150,"#c8ecdc",6,0}, {92,140,"#f2e4c0",8,7},
}

-- balloons: ramp, home x, radius x, radius y, sway amplitude, sway phase
local BALL = {
  { "red",            30, 14, 17, 3, 0.0 },
  { "gold",           88, 15, 19, 4, 1.7 },
  { GV.ramp("#8f6ac8"), 56, 13, 16, 3, 3.1 },
  { "water",          24, 17, 21, 4, 4.4 },
  { "moss",           94, 15, 18, 3, 2.3 },
  { "petal",          60, 14, 17, 4, 5.2 },
}
local SPEED, START = 12, 222  -- half-grid px per frame; 24 x 12 = 288 px path, so each loops once

local function star(c, s, f)
  local x, y, col, per, ph = s[1], s[2], s[3], s[4], s[5]
  local t = (f + ph) % per
  if t == 0 then               -- twinkle: plus shape with a bright core
    c:px(x, y, "#fff1c8")
    c:px(x-1, y, col); c:px(x+1, y, col); c:px(x, y-1, col); c:px(x, y+1, col)
  elseif t == per - 1 then     -- dark beat
  else
    c:px(x, y, col)
  end
end

local function balloon(c, b, p)
  local ramp, hx, rx, ry, amp, ph = b[1], b[2], b[3], b[4], b[5], b[6]
  local a = 2 * pi * p / N + ph
  local cx = hx + floor(amp * sin(a) + 0.5) + 0.5
  local cy = START - SPEED * p
  local bot = cy + ry
  -- body plus a 4x3 tied neck in one mask, so it outlines as one shape
  local m = c:ellipse(cx, cy, rx, ry)
  m:add(c:rect(floor(cx) - 1, bot, floor(cx) + 2, bot + 3))
  m:add(c:rect(floor(cx) - 2, bot + 3, floor(cx) + 3, bot + 4))
  c:part(m, ramp)
  -- panel seam: a curved meridian down the balloon, thread gold 2 on / 1 off
  local pts = {}
  for i = 0, 8 do
    local yy = cy - ry + 2 + (2 * ry - 4) * i / 8
    local tt = (yy - (cy - ry)) / (2 * ry)
    pts[#pts+1] = { floor(cx + 3 - 5 * sin(pi * tt) + 0.5), floor(yy + 0.5) }
  end
  c:seam(pts)
  c:button(floor(cx) - 1, bot + 1)  -- the tie is the join
  -- string: 1 px (2 px written), swinging opposite the sway, ending in a little ribbon-tied box
  local lag = floor(-2 * sin(a) + 0.5)
  local sx, sy = floor(cx), bot + 5
  local s1 = { sx + lag, sy + 10 }
  local s2 = { sx + lag * 2, sy + 21 }
  c:fill(c:line({ { sx, sy }, s1, s2 }, 1), "#c9c5bc")
  local bx, by = s2[1] - 2, s2[2] + 1
  c:part(c:rect(bx, by, bx + 4, by + 4), "wood", { flat = true, contact = false })
  c:seam({ { bx + 2, by }, { bx + 2, by + 4 } }, { on = 1, off = 0 })
end

local function frame(f)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:bands(c:rect(0, 0, W - 1, 176), SKY)
  c:fill(c:rect(0, 177, W - 1, H - 1), SKY[#SKY])
  for _, s in ipairs(STARS) do star(c, s, f) end
  local mt = c:poly({ {-4, 168}, {36, 152}, {70, 173}, {100, 158}, {124, 172}, {124, 204}, {-4, 204} })
  c:part(mt, MOUNT, { gloss = false, stitch = { side = "lit" } })
  -- back to front: higher balloons (further along) first so lower ones overlap them
  local order = {}
  for i, b in ipairs(BALL) do order[#order+1] = { b, (f + (i - 1) * 4) % N } end
  table.sort(order, function(u, v) return u[2] > v[2] end)
  for _, o in ipairs(order) do balloon(c, o[1], o[2]) end
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
for f = 0, N - 1 do
  local fr = (f == 0) and spr.frames[1] or spr:newEmptyFrame()
  fr.duration = DUR
  local img = frame(f)
  if f == 0 then spr.cels[1].image = img else spr:newCel(layer, fr, img) end
  if f == 0 then print(GV.report(GV.check(img))) end
end
pcall(function() app.fs.makeAllDirectories(app.fs.filePath(OUT_ASE)) end)
pcall(function() app.fs.makeAllDirectories(app.fs.filePath(OUT_GIF)) end)
spr:saveAs(OUT_ASE)
spr:saveCopyAs(OUT_GIF)
print("frames", #spr.frames)
spr:close()
