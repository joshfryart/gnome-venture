-- flowers/jar: clear glass mason jar, two layers. Back = shadow + far glass wall + far lip; front = glass walls,
-- threaded neck, twine, felt label and water, with a clear window so the stems show through (hard pixels only).
-- Grid 100x75 written at 2x (200x150). SVG (X,Y) -> grid (X/2, (Y+30)/2); mouth centre (49.5, 23).
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/flowers-pixel/"

local function bez(out, p0, p1, p2, p3, n)
  for i = 1, n do
    local t = i / n; local u = 1 - t
    out[#out+1] = { u^3*p0[1] + 3*u*u*t*p1[1] + 3*u*t*t*p2[1] + t^3*p3[1],
                    u^3*p0[2] + 3*u*u*t*p1[2] + 3*u*t*t*p2[2] + t^3*p3[2] }
  end
  return out
end
local function sym(left)
  local pts = {}
  for _, p in ipairs(left) do pts[#pts+1] = p end
  for i = #left, 1, -1 do pts[#pts+1] = { 99 - left[i][1], left[i][2] } end
  return pts
end
local function canvas() return GV.canvas{ w = 100, h = 75, out = 2, mode = "sticker", halo = 0, close = 0, margin = 0 } end

-- glass (GV.R.glass, water family) for the near walls; a paler cream-blue for the far wall seen through it
local near = GV.R.glass
local far  = GV.ramp("#e3f1ea", { gloss = "#fff3c8", rim = "#eef8f2", shade = "#c8ecdc", deep = "#a9d6ea", bounce = "#cfe9e4", pale = true })
local lipR = GV.ramp("#8fcbd8", { gloss = "#eef8f2", dot = "#f8fcf4", rim = "#c8ecdc", shade = "#6f98c4", deep = "#4e5f9a", bounce = "#8fb4d6" })

local function bodyMask(c)
  local L = { {36, 27} }
  bez(L, {36, 27}, {36, 31}, {28, 33}, {28, 40}, 8)       -- shoulder
  L[#L+1] = {28, 64}
  bez(L, {28, 64}, {28, 69}, {31, 71}, {36, 71}, 6)      -- rounded base
  return c:poly(sym(L))
end
local LIP  = { 49.5, 23, 14.5, 3.5 }
local HOLE = { 49.5, 22.5, 11.5, 2 }

------------------------------------------------------------------ back
do
  local c = canvas()
  local body = bodyMask(c)
  c:part(body, far, { gloss = false, rim = false })
  -- the far half of the base seen through the glass (a lighter arc) and the far wall's soft reflection
  for x = 33, 66 do c:px(x, 66 - ((x < 38 or x > 61) and 1 or 0), "#c8ecdc") end
  for y = 38, 58 do c:px(63, y, "#eef8f2") end
  c:part(c:ellipse(table.unpack(LIP)), lipR, { gloss = false, bounce = false, cres = 3 })
  local hole = c:ellipse(table.unpack(HOLE))
  c:fill(hole, far.base)
  hole:each(function(x, y) if not hole:has(x, y - 1) then c:px(x, y, "#c8ecdc") end end)
  c:ground(49.5, 71, 25, 2.5)
  local t = c:save(O .. "aseprite/jar-back.aseprite", O .. "png/jar-back.png")
  print("jar-back: " .. GV.report(t))
end

------------------------------------------------------------------ front
do
  local c = canvas()
  local body = bodyMask(c)
  local hole = c:ellipse(table.unpack(HOLE))
  local neck = c:rrect(35, 23, 64, 29, 1):add(c:ellipse(table.unpack(LIP)):clip(c:rect(0, 23, 99, 74))):cut(hole)
  local label = c:rrect(38, 44, 61, 57, 2)
  local p = c:build{
    { "body",  body,  near, { gloss = false } },
    { "neck",  neck,  lipR, { gloss = false, light = neck:copy():add(c:rect(35, 18, 64, 32)) } },
  }
  -- clear window: everything 3 px inside the walls (4 at the thick base) is see-through glass
  local win = body:shrink(3):cut(c:rect(0, 66, 99, 74)):cut(c:rect(0, 0, 99, 30))
  -- water at the bottom: hard bands, surface glint line on top
  local water = win:copy():clip(c:rect(0, 60, 99, 65))
  win:cut(water)
  win:each(function(x, y) c.pix[c:key(x, y)] = nil; c.own[c:key(x, y)] = nil end)
  water:each(function(x, y)
    local col = (y == 60) and "#c8ecdc" or ((x > 62) and "#5a86b8" or "#8fcbd8")
    if y == 61 and x > 62 then col = "#8fcbd8" end
    c:px(x, y, col)
  end)
  -- inner edge of the glass wall: 1 px darker line where the wall meets the clear window (thickness)
  win:grow(1):cut(win):clip(body):each(function(x, y)
    if y < 60 and y > 30 then c:px(x, y, (x > 49) and near.shade or "#8fb4d6") end
  end)
  -- the thick glass base: a light band and its glint
  for x = 33, 66 do if c:get(x, 66) then c:px(x, 66, near.rim) end end
  -- vertical reflections over the window (the brightest thing on the jar)
  c:fill(c:rect(32, 33, 33, 56), "#f8fcf4")
  c:fill(c:rect(36, 33, 36, 39), "#eef8f2")
  c:px(33, 58, "#eef8f2")
  c:fill(c:rect(65, 36, 65, 52), "#eef8f2")
  -- threaded neck: two glass threads with shadows
  for x = 36, 63 do
    if c:get(x, 26) then c:px(x, 26, (x < 50) and lipR.rim or lipR.base) end
    if c:get(x, 27) then c:px(x, 27, lipR.shade) end
  end
  -- felt label with an edge stitch, two inked lines
  c:part(label, "cream", { gloss = false, stitch = true, contact = false })
  for x = 44, 55 do c:px(x, 48, "#c9a85a"); c:px(x, 49, "#9a6b3f") end
  for x = 44, 51 do c:px(x, 52, "#c9a85a"); c:px(x, 53, "#9a6b3f") end
  -- twine tied round the neck (thread-gold seam) with the button at the knot
  c:seam({ {35, 29}, {64, 29} }, { free = true, gap = "#b8661a" })
  c:button(37, 28)
  -- open mouth: keep a 1 px inner lip line only
  c:finish()
  hole:each(function(x, y) if not neck:has(x, y + 1) then c.pix[c:key(x, y)] = nil end end)
  -- outline must not fill the clear window (finish only grows outside the silhouette, but be safe)
  local t = c:save(O .. "aseprite/jar-front.aseprite", O .. "png/jar-front.png")
  print("jar-front: " .. GV.report(t))
end
