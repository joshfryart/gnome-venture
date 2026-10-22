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

-- trek-rail-n: 42x4 beam, posts x5..8 and x26..29 (pitch 21).
-- Beam is a darker wood step (base over shade) so the light posts read as bumps at 35/21 px.
new(42, 4)
rect(0, 0, 41, 0, "umber1"); rect(0, 1, 41, 1, "wd_base"); rect(0, 2, 41, 2, "wd_shade"); rect(0, 3, 41, 3, "umber3")
for _, x0 in ipairs({ 5, 26 }) do
  rect(x0, 0, x0 + 2, 0, "umber1")
  px(x0, 1, "wd_gloss")                      -- gloss pixel, upper-left of the post
  rect(x0 + 1, 1, x0 + 2, 1, "thread")       -- lashing
  rect(x0, 2, x0 + 2, 2, "wd_rim")
  rect(x0 + 3, 0, x0 + 3, 2, "umber2")       -- umber edge on the shaded (right) side
  rect(x0, 3, x0 + 3, 3, "umber3")
end
px(14, 2, "wd_deep"); px(35, 2, "wd_deep")     -- wood knots
save("trek-rail-n")
