-- pl-bvd-5-perch.lua : chibi perch sprite (36x36) for pals/perch/pl-bvd-5
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-5-perch-20261120-171502/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

-- ramps (borrowed families: soil-brown body/head, moss green cap, stone-grey rock, cream clay pot)
local brown = GV.ramp("#964936", { gloss = "#d3805e", dot = "#e1b39b", rim = "#d3805e" })
local dark  = GV.ramp("#612a38", { shade = "#501727", deep = "#2b1c26" })
local moss  = GV.ramp("#3b976a", { gloss = "#a7ddb8", dot = "#4bc369", rim = "#4bc369" })
local clay  = GV.ramp("#e1b39b", { shade = "#d3805e", deep = "#964936", bounce = "#d3805e" })
local grey  = GV.ramp("#4e626f")

c:ground(17.5, 30.5, 11, 1) -- soft shadow ellipse, wings past the rock

-- rock perch (small, slate)
local rock = c:rrect(11, 26, 25, 30, 2)
local body = c:rrect(14, 21, 22, 27, 3) -- squat body, sits on the rock
local footL = c:rect(14, 28, 16, 29)    -- feet peek below the body
local footR = c:rect(20, 28, 22, 29)
local head = c:rrect(9, 9, 26, 23, 6)   -- big head
local pot = c:poly({ { 26, 22 }, { 29, 22 }, { 29, 25 }, { 28, 27 }, { 27, 27 }, { 26, 25 } }) -- tapered clay pot
local cap = c:ellipse(17.5, 9, 8, 4)    -- moss beret
local seed = c:ellipse(28.5, 8.5, 1.5, 1.5) -- floating seed accent, top-right

c:build{
  { "rock",  rock,  grey,  { deep = 0 } },
  { "body",  body,  dark,  { gloss = false, deep = 0 } },
  { "footL", footL, GV.ramp("#2b1c26"), { flat = true, contact = false } },
  { "footR", footR, GV.ramp("#2b1c26"), { flat = true, contact = false } },
  { "head",  head,  brown, { gloss = false } },
  { "pot",   pot,   clay,  { contact = false } },
  { "cap",   cap,   moss,  { light = c:rrect(9, 5, 26, 23, 6) } },
  { "seed",  seed,  GV.ramp("#d3805e"), { flat = true, solid = false, contact = false } },
}

-- hand-placed texture, tone-on-tone, following the form
c:px(13, 8, "#4bc369")  -- moss tufts on the cap (one step from base)
c:px(15, 6, "#4bc369")
c:px(19, 6, "#4bc369")
c:px(22, 8, "#4bc369")
c:px(24, 10, "#4bc369")
c:px(11, 19, "#7b3f2c") -- burlap grain on the head, curving with the shade side
c:px(25, 17, "#7b3f2c")
c:px(24, 20, "#7b3f2c")
c:px(16, 26, "#501727") -- weave on the body
c:px(19, 27, "#501727")
c:px(12, 27, "#739a9c") -- edge wear, lit top-left of the rock
c:px(17, 26, "#739a9c")
c:px(24, 30, "#292c3a") -- stone deep, lower-right corner only
c:px(23, 30, "#292c3a")

-- detail: face and accents
for _, e in ipairs({ { 11, 15 }, { 21, 17 } }) do -- big round eyes, upper-left glints
  for j = 0, 3 do for i = 0, 3 do
    if not ((i == 0 and j == 0) or (i == 3 and j == 0) or (i == 0 and j == 3) or (i == 3 and j == 3)) then
      c:px(e[1] + i, e[2] + j, "#2b1c26")
    end
  end end
  c:px(e[1], e[2] + 1, "#e1b39b")
end
c:paint({ ".mm." }, 16, 19, { m = "#501727" })        -- tiny mouth
c:px(27, 23, clay.gloss)                              -- pot glint, upper-left rim
c:px(28, 8, GV.ramp("#d3805e").gloss)                 -- seed glint
c:px(14, 23, brown.rim)                               -- bounce light, lower body
c:px(14, 28, "#501727")                               -- 1px lit lip on each foot
c:px(20, 28, "#501727")

local t = c:save(D .. "out/pl-bvd-5-perch.aseprite", D .. "out/pl-bvd-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
