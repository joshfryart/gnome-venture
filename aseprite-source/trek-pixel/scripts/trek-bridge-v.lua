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

-- trek-bridge-v: three horizontal planks (y1..12, y15..26, y29..40; x2..39), 2 px transparent gaps.
new(42, 42)
local function plank(y0, body, rim)
  local y1 = y0 + 11
  rect(2, y0, 39, y1, body)
  rect(2, y0, 39, y0, "umber1")         -- top outline
  rect(2, y0, 2, y1, "umber1")          -- left outline
  rect(2, y1, 39, y1, "umber3")         -- bottom outline
  rect(39, y0, 39, y1, "umber3")        -- right outline
  px(2, y1, "umber2"); px(39, y0, "umber2")
  rect(3, y0 + 1, 37, y0 + 1, rim)      -- lit rim, top
  rect(3, y0 + 1, 3, y0 + 9, rim)       -- lit rim, left
  rect(4, y0 + 9, 37, y0 + 9, "wd_shade")    -- 2 px band bottom/right: shade ...
  rect(37, y0 + 2, 37, y0 + 9, "wd_shade")
  rect(3, y0 + 10, 38, y0 + 10, "wd_bounce") -- ... with the 1 px bounce on the edge
  rect(38, y0 + 1, 38, y0 + 10, "wd_bounce")
end
plank(1, "wd_rim", "wd_gloss")
plank(15, "wd_base", "wd_rim")   -- middle plank darker
plank(29, "wd_rim", "wd_gloss")

-- grain: long horizontal lines (plank 2 grain in wd_shade so it shows on its wd_base body)
rect(8, 5, 20, 5, "wd_base");   rect(24, 9, 34, 9, "wd_base")
rect(6, 19, 16, 19, "wd_shade"); rect(20, 23, 34, 23, "wd_shade")
rect(10, 33, 24, 33, "wd_base"); rect(6, 37, 14, 37, "wd_base")

-- pegs: 3x3 deep, lit pixel upper-left
for _, py in ipairs({ 4, 18, 32 }) do
  for _, pxx in ipairs({ 6, 33 }) do
    rect(pxx, py, pxx + 2, py + 2, "wd_deep"); px(pxx, py, "wd_rim")
  end
end

-- lashing at the rail joins only: 1x2 thread at each plank end, thread2 under it
for _, ly in ipairs({ 5, 19, 33 }) do
  for _, lx in ipairs({ 3, 38 }) do
    rect(lx, ly, lx, ly + 1, "thread"); px(lx, ly + 2, "thread2")
  end
end
save("trek-bridge-v")
