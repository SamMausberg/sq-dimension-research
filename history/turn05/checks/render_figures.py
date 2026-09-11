from pathlib import Path
import subprocess, fitz
from PIL import Image, ImageOps, ImageDraw
root=Path(__file__).resolve().parents[1]
figs=['template_flip','rectify_round','implication_map','cap_geometry','order_median']
for name in figs:
    driver=root/f'preview_{name}.tex'
    import re
    body=(root/'figures'/f'{name}.tex').read_text()
    body=re.sub(r'\\begin\{figure\}(?:\[[^]]*\])?', '',body).replace(r'\end{figure}','')
    labels={'template_flip':'fig:template','rectify_round':'fig:rectify','implication_map':'fig:landscape','cap_geometry':'fig:cap','order_median':'fig:order'}
    am=re.search(r'\\newlabel\{'+re.escape(labels[name])+r'\}\{\{(\d+)\}',(root/'paper.aux').read_text())
    body=r'\setcounter{figure}{'+str(int(am.group(1))-1)+r'}'+body
    driver.write_text(r'\documentclass[11pt]{article}'+'\n'+r'\input{preamble}'+'\n'+r'\usepackage{xr}\externaldocument{paper}'+'\n'+r'\usepackage[active,tightpage]{preview}\setlength\PreviewBorder{8pt}'+'\n'+r'\begin{document}\begin{preview}\begin{minipage}{\textwidth}\makeatletter\def\@captype{figure}\makeatother'+'\n'+body+'\n'+r'\end{minipage}\end{preview}\end{document}'+'\n')
    p=subprocess.run(['pdflatex','-interaction=nonstopmode','-halt-on-error',driver.name],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (root/'logs'/f'figure_{name}.log').write_bytes(p.stdout)
    if p.returncode: raise RuntimeError(f'Figure compilation failed: {name}')
    pdf=fitz.open(root/f'preview_{name}.pdf')
    assert len(pdf)==1,(name,len(pdf))
    pdf[0].get_pixmap(matrix=fitz.Matrix(2.5,2.5),alpha=False).save(root/'renders'/f'{name}.png')
# Page renders at 120 dpi, and compact sheets of all pages.
doc=fitz.open(root/'paper.pdf')
for start in range(0,len(doc),12):
    thumbs=[]
    for i in range(start,min(len(doc),start+12)):
        pix=doc[i].get_pixmap(matrix=fitz.Matrix(0.45,0.45),alpha=False)
        im=Image.frombytes('RGB',(pix.width,pix.height),pix.samples)
        im=ImageOps.expand(im,border=(4,4,4,22),fill='white')
        ImageDraw.Draw(im).text((8,im.height-18),str(i+1),fill='black')
        thumbs.append(im)
    w=max(im.width for im in thumbs);h=max(im.height for im in thumbs)
    sheet=Image.new('RGB',(w*3,h*4),'#dddddd')
    for j,im in enumerate(thumbs):sheet.paste(im,((j%3)*w,(j//3)*h))
    sheet.save(root/'renders'/f'pages_{start+1:02d}_{min(len(doc),start+12):02d}.png')
for i in [0,1,2,5,9,15,20,29]:
    doc[i].get_pixmap(matrix=fitz.Matrix(1.6,1.6),alpha=False).save(root/'renders'/f'page_{i+1:02d}.png')
print(f'Rendered {len(figs)} vector figures and {len(doc)} page thumbnails.')
