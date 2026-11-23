-- pl-bvd-6-perch: chibi beaver pal with blue cap on a wood log perch, 36x36
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-6-perch-20261120-171543/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, margin = 2 }

local capR  = GV.ramp("#545988")
local furR  = GV.ramp("#b87a46")
local belR  = GV.ramp("#eac784", { deep = "#b07a45" })
local woodR = GV.ramp("#8f6040", { deep = "#5a3620" })

-- shapes
local log   = c:rrect(9, 26, 26, 30, 2)
local body  = c:rrect(12, 18, 23, 27, 3)
local belly = c:rrect(15, 21, 20, 27, 3)
local armL  = c:rrect(10, 20, 12, 24, 1)
local armR  = c:rrect(23, 20, 25, 24, 1)
local head  = c:ellipse(17.5, 12.5, 8.5, 7)
local earL  = c:ellipse(9.5, 10.5, 1.5, 1.5)
local earR  = c:ellipse(25.5, 10.5, 1.5, 1.5)
local crown = c:rrect(10, 3, 25, 6, 2)
local brim  = c:rrect(8, 6, 27, 7, 1)
local chip  = c:rrect(28, 26, 31, 28, 1)

local p = c:build{
  { "log",   log,   woodR, { cres = 2, deep = 0 } },
  { "body",  body,  furR,  { cres = 2, deep = 1 } },
  { "belly", belly:clip(body), belR, { gloss = false } },
  { "armL",  armL,  furR, { flat = true } },
  { "armR",  armR,  furR, { flat = true } },
  { "head",  head,  furR },
  { "earL",  earL,  furR, { flat = true, gloss = false } },
  { "earR",  earR,  furR, { flat = true, gloss = false } },
  { "crown", crown, capR, { rim = false, bounce = false, gloss = { x = 13, y = 3 }, cres = 1, deep = 1 } },
  { "brim",  brim,  capR, { flat = true, gloss = false } },
  { "chip",  chip,  woodR, { flat = true } },
}
-- face after parts: locked small eyes + tiny mouth
c:eye(13, 11, true); c:eye(20, 11, true)
c:px(17, 15, "#2a1a10"); c:px(17, 16, "#2a1a10")
c:ground(17.5, 31, 10, 1.5)
-- texture: tone-on-tone, follows form, <=1 shade step
c:px(12, 10, furR.shade); c:px(23, 10, furR.shade)                 -- head fur pits, lit cheeks
c:px(19, 23, belR.shade); c:px(16, 25, belR.shade)                 -- belly weave, sparse
c:paint({ "yy.y.yy" }, 13, 28, { y = woodR.shade })                -- log grain line, lit top
c:paint({ ".yy" }, 20, 29, { y = woodR.shade })                    -- short grain tick
c:px(10, 28, woodR.shade); c:px(10, 29, woodR.deep)                -- log end grain
c:px(25, 11, furR.shade)                                           -- inner ear R
c:px(10, 11, furR.shade)                                           -- inner ear L
-- details: accents + glints
c:part(c:ellipse(4.5, 28.5, 1.5, 1.5), woodR, { flat = true, cres = 1, deep = 0, gloss = false })
c:px(14, 12, "#f2e4c0")                                            -- eye glint L (cream of locked eye)
c:px(21, 12, "#f2e4c0")                                            -- eye glint R
_ = p

local t = c:save(D .. "out/pl-bvd-6-perch.aseprite", D .. "out/pl-bvd-6-perch.png")
print(GV.report(t))
