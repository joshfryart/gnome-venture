-- Shared route-ribbon sprites: gnome token, tinted gnome miniature, goal flag, danger pips.
-- Run: aseprite -b --script-param src=<dir> --script-param out=<dir> --script-param game=<game/assets/img> --script shared.lua
local L = dofile(app.fs.joinPath(app.fs.filePath(debug.getinfo(1, "S").source:sub(2)), "route-lib.lua"))
local px = L.px

-- 1. gnome token (15 x 19 art + edge): the "you are here" marker on every ribbon
do
  local spr, img = L.new(19, 24)
  L.rows(img, 2, 2, {
    ".......R.......",
    "......hR.......",
    "......hRr......",
    ".....hRRr......",
    ".....hRRRr.....",
    "....hRRRRr.....",
    "....hRRRRRr....",
    "...hRRRRRRrr...",
    "..gRRRRRRRRrd..",
    "..gGgGGgGGgGd..",
    "...FeFFFFFef...",
    "...FeFFFFFef...",
    "..BBFFNnFFBbb..",
    "..BBBBBBBBBbb..",
    "..wBBBBBBBBbb..",
    "...BBBBBBBbb...",
    "...CBBBBBbbc...",
    "...CCCBBbccc...",
    "...KK.....kk...",
  }, { R="#dd3a2a", h="#f2793a", r="#ae2a2a", d="#6b1b2c", g="#f5cf6a", G="#e8a317",
       F="#e9b98a", f="#c47a52", e="#2a1a10", N="#d9885a", n="#c47a52",
       B="#f2e4c0", b="#c9a96e", w="#fff3c8", C="#3f8fb0", c="#2f6290", K="#4a2c1a", k="#2a1a10" })
  px(img, 8, 6, "#ff9158")   -- hat gloss
  L.outline(img, 1, false)
  L.border(img)
  L.save(spr, "gnome-token")
end

-- 2. gnome miniature: the existing mini-gnome layers stacked and tinted (hat red, beard cream)
do
  local G = app.params["game"] .. "/mini/"
  local spr, img = L.new(64, 80)
  local pc = app.pixelColor
  local function stack(name, tint)
    local src = Image{ fromFile = G .. name .. ".png" }
    for y = 0, src.height - 1 do for x = 0, src.width - 1 do
      local v = src:getPixel(x, y)
      if pc.rgbaA(v) > 0 then
        local r, g, b = pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)
        if tint and r == g and g == b and r > 100 then   -- neutral grey = tint area (outline stays)
          local t = L.hex(tint)
          local gain = r / 203 * 1.0
          r = math.min(255, math.floor(t.red * gain)); g = math.min(255, math.floor(t.green * gain)); b = math.min(255, math.floor(t.blue * gain))
        end
        img:drawPixel(x, y, Color{ r = r, g = g, b = b, a = 255 })
      end
    end end
  end
  stack("mini-gnome-shadow"); stack("mini-gnome-body"); stack("mini-gnome-face")
  stack("mini-gnome-beard", "#f2e4c0"); stack("mini-gnome-hat", "#dd3a2a"); stack("mini-gnome-band")
  L.save(spr, "gnome-mini")
end

-- 3. goal flag (replaces the 🏁 emoji): a felt check pennant on a wooden pole with a gold knob
do
  local spr, img = L.new(20, 26)
  -- pole (2 px, wood) + knob
  for y = 6, 22 do px(img, 4, y, "#d9a660"); px(img, 5, y, "#8a4f2a") end
  L.blob(img, 5, 4, 2, 2, L.R.gold, { k = 1 })
  -- pennant: checkered felt, cream and red, with a gold hem seam
  for y = 6, 14 do
    local wdt = 13 - math.abs(y - 10)
    for x = 6, 6 + wdt do
      local c = ((math.floor((x - 6) / 2) + math.floor((y - 6) / 2)) % 2 == 0) and "#dd3a2a" or "#f2e4c0"
      if (x - 6) + (y - 6) > 13 then c = (c == "#dd3a2a") and "#ae2a2a" or "#c9a96e" end   -- crescent to the lower right
      px(img, x, y, c)
    end
  end
  local hem = {}
  for x = 6, 15 do hem[#hem + 1] = { x, 7 } end
  L.seam(img, hem, "#f5cf6a")
  -- base peg
  L.rect(img, 3, 23, 4, 1, "#5e2f1e")
  L.outline(img, 1, false)
  L.border(img)
  L.save(spr, "goal-flag")
end

-- 4. danger pips: an ember thorn diamond (on) and an empty felt socket (off)
for _, on in ipairs({ true, false }) do
  local spr, img = L.new(13, 13)
  local d = {
    "....X....",
    "...XXX...",
    "..XXXXX..",
    ".XXXXXXX.",
    "XXXXXXXXX",
    ".XXXXXXX.",
    "..XXXXX..",
    "...XXX...",
    "....X....",
  }
  for y = 1, 9 do for x = 1, 9 do
    if d[y]:sub(x, x) == "X" then
      local s = (x - 5) + (y - 5)
      local c
      if on then c = s >= 3 and "#ae2a2a" or (s <= -3 and "#f2793a" or "#dd3a2a")
      else c = s >= 3 and "#5b6470" or (s <= -3 and "#c9c5bc" or "#8b8f96") end
      px(img, x + 1, y + 1, c)
    end
  end end
  if on then px(img, 5, 4, "#ffc27a"); px(img, 4, 5, "#ff9158")
  else
    -- empty socket: a gold stitch ring (2 on, 1 off) shows where a thorn would sit
    L.seam(img, { {6,3},{7,4},{8,5},{9,6},{8,7},{7,8},{6,9},{5,8},{4,7},{3,6},{4,5},{5,4} }, "#5b6470")
  end
  L.outline(img, 1, false)
  L.border(img)
  L.save(spr, on and "danger-on" or "danger-off")
end

print("shared sprites ok")
