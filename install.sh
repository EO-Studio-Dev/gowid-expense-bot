#!/usr/bin/env bash
# Gowid 경비 어시스턴트 — 원클릭 설치
set -e

echo "🔧 Gowid 경비 어시스턴트 설치 중..."

# 1. Claude Code 스킬 설치
npx skills add EO-Studio-Dev/gowid-expense-skill --skill gowid-expense -y 2>/dev/null || {
  echo "❌ 스킬 설치 실패. npx가 설치되어 있는지 확인하세요."
  exit 1
}

# 2. API 키 설정
KEY="2a33cb19-f808-45a0-9e16-466a896e278a"
SHELL_RC="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"

if grep -q "GOWID_API_KEY" "$SHELL_RC" 2>/dev/null; then
  echo "✅ API 키 이미 설정됨"
else
  echo "" >> "$SHELL_RC"
  echo "# Gowid 경비 어시스턴트" >> "$SHELL_RC"
  echo "export GOWID_API_KEY=\"$KEY\"" >> "$SHELL_RC"
  echo "✅ API 키 추가됨 ($SHELL_RC)"
fi

# 3. 현재 세션에도 적용
export GOWID_API_KEY="$KEY"

echo ""
echo "✅ 설치 완료!"
echo ""
echo "사용법: Claude Code에서 '내 경비 보여줘' 라고 말하세요."
echo ""
echo "⚠️  새 터미널을 열거나 source $SHELL_RC 를 실행하세요."
