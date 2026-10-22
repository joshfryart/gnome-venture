-- trek-flag (family 6, marker, 20x20): destination flag. Red pennant pointing right on a wooden pole,
-- thread-gold hem stitched at the pole, pole planted in a small grey stone. No ground shadow.
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local NAME, W, H = "trek-flag", 20, 20

local U1, U2, U3 = "#74462a", "#4a2c1a", "#2a1a10"
local WD = { gloss = "#ecc58a", rim = "#d9a660", base = "#b07a45", shade = "#8a4f2a" }
local RD = { gloss = "#ff9158", rim = "#f2793a", base = "#dd3a2a", shade = "#ae2a2a", deep = "#6b1b2c" }
local SN = { rim = "#b3b2b0", base = "#8b8f96", shade = "#5b6470" }
local THREAD = "#f5cf6a"

local c = GV.canvas{ w = W, h = H, mode = "scene" }
local function set(x, y, h) c:px(x, y, h) end

---------------------------------------------------------------- pole (x4..5), outline x3 / x6
-- top outline at y1 keeps the 1 px transparent margin; 2x2 wd_gloss cap at y2..3 (gloss px (4,2) inside it)
set(4, 1, U1); set(5, 1, U1)
for y = 1, 15 do set(3, y, U1); set(6, y, U3) end
for y = 2, 3 do set(4, y, WD.gloss); set(5, y, WD.gloss) end
for y = 4, 15 do set(4, y, WD.rim); set(5, y, y >= 14 and WD.shade or WD.base) end

---------------------------------------------------------------- pennant: (6,2) -> (18,6) -> (6,11)
local top = { [2] = {6, 9}, [3] = {10, 12}, [4] = {13, 15}, [5] = {16, 17} }      -- upper edge, umber1
local bot = { [7] = {16, 17}, [8] = {13, 15}, [9] = {11, 12}, [10] = {8, 10}, [11] = {6, 7} } -- lower edge, umber3
local fill = { [3] = 9, [4] = 12, [5] = 15, [6] = 17, [7] = 15, [8] = 12, [9] = 10, [10] = 7 } -- interior x7..n
local function isBot(x, y) local b = bot[y] return b and x >= b[1] and x <= b[2] end
local function isTop(x, y) local t = top[y] return t and x >= t[1] and x <= t[2] end
for y, xe in pairs(fill) do
  for x = 7, xe do
    local h = RD.base
    if isTop(x, y - 1) then h = RD.rim end
    if isBot(x, y + 1) or (y == 6 and x >= 15) then h = RD.shade end
    set(x, y, h)
  end
end
set(17, 6, RD.deep)                               -- the tip pixel
for y, t in pairs(top) do for x = t[1], t[2] do set(x, y, U1) end end
for y, b in pairs(bot) do for x = b[1], b[2] do set(x, y, U3) end end
set(18, 6, U2)                                    -- tip outline
set(8, 3, RD.gloss); set(9, 3, RD.gloss)          -- gloss
-- hem stitch: the cloth-to-pole join, 2 on / 1 off along x=7 (y3-4, y6-7, y9-10)
for _, y in ipairs({ 3, 4, 6, 7, 9, 10 }) do set(7, y, THREAD) end

---------------------------------------------------------------- base stone 8x3 (x1..8, y16..18), pole planted in it
set(1, 16, U1); for x = 2, 7 do set(x, 16, SN.rim) end; set(8, 16, U2)
set(1, 17, U1); for x = 2, 6 do set(x, 17, SN.base) end; set(7, 17, SN.shade); set(8, 17, U3)
for x = 2, 7 do set(x, 18, U2) end

local t = c:save(ROOT .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", ROOT .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME .. ": " .. GV.report(t))
