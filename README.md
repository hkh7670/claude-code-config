# claude-config

`~/.claude/` 디렉토리의 개인 Claude Code 설정 동기화용 repo.

## 포함 내용

| 항목 | 설명 |
|------|------|
| `settings.json` | Claude Code 메인 설정 |
| `CLAUDE.md` | 글로벌 instructions |
| `statusline-command.sh` | 상태표시줄 스크립트 |
| `agents/` | 커스텀 에이전트 |
| `commands/` | 커스텀 슬래시 커맨드 |
| `rules/` | 코딩 규칙 (common / language별) |
| `skills/` | 스킬 정의 |
| `scripts/` | 보조 스크립트 |
| `hooks/` | 훅 설정 |
| `mcp-configs/` | MCP 서버 설정 |

## 새 머신에서 처음 설정하기

기존 `~/.claude` 디렉토리가 있다면 백업 후 clone:

```bash
mv ~/.claude ~/.claude.backup
git clone git@github.com:hkh7670/claude-config.git ~/.claude
```

## 변경사항 받기 (pull)

다른 머신에서 푸시한 변경사항 가져오기:

```bash
cd ~/.claude && git pull
```

## 변경사항 올리기 (push)

설정 변경 후 다른 머신과 공유:

```bash
cd ~/.claude
git add .
git commit -m "update: 변경 내용"
git push
```

## 동기화 제외 항목

머신별로 다르거나 민감한 데이터는 `.gitignore`로 제외됨:

- **대화 기록 / 세션**: `projects/`, `sessions/`, `session-data/`, `history.jsonl`, `todos/`
- **로그 / 캐시**: `*.log`, `cache/`, `backups/`, `metrics/`, `statsig/`
- **플러그인 설치 상태**: `plugins/`, `.agents/`, `ecc/`, `homunculus/` (각 머신에서 재설치)
- **자격 증명**: `.credentials*`, `*.token`, `*api*key*`

## 워크플로우 팁

자주 잊지 않으려면 셸 alias 추가:

```bash
# ~/.zshrc 또는 ~/.bashrc
alias claude-sync='cd ~/.claude && git pull'
alias claude-push='cd ~/.claude && git add . && git commit -m "update" && git push'
```

또는 `chezmoi` 같은 dotfiles 매니저 사용도 가능.
