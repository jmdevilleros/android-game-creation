import re, markdown, pathlib
src = pathlib.Path('android_game_checklist_generic_en.md').read_text()
fm = re.match(r'^---\n(.*?)\n---\n', src, re.S)
meta = dict(l.split(': ',1) for l in fm.group(1).splitlines())
body = src[fm.end():]
import html as _h
blocks=[]
def _fence(m):
    ind, code = m.group(1), m.group(3)
    code = "\n".join(l[len(ind):] if l.startswith(ind) else l for l in code.split("\n"))
    blocks.append('<pre><code>'+_h.escape(code)+'</code></pre>')
    return f"{ind}FENCEBLOCK{len(blocks)-1}X"
body = re.sub(r'^([ \t]*)```(\w*)\n(.*?)\n[ \t]*```[ \t]*$', _fence, body, flags=re.S|re.M)
body = re.sub(r'^  (?=\S)', '    ', body, flags=re.M)
html = markdown.markdown(body, extensions=['tables','sane_lists'])
html = html.replace('\\|','|')
for i,b in enumerate(blocks):
    html = re.sub(rf'(<p>)?FENCEBLOCK{i}X(</p>)?', lambda m: b, html)
html = html.replace('<li>[ ] ', '<li class="task"><span class="cb"></span>')
html = re.sub(r'<li>\s*<p>\[ \] ', '<li class="task"><p><span class="cb"></span>', html)
pri = {'critical':'miss','important':'part','nice-to-have':'na'}
def pr(m):
    txt=m.group(1)
    out=txt
    for k,c in pri.items():
        out=re.sub(rf'(?<![\w-]){re.escape(k)}(?![\w-])(?![^<]*</code>)', f'<span class="b {c}">{k}</span>', out, count=0)
    return 'Priority: '+out
html = re.sub(r'Priority: ([^<]+)', pr, html)
html = html.replace('<code>critical</code>','<span class="b miss">critical</span>').replace('<code>important</code>','<span class="b part">important</span>').replace('<code>nice-to-have</code>','<span class="b na">nice-to-have</span>')
html = html.replace('<code>[agnostic]</code>','<span class="tag ag">agnostic</span>').replace('<code>[flutter/flame]</code>','<span class="tag ff">flutter/flame</span>')
html = html.replace('⚠ verify still current','<span class="vig">⚠ verify still current</span>')
html = re.sub(r'<h1>(Phase \d+) · ', r'<h1><span class="ph">\1</span>', html)
css = """
@page { size: A4; margin: 15mm 14mm 15mm 14mm; }
@page cover { margin: 0; }
body { font-family: 'Noto Sans','DejaVu Sans',sans-serif; font-size: 9.4pt; color:#1d2230; line-height:1.4; }
.cover { page: cover; box-sizing:border-box; height:297mm; width:210mm; padding:0 22mm; display:flex; flex-direction:column; justify-content:center;
  background: linear-gradient(160deg,#08131f 0%,#123d4a 50%,#2f2a66 100%); color:#fff; page-break-after: always; }
.cover h1 { font-size: 30pt; border:none; color:#fff; margin:0 0 6mm; page-break-before:avoid; }
.cover .sub { font-size: 14pt; color:#a9e3ea; margin-bottom: 12mm; }
.cover .meta { font-size: 10.5pt; color:#d6eef2; line-height:1.7; }
.cover .chips span { display:inline-block; border:1px solid rgba(255,255,255,.4); border-radius:4mm; padding:1mm 3mm; margin:0 2mm 2mm 0; font-size:9pt; }
h1 { font-size: 16pt; color:#123d4a; border-bottom: 2.5px solid #1fa6b8; padding-bottom: 2mm; page-break-before: always; margin-top:0; }
h1 .ph { display:inline-block; background:#1fa6b8; color:#fff; border-radius:2mm; padding:0 2.5mm; margin-right:3mm; font-size:12pt; vertical-align:middle; }
ul { padding-left: 5mm; }
li.task { list-style:none; margin: 0 0 3mm -5mm; padding: 2mm 3mm; border:1px solid #e3e8ef; border-left:3px solid #1fa6b8; border-radius:2mm; background:#fbfcfe; page-break-inside: avoid; }
li.task > ul { margin: 1mm 0 0; padding-left: 6mm; } li.task > ul > li { margin: .6mm 0; font-size: 8.8pt; }
.cb { display:inline-block; width:3.2mm; height:3.2mm; border:1.4px solid #123d4a; border-radius:.6mm; margin-right:2mm; vertical-align:-0.4mm; }
.b { display:inline-block; padding:.2mm 1.6mm; border-radius:3mm; font-size:7.6pt; font-weight:700; }
.miss { background:#fee4e2; color:#912018; } .part { background:#fef0c7; color:#93370d; } .na { background:#eaecf0; color:#344054; }
.tag { display:inline-block; padding:.1mm 1.4mm; border-radius:1mm; font-size:7.2pt; font-weight:600; margin-left:1mm; }
.ag { background:#e0f2fe; color:#075985; } .ff { background:#ede9fe; color:#5b21b6; }
.vig { display:inline-block; background:#fff4e5; color:#b54708; border:1px solid #f7b267; border-radius:1mm; padding:0 1.4mm; font-size:7.4pt; font-weight:700; }
code { font-family:'DejaVu Sans Mono',monospace; font-size:7.8pt; background:#eef2f6; padding:0 .8mm; border-radius:1mm; word-break:break-word; }
pre { background:#0f1b2b; color:#e6edf3; padding:2.5mm 3mm; border-radius:2mm; font-size:7.4pt; line-height:1.35; white-space:pre-wrap; page-break-inside: avoid; margin:1.5mm 0; }
pre code { background:none; color:inherit; padding:0; font-size:7.4pt; }
table { width:100%; border-collapse:collapse; font-size:8.2pt; margin:2mm 0 4mm; }
th { background:#123d4a; color:#fff; text-align:left; padding:1.5mm 2mm; } td { border-bottom:1px solid #e3e8ef; padding:1.3mm 2mm; vertical-align:top; }
tr:nth-child(even) td { background:#f6f9fb; } tr { page-break-inside: avoid; }
a { color:#0e7490; text-decoration:none; word-break:break-all; }
h1 + p, p { margin: 1.5mm 0; }
"""
cover = f"""<div class="cover"><h1>{meta['title']}</h1><div class="sub">{meta['subtitle']}</div>
<div class="chips"><span>13 phases · 94 items</span><span>Priorities: critical · important · nice-to-have</span><span>agnostic / flutter-flame</span><span>⚠ verify still current</span></div>
<div class="meta" style="margin-top:10mm">Prepared for Juan Manuel de Villeros<br>{meta['date']} (Bogotá time, UTC-5)<br>
Distilled from three in-house projects and the official Android, Google Play, Flutter and Flame guidelines</div></div>"""
pathlib.Path('android_game_checklist_generic_en.html').write_text(f"<!doctype html><html lang='en'><head><meta charset='utf-8'><style>{css}</style></head><body>{cover}{html}</body></html>")
