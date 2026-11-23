-- pl-drft-6-perch: chibi gnome on a wooden perch (36x36)
-- PHASE: DETAIL (face, gloss, bounce, contacts by hand)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-6-perch-20261120-175009/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, cres = 0, margin = 3 }

-- soft shadow ellipse (back-most, flat)
c:fill(c:ellipse(17.5, 28, 9, 1.25), "#7d737d")

local stump = c:rrect(11, 23, 24, 29, 2):add(c:ellipse(17.5, 23.5, 6.5, 2))
local body  = c:rrect(13, 19, 22, 24, 3)
local head  = c:ellipse(17.5, 12.5, 6, 5.5)
local beard = c:rrect(14, 15, 21, 20, 4)
local hat   = c:poly({ {17.5, 3}, {23.5, 10}, {11.5, 10} }):add(c:rrect(11, 9, 24, 11, 1))

local FL = { flat = true, contour = false, contact = false }
c:build{
  { "stump", stump, "#8a5a34", FL },
  { "body",  body,  "#bc743f", FL },
  { "head",  head,  "#f7f0e3", FL },
  { "beard", beard, "#e7d1c0", FL },
  { "hat",   hat,   "#cf4897", FL },
}

-- hat band by hand
c:fill(c:rrect(12, 9, 23, 11, 1), "#ffeca4")
c:fill(c:rrect(12, 9, 20, 11, 1), "#fff3c8")

-- hand shading, light from upper-left -------------------------------------
-- hat: shade crescent on the right of the cone
c:fill(c:poly({ {17.5,3},{23.5,10},{20,10},{15,4.5} }), "#b53079")
c:px(22, 10, "#8a2070")
-- soft contact on the face under the brim
c:fill(c:rect(12, 12, 23, 12), "#e4c3a1")
-- head: shade crescent lower-right (cut shift trick)
c:fill(head:copy():cut(c:ellipse(15.5, 10.5, 6, 5.5)), "#deb38b")
-- beard: shade along its lower edge
c:fill(c:rrect(14, 18, 21, 20, 3), "#d0b4a0")
-- contact line where the beard hangs over the body
c:fill(c:rect(15, 20, 20, 20), "#8f4830")
-- body: right-side shade + hem
c:fill(body:copy():cut(c:rrect(12, 18, 21, 22, 3)), "#a5632f")
-- stump: lit top surface + right shade, clipped to the stump outside the body
local litTop = c:ellipse(17.5, 23.5, 6.5, 2):clip(stump):cut(body)
c:fill(litTop, "#bea352")
c:fill(c:poly({ {22,24},{24,24},{24,29},{21,29} }):clip(stump):cut(body), "#693a28")
-- contact line where the body rests on the pot
c:fill(c:rect(15, 25, 20, 25), "#8f4830")
-- bounce light on lower-right edges
c:px(24, 26, "#8f4830"); c:px(23, 29, "#8f4830"); c:px(22, 24, "#8f4830")

-- texture: subtle, following the form --------------------------------------
-- wood grain on the stump: two short tone-on-tone dashes
c:px(15, 26, "#693a28"); c:px(16, 28, "#693a28")
-- felt body specks
c:px(15, 22, "#a5632f"); c:px(17, 24, "#a5632f")
-- beard knit step
c:px(18, 19, "#d0b4a0")

-- gloss --------------------------------------------------------------------
-- hat enamel comma
c:px(14, 5, "#e4849c"); c:px(13, 6, "#e4849c")
-- face small gloss dot
c:px(13, 10, "#fff3c8")

-- face ---------------------------------------------------------------------
c:eye(14, 10, true); c:eye(19, 10, true)
c:px(12, 14, "#d88d8f"); c:px(23, 14, "#d88d8f")
c:paint({ ".uu." }, 16, 14, { u = "#724067" })

-- tiny sparkle accents from the pal
c:paint({ ".u.", "u.u", ".u." }, 5, 5, { u = "#ffeca4" })
c:paint({ ".u.", "u.u", ".u." }, 27, 8, { u = "#ffeca4" })

local t = c:save(D .. "out/pl-drft-6-perch.aseprite", D .. "out/pl-drft-6-perch.png")
print(GV.report(t))
