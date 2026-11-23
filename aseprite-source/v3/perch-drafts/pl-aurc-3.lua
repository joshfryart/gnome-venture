-- pl-aurc-3-perch.lua : chibi stitched pal (pale dome cap, green body, gold flag) on a purple plinth (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurc-3-perch-20261120-163708/"
local GV = dofile(D .. "gvlib/gvlib.lua")

-- ramps -------------------------------------------------------------------
local capR  = GV.ramp("#c8d0e0", { gloss = "#f2f6fc", rim = "#d5dced", shade = "#8f93a5",
                                   deep = "#565b7c", bounce = "#a9b0c4" })
local bandR = GV.ramp("#565b7c", { shade = "#43486a", deep = "#33355a", rim = "#7883a8", bounce = "#5f6488" })
local bodyR = GV.ramp("#3a704b", { gloss = "#8ecd90", rim = "#7ab578", dot = "#a8dc74",
                                   shade = "#2c483a", deep = "#173530", bounce = "#45684d" })
local baseR = GV.ramp("#6a5361", { gloss = "#b8aecc", rim = "#d8c8f0", dot = "#e0d8ec",
                                   shade = "#4a3a68", deep = "#33355c", bounce = "#7a6a85" })
local bootR = GV.ramp("#5b3a3c", { gloss = "#a86a5e", rim = "#8a5550", shade = "#4a2430",
                                   deep = "#35161f", bounce = "#6a4238" })
local woodR = GV.ramp("#9a6b3f", { base = "#8a5f46", gloss = "#c9a96e", rim = "#b5854f",
                                   bounce = "#a05a34", shade = "#5b3a2c", deep = "#3c2519" })
local sprR  = GV.ramp("#8ecd90", { rim = "#a8dc74" })
local stubR = GV.ramp("#7ac8f0", { gloss = "#c2dded", rim = "#a6cee4", shade = "#4a8ac0",
                                   deep = "#35619a", bounce = "#5a86b8" })
local flagR = GV.ramp("#f8e994", { gloss = "#ffefae", rim = "#ffefae", shade = "#e8a317", deep = "#b07a1c" })

local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

-- parts back to front ------------------------------------------------------
p = c:build({
  { "pole", c:rect(5, 6, 6, 29), woodR, { flat = true } },
})

-- pale dome cap
p.cap = c:part(c:ellipse(16.5, 11.5, 8.5, 5), capR, { bounce = false })

-- flag in front of the cap's left edge (as in the pal)
p.flag = c:part(c:rect(6, 8, 11, 9):add(c:rect(6, 10, 8, 11)), flagR, { flat = true })
c:px(6, 9, flagR.shade); c:px(11, 9, flagR.deep); c:px(7, 10, flagR.dot)

-- sprout on the cap top
p.sprout = c:part(c:rect(15, 5, 16, 7), sprR, { flat = true })

-- green body
local bodyM = c:ellipse(17, 21, 8.5, 4.5)
p.body = c:part(bodyM, bodyR, { gloss = false })

-- brim band in front of cap bottom
p.band = c:part(c:rrect(8, 15, 25, 17, 1), bandR, { contour = false })

-- blue stub at the right shoulder
p.stub = c:part(c:ellipse(25.5, 20.5, 1.8, 2.3), stubR, { flat = true })

-- purple plinth, boots on top
p.base = c:part(c:rrect(10, 27, 24, 29, 1), baseR, {})
p.bootL = c:part(c:rrect(12, 25, 14, 27, 1), bootR, { flat = true })
p.bootR2 = c:part(c:rrect(19, 25, 21, 27, 1), bootR, { flat = true })

-- texture: hand-placed, tone-on-tone, following the form --------------------
-- lit green mass on the body's upper-left (under the band shadow's edge)
local lit = c:ellipse(11.5, 19.5, 4, 2.5):add(c:ellipse(14.5, 18.2, 3, 1.6))
c:fill(bodyM:copy():clip(lit), bodyR.rim)
c:px(10, 19, bodyR.dot); c:px(13, 18, bodyR.dot)
-- mossy shade dashes on the body's lower-right (1 tone step down)
local sh = c:ellipse(20, 23.5, 3.5, 1.6):add(c:ellipse(17, 24, 2.4, 1.2))
c:fill(bodyM:copy():clip(sh), bodyR.shade)
-- dither at the lit/shade boundary
c:px(16, 21, bodyR.shade); c:px(18, 20, bodyR.shade); c:px(20, 22, bodyR.shade)
-- cap: faint weave dashes following the dome, left lit / right shaded
c:px(11, 10, capR.rim); c:px(12, 9, capR.rim); c:px(10, 12, capR.rim)
c:px(22, 12, capR.shade); c:px(23, 13, capR.shade); c:px(21, 14, capR.shade)
-- pole wood grain
c:px(5, 14, woodR.shade); c:px(6, 21, woodR.shade); c:px(5, 25, woodR.rim)
-- plinth lavender sparkle + shade marks
c:px(11, 28, baseR.dot); c:px(21, 29, baseR.shade); c:px(22, 28, baseR.shade)
-- boot highlights
c:px(13, 26, bootR.rim); c:px(20, 26, bootR.rim)
-- sprout highlight
c:px(15, 5, sprR.rim)

-- face: 4x4 cream eyes, cheeks, gold zigzag chest seam ----------------------
local function eye4(x, y)
  for j = 0, 3 do for i = 0, 3 do
    if not ((i == 0 or i == 3) and (j == 0 or j == 3)) then c:px(x + i, y + j, GV.C.halo) end
  end end
  for j = 1, 2 do for i = 2, 3 do c:px(x + i, y + j, GV.C.ol3) end end
  c:px(x + 2, y + 1, GV.C.halo)               -- glint
  return c
end
eye4(10, 19); eye4(19, 19)
c:px(10, 23, "#f08aa0"); c:px(15, 23, "#f08aa0")          -- pink cheek + tongue px
c:seam({ {10,24},{12,23},{14,24},{16,23},{18,24},{21,23} }) -- chest zigzag
c:px(25, 20, stubR.gloss)                                 -- stub glint

c:ground(17.5, 28.5, 10, 0.8)
local t = c:save(D .. "out/pl-aurc-3-perch.aseprite", D .. "out/pl-aurc-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)

-- 16px readability check: nearest-sample the saved png down to 16x16
do
  local pc = app.pixelColor
  local img = Image{ fromFile = D .. "out/pl-aurc-3-perch.png" }
  local rows, legend, seen = {}, {}, {}
  for y = 0, 15 do
    local r = {}
    for x = 0, 15 do
      local v = img:getPixel(math.min(35, math.floor((x + 0.5) * 36 / 16)), math.min(35, math.floor((y + 0.5) * 36 / 16)))
      if pc.rgbaA(v) == 0 then r[#r+1] = "."
      else
        if not legend[v] then legend[v] = ("abcd"):sub(#seen + 1, #seen + 1) seen[v] = true end
        r[#r+1] = legend[v]
      end
    end
    rows[#rows+1] = table.concat(r)
  end
  local tag = {}
  for v, ch in pairs(legend) do tag[#tag+1] = ch .. "=#" .. string.format("%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)) end
  print("=== read 16x16 ===")
  print(table.concat(rows, "\n"))
  print(table.concat(tag, " "))
end
