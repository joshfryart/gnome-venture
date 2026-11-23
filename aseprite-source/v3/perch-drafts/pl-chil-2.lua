-- pl-chil-2-perch.lua : 36x36 chibi boat pal on a small water perch
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-chil-2-perch-20261120-173018/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }
-- palette-dark selective outline (spec: dark palette colour, not pure black)
c.tone = function(self, x, y) return self:s(x, y) < self.t2 and "#2b1c26" or "#202466" end

-- palette
local NAVY, MID, BLU, LT = "#202466", "#2e5c9b", "#39a1d5", "#70bbe1"
local CREAM, DARK, PANEL, PINK = "#d6e9e0", "#2b1c26", "#6ba8cb", "#f5a0b8"
local WOODB, WOOLL, WOODD, MOUTHD = "#543737", "#926858", "#3c1b15", "#3c1b15"

-- debug: dump reference character maps
if true then
  local function dmp(src, dst)
    local spr = app.open(src)
    local img = Image(spr.spec); img:drawSprite(spr, 1)
    local pc, map, legend = app.pixelColor, {}, {}
    local f = io.open(dst, "w")
    for y = 0, img.height - 1 do
      local row = {}
      for x = 0, img.width - 1 do
        local v = img:getPixel(x, y)
        if pc.rgbaA(v) == 0 then row[x + 1] = "."
        else
          local m = map[v]
          if not m then
            local ch = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"):sub(#legend + 1, #legend + 1)
            map[v] = ch; m = ch
            legend[#legend + 1] = string.format("%s=#%02x%02x%02x", ch, pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
          end
          row[x + 1] = m
        end
      end
      f:write(table.concat(row) .. "\n")
    end
    f:write(table.concat(legend, " ") .. "\n")
    f:close(); spr:close()
  end
  dmp(D .. "x/pal.png", D .. "debug/pal-map.txt")
end

-- ramps (one per part)
local wood  = { base = WOODB, rim = WOOLL, gloss = WOOLL, dot = WOOLL, shade = WOODD, deep = WOODD, bounce = WOODB }
local flagr = { base = BLU,   rim = LT, gloss = LT, dot = CREAM, shade = MID, deep = NAVY, bounce = BLU }
local hullr = { base = BLU,   rim = LT, gloss = LT, dot = CREAM, shade = MID, deep = NAVY, bounce = BLU }
local watr  = { base = MID,   rim = LT, gloss = LT, dot = CREAM, shade = NAVY, deep = NAVY, bounce = BLU }

-- parts, back to front
local p = c:build{
  { "mast",  c:line({ {14, 4}, {14, 11} }, 2), wood, { flat = true } },
  { "flag",  c:rect(7, 5, 13, 8), flagr, { flat = true } },
  { "hull",  c:rrect(5, 11, 29, 26, 6), hullr, { gloss = false, cres = 2, deep = 2 } },
  { "water", c:ellipse(17.5, 28, 12, 2), watr, { cres = 1, deep = 1, bounce = false } },
}
local hm = p.hull.m

-- flags: 1px shade on lit flag, wood mast handled by flat rim
c:fill(c:rect(13, 5, 13, 8), MID)
c:fill(c:rect(7, 8, 12, 8), MID)
c:px(13, 8, NAVY)

-- hull: deck rail + sheer stripe + bottom band
c:fill(c:rect(5, 11, 29, 11):clip(hm), CREAM)
c:fill(c:rect(5, 12, 29, 12):clip(hm), LT)
c:fill(c:rect(5, 14, 29, 14):clip(hm), NAVY)
c:fill(c:rect(5, 23, 29, 23):clip(hm), MID)
c:fill(c:rect(5, 24, 29, 24):clip(hm), NAVY)
c:fill(c:rect(5, 13, 29, 13):clip(hm), MID)      -- plank seam under the rail
c:fill(c:rect(5, 25, 29, 25):clip(hm), MID)      -- hull wale lit by the water
c:fill(c:rect(29, 13, 29, 23):clip(hm), MID)     -- right-edge form shade
c:px(6, 25, BLU); c:px(7, 24, BLU)               -- edge wear, lower-left

-- face panel with own lit rim + shade crescent
local plate = c:rrect(8, 15, 26, 22, 2)
local pr = GV.ramp(PANEL)
plate:each(function(x, y) c:px(x, y, PANEL) end)
plate:each(function(x, y)
  if not plate:has(x + 2, y + 2) then c:px(x, y, pr.shade) end
end)
plate:each(function(x, y)
  if not plate:has(x + 1, y) or not plate:has(x, y + 1) then
    if c:get(x, y) == pr.shade then c:px(x, y, pr.deep) end
  end
end)
c:fill(c:rect(10, 15, 12, 15):clip(plate), LT)    -- gloss comma on the panel
c:px(10, 16, LT)

-- eyes: cream disc, dark pupil, glint, purple accent
local function eye(x0, y0)
  c:paint({ ".ooo.", "o###o", "o###o", "o###o", ".ooo." }, x0, y0, { o = CREAM, ["#"] = DARK })
  c:px(x0 + 1, y0 + 1, CREAM)          -- glint at pupil upper-left
  c:px(x0 + 3, y0 + 3, "#4c4c9f")      -- subtle accent
end
eye(10, 16); eye(20, 16)

-- tiny grin + cheeks
c:fill(c:rect(15, 21, 18, 21), MOUTHD)
c:fill(c:rect(9, 21, 10, 21), PINK)
c:fill(c:rect(24, 21, 25, 21), PINK)

-- water texture: hand bounce, ripples, foam
c:px(25, 29, BLU); c:px(28, 28, BLU)             -- bounce, lower-right water edge
c:px(11, 28, NAVY); c:px(21, 28, NAVY)           -- ripple ticks
c:px(12, 26, CREAM); c:px(22, 26, CREAM)
c:px(8, 27, CREAM); c:px(27, 27, CREAM)
c:px(14, 6, WOODD); c:px(15, 8, WOODD)           -- mast grain ticks

local t = c:save(D .. "out/pl-chil-2-perch.aseprite", D .. "out/pl-chil-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
