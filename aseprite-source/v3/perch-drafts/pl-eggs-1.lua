-- pl-eggs-1-perch: chibi leaf-hedgehog pal on a wood stump perch (36x36)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-eggs-1-perch-20261120-180541/gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

local S = { cres = 1, deep = 0 }                      -- thin parts: 1px shade only
local p = c:build{
  { "stump",  c:rrect(12, 25, 24, 28, 2), "wood" },
  { "trunk",  c:rrect(14, 20, 22, 24, 2), GV.ramp("#5f4022", { rim = "#8a6238", gloss = "#a87d4e" }), { flat = true } },
  { "head",   c:ellipse(17.5, 12.5, 8, 6.5), GV.ramp("#4fab3d") },
  { "sproutL", c:ellipse(11.5, 7, 1.5, 2), GV.ramp("#3f8941"), { cres = 1, deep = 0, contour = false } },
  { "sproutM", c:ellipse(17.5, 7, 2, 2), GV.ramp("#3f8941"), { cres = 1, deep = 0, contour = false } },
  { "sproutR", c:ellipse(23.5, 7, 1.5, 2), GV.ramp("#3f8941"), { cres = 1, deep = 0, contour = false } },
  { "scarf",  c:rrect(11, 18, 24, 20, 2), GV.ramp("#bb2d80", { shade = "#9a6586" }), S },
  { "tail",   c:rrect(10, 20, 12, 24, 1), GV.ramp("#bb2d80", { shade = "#9a6586" }), S },
  { "footL",  c:rrect(13, 23, 16, 24, 1), GV.ramp("#5f4022"), S },
  { "footR",  c:rrect(19, 23, 22, 24, 1), GV.ramp("#5f4022"), S },
  { "snout",  c:ellipse(8.5, 14, 2.5, 1.5), GV.ramp("#bcb094"), S },
}
c:paint({ ".u.", "uUu", ".u." }, 4, 10, { u = "#8fcbd8", U = "#c8ecdc" })
c:ground(17.5, 27.5, 10.5, 1, "#4a375e")
c:px(15, 21, "#8a6238"); c:px(16, 21, "#8a6238")
c:px(21, 22, "#48291a"); c:px(20, 23, "#48291a")
c:eye(11, 9); c:eye(20, 9)
c:px(17, 15, "#2b1c26"); c:px(18, 15, "#2b1c26")
-- texture: moss speckles on the lit head, tone-on-tone; dither dots at the crescent border
c:px(12, 12, "#7ab660"); c:px(15, 11, "#7ab660"); c:px(16, 15, "#a4d476")
c:px(21, 12, "#7ab660"); c:px(24, 16, "#2e822e")
-- wood grain on stump front + bark seam on belly
c:px(15, 26, "#8a4f2a"); c:px(15, 27, "#8a4f2a"); c:px(22, 26, "#8a4f2a"); c:px(21, 27, "#8a4f2a")
c:px(18, 23, "#48291a")
-- knit dashes on scarf upper band
c:px(14, 19, "#9a6586"); c:px(18, 19, "#9a6586"); c:px(22, 19, "#9a6586")
c:px(16, 20, "#8a2672"); c:px(20, 20, "#8a2672")
-- detail: light sprout tips, nose glint, tassel bounce, stump lip highlight, leaf accent
c:px(11, 5, "#a4d476"); c:px(12, 5, "#a4d476")
c:px(17, 5, "#a4d476"); c:px(18, 5, "#a4d476")
c:px(23, 5, "#a4d476"); c:px(24, 5, "#a4d476")
c:px(7, 13, "#e2e0a5")
c:px(10, 24, "#9a6586")
c:px(13, 25, "#ecc58a")
c:paint({ ".l.", "lll" }, 27, 26, { l = "#3f8941" })

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-eggs-1-perch-20261120-180541/out/pl-eggs-1-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-eggs-1-perch-20261120-180541/out/pl-eggs-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
