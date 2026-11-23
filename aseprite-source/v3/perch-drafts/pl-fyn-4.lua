-- pl-fyn-4-perch.lua : 36x36 chibi perch pal (pink pal with gold cap, green striped cushion, taupe pole)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-fyn-4-perch-20261120-185728/gvlib/gvlib.lua")
local OUT = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-fyn-4-perch-20261120-185728/out/"

-- palette-tuned outline + eye cream (spec: dark palette colours, pal cream tone)
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#5b3a44", "#4a2430", "#2b1c26"
GV.C.halo = "#f4eede"

local c = GV.canvas{ w = 36, h = 36, ol = 1 }

local PINK   = GV.ramp("#d58a8d", { shade = "#c04a75", deep = "#953363" })
local GREEN  = GV.ramp("#91d26f")
local GOLD   = GV.ramp("#f6d17c")
local POLE   = GV.ramp("#876464")

local dia  = c:rrect(3, 4, 5, 6, 1)               -- accent diamond A
local dia2 = c:rrect(7, 3, 9, 5, 1)               -- accent diamond B
local pole = c:rect(27, 11, 28, 29)               -- taupe pole, touches the blob, planted into the cushion
local cush = c:rrect(5, 25, 29, 30, 3)            -- green cushion
local body = c:ellipse(16.5, 19, 9.5, 10.5)       -- pink chibi blob, sits on the cushion
local cap  = c:rrect(9, 5, 24, 9, 2)              -- gold cap slab on the head

local p = c:build{
  { "dia",  dia,  GOLD, { flat = true } },
  { "dia2", dia2, GOLD, { flat = true } },
  { "pole", pole, POLE, { rim = false, cres = 1, deep = 0 } },
  { "cush", cush, GREEN, { cres = 1, deep = 1 } },
  { "body", body, PINK, { cres = 3, deep = 2 } },
  { "cap",  cap,  GOLD, { cres = 2, deep = 1 } },
}

c:eye(10, 15); c:eye(19, 15)
c:px(16, 21, "#661e49"); c:px(17, 21, "#661e49")
c:px(9, 20, "#c04a75"); c:px(10, 20, "#c04a75")
c:px(23, 20, "#c04a75"); c:px(24, 20, "#c04a75")
c:px(30, 6, GV.ramp("#f6d17c").dot); c:px(31, 5, GV.ramp("#f6d17c").rim)

c:ground(17, 31.5, 14, 1, "#4a2430")

-- TEXTURE: cushion weave stripes, cap dots, terminator dither  (after parts, before save)
local stripe = c:rect(6, 26, 21, 26):clip(p.cush.m)  -- weave stripe A, left of the gloss zone
stripe:each(function(x, y) if not c.gl.s[c:key(x, y)] then c:px(x, y, GREEN.gloss) end end)
local stripe2 = c:rect(6, 28, 19, 28):clip(p.cush.m) -- weave stripe B
stripe2:each(function(x, y) if not c.gl.s[c:key(x, y)] then c:px(x, y, GREEN.shade) end end)
c:px(12, 7, "#c04a75"); c:px(21, 7, "#c04a75")              -- cap dots
for _, d in ipairs({ {21, 14}, {22, 18}, {20, 24}, {16, 25}, {12, 25} }) do -- terminator dither
  if c:get(d[1], d[2]) == PINK.base then c:px(d[1], d[2], PINK.shade) end
end

-- DETAIL: pole lit top, gloss placement checks
c:px(27, 11, POLE.gloss); c:px(28, 11, POLE.base)

local t = c:save(OUT .. "pl-fyn-4-perch.aseprite", OUT .. "pl-fyn-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
