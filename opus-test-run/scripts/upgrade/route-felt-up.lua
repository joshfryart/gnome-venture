-- Upgrade of mockup A felt strip + thread tiles (pins left to the original script).
local L = dofile("/home/user/gnome-venture/aseprite-source/route-mockups/route-lib.lua")
L.SRC = "/home/user/gnome-venture/opus-test-run/aseprite/route/"
L.OUT = "/home/user/gnome-venture/opus-test-run/game/assets/img/route/"
local px = L.px
local UMB, LIP, LIP2, HI, FELT, FELT2, FELTD, WEAVE = "#2a1a10", "#9a6b3f", "#74462a", "#5e3a24", "#4a2c1a", "#3d2a1c", "#2a1a10", "#553320"
local G3, G5, G7, GW = "#f5cf6a", "#e8a317", "#b07a10", "#fff1c8"

-- all periods divide 6, so 12-wide cap and 18-wide strip join and repeat cleanly
local function band(img, x0, w)
  for x = x0, x0 + w - 1 do
    px(img, x, 0, UMB); px(img, x, 1, LIP); px(img, x, 2, LIP2)
    for y = 3, 26 do
      local c = FELT
      if y <= 6 then c = HI elseif y >= 21 then c = FELT2 end
      -- soft fold: a 1px dither step between bands
      if y == 7 and x % 2 == 0 then c = HI end
      if y == 20 and x % 2 == 1 then c = FELT2 end
      -- weave: sparse diagonal twill flecks
      if y >= 8 and y <= 19 and (x + y) % 6 == 0 and y % 2 == 0 then c = WEAVE end
      if y >= 8 and y <= 19 and (x - y) % 6 == 3 and y % 2 == 1 then c = FELT2 end
      px(img, x, y, c)
    end
    px(img, x, 27, FELTD); px(img, x, 28, UMB); px(img, x, 29, UMB)
    -- hem: 2-on-1-off running stitch with a tiny cast shadow
    if x % 3 ~= 2 then px(img, x, 4, G5); px(img, x, 5, LIP2)
                       px(img, x, 24, G7); px(img, x, 25, FELTD)
    else px(img, x, 4, FELT); px(img, x, 24, FELTD) end
    if x % 3 == 0 then px(img, x, 4, G3) end
  end
end

do
  local spr, img = L.new(18, 30)
  band(img, 0, 18)
  for _, p in ipairs({ {12,11},{14,11},{13,12},{12,13},{14,13} }) do px(img, p[1], p[2], "#7a4a1f") end
  px(img, 13, 12, LIP)
  L.save(spr, "a-strip")
end

do
  local spr, img = L.new(12, 30)
  band(img, 0, 12)
  for _, p in ipairs({ {0,0},{1,0},{2,0},{0,1},{1,1},{0,2},{0,29},{1,29},{2,29},{0,28},{1,28},{0,27} }) do
    img:drawPixel(p[1], p[2], Color{ r = 0, g = 0, b = 0, a = 0 })
  end
  for y = 3, 26 do px(img, 0, y, UMB) end
  px(img, 1, 2, UMB); px(img, 2, 1, UMB); px(img, 1, 27, UMB); px(img, 2, 28, UMB)
  for y = 3, 26 do px(img, 1, y, y <= 12 and LIP or LIP2) end
  px(img, 2, 2, LIP); px(img, 3, 1, LIP)
  for x = 1, 3 do px(img, x, 4, x == 1 and LIP or HI); px(img, x, 5, HI); px(img, x, 24, FELT2); px(img, x, 25, FELT2) end
  L.rows(img, 5, 12, { ".gg.", "gHgs", "gsHs", ".ss." }, { g = G3, s = G5, H = "#8a4a1c" })
  px(img, 6, 12, GW)
  for x = 5, 8 do px(img, x, 16, FELT2) end -- button shadow
  L.save(spr, "a-strip-cap")
end

-- thread tiles; fn(x,y) defines horizontal art, vertical is the transpose
local function tile(name, f, vert)
  local spr, img = L.new(6, 6)
  for x = 0, 5 do for y = 0, 5 do
    local c = f(x, y)
    if c then if vert then px(img, y, x, c) else px(img, x, y, c) end end
  end end
  L.save(spr, name)
end
local function done(x, y)
  local on = x % 3 ~= 2
  if y == 2 then return on and (x % 3 == 0 and GW or G3) or G7 end
  if y == 3 then return on and G5 or G7 end
  if (y == 1 or y == 4) and on then return "#7a4a1f" end -- warm glow halo
end
local function todo(x, y)
  if x <= 1 and y == 2 then return "#74462a" end
  if x <= 1 and y == 3 then return FELT2 end
  if x == 4 and y == 2 then return UMB end
end
tile("a-thread-done", done, false); tile("a-thread-todo", todo, false)
tile("a-thread-done-v", done, true); tile("a-thread-todo-v", todo, true)
print("route felt up ok")
