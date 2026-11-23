-- pl-eggs-2-perch : 36x36 perch sprite for the red egg-pal with the straw hat
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-eggs-2-perch-20261120-180543/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

local strawL = GV.ramp("#eed18a", { shade = "#d9ad55", deep = "#a8773a", bounce = "#e6ca86" }) -- hat dome
local straw  = GV.ramp("#c6a358", { shade = "#a8773a", deep = "#7a5034", bounce = "#cfa85e" }) -- brim + rim lip
local nestR  = GV.ramp("#9f6e41", { bounce = "#b0814f", shade = "#7a5034" })                   -- nest back wall
local redR   = GV.ramp("#c3364f", { shade = "#a92b2b", deep = "#6b162e", bounce = "#b0453f" }) -- body
local skinR  = GV.ramp("#e0987e", { rim = "#f2c3a8", shade = "#d4744b", deep = "#b45a3e", bounce = "#e3a98e" })
local greenR = GV.ramp("#bbd6a1")                                                              -- hat band
local creamE = GV.ramp("#eed18a", { shade = "#c0a964", deep = "#9f6e41", bounce = "#e6d19a" }) -- eggs

local build = {
  { "nest", c:ellipse(17.5, 26.5, 10, 2.5), nestR, { gloss = false, contour = false } },
  { "eggL", c:ellipse(9.5, 25, 2, 2.5),     creamE, { gloss = false } },
  { "eggR", c:ellipse(25, 25.5, 2, 2.5),    creamE, { gloss = false } },
  { "body", c:rrect(12, 18, 23, 26, 4),     redR,   { gloss = { 14, 20 }, deep = 1 } },
  { "rim",  c:ellipse(17.5, 27.5, 10.5, 2.5):cut(c:rect(0, 0, 35, 26)), straw, { gloss = false, contour = false, contact = true } },
  { "face", c:ellipse(17.5, 13, 6, 5.5),    skinR,  { gloss = false, deep = 1 } },
  { "dome", c:ellipse(17.5, 4.5, 5, 1.5),   strawL, { gloss = false } },
  { "band", c:rrect(13, 7, 22, 8, 0),       greenR, { flat = true, gloss = false, contact = false } },
  { "brim", c:rrect(8, 9, 27, 12, 2),       straw,  { gloss = false, deep = 1, contact = false } },
}
local P = c:build(build)

-- sitting shade: body strip just above the rim lip falls into the bowl's shadow
c:fill(c:rect(12, 26, 23, 26):clip(P.body.m), redR.shade)
-- narrow, soft ground shadow under the bowl
c:ground(17.5, 31.5, 9.5, 0.7)

-- TEXTURE (tone-on-tone, <=1 step from base)
for _, p in ipairs({ {14,4},{17,4},{21,5} }) do c:px(p[1], p[2], strawL.shade) end          -- dome weave ticks
for _, p in ipairs({ {10,10},{15,10},{20,11},{25,10} }) do c:px(p[1], p[2], straw.rim) end  -- brim weave
for _, p in ipairs({ {9,29},{12,30},{17,30},{23,30},{26,29} }) do c:px(p[1], p[2], straw.shade) end -- rim weave
for _, p in ipairs({ {10,27},{25,27} }) do c:px(p[1], p[2], nestR.shade) end
c:fill(c:rect(8, 26, 11, 26):clip(P.eggL.m), creamE.base)                                   -- egg dither at border
c:fill(c:rect(24, 26, 26, 26):clip(P.eggR.m), creamE.base)
for _, p in ipairs({ {14,21},{19,23},{16,24} }) do c:px(p[1], p[2], redR.shade) end         -- body fabric nubs

-- DETAIL: face (pal kept big round eyes, tiny mouth, pink cheeks), glosses, sparkles
c:eye(13, 14, true); c:px(14, 15, GV.C.halo)   -- cream eye, L-shape pupil, glint
c:eye(19, 14, true); c:px(20, 15, GV.C.halo)
c:px(17, 17, "#2a1a10"); c:px(18, 17, "#2a1a10")
c:px(13, 16, "#f5a0b8"); c:px(22, 16, "#f5a0b8")
c:px(8, 23, creamE.gloss); c:px(24, 24, creamE.gloss)
c:px(27, 6, "#ffe98a"); c:px(26, 13, "#ffe98a")

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-eggs-2-perch-20261120-180543/out/pl-eggs-2-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-eggs-2-perch-20261120-180543/out/pl-eggs-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
