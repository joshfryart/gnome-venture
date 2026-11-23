-- pl-drmc-2-perch.lua : chibi wizard pal on a wooden stump perch (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drmc-2-perch-20261120-175719/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0, cres = 2, deep = 1 }

-- palette
local PINK   = "#d53987"   -- hat / scarf base
local LPINK  = "#e26fa5"   -- lit pink
local MAG    = "#8c1e4b"   -- deep magenta (beard / shade)
local CREAM  = "#e5ca89"   -- face base
local TAN    = "#d6b370"   -- face lower / brim / stump-top warm tone
local GOLD   = "#fbe69b"   -- pale gold (star, glints)
local BROWN  = "#c38b6c"   -- log body
local DBROWN = "#442217"   -- deep wood
local MAUVE  = "#7a5552"   -- mid mauve-brown
local OL     = "#2b1c26"   -- outline
local PALG   = "#4e3e5c"   -- dark purple-grey

-- ramps (derived, light upper-left)
local PINKR  = GV.ramp(PINK,  { gloss = LPINK, dot = "#f3b1cc", rim = LPINK })
local FACER  = GV.ramp(CREAM, { gloss = GOLD, dot = "#fff6e0", rim = "#f6e2b0", shade = TAN, deep = "#9a6b3f", bounce = "#cfa967" })
local TOPR   = GV.ramp(TAN,   { gloss = "#f2e0ae", dot = "#fff6e0", rim = "#e8ce96" })
local BRIMR  = GV.ramp(TAN,   { gloss = "#f6e6b8", rim = "#f6e2b0", shade = "#b98a52", deep = "#7d5530", bounce = "#cfa967" })
local WOODR  = GV.ramp(BROWN, { gloss = "#e0c19a", rim = "#d8ac80", shade = MAUVE, deep = DBROWN })
local BOOR   = GV.ramp(MAUVE, { deep = DBROWN })
local MAGR   = GV.ramp(MAG,   { gloss = "#c3558a", dot = "#ee88b4" })
local GOLDR  = GV.R.gold
local HEARTR = GV.ramp(LPINK, { gloss = GOLD, rim = "#f2a0c2" })

-- SHADE + TEXTURE — back to front
-- 1) stump perch: 2-tone log, slim top face
local logM, topM = c:rrect(10, 26, 25, 30, 2), c:ellipse(17.5, 26.5, 7.5, 1.4)
c:part(logM, WOODR, { cres = 1, deep = 1, bounce = false })   -- log body: base sides, shade bottom-right edge
c:part(topM, TOPR)
-- tree ring on the top face (tone-on-tone)
local ring = c:ellipse(17.5, 26.5, 5, 1):cut(c:ellipse(17.5, 26.5, 3.6, 0.6)):clip(topM)
ring:each(function(x, y) if y <= 26 then c:px(x, y, "#b98a52") end end)

-- 2) scarf / body (lit pink, clear against the boots)
c:part(c:rrect(14, 20, 21, 24, 1), PINKR)

-- 3) boots planted on the top face
c:part(c:rrect(11, 24, 15, 26, 1), BOOR, { bounce = false })
c:part(c:rrect(20, 24, 24, 26, 1), BOOR, { bounce = false })

-- 4) face + beard
local face = c:ellipse(17.5, 17.2, 8, 5.1)
c:part(face, FACER)
c:part(c:ellipse(17.5, 21.2, 6.5, 1.3):clip(face), MAGR)

-- 5) hat: cone (crescent measured on cone+brim) then TAN brim
local coneM = c:poly({ {16,3},{11,6},{9,9},{9,11},{26,11},{22,8} })
local brimM = c:ellipse(17.5, 12.5, 8.5, 1.7)
local hatLight = coneM:copy():add(brimM)
local coneP = c:part(coneM, PINKR, { light = hatLight })
c:part(brimM, BRIMR)

-- 6) staff + lantern on the left
c:part(c:rect(5, 11, 6, 25), WOODR, { contact = false })
c:part(c:rrect(4, 7, 7, 10, 1), GOLDR, { contact = false, cres = 1, deep = 1 })
c:px(5, 8, "#fff6e0"); c:px(6, 8, "#fff6e0")                  -- lantern glow
c:part(c:rect(5, 6, 6, 6), BOOR, { contact = false })

-- 7) heart accent (floats to the right)
c:part(c:ascii({ ".h.h", "hhhh", ".hh.", "..h." }, 29, 13), HEARTR, { contact = false })

-- dither at light/shade borders: soften one shade step into the lit side (max 2 px per part)
local function soften(P, r, n)
  local hits = {}
  P.m:each(function(x, y) hits[x + y * 64] = true end)
  local edits = 0
  for k, _ in pairs(hits) do
    local x, y = k % 64, (k - k % 64) / 64
    if c:get(x, y) == r.shade and c:get(x - 1, y - 1) == r.base and edits < n then
      c:px(x, y, r.base); edits = edits + 1
    end
  end
end
soften(coneP, PINKR, 2)

-- 9) texture: fabric weave on the scarf, bark on the log, skin speckle
c:px(15, 23, "#a9247d"); c:px(17, 24, "#a9247d"); c:px(19, 23, "#a9247d")  -- scarf weave dashes
c:px(14, 22, "#e9a6c1"); c:px(20, 22, "#e9a6c1")                            -- weave lights
c:px(24, 29, DBROWN); c:px(22, 30, DBROWN); c:px(19, 29, DBROWN)            -- bark ticks
c:px(12, 19, FACER.shade)                                                   -- face felt speckle

-- 8) small details / gloss
c:paint({ ".g.", "ggg", ".g." }, 17, 5, { g = GOLD })   -- hat star
c:px(18, 5, "#fff6e0")                                  -- star sparkle
c:eye(12, 14); c:eye(19, 14)
c:px(17, 19, OL); c:px(18, 19, OL)                      -- mouth
c:px(30, 14, GOLD)                                      -- heart glint

-- shadow
c:ground(17.5, 31, 11, 1.5, MAUVE)

c:finish()
for k, v in pairs(c.pix) do
  if v == "#74462a" or v == "#4a2c1a" or v == "#2a1a10" then c.pix[k] = OL end
end

local t = c:save(D .. "out/pl-drmc-2-perch.aseprite", D .. "out/pl-drmc-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1 and t.colours <= 44)
