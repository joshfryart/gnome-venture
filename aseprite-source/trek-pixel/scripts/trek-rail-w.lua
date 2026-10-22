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

-- trek-rail-w: 4x42 beam, posts y14..17 and y35..38 (pitch 21), cast shade under each post.
-- Beam is a darker wood step (base beside shade) so the light posts read as bumps at 35/21 px.
new(4, 42)
rect(0, 0, 0, 41, "umber1"); rect(1, 0, 1, 41, "wd_base"); rect(2, 0, 2, 41, "wd_shade"); rect(3, 0, 3, 41, "umber3")
for _, y0 in ipairs({ 14, 35 }) do
  rect(0, y0, 0, y0 + 2, "umber1")
  px(1, y0, "wd_gloss")                      -- gloss pixel, upper-left of the post
  rect(1, y0 + 1, 1, y0 + 2, "wd_rim")
  px(2, y0, "wd_rim")
  rect(2, y0 + 1, 2, y0 + 2, "thread")       -- lashing
  rect(0, y0 + 3, 2, y0 + 3, "umber2")       -- umber edge on the shaded (lower) side
  rect(3, y0, 3, y0 + 3, "umber3")
  px(1, y0 + 4, "wd_shade"); px(2, y0 + 4, "wd_deep")   -- cast shade under the post
end
px(1, 5, "wd_shade"); px(1, 26, "wd_shade")    -- wood knots
save("trek-rail-w")
