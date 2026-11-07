"""Hand-drawn water ways for the 13 regions other than Maplewold (NA has its own: tools/maplewold_waterways.py). Region frame 480 x 270, drawn over the region pictures
game/assets/img/scenes/map-<CODE>.png (grid overlay from the layout dump). Each stream is [name, wide, [[x, y], ...]] listed UPSTREAM -> DOWNSTREAM; a stream ends in a lake,
the sea, another stream, or runs off the map edge. 'wide' = a river (2 tiles) instead of a brook. 'ponds' = water the colour reader (tools/bend_water.py) does not see
(oases, waterholes drawn in odd colours), [x, y, radius]. Where a drawn river or lake exists in the picture the line follows it; the rest is invented to drain to the sink."""
HAND = {
 "SA": dict(ponds=[], streams=[   # the Rainroot river runs from the top edge past two ponds to the bottom edge; two brooks drain the west forest to the lake (150,245)
    ["rainroot-river", True, [[235, 12], [236, 40], [242, 68], [250, 88], [262, 110], [278, 130], [298, 150], [318, 172], [340, 188], [355, 205], [362, 225], [366, 250], [366, 268]]],
    ["west-brook", False, [[40, 110], [70, 135], [95, 160], [115, 190], [135, 215], [148, 232]]],
    ["trail-brook", False, [[215, 140], [200, 175], [180, 205], [160, 228]]],
    ["east-tributary", False, [[430, 120], [400, 150], [370, 185], [356, 204]]]]),
 "SE": dict(ponds=[], streams=[   # the river from the top ridge, under the two bridges, to the bottom edge; a brook to the lake (125,222) and one into the river
    ["olive-river", True, [[288, 14], [300, 28], [322, 50], [346, 72], [360, 100], [366, 128], [360, 152], [346, 172], [330, 190], [312, 206], [290, 222], [268, 244], [258, 262]]],
    ["lake-brook", False, [[130, 100], [135, 130], [125, 160], [120, 190], [125, 214]]],
    ["terrace-brook", False, [[230, 60], [260, 90], [300, 120], [340, 135], [364, 140]]]]),
 "EA": dict(ponds=[], streams=[   # the teal river between the pagodas, top to bottom edge
    ["jade-river", True, [[243, 50], [252, 72], [262, 98], [270, 120], [274, 142], [266, 168], [252, 195], [240, 220], [228, 240], [218, 260]]],
    ["pond-brook", False, [[120, 220], [150, 205], [185, 205], [215, 215], [232, 225]]]]),
 "CB": dict(ponds=[], streams=[   # creeks between the lagoons: east creek from the town pool to the south lagoon (293,212), west creek to the west lagoon (85,200), middle creek
    ["east-creek", False, [[352, 78], [352, 100], [360, 125], [362, 150], [350, 170], [330, 190], [310, 205]]],
    ["west-creek", False, [[65, 90], [72, 115], [62, 140], [56, 165], [68, 185]]],
    ["mid-creek", False, [[240, 105], [255, 135], [262, 160], [275, 185], [285, 200]]]]),
 "CA": dict(ponds=[], streams=[   # the dry arroyo that runs when it rains: north-east to the bottom edge
    ["arroyo", True, [[357, 22], [330, 45], [300, 72], [272, 98], [250, 122], [243, 148], [245, 172], [258, 196], [272, 222], [284, 246], [288, 262]]]]),
 "NWE": dict(ponds=[[55, 180, 5]], streams=[   # the pale river down the east side, a brook through the mill lanes, a brook to the west pond
    ["mist-river", True, [[420, 100], [425, 130], [420, 160], [408, 190], [395, 215], [385, 240], [380, 262]]],
    ["mill-brook", False, [[300, 40], [305, 70], [300, 100], [285, 130], [262, 150], [250, 168], [240, 185], [236, 200]]],
    ["west-brook", False, [[120, 50], [125, 80], [128, 110], [130, 140], [125, 170], [112, 180], [90, 182], [62, 181]]]]),
 "EE": dict(ponds=[[25, 225, 8]], streams=[   # the grey river down the east edge, and the steppe river across the middle to the frozen lake (25,225)
    ["east-river", True, [[453, 15], [452, 50], [449, 90], [444, 130], [438, 165], [435, 195], [432, 220], [425, 245], [422, 264]]],
    ["steppe-river", True, [[300, 70], [270, 95], [240, 115], [205, 135], [170, 160], [130, 185], [90, 205], [50, 222], [32, 226]]]]),
 "MENA": dict(ponds=[[100, 127, 6], [75, 177, 6], [290, 67, 7], [300, 243, 8]], streams=[   # oases are ponds; the trickle by the central town, and the dry wadi to the west oasis
    ["town-trickle", False, [[290, 100], [270, 125], [255, 150], [238, 172], [230, 192], [236, 205]]],
    ["wadi-west", False, [[285, 75], [255, 95], [215, 100], [170, 112], [130, 122], [106, 127]]]]),
 "WCA": dict(ponds=[], streams=[   # the great river through the bridge (368,75) to the bottom edge, and a west fork
    ["canopy-river", True, [[400, 15], [385, 45], [368, 75], [345, 110], [320, 145], [290, 175], [265, 205], [250, 235], [245, 262]]],
    ["west-fork", False, [[40, 60], [90, 100], [130, 135], [165, 165], [190, 190], [215, 205], [255, 215], [266, 208]]]]),
 "ESA": dict(ponds=[], streams=[   # meltwater from the snow peak (355,15) past the waterhole (361,73) to the town, and a seasonal river from the west waterhole to the bottom edge
    ["kili-melt", False, [[356, 28], [358, 50], [361, 73], [352, 100], [338, 125], [322, 152], [308, 178], [292, 200]]],
    ["west-wash", False, [[88, 45], [95, 75], [110, 105], [130, 135], [150, 160], [170, 185], [185, 210], [195, 235], [200, 262]]]]),
 "CSA": dict(ponds=[], streams=[   # snow-melt from the peaks: the silt river from the north peak to the south-east edge, the west melt to the bottom edge
    ["silt-river", True, [[270, 55], [280, 85], [300, 110], [320, 140], [350, 165], [380, 190], [405, 215], [420, 245], [424, 264]]],
    ["west-melt", False, [[30, 100], [55, 125], [95, 148], [135, 162], [165, 190], [165, 215], [165, 240], [168, 264]]]]),
 "SEA": dict(ponds=[], streams=[   # the waterfall and pond (150,48), the river from it to the bridge at the bottom (262,243), a paddy brook from the north-east
    ["waterfall", False, [[170, 18], [160, 35], [150, 52]]],
    ["tangle-river", True, [[150, 60], [170, 80], [190, 100], [205, 125], [225, 150], [245, 185], [255, 215], [262, 243], [265, 266]]],
    ["paddy-brook", False, [[345, 20], [340, 45], [335, 70], [320, 100], [310, 130], [300, 150], [285, 175], [270, 200], [262, 235]]]]),
 "OC": dict(ponds=[], streams=[   # short island rivers that run into the sea
    ["lagoon-creek", False, [[150, 95], [175, 110], [200, 122], [215, 130]]],
    ["spire-river", False, [[422, 70], [415, 92], [405, 112], [398, 128]]],
    ["island-creek", False, [[330, 150], [318, 165], [300, 178], [285, 190]]]]),
}
