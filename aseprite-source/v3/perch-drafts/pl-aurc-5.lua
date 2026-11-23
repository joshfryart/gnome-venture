-- pl-aurc-5-perch: chibi perched on its rock, 36x36. Light upper-left.
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurc-5-perch-20261120-164110/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "scene", ol = 1, olx = 0 }
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#5c244f", "#5c244f", "#2b1c26"  -- one dark-plum outline

local blue = GV.ramp("#8ca7b9")   -- dome + body (pal's blue-grey)
local pink = GV.ramp("#d53987")   -- hood + diamonds (pal's pink)
local rock = GV.ramp("#5b465e")   -- perch stone (pal's grey-purple rock)
local wood = GV.ramp("#9a8669")   -- staff + feet (pal's mauve-tan)
local glow = GV.ramp("#e2e3bc")   -- lantern (pale -> gold rim, cream)

local FL = { flat = true, gloss = false, contact = false, contour = false, bounce = false, stitch = false, outline = false }
local NO = { outline = false }

-- back to front
c:part(c:line({ {5, 11}, {5, 30} }, 2), wood, FL)                                   -- staff
c:part(c:rrect(3, 6, 7, 10, 1), glow, FL)                                           -- lantern
c:part(c:rrect(7, 26, 27, 31, 3), rock, { bounce = true, outline = false })         -- rock perch
c:part(c:rect(13, 25, 14, 26), wood, { flat = true, contour = false, outline = false })   -- feet
c:part(c:rect(21, 25, 22, 26), wood, { flat = true, contour = false, outline = false })
c:part(c:rrect(12, 19, 23, 24, 3), blue, { contour = false, outline = false, bounce = false }) -- body
c:part(c:ellipse(17.5, 13, 10, 7), blue, { contour = false, gloss = false, outline = false, bounce = false })  -- head-dome
c:part(c:ellipse(17.5, 6, 6, 3), pink, { contour = "#5c244f", gloss = false, outline = false, bounce = true }) -- hood
c:part(c:poly({ {32, 7}, {34, 10}, {32, 13}, {29, 10} }), pink, { flat = true, outline = false }) -- floating diamond
c:eye(10, 11); c:eye(21, 11)                                                        -- 5x5 cream eyes
c:fill(c:rect(8, 16, 9, 17), "#cd6e8c"); c:fill(c:rect(25, 16, 26, 17), "#cd6e8c")  -- cheeks
c:fill(c:rect(17, 18, 18, 18), "#343d65")                                           -- tiny mouth
c:spot(c:ellipse(17.5, 28, 2, 1), "#d53987", "#cd6e8c")                             -- gem inlay on rock

-- texture: sparse 1px dither at light/shade crescent borders, tone-on-tone
local function dither(mask, from, to, step)
  mask:each(function(x, y)
    if c:get(x, y) == from and (x + y) % (step or 4) == 0 then c:px(x, y, to) end
  end)
end
dither(c:ellipse(17.5, 6, 6, 3), pink.deep, pink.shade, 4)                        -- hood crescent edge
dither(c:ellipse(17.5, 13, 10, 7), blue.deep, blue.shade, 4)                      -- dome crescent edge
dither(c:ellipse(17.5, 13, 10, 7), blue.shade, blue.base, 5)                      -- dome shade/base edge
dither(c:rrect(7, 26, 27, 31, 3), rock.deep, rock.shade, 4)                       -- rock crescent edge
c:px(11, 28, rock.shade); c:px(11, 29, rock.shade)                                -- stone joint, left
c:px(23, 29, rock.shade); c:px(24, 28, rock.shade)                                -- stone joint, right
c:px(5, 16, wood.shade); c:px(6, 21, wood.shade); c:px(5, 26, wood.shade)         -- staff grain
local dome = c:ellipse(17.5, 13, 10, 7)
c:gloss(dome, blue, {12, 10})                                                     -- enamel gloss comma, upper-left
c:gloss(c:ellipse(17.5, 6, 6, 3), pink, {13, 5})                                  -- hood gloss comma
c:px(9, 4, "#e2e3bc"); c:px(10, 6, "#e2e3bc")                                     -- tiny bubble accents

c:ground(17.5, 31, 14, 1.2, "#2a214e")                                            -- shadow ellipse
c:outline(c.sil, { keep = true })                                                 -- one dark outline, no border

local t = c:save(D .. "out/pl-aurc-5-perch.aseprite", D .. "out/pl-aurc-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
