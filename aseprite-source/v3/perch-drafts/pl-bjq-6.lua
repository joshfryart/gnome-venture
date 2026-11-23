-- pl-bjq-6-perch: chibi perch sprite, 36x36. Phase: CRITIQUE (fix bowl overlap + beak, final check)
local ROOT = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bjq-6-perch-20261120-170438/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", margin = 2 }

-- ramps from the pal's dominant colours
local bodyRp  = GV.ramp("#8fc0f0", { shade = "#5a90d8", deep = "#4a589e", bounce = "#cfe8ff", rim = "#cfe8ff" })
local chestRp = GV.ramp("#fdf5d3", { shade = "#e0c8d8", deep = "#ca9787", bounce = "#e0c8d8", rim = "#fdf5d3" })
local wingRp  = GV.ramp("#8965a0")
local bowlRp  = GV.ramp("#4a589e")   -- indigo wicker perch

-- masks
local body      = c:ellipse(17.5, 13.5, 10, 10)                    -- head+body dome, y3..y23
local chest     = c:ellipse(17.5, 16.5, 7, 5.5):clip(body)         -- cream front, y11..y22
local wingL     = c:ellipse(8, 14, 2, 4.5)                         -- x6..x10, y9..y19
local wingR     = c:ellipse(27, 14, 2, 4.5)
local bowlBack  = c:ellipse(17.5, 24.5, 12, 5.5)                   -- perch cradle, y19..y30
local bowlFront = c:ellipse(17.5, 24.5, 12, 5.5):cut(c:rect(0, 0, 35, 23)) -- front wall, y24..y30

c:build{
  { "bowlBack", bowlBack, bowlRp, { gloss = false } },
  { "body",     body,     bodyRp, {} },
  { "chest",    chest,    chestRp, { gloss = false, contour = false, contact = false } },
  { "wingL",    wingL,    wingRp, { gloss = false } },
  { "wingR",    wingR,    wingRp, { gloss = false } },
  { "bowlFront", bowlFront, bowlRp, { gloss = false } },}

-- face (locked gvlib eyes, 5x5, top-left corner)
c:eye(12, 8); c:eye(20, 8)
-- pink cheeks (low on the cream face, beside the mouth)
c:paint({ "uu", "uu" }, 11, 14, { u = "#ca9787" })
c:paint({ "uu", "uu" }, 23, 14, { u = "#ca9787" })

-- TEXTURE: tiny beak wedge (2x2, dark), 1px warm transition at its lower-left
c:paint({ "uu", "uu" }, 17, 14, { u = "#2b1c26" })
c:px(16, 15, "#ca9787")

-- TEXTURE: subtle tone-on-tone flecks on the cream face, following the form
c:px(14, 18, "#e0c8d8"); c:px(19, 19, "#e0c8d8"); c:px(22, 17, "#e0c8d8")
c:px(15, 12, "#e0c8d8")

-- TEXTURE: wicker joint marks on the bowl front wall, tone-on-tone, woven offsets
c:paint({ "uuu" }, 11, 26, { u = "#312652" })
c:paint({ "uu" }, 20, 26, { u = "#312652" })
c:paint({ "uuu" }, 14, 28, { u = "#312652" })
c:paint({ "uu" }, 22, 28, { u = "#312652" })
c:paint({ "uu" }, 9, 28, { u = "#312652" })

-- DETAIL: tiny feather accent from the pal, resting on the bowl's right lip
c:px(30, 24, "#b185b4")
c:paint({ "u.", "uu", "uu", "u." }, 29, 23, { u = "#8965a0" })

-- soft shadow under the perch
c:ground(17.5, 31, 9, 1.5)

local t = c:save(
  ROOT .. "out/pl-bjq-6-perch.aseprite",
  ROOT .. "out/pl-bjq-6-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
