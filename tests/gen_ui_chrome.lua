-- Gnome Venture v2.0.32: Stitched Toy site chrome pieces (flat UI, hard pixels, Part A/D palette only).
-- Run: "C:\Program Files\Aseprite\Aseprite.exe" -b --script tests/gen_ui_chrome.lua   (Aseprite 1.3.18)
-- Writes game/assets/img/ui/*.png and the .aseprite sources to SRC. Paths below are Joshua's machine; change OUT/SRC to run elsewhere.
local OUT = "C:/Users/hello/OneDrive/Desktop/claude/gnomeventures/game/assets/img/ui/"
local SRC = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/aseprite/ui/"
app.fs.makeAllDirectories(OUT)
app.fs.makeAllDirectories(SRC)

local function hex(h)
  h = h:gsub("#", "")
  return Color{ r = tonumber(h:sub(1,2),16), g = tonumber(h:sub(3,4),16), b = tonumber(h:sub(5,6),16), a = 255 }
end

-- paint an ascii map; legend maps chars to hex, "." = transparent
-- k = whole-number scale (each art pixel written as k x k), so tiles need no browser scaling
local function sprite(name, rows, legend, bg, k)
  k = k or 1
  local h, w = #rows, #rows[1]
  local spr = Sprite(w * k, h * k, ColorMode.RGB)
  local img = spr.cels[1].image
  for y = 1, h do
    local row = rows[y]
    for x = 1, w do
      local ch = row:sub(x, x)
      local col = legend[ch] or bg
      if col then
        for dy = 0, k - 1 do for dx = 0, k - 1 do img:drawPixel((x - 1) * k + dx, (y - 1) * k + dy, hex(col)) end end
      end
    end
  end
  spr:saveAs(SRC .. name .. ".aseprite")
  spr:saveCopyAs(OUT .. name .. ".png")
  spr:close()
end

-- 1. Gold thread button (logo mark, divider knot). 12 x 12: umber outline, cut corners,
--    gold #f5cf6a with darker lower-right #e8a317, gloss #fff3c8, two diagonal holes #8a4a1c.
sprite("button", {
  "....uuuu....",
  "..uuwggguu..",
  ".uwwgggggsu.",
  ".uwggggggsu.",
  "uggggggggssu",
  "ugggghgggssu",
  "uggggghggssu",
  "ugggggggsssu",
  ".ugsssssssu.",
  ".uussssssuu.",
  "..uussssuu..",
  "....uuuu....",
}, { u = "#2a1a10", g = "#f5cf6a", s = "#e8a317", w = "#fff3c8", h = "#8a4a1c" })

-- 2. Felt page tiles, 16 x 16 art written at 2x (32 x 32 files): plain felt with two sparse cross-stitch marks (no dither).
local felt = {
  "................",
  "................",
  "..x.x...........",
  "...x............",
  "..x.x...........",
  "................",
  "................",
  "................",
  "................",
  "................",
  "..........x.x...",
  "...........x....",
  "..........x.x...",
  "................",
  "................",
  "................",
}
sprite("felt-light", felt, { x = "#f2e4c0" }, "#f1ece0", 2)
sprite("felt-dark", felt, { x = "#3d2a1c" }, "#2a1a10", 2)

-- 3. Header / bottom bar / footer felt tile, 16 x 16 art at 2x (umber felt, one quiet stitch mark).
sprite("felt-umber", felt, { x = "#4a2c1a" }, "#3d2a1c", 2)

print("ui chrome written to " .. OUT)
