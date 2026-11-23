-- pl-drft-1-perch : chibi perch sprite, 36x36 (pal: blue blob w/ gold fronds, rock perch)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-1-perch-20261120-173754/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

local gold  = GV.R.gold
local dome  = GV.ramp("#7493dc")
local body  = GV.ramp("#9daab5")
local rock  = GV.ramp("#9c886f")
local dark  = "#2b1c26"

-- crown fronds (flat, behind the body)
local fronds = c:mask()
fronds:poly({{13,13},{12,7},{14,4},{15,12}})                 -- left frond
fronds:poly({{12,12},{13,5},{16,3},{17,12}})                 -- centre-left
fronds:poly({{17,13},{18,4},{21,6},{20,13}})                 -- centre-right
fronds:poly({{20,13},{22,5},{25,8},{23,13}})                 -- right frond
c:part(fronds, gold, { flat = true, gloss = false })

-- head/body blob (sits 3 px into the perch top)
local bod = c:ellipse(17.5, 20.5, 10, 10)
c:part(bod, body, { gloss = {13, 18} })

-- blue dome cap on the head top
local cap = c:ellipse(17.5, 13.5, 10, 4.5)
cap:clip(bod)
c:part(cap, dome, { flat = true, gloss = false })

-- rock perch (smaller than the body)
local perch = c:rrect(9, 26, 27, 31, 3)
c:part(perch, rock, { gloss = false })

-- accent: tiny swirl-fish right of the body
local fish = c:ellipse(29.5, 24, 2, 2)
c:part(fish, dome, { flat = true, gloss = false })

-- face: big cream eyes with dark pupils + glints, tiny mouth, dusk-pink cheeks
c:eye(12, 19); c:eye(21, 19)
c:px(17, 24, dark); c:px(18, 24, dark); c:px(18, 25, dark)   -- tiny open smile
c:paint({ "cc", "cc" }, 10, 23, { c = "#484076" })           -- left cheek
c:paint({ "cc", "cc" }, 26, 23, { c = "#484076" })           -- right cheek

-- brown swirl marks on the lower body (from the pal's spiral pattern)
c:px(12, 25, "#8d5a37"); c:px(13, 26, "#8d5a37"); c:px(12, 26, "#46333f")
c:px(23, 25, "#8d5a37"); c:px(22, 26, "#8d5a37"); c:px(23, 26, "#46333f")

-- 1px dither at the body's light/shade border (follows the crescent)
c:px(11, 21, "#9daab5"); c:px(26, 20, "#6f7c92"); c:px(25, 22, "#6f7c92"); c:px(10, 24, "#6f7c92")

-- perch texture: 2 stone joint cracks + tone-on-tone wear on the lit top
c:px(14, 29, "#523c39"); c:px(14, 30, "#523c39")
c:px(22, 30, "#523c39"); c:px(23, 30, "#523c39")
c:px(12, 28, "#b0a78d"); c:px(19, 28, "#9c886f"); c:px(25, 29, "#b0a78d")
c:px(16, 30, "#826e59"); c:px(20, 30, "#826e59")              -- lower-edge wear

-- fish detail: eye, tail tick, glint (flat blue dome tones)
c:px(31, 23, "#46333f")            -- eye
c:px(30, 26, "#6f98c4")            -- tail tick
c:px(29, 23, "#85bfe0")            -- glint

-- the pal's tiny gold spark, upper-right of the crown
c:px(30, 15, "#f5cf6a"); c:px(31, 16, "#e8a317")

-- soft ground shadow ellipse under the perch
c:ground(17.5, 31.2, 11, 1)

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-1-perch-20261120-173754/out/pl-drft-1-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-1-perch-20261120-173754/out/pl-drft-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
