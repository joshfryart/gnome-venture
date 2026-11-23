-- pl-ana-5-perch.lua : 36x36 perch sprite for pals/perch/pl-ana-5
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ana-5-perch-20261120-162837/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "scene" }
local OL, BODY, LID, PALE, SHADOW = "#2b1c26", "#aa7d45", "#894bb2", "#e3ead6", "#5b3862"
local rBody  = GV.ramp(BODY, { gloss = "#c09b65", rim = "#c09b65", shade = "#7b4732", deep = "#551a1e", bounce = "#8b6a5b" })
local rLid   = GV.ramp(LID,  { gloss = "#ab7dd4", rim = "#ab7dd4" })
local rStump = GV.ramp("#7b4732", { gloss = "#aa7d45", rim = "#aa7d45", deep = "#551a1e" })
local rBoot  = GV.ramp("#8b6a5b", { deep = "#5b3862" })

-- SHADE: shapes from PERSPECTIVE kept; parts get ramps/crescents/bounce
c:ground(16.5, 31.5, 13, 1.5, SHADOW)
local staff = c:rect(25, 4, 26, 30)
local flag  = c:rect(27, 4, 32, 8)                               -- banner + pennant foot below
local foot  = c:rect(29, 9, 30, 9)
flag:add(foot)
local feather = c:line({{24, 10}, {20, 4}}, 4)
local lid   = c:rrect(8, 8, 25, 13, 4)
local body  = c:rrect(8, 12, 24, 26, 5)
local stump = c:rrect(9, 27, 24, 31, 3)
local bootL = c:rect(11, 26, 13, 28)
local bootR = c:rect(19, 26, 21, 28)

local p = c:build{
  { "staff",   staff,      rBoot, { flat = true, outline = false, contact = false } },
  { "stump",   stump,      rStump, { cres = 2, deep = 1, outline = false } },
  { "body",    body,       rBody,  { cres = 3, deep = 1, outline = false } },
  { "lid",     lid,        rLid,   { cres = 2, deep = 1, outline = false, gloss = { 11, 10 } } },
  { "flag",    flag,       rLid,   { cres = 2, deep = 1, outline = false, contour = false } },
  { "feather", feather,    rLid,   { cres = 2, deep = 1, outline = false, contour = false, gloss = false } },
}
-- stump top face: lighter wood, painted BEFORE the boots so they stay separate
c:fill(c:rrect(10, 27, 23, 28, 1):clip(stump), "#aa7d45")
c:px(10, 27, rBody.rim); c:px(23, 27, rBody.rim)
-- boots, hand-painted 3-tone (gvlib contour drowned the 3px part)
local function boot(x)
  for i = 0, 2 do
    c:px(x + i, 26, "#aa9a7d")           -- rim (lit top)
    c:px(x + i, 27, "#8b6a5b")           -- base
    c:px(x + i, 28, "#5b3862")           -- shade foot, one step
  end
  c:px(x + 2, 27, "#7b4732")
end
boot(11); boot(19)

-- face on the body (light upper-left)
local EYE = PALE
local function eye(x)
  c:px(x, 16, EYE); c:px(x + 1, 16, EYE); c:px(x, 17, EYE); c:px(x + 3, 16, EYE)
  c:px(x + 2, 16, EYE); c:px(x + 3, 17, EYE)
  c:px(x + 1, 17, "#2b1c26"); c:px(x + 2, 17, "#2b1c26")
  c:px(x + 1, 18, "#2b1c26"); c:px(x + 2, 18, "#2b1c26")
  c:px(x + 1, 17, PALE) -- glint
  c:px(x, 18, EYE); c:px(x + 2, 19, EYE); c:px(x + 3, 18, EYE); c:px(x, 19, EYE); c:px(x + 3, 19, EYE)
end
eye(12); eye(19)
c:px(16, 20, "#7b4732"); c:px(17, 20, "#7b4732")                     -- nose
c:fill(c:ellipse(17.5, 22.5, 1.5, 1.5):clip(body), "#debcbd")        -- held coin
c:px(16, 22, PALE)                                                   -- coin glint
c:px(10, 21, "#debcbd"); c:px(11, 21, "#debcbd")                     -- cheek L
c:px(22, 21, "#debcbd"); c:px(23, 21, "#debcbd")                     -- cheek R
c:px(16, 21, PALE); c:px(17, 21, PALE)                               -- coin top glint (1 shade step)

-- TEXTURE: material marks, tone-on-tone, following the light
c:seam({ { 11, 11 }, { 15, 11 } }, { gap = "#743987" })              -- stitched lid hem, lit half
c:seam({ { 18, 11 }, { 22, 11 } }, { gap = "#743987" })
c:px(4, 6, GV.C.gold); c:px(6, 6, GV.C.gold); c:px(5, 7, GV.C.gold)  -- sparkle accent from the pal (plus)
c:px(5, 6, GV.C.gold); c:px(5, 5, "#f8e6b8")
c:px(14, 30, rStump.rim); c:px(15, 30, rStump.rim)                   -- wood grain, tone-on-tone
c:px(20, 30, rStump.rim); c:px(21, 30, rStump.rim)
c:fill(c:line({{24, 9}, {21, 6}}, 1):clip(feather), rLid.shade)      -- feather spine
-- DETAIL: small highlights and accents
c:px(25, 5, rBoot.rim); c:px(26, 5, rBoot.rim)                       -- staff top catches light
c:px(28, 5, rLid.dot); c:px(28, 6, rLid.gloss)                      -- flag lit top edge
c:px(21, 4, rLid.dot)                                                -- feather tip glint

-- lid seam + gloss: enamel comma upper-left of lid, dot on body
c:gloss(lid, rLid, { 11, 10 })
c:px(10, 14, rBody.gloss); c:px(11, 14, rBody.gloss)                 -- body sheen under rim

-- hand outline: 1px ring of #2b1c26 around the whole silhouette
local sil = c:mask():add(stump):add(staff):add(flag):add(feather):add(lid):add(body):add(bootL):add(bootR)
sil:grow(1):each(function(x, y) if not sil:has(x, y) then c:px(x, y, OL) end end)
-- CRITIQUE fixes: dark 1px cut separating the feather from the lid mass
feather:grow(1):each(function(x, y)
  if not feather:has(x, y) and c:get(x, y) and c:get(x, y) ~= OL and not staff:has(x, y) and not flag:has(x, y) then
    c:px(x, y, OL)
  end
end)

local t = c:save(D .. "out/pl-ana-5-perch.aseprite", D .. "out/pl-ana-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
