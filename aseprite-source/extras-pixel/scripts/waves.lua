-- puzzles/waves.gif : Stitched Toy redraw. 480x200, 24 frames x 70 ms, loops forever, opaque sunset sky.
-- Drawn on a 240x100 grid, written at 2x nearest. Four felt wave strips slide (looping exactly over 24 frames)
-- under a static stitched sun. Families: sky = red/ember gloss tints, waves = water family, sun = pale cream.
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local OUT = ROOT .. "extras-pixel/"
local W, H, N, DUR = 240, 100, 24, 70
local TAU = math.pi * 2
local floor = math.floor

-- wave strips back to front: base y, amplitude, wavelength, cycles per loop (sign = direction), phase, ramp
local WAVES = {
  { y = 50.5, a = 5.5, l = 162, k = -1, p = 0.0, ramp = GV.ramp("#5a9ad0", { rim = "#8fcbd8", gloss = "#c8ecdc", dot = "#eaf8e4" }) },
  { y = 62.5, a = 6.0, l = 144, k =  2, p = 1.7, ramp = GV.ramp("#3f78b8", { rim = "#6fa6d8", gloss = "#b4dcec", dot = "#dcf2ec" }) },
  { y = 75.0, a = 6.0, l = 180, k = -1, p = 3.4, ramp = GV.ramp("#2f5a9a", { rim = "#5a86b8", gloss = "#8fb4d6" }) },
  { y = 87.5, a = 6.0, l = 198, k =  2, p = 5.0, ramp = GV.ramp("#22396e", { rim = "#3f5a92", gloss = "#6f8cc0" }) },
}
local SKY = { "#ffc27a", "#ffb877", "#ffad72", "#ffa36e", "#ff996a" }

local function top(w, x, f)
  return floor(w.y + w.a * math.sin(TAU * (x / w.l + w.k * f / N) + w.p) + 0.5)
end

local function frame(f)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  c:bands(c:rect(0, 0, W-1, 56), SKY)
  -- sun: pale felt disc with an edge stitch, sits just above the first swell
  c:part(c:ellipse(148.5, 23.5, 16, 16), "#fff1c8", { stitch = {} })
  for i, w in ipairs(WAVES) do
    local nxt = WAVES[i+1]
    local m = c:mask()
    for x = -14, W + 13 do
      local y0 = top(w, x, f)
      local y1 = nxt and (top(nxt, x, f) + 3) or (H + 12)
      for y = y0, y1 do m:set(x, y) end
    end
    c:part(m, w.ramp, { outline = false, contour = false, contact = false, gloss = false, cres = 3, deep = 0 })
    c:outline(m, { ol = 1, olx = 0 })
    -- felt seam 3 px under the crest line; the dashes travel with the water
    local shift = w.k * f * w.l / N
    if i % 2 == 1 then
    for x = 0, W-1 do
      if floor(x + shift + 0.5) % 3 < 2 then
        local y = top(w, x, f) + 3
        if c:get(x, y) == w.ramp.base or c:get(x, y) == w.ramp.rim then c:px(x, y, GV.C.gold) end
      end
    end
    end
    -- enamel glint on each crest (where the strip is highest), moving with it
    for x = 1, W-2 do
      local y = top(w, x, f)
      if y <= top(w, x-1, f) and y < top(w, x+1, f) or (y < top(w, x-1, f) and y <= top(w, x+1, f)) then
        for dx = -4, 1 do
          local yy = top(w, x+dx, f) + 1
          if c:get(x+dx, yy) == w.ramp.base or c:get(x+dx, yy) == w.ramp.rim then c:px(x+dx, yy, w.ramp.gloss) end
        end
        if w.ramp.dot then c:px(x-2, top(w, x-2, f) + 2, w.ramp.dot) end
      end
    end
  end
  return c
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
for f = 0, N-1 do
  if f > 0 then spr:newEmptyFrame() end
  local c = frame(f)
  local img = c:image()
  if f == 0 then print(GV.report(GV.check(img))) end
  spr:newCel(spr.layers[1], spr.frames[f+1], img, Point(0, 0))
  spr.frames[f+1].duration = DUR / 1000
end
spr.layers[1].name = "waves"
for _, d in ipairs({ "aseprite", "png" }) do pcall(function() app.fs.makeAllDirectories(OUT .. d) end) end
spr:saveAs(OUT .. "aseprite/waves.aseprite")
spr:saveCopyAs(OUT .. "png/waves.gif")
spr:close()
print("saved")
