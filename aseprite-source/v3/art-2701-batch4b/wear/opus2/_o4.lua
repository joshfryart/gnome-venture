-- _o4.lua: helpers for the Opus second pass on the batch4b wear rank icons (cut b + rank), 64x64.
-- Reuses ../../../art-2701-batch3/wear/opus2/_o2.lua (load, get, px, paint, reink) and adds:
--   O.graft(rankPath, cutbPath, basePath): start from the finished cut-a rank icon (opus3), then copy in every
--     pixel where the finished cut-b icon differs from the plain game base (= the stitched patch, its stitches and
--     its contact shadow). The patch always wins, so fleece or gold can never cover it. Returns img, mask.
--   O.save(img, name): HP.assertClean, then .aseprite + .png into OUT.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/../../../art-2701-batch3/wear/opus2/_o2.lua")
local HP = O.HP
O.DIR4 = DIR
O.OUT = (app.params and app.params.out) or (DIR .. "/")
O.V3 = DIR .. "/../../.."
O.OP3 = O.V3 .. "/art-2701-batch3/wear/opus3/"
O.FLEECE = { hi = "#fff4d6", base = "#f8e8c6", mid = "#ecd4a8", shade = "#d4b48c", deep = "#9c8270" }
O.GOLD6 = { pale = "#fff0b0", hi = "#ffe38a", base = "#f5b82e", shade = "#d98322", deep = "#a8581e", umber = "#6e3a1c" }

function O.graft(rankPath, cutbPath, basePath)
  local img = O.load(rankPath)
  local cb, base = O.load(cutbPath), O.load(basePath)
  local mask = {}
  for y = 0, 63 do for x = 0, 63 do
    local a, b = cb:getPixel(x, y), base:getPixel(x, y)
    if a ~= b then img:putPixel(x, y, a); mask[y * 64 + x] = true end
  end end
  return img, mask
end
function O.inMask(mask, x, y) return mask[y * 64 + x] == true end

-- apply fn(x, y, hex) -> newhex|nil over a box (body pixels only), skipping masked (patch) pixels
function O.each(img, x0, y0, x1, y1, fn, mask)
  local ch = {}
  for y = y0, y1 do for x = x0, x1 do
    if O.isBody(img, x, y) and not (mask and mask[y * 64 + x]) then
      local n = fn(x, y, O.get(img, x, y))
      if n then ch[#ch + 1] = { x, y, n } end
    end
  end end
  for _, c in ipairs(ch) do O.px(img, c[1], c[2], c[3]) end
end

function O.save4(img, name)
  local r = HP.report(img, true)
  HP.assertClean(img)
  local spr = Sprite(64, 64, ColorMode.RGB)
  spr.cels[1].image = img
  spr:saveAs(O.OUT .. name .. ".aseprite")
  spr:saveCopyAs(O.OUT .. name .. ".png")
  spr:close()
  print(string.format("%s: distinct=%s semi=%s blackWhite=%s", name, tostring(r.distinct), tostring(r.semi), tostring(r.blackWhite)))
end
return O
