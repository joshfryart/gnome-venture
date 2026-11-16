-- _o3.lua: helpers for the Opus richness pass (opus3) on the batch3 wear rank icons.
-- Reuses ../opus2/_o2.lua (load, paint, wool, remap, reink, save) and adds texture helpers.
-- Every icon loads its opus2 PNG (read only) and hand-places pixels on top.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/../opus2/_o2.lua")
O.DIR3 = DIR
O.OUT = (app.params and app.params.out) or (DIR .. "/")   -- never write into opus2
O.O2 = DIR .. "/../opus2/"
function O.base(name) return O.load(O.O2 .. name .. ".png") end

-- 6-tone hue-shifted fleece (warm cream lights, cool lilac-grey deep): richer than opus2 WOOL
O.FLEECE = { hi = "#fff4d6", base = "#f8e8c6", mid = "#ecd4a8", shade = "#d4b48c", deep = "#9c8270" }
-- 6-tone gold: pale glint, hi, base, shade, deep, umber outline-side
O.GOLD6 = { pale = "#fff0b0", hi = "#ffe38a", base = "#f5b82e", shade = "#d98322", deep = "#a8581e", umber = "#6e3a1c" }

-- colour swap for listed pixels only when the current colour is in `from`
function O.swapAt(img, pts, map)
  for _, p in ipairs(pts) do
    local h = O.get(img, p[1], p[2])
    if h and map[h] then O.px(img, p[1], p[2], map[h]) end
  end
end
-- rim light: body pixels touching the outline on the given side get `hex`
-- side: "left" / "top" / "right" / "bottom"; only where the current colour is in `only` (set) if given
function O.rim(img, side, hex, only, box)
  local d = ({ left = { -1, 0 }, top = { 0, -1 }, right = { 1, 0 }, bottom = { 0, 1 } })[side]
  local pts = {}
  local x0, y0, x1, y1 = 0, 0, 63, 63
  if box then x0, y0, x1, y1 = box[1], box[2], box[3], box[4] end
  for y = y0, y1 do for x = x0, x1 do
    if O.isBody(img, x, y) and not O.isBody(img, x + d[1], y + d[2]) then
      local h = O.get(img, x, y)
      if not only or only[h] then pts[#pts + 1] = { x, y } end
    end
  end end
  for _, p in ipairs(pts) do O.px(img, p[1], p[2], hex) end
  return pts
end
-- apply fn(x, y, hex) -> newhex|nil over a box (body pixels only)
function O.each(img, x0, y0, x1, y1, fn)
  local ch = {}
  for y = y0, y1 do for x = x0, x1 do
    if O.isBody(img, x, y) then
      local n = fn(x, y, O.get(img, x, y))
      if n then ch[#ch + 1] = { x, y, n } end
    end
  end end
  for _, c in ipairs(ch) do O.px(img, c[1], c[2], c[3]) end
end

-- work gloves leather (shared by both ranks so they stay siblings): pores, rim light on the
-- lit left edges, a cool lilac bounce on the lower-right edge of the back glove
function O.gloveLeather(img)
  local PORE = { ["#c4864c"] = "#b87a44", ["#dca566"] = "#cf9858", ["#a5673a"] = "#9a5e36" }
  O.each(img, 8, 8, 50, 46, function(x, y, h)
    if PORE[h] and (x * 3 + y * 5) % 7 == 0 and y % 2 == 1 then return PORE[h] end
  end)
  O.rim(img, "left", "#f0c98a", { ["#dca566"] = 1, ["#c4864c"] = 1, ["#cf9858"] = 1, ["#b87a44"] = 1 }, { 8, 8, 34, 44 })
  O.rim(img, "right", "#8c6070", { ["#55301f"] = 1, ["#80492c"] = 1, ["#a5673a"] = 1 }, { 40, 28, 50, 45 })
end
return O
