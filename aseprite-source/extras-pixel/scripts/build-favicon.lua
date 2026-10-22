-- extras/favicon.ico: packs the hand-drawn png/icon-16.png and png/icon-32.png into one ICO
-- as classic 32-bit BMP entries (BGRA + AND mask), readable by browsers, Windows and Aseprite.
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/extras-pixel/png/"
local pc = app.pixelColor
local function u16(v) return string.char(v & 255, (v >> 8) & 255) end
local function u32(v) return string.char(v & 255, (v >> 8) & 255, (v >> 16) & 255, (v >> 24) & 255) end
local function entry(file)
  local img = Image{ fromFile = D .. file }
  local w, h = img.width, img.height
  local px, mask = {}, {}
  for y = h - 1, 0, -1 do -- bottom-up rows
    for x = 0, w - 1 do
      local v = img:getPixel(x, y)
      px[#px+1] = string.char(pc.rgbaB(v), pc.rgbaG(v), pc.rgbaR(v), pc.rgbaA(v))
    end
    local rowbytes = ((w + 31) // 32) * 4
    local bits = {}
    for i = 1, rowbytes do bits[i] = 0 end
    for x = 0, w - 1 do
      if pc.rgbaA(img:getPixel(x, y)) == 0 then local b = x // 8 + 1 bits[b] = bits[b] | (0x80 >> (x % 8)) end
    end
    for i = 1, rowbytes do mask[#mask+1] = string.char(bits[i]) end
  end
  local hdr = u32(40) .. u32(w) .. u32(h * 2) .. u16(1) .. u16(32) .. u32(0) .. u32(0) .. u32(0) .. u32(0) .. u32(0) .. u32(0)
  return w, h, hdr .. table.concat(px) .. table.concat(mask)
end
local list = { { entry("icon-16.png") }, { entry("icon-32.png") } }
local out = { u16(0), u16(1), u16(#list) }
local off = 6 + 16 * #list
for _, e in ipairs(list) do
  out[#out+1] = string.char(e[1] % 256, e[2] % 256, 0, 0) .. u16(1) .. u16(32) .. u32(#e[3]) .. u32(off)
  off = off + #e[3]
end
for _, e in ipairs(list) do out[#out+1] = e[3] end
local f = io.open(D .. "favicon.ico", "wb") f:write(table.concat(out)) f:close()
print("favicon.ico 16x16 + 32x32, " .. off .. " bytes")
