---------------------------------------------------------------- the 20 villagers
local ENV = {
  sand = { sky = { "#8ec8e8", "#a8d8ec", "#c4e4ee", "#f0e8cc", "#f8dcb0" }, cl = { "#fff4e0", "#f0d0b0" }, hill = { "#a8784c", "#bc8c58", "#d0a468", "#e0bc7c", "#ecd096", "#f4e0ac" }, grass = { "#97754a", "#b8935e", "#d0b078", "#e8d09a", "#f0dcaa", "#f8e8bc" }, tuft = { "#6a502e", "#8a6a34", "#a8863c", "#c2a04a", "#d8b862", "#e8cc7c" }, side = "banana" },
  meadow = { sky = { "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8" }, cl = { "#f8f0e0", "#d6e6f0" }, hill = { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, grass = GREEN, tuft = GREEN, side = "bush", flowers = { "#f0809c", "#ffd24a", "#fff2dc" }, pebble = "#a8a890" },
  rocks = { sky = { "#a4b4c8", "#b8c4d4", "#ccd4e0", "#dce0e8", "#eceef0" }, cl = { "#f4f4f4", "#d0d8e4" }, hill = { "#4a566e", "#5c6a84", "#74829c", "#8e9cb4", "#aab6ca", "#c4cedc" }, grass = { "#4a5a4a", "#627464", "#7a8e78", "#94a892", "#aec0aa", "#c4d4c0" }, tuft = { "#4a5a4a", "#627464", "#7a8e78", "#94a892", "#aec0aa", "#c4d4c0" }, side = "rocks", pebble = "#8a8a9a" },
  dawn = { sky = { "#b8a4d8", "#d0b0d8", "#e8c0d8", "#f8d0cc", "#fce0c0" }, cl = { "#fff0e8", "#f0c8d8" }, hill = { "#5a4a7a", "#6e5c90", "#8a74a8", "#a88cc0", "#c4a8d4", "#dcc4e4" }, grass = { "#4a6a48", "#5e8458", "#78a068", "#94bc7c", "#b0d494", "#cce8ac" }, tuft = { "#4a6a48", "#5e8458", "#78a068", "#94bc7c", "#b0d494", "#cce8ac" }, side = "bush", flowers = { "#f8a0c8", "#c8b8ec", "#fff2dc" }, pebble = "#b098a8" },
}
local V = {
 ["auntie-mossbead"] = { kind = "treehouse", shape = "arch", frame = TIMB, wood = PLM, ov = "scales", plate = TIMB, trunk = OAK, fol1 = GREEN, fol2 = LEAF, seed = 9, straps = { 152, 184 },
   props = { { "ladder", 186 }, { "fruitbowl", 116, 206 }, { "birdhouse", 286, 132 } } },
 ["bramble-mossfoot"] = { kind = "treehouse", shape = "round", frame = OAK, wood = REDW, ov = "spots", plate = OAK, trunk = TIMB, fol1 = LEAF, fol2 = GREEN, seed = 4, fseed = 33, fl = { "#f0809c", "#fff2dc", "#c8b8ec" },
   props = { { "shelf", 288, 156 }, { "mushroomset", 124, 206 }, { "stump", 84, 206 } } },
 ["ember-seedwell"] = { kind = "treehouse", shape = "arch", frame = TIMB, wood = BARN, ov = "spiral", plate = TIMB, trunk = OAK, fol1 = AUTUMN, fol2 = ORG, seed = 12, fl = { "#ffd24a", "#fff2dc", "#f0809c" },
   props = { { "sproutpot", 126, 206 }, { "acorn", 292, 206 }, { "trail" } } },
 ["ivy-brambleby"] = { kind = "treehouse", shape = "point", frame = TIMB, wood = MOSSR, ov = "leaf", plate = OAK, trunk = SND, fol1 = LEAF, fol2 = GREEN, seed = 15,
   props = { { "ladder", 186 }, { "grapes", 280, 138 } } },
 ["juniper-seedwell"] = { kind = "treehouse", shape = "arch", frame = TIMB, wood = YEL, ov = "stripes", plate = YEL, trunk = OAK, fol1 = BLOSS, fol2 = GREEN, seed = 17, fl = { "#f8b8cc", "#fff2dc", "#ffd24a" },
   props = { { "ladder", 186 }, { "skep", 114, 206 }, { "bigflower", 84, 206, "#ffd24a" } } },
 ["sorrel-inkcap"] = { kind = "treehouse", shape = "rect", frame = OAK, wood = DKS, ov = "feather", plate = TAN, trunk = TAN, fol1 = TLW, fol2 = GREEN, seed = 21,
   props = { { "bookstack", 112, 206 }, { "scroll", 284, 132 }, { "shelf", 280, 168 } } },
 ["burdock-puddlejump"] = { kind = "boat", shape = "arch", frame = CREAM, wood = ORG, ov = "port", plate = OAK, cabin = TEAL, roof = BARN, hull = SBLUE, ring = true, seed = 5,
   props = { { "bunting", 156, 100, 212, 100, { "#e8493b", "#ffd24a", "#f090c0", "#3f9fd0" } }, { "leafbrella", 176, 204 }, { "crate", 424, 200 } } },
 ["nutmeg-rootstock"] = { kind = "boat", shape = "rect", frame = OAK, wood = GREEN, ov = "gear", plate = OAK, cabin = OLV, roof = SLT, hull = REDW, port = true, seed = 8, chim = DKS,
   props = { { "planter", 178, 204 }, { "sproutpot", 296, 204 }, { "barrel", 432, 200 } } },
 ["coral-pennyfeather"] = { kind = "stone", shape = "arch", frame = STONE, wood = SLT, ov = "plaid", plate = OAK, stone = STONE, roof = BARN, seed = 6, straps = { 150, 184 },
   props = { { "rod", 160, 206 }, { "pail", 194, 206 }, { "boots", 292, 206 } } },
 ["lyra-fiddlewing"] = { kind = "stone", shape = "arch", frame = OAK, wood = TAN, ov = "notes", plate = YEL, stone = SND, roof = YEL, seed = 14, sseed = 9, fl = { "#ffd24a", "#fff2dc", "#f0809c" },
   props = { { "violin", 174, 206 }, { "bunting", 146, 98, 210, 100, { "#ffd24a", "#fff2dc", "#82b4e4", "#f090c0" } }, { "sproutpot", 428, 206 } } },
 ["tobias-trundle"] = { kind = "stone", shape = "round", frame = STONE, wood = GOLD, ov = "hex", plate = SLT, stone = DKS, roof = SLT, roofmoss = true, moss = .08, seed = 3, sseed = 12,
   props = { { "sundial", 158, 206 }, { "cane", 292, 206 }, { "stump", 432, 206 } } },
 ["ginger-thornwhistle"] = { kind = "hut", env = ENV.sand, shape = "arch", frame = TIMB, wood = PNK, ov = "sun", plate = PNK, roof = THATCH, seed = 11,
   props = { { "pinwheel", 176, 206 }, { "chimes", 194 }, { "pumpkin", 436, 206 } } },
 ["hazel-brambleby"] = { kind = "hut", env = ENV.meadow, shape = "rect", frame = OAK, wood = BLUEW, ov = "berries", plate = OAK, wall = SND, roof = MOSSR, woven = true, seed = 7,
   props = { { "bush", 108, 206 }, { "herbs", 188 }, { "bush", 432, 206, "#e8493b" } } },
 ["pebble-barkley"] = { kind = "hut", env = ENV.rocks, shape = "rect", frame = STONE, wood = REDW, ov = "pebbles", plate = STONE, wall = SND, roof = DKS, seed = 13,
   props = { { "cairn", 166, 206 }, { "cairn", 112, 206 }, { "fruitbowl", 432, 206 } } },
 ["woad"] = { kind = "hut", env = ENV.dawn, shape = "arch", frame = TIMB, wood = SND, ov = "splat", plate = PLM, wall = SAGEP, roof = PLM, seed = 19,
   props = { { "easel", 158, 206 }, { "birdhouse", 282, 134 }, { "can", 420, 205 } } },
 ["marigold-tuftwhistle"] = { kind = "cottage", shape = "arch", frame = TIMB, wood = CREAM, ov = "knit", plate = ORG, wall = PEACH, roof = ORG, shut = YEL, seed = 3,
   box1 = { "#e8493b", "#ffd24a", "#f0809c" }, box2 = { "#ffd24a", "#f08838", "#fff2dc" },
   props = { { "washline", 36, 96, 156 }, { "bigflower", 188, 206, "#ffa020" }, { "pumpkin", 440, 206 } } },
 ["pomeroy-crumbworth"] = { kind = "cottage", shape = "point", frame = STONE, wood = VIO, ov = "window", plate = VIO, wall = SAGEP, roof = SLT, shut = PNK, seed = 6, beam = OAK,
   box1 = { "#c8b8ec", "#fff2dc", "#f0809c" }, box2 = { "#82b4e4", "#fff2dc", "#ffd24a" },
   props = { { "wallclock", 194, 118 }, { "cheese", 440, 206 }, { "can", 120, 205 } } },
 ["nettle-thornwhistle"] = { kind = "burrow", shape = "round", frame = STONE, wood = TEAL, ov = "gems", plate = OAK, hill = OLV, post = TIMB, seed = 6, fl = { "#c8a8ff", "#ffd24a", "#fff2dc" },
   props = { { "crystals", 150, 206 }, { "staff", 412 } } },
 ["reed-hollowell"] = { kind = "burrow", shape = "round", frame = STONE, wood = SBLUE, ov = "lily", plate = OAK, hill = MOSSR, far = { "#2c5a58", "#3a6e6a", "#4c8480", "#62a09a", "#7ab8b0", "#98ccc4" }, post = TIMB, seed = 7, fl = { "#f8a0c8", "#fff2dc", "#82b4e4" },
   props = { { "cattails", 158, 206 }, { "barrel", 424, 206 } } },
 ["zinnia-fuzzbottom"] = { kind = "burrow", shape = "round", frame = OAK, wood = ORG, ov = "petals", ova = { pet = "#fff2dc" }, plate = TIMB, hill = GREEN, post = TIMB, seed = 9, fl = { "#f08838", "#ffd24a", "#f0809c" },
   props = { { "bigflower", 156, 206, "#f08838" }, { "skep", 424, 206 } } },
}
local p = V[name]
K[p.kind](p)
c:save{ aseprite = OUT .. "door-" .. name .. ".aseprite", png = OUT .. "door-" .. name .. ".png", scale = 1 }
end

local ORDER = { "auntie-mossbead", "bramble-mossfoot", "burdock-puddlejump", "coral-pennyfeather", "ember-seedwell", "ginger-thornwhistle", "hazel-brambleby", "ivy-brambleby", "juniper-seedwell", "lyra-fiddlewing", "marigold-tuftwhistle", "nettle-thornwhistle", "nutmeg-rootstock", "pebble-barkley", "pomeroy-crumbworth", "reed-hollowell", "sorrel-inkcap", "tobias-trundle", "woad", "zinnia-fuzzbottom" }
for _, n in ipairs(NAME == "all" and ORDER or { NAME }) do
  local ok, err = pcall(build, n)
  if not ok then print("FAIL " .. n .. ": " .. tostring(err)) end
end
