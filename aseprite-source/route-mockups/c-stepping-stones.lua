-- Mockup C: "stepping-stone track". A cavern-floor felt band (tile) with one stone slab per space.
-- c-ground (repeating floor tile), c-stone-done / -todo / -here / -danger / -goal.
-- The gnome miniature (gnome-mini.png, from shared.lua) stands on the -here stone.
local L = dofile(app.fs.joinPath(app.fs.filePath(debug.getinfo(1, "S").source:sub(2)), "route-lib.lua"))
local px = L.px

-- floor tile 36 x 24: lit lip, felt, one stepped shade band, gold hem, a glow-cap and two pebbles
do
  local spr, img = L.new(36, 24)
  for x = 0, 35 do
    px(img, x, 0, "#2a1a10"); px(img, x, 1, "#74462a")
    for y = 2, 15 do px(img, x, y, "#4a2c1a") end
    for y = 16, 20 do px(img, x, y, "#3d2a1c") end
    px(img, x, 21, "#2a1a10"); px(img, x, 22, "#2a1a10"); px(img, x, 23, "#2a1a10")
    if x % 3 ~= 2 then px(img, x, 18, "#b07a10") end
  end
  -- glow-cap mushroom (water ramp: the cavern glow)
  L.rows(img, 27, 7, {
    ".gRRr.",
    "gRRRrr",
    "rrrrdd",
    "..cs..",
    "..cs..",
  }, { g = "#c8ecdc", R = "#8fcbd8", r = "#3f8fb0", d = "#2f6290", c = "#f2e4c0", s = "#c9a96e" })
  px(img, 26, 8, "#2f6290"); px(img, 33, 8, "#2f6290")
  -- pebbles
  L.rows(img, 6, 12, { ".ab", "abb" }, { a = "#8b8f96", b = "#5b6470" })
  L.rows(img, 17, 5, { "ab", "bb" }, { a = "#74462a", b = "#3d2a1c" })
  L.save(spr, "c-ground")
end

local function slab(img, cx, cy, rx, ry)
  -- side (dark) then the flat top with its own crescent, rim and gloss
  for y = 0, img.height - 1 do for x = 0, img.width - 1 do
    if L.inEl(x, y, cx, cy + 1.5, rx, ry) then px(img, x, y, ((x - cx) > rx * 0.3) and "#3e3a52" or "#5b6470") end
  end end
  L.blob(img, cx, cy - 1, rx - 0.5, ry - 1.5, L.R.stone, { k = 1 })
end

local function stone(name, mark, w, h)
  w, h = w or 28, h or 20
  local spr, img = L.new(w, h)
  local cx, cy, rx, ry = w / 2, h / 2 - 0.5, w / 2 - 3, h / 2 - 4
  if mark == "here" then
    -- cavern glow: a stepped light-blue pool under the stone
    for y = 0, h - 1 do for x = 0, w - 1 do
      if L.inEl(x, y, cx, cy + 2, rx + 1.5, ry + 1) then px(img, x, y, "#3f8fb0") end
    end end
    for y = 0, h - 1 do for x = 0, w - 1 do
      if L.inEl(x, y, cx, cy + 2, rx + 0.5, ry) then px(img, x, y, "#8fcbd8") end
    end end
  end
  slab(img, cx, cy, rx, ry)
  if mark == "done" then         -- sewn: a gold cross-stitch on the top
    L.rows(img, math.floor(cx) - 3, math.floor(cy) - 3, { "g...g", ".g.g.", "..s..", ".g.s.", "g...s" },
      { g = "#f5cf6a", s = "#e8a317" })
  elseif mark == "danger" then   -- a crack with an ember thorn
    L.rows(img, math.floor(cx) - 4, math.floor(cy) - 3, {
      "...r....", "..rRr...", ".rRRRr..", "..rdr...", "...d.u..", "....uu.u",
    }, { r = "#dd3a2a", R = "#ff9158", d = "#ae2a2a", u = "#3e3a52" })
  elseif mark == "goal" then     -- the gold button where the goal flag is planted
    L.rows(img, math.floor(cx) - 2, math.floor(cy) - 2, { ".gg.", "gHgs", "gsHs", ".ss." },
      { g = "#f5cf6a", s = "#e8a317", H = "#8a4a1c" })
  elseif mark == "here" then
    for x = math.floor(cx - rx + 3), math.floor(cx + rx - 3) do
      if x % 3 ~= 2 then px(img, x, math.floor(cy - 1), "#c8ecdc") end   -- lit seam of glow across the top
    end
  end
  L.outline(img, 1, false)
  L.border(img)
  L.save(spr, name)
end
stone("c-stone-done", "done")
stone("c-stone-todo", nil)
stone("c-stone-here", "here")
stone("c-stone-danger", "danger")
stone("c-stone-goal", "goal", 34, 22)
print("C sprites ok")
