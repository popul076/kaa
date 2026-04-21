#!/usr/bin/env python3
import sys

apk_ver   = sys.argv[1]   # e.g. v48
apk_file  = sys.argv[2]   # e.g. moincar-v48.apk
prev_ver  = sys.argv[3]   # e.g. v47
prev_file = sys.argv[4]   # e.g. moincar-v47.apk
build_date= sys.argv[5]   # e.g. 2026-04-21

html = (
    '<!DOCTYPE html>\n'
    '<html lang="ko">\n'
    '<head>\n'
    '<meta charset="UTF-8">\n'
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">\n'
    '<title>모인카 앱 다운로드</title>\n'
    '<style>\n'
    '* { margin: 0; padding: 0; box-sizing: border-box; }\n'
    'body { background: #0d1b2a; color: #fff; font-family: sans-serif; min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }\n'
    '.card { background: #1a2d42; border-radius: 20px; padding: 40px 30px; max-width: 380px; width: 100%; text-align: center; box-shadow: 0 8px 32px rgba(0,0,0,0.4); }\n'
    '.badge { background: #10b981; color: #fff; border-radius: 20px; padding: 4px 16px; font-size: 13px; font-weight: 700; display: inline-block; margin-bottom: 20px; }\n'
    '.phone-icon { font-size: 60px; margin-bottom: 16px; }\n'
    'h1 { font-size: 26px; font-weight: 800; margin-bottom: 8px; }\n'
    '.meta { color: #8fa8c0; font-size: 13px; margin-bottom: 28px; line-height: 1.8; }\n'
    '.btn-primary { display: block; background: linear-gradient(135deg,#1565c0,#4fc3f7); color: #fff; text-decoration: none; border-radius: 14px; padding: 18px; font-size: 18px; font-weight: 800; margin-bottom: 12px; }\n'
    '.btn-primary:active { opacity: 0.85; }\n'
    '.btn-secondary { display: block; background: #253548; color: #8fa8c0; text-decoration: none; border-radius: 12px; padding: 14px; font-size: 14px; margin-bottom: 8px; }\n'
    '.direct-link { margin-top: 14px; padding: 12px; background: #0d1b2a; border-radius: 10px; border: 1px solid #1e3a5f; }\n'
    '.direct-link p { font-size: 11px; color: #8fa8c0; margin-bottom: 6px; }\n'
    '.direct-link a { color: #4fc3f7; font-size: 12px; word-break: break-all; }\n'
    '.install-guide { margin-top: 16px; background: #1a2d42; border: 1px solid #ff6b35; border-radius: 10px; padding: 14px; text-align: left; }\n'
    '.install-guide h4 { font-size: 13px; color: #ff6b35; margin-bottom: 8px; }\n'
    '.install-guide p { font-size: 12px; color: #cdd8e3; line-height: 1.8; }\n'
    '</style>\n'
    '</head>\n'
    '<body>\n'
    '<div class="card">\n'
    '  <div class="badge">&#9989; ' + apk_ver + ' 최신버전</div>\n'
    '  <div class="phone-icon">&#128241;</div>\n'
    '  <h1>moincar ' + apk_ver + '</h1>\n'
    '  <div class="meta">버전 ' + apk_ver + ' &middot; 약 27MB<br>' + build_date + ' 배포</div>\n'
    '  <a href="./' + apk_file + '" download="' + apk_file + '" class="btn-primary">&#11015; APK 다운로드 (' + apk_ver + ')</a>\n'
    '  <a href="./' + prev_file + '" download="' + prev_file + '" class="btn-secondary">이전 버전 (' + prev_ver + ') 다운로드</a>\n'
    '  <div class="direct-link">\n'
    '    <p>&#9888; 버튼이 작동 안 할 경우 아래 링크를 길게 눌러 저장하세요</p>\n'
    '    <a href="https://popul076.github.io/' + apk_file + '">https://popul076.github.io/' + apk_file + '</a>\n'
    '  </div>\n'
    '  <div class="install-guide">\n'
    '    <h4>&#128204; 안드로이드 설치 방법</h4>\n'
    '    <p>1. APK 다운로드 후 파일 앱에서 실행<br>2. 알 수 없는 앱 설치 허용<br>3. 설치 완료 후 moincar 실행</p>\n'
    '  </div>\n'
    '</div>\n'
    '</body>\n'
    '</html>\n'
)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print('index.html generated:', apk_ver)
