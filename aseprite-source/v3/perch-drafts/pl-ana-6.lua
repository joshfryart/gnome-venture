-- pl-ana-6-perch.lua : chibi perch sprite of the pl-ana-6 pal, 36x36 (gvlib)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ana-6-perch-20261120-163247/gvlib/gvlib.lua")
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ana-6-perch-20261120-163247/"
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

-- ramps (palette from spec, generated light/shade tones per gvlib addenda)
local R_body = GV.ramp("#5fae4a", { gloss = "#8fd05a", rim = "#8fc870", shade = "#3a8a52", deep = "#35507a" })
local R_leaf = GV.ramp("#3a8a52", { gloss = "#8fc870", rim = "#8fd05a", shade = "#35507a", deep = "#2b1c26" })
local R_perch = GV.ramp("#6e5c8d", { deep = "#4b3b69" })
local R_dia  = GV.ramp("#ff93b1", { base = "#ff93b1", gloss = "#ffc0d0", dot = "#ffdce4", rim = "#f8a8bc",
                                     shade = "#d85a78", deep = "#aa404b", bounce = "#c2506a", pale = false })

-- parts, back to front (TEXTURE: face redrawn, mottling added)
c:part(c:poly({ {13.5,7},{12,5},{13,3},{14.5,4},{16,7} }), R_leaf, { flat = true, gloss = false })
c:part(c:poly({ {21,7},{19,4},{20.5,3},{22,5},{23.5,7} }), R_leaf, { flat = true, gloss = false })
local p_mound = c:part(c:ellipse(18.5, 28, 7, 2.2), R_perch, { gloss = false, cres = 1, deep = 0 })
local p_body  = c:part(c:ellipse(18, 17, 9, 10), R_body, { cres = 2, deep = 0, gloss = false })
local p_dia   = c:part(c:poly({ {28.5,5.5},{30.5,8.5},{28.5,11.5},{26.5,8.5} }), R_dia, { cres = 1, deep = 0, gloss = { 27.5, 7 } })

-- face: almond glossy eyes at the crown (from x/pal.png), pink cheeks, wide open mouth + tongue
local eye = "#2b1c26"; local cream = "#f0e8b7"; local red = "#aa404b"; local lid = "#8fd05a"
for _, e in ipairs({ { 13, 8 }, { 19, 8 } }) do
  local ex, ey = e[1], e[2]
  c:fill(c:rect(ex, ey, ex + 3, ey + 2), eye)      -- pupil block
  c:fill(c:rect(ex, ey, ex + 3, ey), lid)           -- light-green upper lid
  c:px(ex, ey, eye); c:px(ex + 3, ey, eye)          -- outer corners stay dark
  c:px(ex, ey + 2, eye)                             -- rounded bottom-left
  c:px(ex + 1, ey + 1, cream); c:px(ex + 2, ey + 1, cream)   -- glossy shine pair
end
c:fill(c:rect(10, 11, 11, 12), "#d85a78")
c:fill(c:rect(10, 11, 11, 11), "#ff93b1")
c:fill(c:rect(24, 11, 25, 12), "#d85a78")
c:fill(c:rect(24, 11, 25, 11), "#ff93b1")
-- wide open smile x14..22, y13..20, dark rim, red interior, cream teeth, tongue down-left
c:paint({
  ".RRRRRR.",
  "RAAAAAR.",
  "RATTTAR.",
  "RAAATAR.",
  ".TAAT...",
  ".TA.....",
  ".TA.....",
  ".T......",
}, 14, 13, { R = "#2b1c26", A = red, T = cream })
-- body mottling: sparse leaf-tone and light-green flecks following the round form
c:paint({
  "d..d...d....",
  "...d..d....d",
  ".d....d..d..",
  "d.......d...",
  "....d..d...d",
  "..d........d",
  "d......d..d.",
  ".....d......",
}, 13, 20, { d = "#3a8a52" })
c:px(16, 20, "#8fc870"); c:px(22, 22, "#8fc870"); c:px(14, 24, "#8fc870")
c:px(17, 22, "#8fd05a"); c:px(24, 20, "#8fd05a")

-- accents from the pal: cream 4-point sparkles
c:paint({ ".T.", "TTT", ".T." }, 5, 14, { T = "#f0e8b7" })
c:px(8, 19, "#f0e8b7")
c:px(32, 25, "#f0e8b7")
-- upper-half lightening flecks + a forehead shine dot (light from upper-left)
c:px(17, 9, "#8fd05a"); c:px(18, 8, "#8fc870"); c:px(12, 10, "#8fc870"); c:px(25, 12, "#8fd05a")

-- soft contact shadow under the perch
c:ground(18.5, 30.2, 8.5, 1.1, "#4b3b69")

local t = c:save(D .. "out/pl-ana-6-perch.aseprite", D .. "out/pl-ana-6-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
