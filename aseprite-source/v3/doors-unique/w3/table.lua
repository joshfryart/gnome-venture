-- ===================== w3: per-villager parameter table
PR.acorn, PR.herbs, PR.chimes, PR.can = acorn, herbs, chimes, can
local function pp(id, ...) local a = { ... }; return function() assert(PR[id], "no prop " .. id); PR[id](table.unpack(a)) end end
local DUSK = { "#6a5a9a", "#8a72b0", "#b48ac0", "#e0a0a8", "#f8c8a0" }
local V = {}
V["auntie-saffira"] = { home = "cottage", wall = "YEL", beam = "TIMB", roof = "THATCH", win = 3, shut = "TEAL", plate = "TIMB",
  door = { shape = "arch", wood = "TEAL", frame = "TIMB", straps = { 150, 186 } }, ov = { "crocus" }, lamp = "hang", fl = { "#c8b8ec", "#ffd24a", "#fff2dc" },
  props = { pp("yarnbasket", 190, 205), pp("bench", 40, 205, R.LAV), pp("bunting", 12, 205, 80, { "#e8493b", "#ffd24a", "#7fd0c4", "#c8b8ec" }, 7), pp("bunting", 280, 468, 80, { "#ffd24a", "#f0809c", "#7fd0c4" }, 7), pp("pot", 436, 205, "#c8b8ec") } }
V["cricket-hollowell"] = { home = "cottage", wall = "PEACH", beam = "OAK", roof = "BARN", roofkind = "tiles", win = 2, shut = "GREEN", plate = "OAK",
  door = { shape = "round", wood = "GREEN", frame = "TIMB", f = 4 }, ov = { "apple" }, lamp = "post", fl = { "#e8493b", "#ffd24a", "#fff2dc" },
  props = { pp("barrel", 66, 205, "apples"), pp("logs", 140, 205), pp("acorn", 286, 206), pp("berrybush", 436, 205, { "#7a2230", "#b0343a", "#e8493b" }) } }
V["fennick-barkley"] = { home = "cottage", wall = "MINT", beam = "TIMB", roof = "PLUM", roofkind = "tiles", win = 1, shut = "VIO", plate = "TIMB", wcols = { "#c8b8ec", "#ffd24a", "#7fd0c4" },
  door = { shape = "rect", wood = "VIO", frame = "TIMB" }, ov = { "lilypad" }, lamp = "jar", fl = { "#c8b8ec", "#7fd0c4", "#fff2dc" },
  props = { pp("stool", 190, 205, R.TEAL), pp("bookstack", 440, 205, { R.CORAL, R.NAVY, R.YEL }), pp("herbs", 344), pp("herbs", 366), pp("pot", 60, 205, "#7fd0c4") } }
V["jasper-burrowman"] = { home = "cottage", wall = "SBLUE", beam = "OAK", roof = "MOSSR", win = 2, shut = "OAK", plate = "OAK", wcols2 = { "#fff2dc", "#ffd24a", "#8fc0f0" },
  door = { shape = "rect", wood = "OAK", frame = "STONE", f = 4 }, ov = { "cross" }, lamp = "hang", fl = { "#8fc0f0", "#ffd24a", "#fff2dc" },
  props = { pp("wheelbarrow", 50, 205, "pumpkins"), pp("shovel", 170, 206), pp("vegrows", 392, 468, 214, "lettuce"), pp("fence", 100, 164, 205) } }
V["kestrel-petalwing"] = { home = "cottage", wall = "PASTEL", beam = "TIMB", roof = "CORAL", roofkind = "tiles", win = 0, plate = "ROSE",
  door = { shape = "arch", wood = "ROSE", frame = "CREAM", f = 4 }, ov = { "petals" }, lamp = "paper", lampcol = "CORAL", fl = { "#f0809c", "#ffd24a", "#fff2dc" },
  props = { pp("skep", 60, 205), pp("wreath", 166, 128, { "#fff2dc", "#f8c8dc", "#ffd24a" }), pp("pinwheel", 440, 205, 34, { "#f0809c", "#ffd24a", "#7fd0c4", "#c8b8ec" }), pp("pot", 150, 205, "#f0809c"), pp("pot", 384, 205, "#fff2dc") } }
V["bramble-sunpatch"] = { home = "boat", wall = "YEL", roof = "ORG", roofkind = "flat", roofdeco = "plants", hull = "TEAL", trim = "CREAM", port = "round", ring = { "#f08030", "#fff2dc" }, plate = "OAK", chimr = "ORG",
  door = { shape = "arch", wood = "REDW", frame = "CREAM", f = 4 }, ov = { "sun" }, lamp = "hang",
  props = { pp("sunflower", 168, 204, 36), pp("sunflower", 184, 204, 26), pp("tomatoes", 280, 204), pp("tomatoes", 300, 204) } }
V["captain-pipi-shellback"] = { home = "boat", wall = "CREAM", roof = "BARN", roofkind = "pitch", hull = "NAVY", trim = "GOLD", port = "round", ring = { "#e8493b", "#fff2dc" }, plate = "OAK", pat = "horiz",
  door = { shape = "arch", wood = "NAVY", frame = "GOLD", f = 4 }, ov = { "wheel" }, lamp = "hang",
  props = { pp("telescope", 174, 204), pp("coil", 198, 204), pp("bell", 290, 150), pp("buoy", 264, 204, "#e8493b", "#fff2dc") } }
V["gloam"] = { home = "boat", wall = "NIGHT", roof = "PLUM", roofkind = "dome", hull = "IRON", trim = "PLUM", port = "square", portr = "PLUM", plate = "PLUM", chim = true, chimr = "STONE", pat = "vert",
  sky = DUSK, hill = { "#2c2048", "#443272", "#5a4488", "#7258a0", "#9072b8", "#b094d0" }, water = { "#140e30", "#1e1848", "#2c2868", "#403a88", "#5a58a8", "#8a88c8" }, cl1 = "#d8b8d8", cl2 = "#9a78b8",
  door = { shape = "arch", wood = "PLUM", frame = "IRON", f = 4 }, ov = { "batwing" }, lamp = "paper", lampcol = "REDW",
  props = { pp("candlestack", 176, 204), pp("barrel", 200, 204, "green"), pp("lights", 156, 326, 100, 9, { "#ff9a8a", "#ffd070", "#e8493b" }), pp("crates", 268, 204) } }
V["moss-petalwing"] = { home = "boat", wall = "MINT", roof = "VIOLET", roofkind = "dome", hull = "CORAL", trim = "CREAM", port = "square", portr = "CREAM", plate = "OAK", chim = false, pat = "vert",
  door = { shape = "rect", wood = "VIO", frame = "CREAM", f = 4 }, ov = { "leaf" }, lamp = "star",
  props = { pp("easel", 178, 204), pp("pinwheel", 280, 204, 30, { "#7a5ac8", "#7fd0c4", "#ffd24a", "#f0809c" }), pp("crates", 292, 204), pp("pot", 158, 204, "#c8b8ec") } }
V["oakley-mossfoot"] = { home = "boat", wall = "GREEN", roof = "YEL", roofkind = "dome", hull = "TEAL", trim = "CREAM", port = "none", ring = false, plate = "OAK", chim = false, pat = "horiz",
  door = { shape = "arch", wood = "NAVY", frame = "CREAM", f = 4 }, ov = { "ripple" }, lamp = "hang",
  props = { pp("fishingrod", 160, 204), pp("lobsterpot", 198, 204), pp("net", 298, 168), pp("buoy", 270, 204, "#ffd24a", "#fff2dc") } }
V["rowan-burrowman"] = { home = "boat", wall = "OAK", roof = "BLUEW", roofkind = "pitch", hull = "GOLD", trim = "CREAM", port = "round", ring = false, plate = "OAK", chimr = "STONE", pat = "vert",
  door = { shape = "arch", wood = "BLUEW", frame = "GOLD", f = 4 }, ov = { "hex" }, lamp = "jar",
  props = { pp("skep", 172, 204), pp("oar", 198, 204, R.BLUEW), pp("shelfjars", 290, 160), pp("coil", 296, 204) } }
V["sorrel-petalwing"] = { home = "boat", wall = "LAV", roof = "ROSE", roofkind = "pitch", hull = "BARN", trim = "CREAM", port = "round", ring = { "#f0809c", "#fff2dc" }, plate = "OAK", chimr = "PLUM",
  door = { shape = "arch", wood = "PLUM", frame = "ROSE", f = 4 }, ov = { "feather" }, lamp = "hang",
  props = { pp("bookstack", 172, 204, { R.PLUM, R.CORAL, R.TEAL }), pp("pot", 198, 204, "#fff2dc"), pp("hangpots", 286, 150), pp("pot", 268, 204, "#f0809c") } }
V["madder-quillfeather"] = { home = "hut", wall = "DIRT", roof = "THATCH", plants = "bamboo", plate = "TIMB",
  door = { shape = "rect", wood = "REDW", frame = "TIMB", woven = true }, ov = { "scroll" }, lamp = "hang",
  props = { pp("quillink", 176, 205), pp("scrollrack", 296, 160), pp("bookstack", 112, 205, { R.NAVY, R.REDW, R.GOLD }), pp("bookstack", 214, 205, { R.CORAL, R.TEAL }) } }
V["pebble-leafwhisker"] = { home = "hut", wall = "SAGE", roof = "MOSSR", plants = "cactus", plate = "OAK", sky = { "#8ec8e8", "#b0d8ec", "#d0e8ee", "#f4ecd0", "#f8e4bc" },
  door = { shape = "arch", wood = "TEAL", frame = "TIMB", pw = 6 }, ov = { "dots" }, lamp = "post",
  props = { pp("cairn", 188, 206, 4), pp("cairn", 116, 206, 3), pp("signpost", 288, 206), pp("cairn", 420, 206, 2) } }
V["poppy-puddlejump"] = { home = "hut", wall = "ORG", roof = "THATCH", plants = "none", plate = "TIMB", ground = { "#7a8a3c", "#98a850", "#b4c468", "#cad884", "#dae8a0", "#eaf4bc" }, hill = { "#6a8a4a", "#80a05c", "#98b870", "#b0cc88", "#c8dca0", "#e0ecb8" },
  tuft = GREEN,
  door = { shape = "arch", wood = "GREEN", frame = "TIMB", woven = false }, ov = { "poppy" }, lamp = "paper", lampcol = "ORG",
  props = { pp("vegrows", 392, 468, 214, "carrot"), pp("can", 262, 205), pp("pot", 196, 205, "#e8493b"), pp("chilis", 168, 96, { "#7a2230", "#b0343a", "#e8493b" }), pp("pot", 152, 205, "#e8493b"), pp("sunflower", 70, 205, 40), pp("pumpkin", 100, 207, 7) } }
V["nocturna"] = { home = "stone", wall = "STONE", roof = "PLUM", plate = "OAK", sky = { "#5a4a8a", "#7a64a8", "#a484bc", "#d89ab0", "#f8c0a0" }, hill1 = { "#2c2048", "#443272", "#5a4488", "#7258a0", "#9072b8", "#b094d0" }, cl1 = "#e8c0d0", cl2 = "#a884b8",
  door = { shape = "arch", wood = "VIO", frame = "STONE" }, ov = { "moon" }, lamp = "jar", fl = { "#c8b8ec", "#fff2dc", "#ffd24a" },
  props = { pp("mobile", 178, 104), pp("crystal", 184, 205), pp("telescope", 290, 205), pp("chimes", 160) } }
V["tumble-seedwell"] = { home = "burrow", plate = "OAK",
  door = { wood = "PASTEL", frame = "STONE" }, ov = { "lattice" }, lamp = "post",
  back = { function() PR.chimney(170, 100, 30) end },
  props = { pp("breadrack", 176, 206), pp("seedsack", 286, 206), pp("sunflower", 124, 206, 34) } }
V["hazel-dewberry"] = { home = "treehouse", bark = "OAK", ladder = true, fungus = false, plate = "TIMB",
  door = { shape = "arch", wood = "ROSE", frame = "TIMB", f = 5, straps = { 152, 184 } }, ov = { "grapes" }, lamp = "hang",
  props = { pp("grapevine", 296, 206), pp("hangpots", 160, 136), pp("pot", 120, 206, "#c8b8ec"), pp("pot", 136, 206, "#ffd24a") } }
V["wren-thimblewick"] = { home = "treehouse", bark = "TIMB", ladder = false, fungus = true, plate = "TIMB", fa = "LEAF", fb = "GREEN",
  sky = { "#a8b8e0", "#c8c0e4", "#e8c8e0", "#f8d0c8", "#fce0b8" }, cl1 = "#fff0e8", cl2 = "#f0c8d0",
  door = { shape = "round", wood = "TEAL", frame = "TIMB", f = 5 }, ov = { "button" }, lamp = "hang",
  props = { pp("spool", 184, 206, R.CORAL, 30), pp("thimblePot", 118, 206), pp("bunting", 150, 330, 98, { "#e8493b", "#ffd24a", "#7fd0c4", "#c8b8ec", "#f0809c" }, 6) } }

local order = {}
for _, e in ipairs(LIST) do order[#order + 1] = e end
