-- mini/mini-aphid-swarm : 56x64 small enemy toy miniature, 3/4 view, faces right, on a round felt-soil base
local H = dofile(os.getenv("GV_ROOT") .. "aseprite-source/final/scripts/scenes/head.lua")
local GV = H.GV
local c = GV.canvas{ w = 56, h = 64, mode = "sticker" }
local soil = GV.ramp("#9a6b3f", { shade = "#7a4a1f", deep = "#7a4a1f", bounce = "#7a4a1f", rim = "#bea761" })
local green = GV.ramp("#7ab55c", { shade = "#688f41", deep = "#688f41", bounce = "#688f41", rim = "#acc47d" })

-- base: side then top face (enemy base: soil, no stitching)
c:part(c:ellipse(27.5, 55, 18, 5), soil, { gloss = false, cres = 3, deep = 1 })
c:part(c:ellipse(27.5, 51, 18, 5), soil, { gloss = false, cres = 2, deep = 1, flat = true })
c:fill(c:rect(24, 49, 25, 49), "#7a4a1f"); c:fill(c:rect(36, 52, 37, 52), "#7a4a1f")  -- clods

-- two small aphids behind
c:part(c:ellipse(14.5, 41, 7, 6), green, { gloss = false, cres = 2, deep = 1 })
c:part(c:ellipse(42.5, 40, 6, 5), green, { gloss = false, cres = 2, deep = 1 })
c:eye(11, 38, true); c:eye(38, 37, true)

-- legs (lavender, 2 px) and antennae with 4x4 club tips on the big aphid
c:limb({ {21, 42}, {18, 47}, {17, 49} }); c:limb({ {28, 44}, {28, 48}, {29, 50} }); c:limb({ {35, 42}, {38, 47}, {40, 49} })
c:limb({ {26, 24}, {23, 19} }); c:limb({ {33, 24}, {37, 19} })
c:part(c:rect(20, 15, 23, 18), "leg", { flat = true, gloss = false }); c:part(c:rect(36, 15, 39, 18), "leg", { flat = true, gloss = false })
-- cornicles (rear tail pipes), left side because it faces right
c:limb({ {19, 38}, {14, 36} })

-- the big aphid: pear body, big head to the right
c:part(c:ellipse(29.5, 34, 12, 10), green, { cres = 4, deep = 2 })
c:eye(25, 31); c:eye(33, 31)
c:paint({ "u...u", ".uuu." }, 28, 40, { u = "umber" })
H.done(c, "mini-aphid-swarm", "mini/mini-aphid-swarm.png", 16)
