-- _o2.lua: helpers for the Opus second pass on the batch3 wear rank icons (Hearth Pop, 64x64).
-- Every icon loads its finished base PNG (read only) and hand-places pixels on top.
-- Hand-drawn overlays use a char map; the silhouette is re-inked after edits.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local O = { HP = HP, DIR = DIR, OUT = (app.params and app.params.out) or (DIR .. "/") }
O.ROOT = DIR .. "/../../../../.."           -- repo root
O.PH = O.ROOT .. "/game/assets/img/ph/"     -- read only
local pc = app.pixelColor
O.INK = "#2b1c26"
local INKV = pc.rgba(0x2b, 0x1c, 0x26, 255)

-- shared ramps
O.WOOL = { hi = "#fff4d6", base = "#f6e6c4", mid = "#ead2a6", shade = "#d2b386", deep = "#a8845e" }
O.GOLD = { hi = "#ffe38a", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f", pale = "#fff0b0" }

local function rgb(hex)
  return pc.rgba(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16), 255)
end
O.rgb = rgb
function O.load(path) return Image { fromFile = path } end

local function inb(x, y) return x >= 0 and y >= 0 and x < 64 and y < 64 end
function O.get(img, x, y)
  if not inb(x, y) then return nil end
  local v = img:getPixel(x, y)
  if pc.rgbaA(v) == 0 then return nil end
  return string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
end
function O.isBody(img, x, y)
  if not inb(x, y) then return false end
  local v = img:getPixel(x, y)
  return pc.rgbaA(v) > 0 and v ~= INKV
end
function O.px(img, x, y, hex)
  if not inb(x, y) then return end
  if hex == nil or hex == "_" then img:putPixel(x, y, pc.rgba(0, 0, 0, 0)) else img:putPixel(x, y, rgb(hex)) end
end

-- paint rows of chars at (x0, y0). map: char -> hex | "_" (clear). "." and " " skip. "#" = ink.
function O.paint(img, x0, y0, rows, map)
  for j, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      if ch ~= "." and ch ~= " " then
        local hex = (ch == "#") and O.INK or map[ch]
        if hex == nil then error("O.paint: no colour for '" .. ch .. "'") end
        O.px(img, x0 + i - 1, y0 + j - 1, hex)
      end
    end
  end
end

-- re-ink: every transparent pixel 4-adjacent to a body pixel becomes ink;
-- ink pixels with no body pixel in their 8-neighbourhood are cleared (left over after a cut).
function O.reink(img)
  local add = {}
  for y = 0, 63 do for x = 0, 63 do
    if O.get(img, x, y) == nil then
      if O.isBody(img, x+1, y) or O.isBody(img, x-1, y) or O.isBody(img, x, y+1) or O.isBody(img, x, y-1) then add[#add+1] = { x, y } end
    end
  end end
  for _, p in ipairs(add) do O.px(img, p[1], p[2], O.INK) end
  local del = {}
  for y = 0, 63 do for x = 0, 63 do
    if img:getPixel(x, y) == INKV then
      local any = false
      for dy = -1, 1 do for dx = -1, 1 do if O.isBody(img, x+dx, y+dy) then any = true end end end
      if not any then del[#del+1] = { x, y } end
    end
  end end
  for _, p in ipairs(del) do O.px(img, p[1], p[2], nil) end
end

-- collect the pixels marked `ch` in rows at (x0, y0) into a set (key y*64+x)
function O.marks(x0, y0, rows, ch, set)
  set = set or {}
  for j, row in ipairs(rows) do for i = 1, #row do
    if row:sub(i, i) == ch then set[(y0 + j - 1) * 64 + x0 + i - 1] = true end
  end end
  return set
end
function O.rectSet(x0, y0, x1, y1, set)
  set = set or {}
  for y = y0, y1 do for x = x0, x1 do set[y * 64 + x] = true end end
  return set
end

-- curly wool fill over a pixel set. Light from the upper left: lit top edge, shaded
-- bottom and right edges, small staggered curls (hi crown + shade tail) inside.
-- opts: ramp, shadeFrom (x from which the shade side starts), curl=false,
-- yLight / yDark (rows at or above / at or below get one tone lighter / darker: a rolled form)
function O.wool(img, set, opts)
  opts = opts or {}
  local R = opts.ramp or O.WOOL
  local T = { R.hi, R.base, R.mid, R.shade, R.deep }
  local function S(x, y) return x >= 0 and x < 64 and y >= 0 and y < 64 and set[y * 64 + x] end
  for k in pairs(set) do
    local x, y = k % 64, k // 64
    local t = 2
    if opts.curl ~= false then
      local u = (x + ((y // 2) % 2) * 2 + (opts.phase or 0)) % 4
      local v = y % 2
      if v == 0 and u == 0 then t = 1 elseif v == 1 and u == 0 then t = 3 elseif v == 1 and u == 1 then t = 4 end
    end
    local top, bot, rt, lf = not S(x, y-1), not S(x, y+1), not S(x+1, y), not S(x-1, y)
    local sh = opts.shadeFrom and x >= opts.shadeFrom
    if top then t = sh and 2 or 1 end
    if bot then t = math.max(t, 4) end
    if bot and (rt or sh) then t = 5 end
    if rt and not top then t = math.max(t, 4) end
    if sh and not top and t < 5 then t = t + 1 end
    if opts.yLight and y <= opts.yLight and not top and not bot and t > 1 and t < 5 then t = t - 1 end
    if opts.yDark and y >= opts.yDark and not top and t < 5 then t = t + 1 end
    O.px(img, x, y, T[t])
  end
end

-- swap colours inside a box: map old hex -> new hex
function O.remap(img, x0, y0, x1, y1, map)
  for y = y0, y1 do for x = x0, x1 do
    local h = O.get(img, x, y)
    if h and map[h] then O.px(img, x, y, map[h]) end
  end end
end
-- paint only over body pixels (keeps the ink)
function O.body(img, x, y, hex) if O.isBody(img, x, y) then O.px(img, x, y, hex) end end
function O.hrun(img, x0, x1, y, hex) for x = x0, x1 do O.body(img, x, y, hex) end end
-- cream sparkle (plus), centre x,y, with gold-hi arms if given
function O.sparkle(img, x, y, arm)
  O.px(img, x, y, "#fff4d6")
  for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do O.px(img, x + d[1], y + d[2], arm or "#fff4d6") end
end

function O.save(img, name)
  local r = HP.assertClean(img)
  local spr = Sprite(64, 64, ColorMode.RGB)
  spr.cels[1].image = img
  spr:saveAs(O.OUT .. name .. ".aseprite")
  spr:saveCopyAs(O.OUT .. name .. ".png")
  spr:close()
  print(string.format("%s: distinct=%d semi=%d blackWhite=%d", name, r.distinct, r.semi, r.blackWhite))
end

return O
