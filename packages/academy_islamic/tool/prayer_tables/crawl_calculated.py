#!/usr/bin/env python3
"""Crawl the calculated tables (generic «ДУМ РФ» and local-method cities).

Reads the list of Russian places and, for each, the twelve monthly tables of
2026 via plain HTTP (curl, 6 threads, retries). Writes one JSON per place to
`./cities/` and the list to `./cities-list.json` in the current directory;
already downloaded places are skipped, so it can be re-run.

Run from an empty scratch directory (outside the repo), e.g.
  mkdir -p /tmp/calc && cd /tmp/calc && python3 -I <repo>/apps/zikro/tool/prayer_tables/crawl_calculated.py

The provenance of each place (site, method name) is in logs/provenance-internal.json.
Not shipped: tool/ is not part of the app bundle.
"""
import re,html,json,subprocess,sys,os,time,concurrent.futures as cf
UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15'
def get(url,tries=5):
    for i in range(tries):
        r=subprocess.run(['curl','-sL','-m','60','-A',UA,url,'-w','\n%{http_code}'],capture_output=True)
        out=r.stdout.decode('utf-8','replace'); code=out.rsplit('\n',1)[-1]; body=out[:-(len(code)+1)]
        if code=='200' and len(body)>50000: return body
        time.sleep(1.5*(i+1))
    return None
def rows_of(t,month):
    rows=[]
    for tr in re.findall(r'<tr[^>]*>(.*?)</tr>',t,flags=re.S):
        c=[re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]+>','',x))).strip() for x in re.findall(r'<t[dh][^>]*>(.*?)</t[dh]>',tr,flags=re.S)]
        if len(c)>=7 and re.search(r'^\D+ \d+',c[0]) and all(re.fullmatch(r'\d\d:\d\d',x) for x in c[1:7]):
            day=int(re.search(r'(\d+)',c[0]).group(1)); rows.append((day,c[1:7]))
    return rows
base='https://sajda.com'
index=get(base+'/ru/prayer-times/russia')
links=[]
seen=set()
for h,n in re.findall(r'<a[^>]*href="(/ru/prayer-times/russia/[^"/]+/\d+)"[^>]*>(.*?)</a>',index,flags=re.S):
    if h in seen: continue
    seen.add(h); links.append((h,re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]+>','',n))).strip()))
print('cities',len(links),flush=True)
json.dump(links,open('cities-list.json','w',encoding='utf-8'),ensure_ascii=False)
def do(item):
    h,name=item; slug=h.rsplit('/',2)[-2]+'_'+h.rsplit('/',1)[-1]; out=f'cities/{slug}.json'
    if os.path.exists(out): return slug,'cached'
    res={'url':h,'name':name,'months':{}}
    for m in range(1,13):
        t=get(f'{base}{h}/2026-{m:02d}')
        if t is None: res['months'][m]=None; continue
        if m==1:
            s=t.replace('\\"','"')
            mm=re.search(r'"methodName":"([^"]+)"',s); res['method']=mm.group(1) if mm else None
            tz=re.search(r'"timeZone":"([^"]+)"',s); res['tz']=tz.group(1) if tz else None
            ti=re.search(r'<title>([^<]+)</title>',t); res['title']=ti.group(1) if ti else None
        res['months'][m]=rows_of(t,m)
    json.dump(res,open(out,'w',encoding='utf-8'),ensure_ascii=False)
    return slug,'ok'
with cf.ThreadPoolExecutor(6) as ex:
    for i,(slug,st) in enumerate(ex.map(do,links)):
        print(i+1,slug,st,flush=True)
print('DONE',flush=True)
