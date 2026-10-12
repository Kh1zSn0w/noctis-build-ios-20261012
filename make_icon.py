from PIL import Image, ImageDraw, ImageFilter
import aggdraw, random, math
from pathlib import Path
random.seed(12)
root=Path(__file__).resolve().parent
size=1024
img=Image.new("RGB",(size,size),(5,9,21))
d=ImageDraw.Draw(img)
# Ink-blue concentric halo and fine etched marks
d.ellipse((106,70,920,884),fill=(11,25,58),outline=(38,77,148),width=5)
d.ellipse((168,126,867,825),outline=(28,60,124),width=2)
d.ellipse((232,191,800,758),outline=(26,51,103),width=2)
for i in range(85):
    a=(i/85)*math.tau
    r=445
    x=512+math.cos(a)*r; y=469+math.sin(a)*r
    ln=8 if i%5 else 27
    d.line((x,y,x+math.cos(a)*ln,y+math.sin(a)*ln), fill=(35,72,138), width=2)
# Hard charcoal silhouette beneath illustrated hand
p=aggdraw.Path()
p.moveto(328,1060)
p.curveto(358,912,394,817,386,712)
p.curveto(385,644,338,558,301,500)
p.curveto(281,469,275,429,301,413)
p.curveto(335,387,357,433,388,459)
p.line(419,486)
p.curveto(421,408,415,321,418,274)
p.curveto(420,241,443,224,466,232)
p.curveto(500,241,481,344,496,384)
p.curveto(506,328,508,243,522,211)
p.curveto(536,181,564,189,573,212)
p.curveto(584,248,560,349,566,392)
p.curveto(584,323,591,270,607,259)
p.curveto(636,236,656,267,645,305)
p.curveto(630,353,618,401,613,446)
p.curveto(641,367,660,347,678,355)
p.curveto(703,361,702,396,690,433)
p.curveto(675,484,672,554,645,610)
p.curveto(622,660,582,702,556,764)
p.curveto(538,825,574,934,588,1060)
p.close()
ctx=aggdraw.Draw(img)
ctx.path(p,aggdraw.Brush((25,43,70)),aggdraw.Pen((4,9,18),30))
ctx.flush()
# Offset interior hand gives blockprint shadow
p2=aggdraw.Path()
p2.moveto(370,1060)
p2.curveto(380,930,435,819,424,702)
p2.curveto(418,641,366,555,320,479)
p2.curveto(301,435,315,436,345,472)
p2.curveto(383,526,416,537,434,552)
p2.curveto(443,486,437,313,442,270)
p2.curveto(448,251,463,257,463,288)
p2.line(467,485)
p2.curveto(479,498,492,483,498,466)
p2.curveto(515,392,522,231,538,215)
p2.curveto(553,215,555,239,548,274)
p2.line(539,469)
p2.curveto(545,505,561,493,569,457)
p2.curveto(584,371,604,276,617,277)
p2.curveto(646,270,593,454,589,512)
p2.curveto(606,544,623,500,631,482)
p2.curveto(645,448,663,369,676,375)
p2.curveto(695,385,643,542,626,586)
p2.curveto(607,646,541,699,530,768)
p2.curveto(513,847,550,944,565,1060)
p2.close()
ctx=aggdraw.Draw(img)
ctx.path(p2,aggdraw.Brush((210,220,212)),aggdraw.Pen((242,235,217),7))
ctx.flush()
# Etched anatomical tendon lines
def curve(pts,rgba=(26,45,74),w=5):
    a=aggdraw.Path(); a.moveto(*pts[0])
    for j in range(1,len(pts),3):
        a.curveto(*pts[j],*pts[j+1],*pts[j+2])
    c=aggdraw.Draw(img);c.path(a,None,aggdraw.Pen(rgba,w));c.flush()
curve([(447,568),(467,620),(468,685),(461,740)],(29,49,79),8)
curve([(504,524),(528,610),(516,682),(499,770)],(29,49,79),7)
curve([(582,524),(566,611),(536,645),(520,709)],(50,72,93),5)
curve([(402,733),(470,774),(502,796),(530,813)],(29,49,79),5)
curve([(351,505),(367,536),(379,568),(391,582)],(29,49,79),4)
curve([(443,300),(440,370),(450,427),(453,463)],(43,63,95),4)
curve([(544,252),(532,332),(521,405),(513,440)],(43,63,95),5)
curve([(610,300),(601,370),(588,438),(580,465)],(43,63,95),4)
# Clean rim and engraved streaks
for i in range(120):
    x=random.randint(320,690); y=random.randint(300,900)
    # only draw subtle noise in inner beige, not blue background
    if img.getpixel((x,y))[0]>120:
        dx=random.randint(-15,9); dy=random.randint(7,27)
        d.line((x,y,x+dx,y+dy),fill=(157,170,170),width=random.choice([1,2]))
# accent cobalt beam and sharp typographic zero-mark
d.line((180,841,300,841), fill=(54,111,246),width=5)
d.line((724,179,850,179), fill=(54,111,246),width=5)
d.line((746,196,850,196), fill=(54,111,246),width=2)
# Round iOS will apply system mask
out=root/"Noctis"/"Assets.xcassets"/"AppIcon.appiconset"/"AppIcon.png"
img.save(out,optimize=True)
print("ICON_WRITTEN",out, out.stat().st_size)
