-- pl-eggs-4-perch.lua : 36x36 chibi perch sprite of the moss-rock pal (pals/perch/pl-eggs-4)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-eggs-4-perch-20261120-180903/"
local GV = dofile(D .. "gvlib/gvlib.lua")

-- phase flag: 2=BLOCK-IN 3=PERSPECTIVE 4=SHADE 5=TEXTURE 6=DETAIL 7=CRITIQUE
local PHASE = 7
local FLAT = PHASE <= 3

-- palette-fitted outline / eye colours (from the pal)
GV.C.ol1 = "#593b45"; GV.C.ol2 = "#4c1e1a"; GV.C.ol3 = "#2b1c26"
GV.C.umber = "#4c1e1a"; GV.C.halo = "#fff6e0"

local c = GV.canvas{ w = 36, h = 36, mode = "scene", ol = 1, olx = 1, cres = 3, deep = 1 }

-- ramps
local Rbody = GV.ramp("#4389ab", { gloss = "#a5e5d3", dot = "#a5e5d3", rim = "#73bdd0", shade = "#275383", deep = "#1c1e61" })
local Rcap  = GV.ramp("#3f8a4a", { gloss = "#c5e8aa", dot = "#c5e8aa", rim = "#c5e8aa" })
local Rpad  = GV.ramp("#c6a393", { shade = "#806071" })
local Regg  = GV.ramp("#f2e4c0")

-- flat-silhouette opts override for early phases
local function o(extra)
  extra = extra or {}
  if FLAT then
    extra.cres, extra.deep, extra.rim, extra.bounce, extra.gloss = 0, 0, false, false, false
    if PHASE <= 2 then extra.contact = false end
  end
  return extra
end

-- ground shadow
c:ground(17.5, 30.5, 14.5, 2, "#593b45")

local P = c:build{
  { "pad",    c:rrect(4, 24, 31, 30, 3), Rpad, o({ gloss = false }) },
  { "footL",  c:rrect(10, 27, 14, 29, 1), Rpad, o({ deep = 0, gloss = false }) },
  { "footR",  c:rrect(22, 27, 26, 29, 1), Rpad, o({ deep = 0, gloss = false }) },
  { "egg1",   c:ellipse(28, 26, 1.6, 2.2), Regg, o({ flat = true, gloss = false, contact = PHASE >= 7, rim = false }) },
  { "body",   c:rrect(9, 8, 27, 26, 7), Rbody, o(PHASE >= 4 and { gloss = { 12, 16 } } or { gloss = false }) },
  { "cap",    c:ellipse(18, 10, 10.5, 3.4), Rcap, o({ gloss = false }) },
  { "sproutL", c:line({ { 11.5, 3 }, { 11.5, 10 } }, 2), Rcap, o({ flat = true, gloss = false }) },
  { "sproutR", c:line({ { 21.5, 3 }, { 21.5, 9 } }, 2), Rcap, o({ flat = true, gloss = false }) },
  { "egg2",   c:ellipse(29, 28.5, 1.6, 1.8), Regg, o({ flat = true, gloss = false, contact = PHASE >= 7, rim = false }) },
}

-- face (kept through all phases)
c:eye(13, 15); c:eye(20, 15)
c:paint({ "mm", "mm" }, 11, 19, { m = "#806071" })            -- left cheek
c:paint({ "mm", "mm" }, 25, 19, { m = "#806071" })            -- right cheek
c:paint({ "kk" }, 18, 21, { k = "#2b1c26" })                  -- tiny mouth (centred on the eye gap)

-- brown dirt patches (pal signature, tone-on-tone later phases)
if PHASE >= 5 then
  c:paint({ "ab", "ba" }, 10, 21, { a = "#c6a393", b = "#806071" })
  c:paint({ ".a", ".b" }, 24, 17, { a = "#c6a393", b = "#593b45" })
  c:paint({ "b.b", ".a." }, 16, 27, { a = "#806071", b = "#4c1e1a" })  -- pad soil speckles
  c:px(22, 12, Rcap.shade); c:px(10, 9, Rcap.shade); c:px(25, 8, Rcap.shade) -- moss tufts on cap
end

-- details
if PHASE >= 6 then
  c:px(14, 16, "#fff6e0"); c:px(21, 16, "#fff6e0")            -- pupil glints
  c:px(12, 14, "#a5e5d3")                                     -- crest extension below cap
  c:paint({ ".g.", "gGg", ".g." }, 6, 14, { g = "#ffd84a", G = "#fff6e0" })
  c:paint({ ".g.", "gGg", ".g." }, 31, 17, { g = "#ffd84a", G = "#fff6e0" })
  c:paint({ ".w.", "wcw", ".w." }, 16, 5, { w = "#fff6e0", c = "#ffd84a" })
end

local t = c:save(D .. "out/pl-eggs-4-perch.aseprite", D .. "out/pl-eggs-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)
print("PHASE " .. PHASE)
