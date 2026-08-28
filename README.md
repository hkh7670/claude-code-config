# claude-config

`~/.claude/` 개인 설정 동기화 repo.

## 구조

- 에이전트·스킬·커맨드: [ECC](https://github.com/affaan-m/everything-claude-code) 플러그인으로 설치, 이 저장소엔 없음
- `rules/` — 플러그인이 배포 못 하는 유일한 컴포넌트라 여기 수동 복사. 현재 common/java/kotlin/python/react/react-native/typescript/vue/web만 유지
- `CLAUDE.md` — 글로벌 지침. rules와 중복되지 않게 관리
- `settings.json` — 메인 설정, 알림 훅 등록 포함
- `hooks/notify-terminal.sh` — SSH+tmux 원격 작업 시 알림을 로컬 터미널로 보내는 커스텀 훅 (ECC 기본 알림은 tmux에서 원격 서버에만 뜨는 문제가 있음)
- `memory/` — 세션 간 기억
- `jobs/pins.json` — 고정 백그라운드 작업
- `statusline-command.sh`

> 참고: 예전엔 `install.sh`로 agents/commands/scripts까지 중복 설치했었음. 플러그인과 버전이 어긋나 충돌 발생 → 전부 제거하고 플러그인을 정본으로 통일.

## 룰 업데이트

```bash
cd ~/workspace/ECC
git pull
./install.sh --target claude --modules rules-core
```

## 새 머신 설정

```bash
mv ~/.claude ~/.claude.backup
git clone git@github.com:hkh7670/claude-config.git ~/.claude

/plugin marketplace add https://github.com/affaan-m/ECC
/plugin install ecc@ecc
```

룰은 clone에 포함되어 있어 추가 설치 불필요. 새 언어 스택 추가 시에만 위 룰 업데이트 절차 반복.

## 동기화

```bash
git -C ~/.claude pull
git -C ~/.claude add . && git -C ~/.claude commit -m "설명" && git -C ~/.claude push
```

alias:
```bash
alias claude-sync='git -C ~/.claude pull'
alias claude-push='git -C ~/.claude add . && git -C ~/.claude commit -m "update" && git -C ~/.claude push'
```

## 제외 대상 (`.gitignore`)

- 런타임 데이터 — 대화 기록, 로그, 캐시
- 플러그인 설치 상태 — `plugins/`, `.agents/`, 루트 `ecc/` (머신마다 재설치)
  - `.gitignore`에 `ecc/`가 아닌 `/ecc/`로 앵커링 — 슬래시 없으면 `rules/ecc/`까지 무시됨
- 자격증명 — `.credentials*`, `*.token`, `*api*key*`
- `telemetry/` — 계정 UUID 포함된 전송 실패 로그
