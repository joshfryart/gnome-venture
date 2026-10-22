-- Family 5 (bridge and rails): exact-pixel drawing, transparent overlay, no halo, no border.
local T = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/trek-pixel/"
local P = {
  wd_gloss = "#ecc58a", wd_rim = "#d9a660", wd_base = "#b07a45", wd_bounce = "#a8582f",
  wd_shade = "#8a4f2a", wd_deep = "#5e2f1e",
  umber1 = "#74462a", umber2 = "#4a2c1a", umber3 = "#2a1a10",
  thread = "#f5cf6a", thread2 = "#e8a317",
}
local function col(n)
  local h = assert(P[n], n)
  return app.pixelColor.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255)
end
local img
local function new(w, h) img = Image(w, h, ColorMode.RGB); img:clear(app.pixelColor.rgba(0, 0, 0, 0)) end
local function px(x, y, n) img:drawPixel(x, y, col(n)) end
local function rect(x0, y0, x1, y1, n) for y = y0, y1 do for x = x0, x1 do px(x, y, n) end end end
local function save(name)
  local spr = Sprite(img.width, img.height, ColorMode.RGB)
  spr.cels[1].image = img
  spr:saveAs(T .. "aseprite/" .. name .. ".aseprite")
  spr:saveCopyAs(T .. "png/" .. name .. ".png")
  spr:close()
  print(name .. " saved")
end

-- trek-bridge-h: three vertical planks (x1..12, x15..26, x29..40; y2..39), 2 px transparent gaps.
new(42, 42)
local function plank(x0, body, left, rim)
  local x1 = x0 + 11
  rect(x0, 2, x1, 39, body)
  rect(x0, 2, x1, 2, "umber1")          -- top outline (lit)
  rect(x0, 2, x0, 39, left)             -- left outline
  rect(x1, 2, x1, 39, "umber3")         -- right outline (shaded)
  rect(x0, 39, x1, 39, "umber3")        -- bottom outline (shaded)
  px(x0, 39, "umber2"); px(x1, 2, "umber2")   -- corners where lit meets shaded
  rect(x0 + 1, 3, x0 + 8, 3, rim)       -- lit rim, top
  rect(x0 + 1, 3, x0 + 1, 36, rim)      -- lit rim, left
  rect(x0 + 9, 4, x0 + 9, 37, "wd_shade")   -- 2 px lower-right band: shade ...
  rect(x0 + 2, 37, x0 + 9, 37, "wd_shade")
  rect(x0 + 10, 3, x0 + 10, 38, "wd_bounce") -- ... with the 1 px bounce on the edge
  rect(x0 + 1, 38, x0 + 10, 38, "wd_bounce")
end
plank(1, "wd_rim", "umber1", "wd_gloss")
plank(15, "wd_base", "umber2", "wd_rim")   -- middle plank darker
plank(29, "wd_rim", "umber1", "wd_gloss")

-- grain
rect(4, 8, 4, 20, "wd_base"); rect(8, 26, 8, 34, "wd_base")      -- plank 1
rect(33, 6, 33, 16, "wd_base"); rect(36, 22, 36, 34, "wd_base")  -- plank 3
-- plank 2 knot: shade ring, deep heart, lit rim upper-left
rect(19, 18, 21, 20, "wd_shade"); px(20, 19, "wd_deep"); px(19, 18, "wd_rim")

-- nails 2x2 deep with a gloss pixel upper-left
for _, nx in ipairs({ 4, 18, 32 }) do
  for _, ny in ipairs({ 5, 35 }) do
    rect(nx, ny, nx + 1, ny + 1, "wd_deep"); px(nx, ny, "wd_gloss")
  end
end

-- lashing at the rail joins only: 2x1 thread, thread2 under it
for _, lx in ipairs({ 5, 19, 33 }) do
  rect(lx, 3, lx + 1, 3, "thread");  rect(lx, 4, lx + 1, 4, "thread2")
  rect(lx, 38, lx + 1, 38, "thread"); rect(lx, 39, lx + 1, 39, "thread2")
end
save("trek-bridge-h")
