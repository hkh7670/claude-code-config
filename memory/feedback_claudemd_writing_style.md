---
name: feedback-claudemd-writing-style
description: How to write CLAUDE.md / instruction files — conciseness, concreteness, negative phrasing, avoid duplicating rules/
metadata:
  type: feedback
---

CLAUDE.md 및 유사 지침 파일(rules, memory)을 작성할 때 다음 3원칙을 따른다:

1. **간결하게**: 보편적이고 필수적인 지시만 최소한으로 포함한다. 자주 쓰이지 않거나 당연한 내용, 장황한 배경 설명은 넣지 않는다.
2. **애매한 지시 금지**: "깨끗한 코드를 작성하라" 같은 추상적 표현 대신 "들여쓰기 4 spaces", "한 줄 최대 120자"처럼 구체적인 수치·행동으로 명시한다.
3. **부정문 선호**: Claude는 긍정문("~해라")보다 부정문("~하지 마라")을 더 잘 따른다. 금지 사항 + 대안을 짝지어 표현한다. 예: "필드 주입 금지, 생성자 주입 사용".
4. **rules 폴더와 중복 금지**: `~/.claude/rules/<language>/coding-style.md` 등 언어별 rules 파일이 이미 자동 로드되는 경우가 많다. CLAUDE.md에 규칙을 추가하기 전에 `rules/`, `rules/ecc/` 하위에 동일 언어 디렉터리가 있는지, 같은 내용을 이미 다루는지 확인한다. rules가 느슨하게("프로젝트 표준에 맞춰") 표현한 부분을 CLAUDE.md에서 구체적 수치로 못박는 것은 겹치지 않으므로 유지해도 된다.

**Why:** 사용자가 "클로드코드 창시자"의 CLAUDE.md 작성 가이드라인이라며 전달함(1~3). 이후 실제로 `rules/kotlin`, `rules/ecc/react`, `rules/web/patterns.md`에 이미 있는 규칙(`!!` 금지, `val` 우선, 클래스 컴포넌트 금지, 서버 상태 복제 금지)을 CLAUDE.md에 중복 작성했던 것을 사용자가 지적함(4).

**How to apply:** 사용자의 `~/.claude/CLAUDE.md`나 프로젝트 CLAUDE.md, rules 파일을 새로 쓰거나 수정할 때마다 이 4원칙을 기준으로 검토한다. 표/예시 코드가 꼭 필요한 경우가 아니면 한 줄 규칙 목록으로 압축하고, 작성 전 `ls ~/.claude/rules/<lang>/` 로 기존 커버리지를 먼저 확인한다.
