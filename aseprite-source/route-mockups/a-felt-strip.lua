-- Mockup A: "stitched thread on a felt strip". Tiles and pins that CSS lays out in a row.
-- a-strip (repeating felt band with hem stitch), a-strip-cap (left end, mirrored in CSS for the right),
-- a-thread-done / a-thread-todo (repeating stitch tiles), a-pin-done / a-pin-todo / a-pin-stop (toy pins).
local L = dofile(app.fs.joinPath(app.fs.filePath(debug.getinfo(1, "S").source:sub(2)), "route-lib.lua"))
local px = L.px

local FELT, FELT2, FELTD, EDGE = "#4a2c1a", "#3d2a1c", "#2a1a10", "#74462a"

-- felt band, 18 x 30 tile (18 = six 2-on-1-off stitch repeats, so the hem lines up across tiles)
local function band(img, x0, w)
  for x = x0, x0 + w - 1 do
    px(img, x, 0, "#2a1a10")               -- umber edge
    px(img, x, 1, EDGE)                    -- lit top lip
    for y = 2, 26 do px(img, x, y, FELT) end
    for y = 22, 26 do px(img, x, y, FELT2) end   -- one stepped shade band at the bottom (lower-right light rule)
    px(img, x, 27, FELTD); px(img, x, 28, "#2a1a10"); px(img, x, 29, "#2a1a10")
    if (x % 3) ~= 2 then px(img, x, 4, "#e8a317"); px(img, x, 24, "#b07a10") end   -- hem stitches
  end
end

do
  local spr, img = L.new(18, 30)
  band(img, 0, 18)
  -- one sparse cross-stitch mark, as on the page felt
  for _, p in ipairs({ {12,9},{14,9},{13,10},{12,11},{14,11} }) do px(img, p[1], p[2], "#5e3a24") end
  L.save(spr, "a-strip")
end

-- left cap: rounded felt end with the gold button where the thread is tied off
do
  local spr, img = L.new(12, 30)
  band(img, 0, 12)
  -- round the corners off (cut 3-step corners)
  for _, p in ipairs({ {0,0},{1,0},{2,0},{0,1},{1,1},{0,2},{0,29},{1,29},{2,29},{0,28},{1,28},{0,27} }) do
    img:drawPixel(p[1], p[2], Color{ r = 0, g = 0, b = 0, a = 0 })
  end
  for y = 3, 26 do px(img, 0, y, "#2a1a10") end
  px(img, 1, 2, "#2a1a10"); px(img, 2, 1, "#2a1a10"); px(img, 1, 27, "#2a1a10"); px(img, 2, 28, "#2a1a10")
  for y = 2, 26 do px(img, 1, y, EDGE) end
  for x = 0, 3 do px(img, x, 4, FELT); px(img, x, 24, FELT2) end
  -- gold button (4 x 4 cut corners, two diagonal holes)
  L.rows(img, 5, 12, { ".gg.", "gHgs", "gsHs", ".ss." }, { g = "#f5cf6a", s = "#e8a317", H = "#8a4a1c" })
  L.save(spr, "a-strip-cap")
end

-- thread tiles, 6 x 6: sewn (gold running stitch with its shade) and not yet sewn (needle holes)
do
  local spr, img = L.new(6, 6)
  for x = 0, 5 do if x % 3 ~= 2 then px(img, x, 2, "#f5cf6a"); px(img, x, 3, "#e8a317") end end
  px(img, 0, 2, "#fff1c8")
  L.save(spr, "a-thread-done")
end
do
  local spr, img = L.new(6, 6)
  px(img, 1, 2, "#2a1a10"); px(img, 4, 2, "#2a1a10"); px(img, 1, 3, "#74462a"); px(img, 4, 3, "#74462a")
  L.save(spr, "a-thread-todo")
end

-- vertical versions for the folded Route list
do
  local spr, img = L.new(6, 6)
  for y = 0, 5 do if y % 3 ~= 2 then px(img, 2, y, "#f5cf6a"); px(img, 3, y, "#e8a317") end end
  px(img, 2, 0, "#fff1c8")
  L.save(spr, "a-thread-done-v")
end
do
  local spr, img = L.new(6, 6)
  px(img, 2, 1, "#2a1a10"); px(img, 2, 4, "#2a1a10"); px(img, 3, 1, "#74462a"); px(img, 3, 4, "#74462a")
  L.save(spr, "a-thread-todo-v")
end

-- toy pins: an enamel head on a 2 px steel shaft. 14 x 22.
local function pin(name, ramp, mark)
  local spr, img = L.new(14, 22)
  -- shaft
  for y = 10, 18 do px(img, 6, y, "#c9c5bc"); px(img, 7, y, "#8b8f96") end
  px(img, 6, 19, "#8b8f96")
  -- head
  L.blob(img, 7, 7, 4.4, 4.4, ramp, { k = 1 })
  if mark == "stitch" then   -- sewn: a gold cross-stitch on the head
    for _, p in ipairs({ {6,6},{8,6},{7,7},{6,8},{8,8} }) do px(img, p[1], p[2], "#fff1c8") end
  elseif mark == "button" then
    L.rows(img, 6, 6, { "gH", "Hs" }, { g = "#f5cf6a", s = "#e8a317", H = "#8a4a1c" })
  end
  L.outline(img, 1, false)
  L.border(img)
  L.save(spr, name)
end
pin("a-pin-done", L.R.gold, "stitch")
pin("a-pin-todo", L.R.stone, nil)
pin("a-pin-stop", L.R.red, "button")
pin("a-pin-danger", L.R.dusk, nil)

print("A sprites ok")
