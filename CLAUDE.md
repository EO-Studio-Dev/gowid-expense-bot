# CLAUDE.md — gowid-expense-skill

## 프로젝트 개요

Gowid 법인카드 경비를 Claude Code에서 자동 분류·제출하는 스킬.
서버 없이 각 팀원의 Claude Code에서 직접 Gowid API를 호출하는 구조.

## 아키텍처

```
팀원 Claude Code
  └── gowid-expense 스킬
       ├── SKILL.md (워크플로우 정의)
       ├── scripts/gowid.sh (API 헬퍼 — py 전환 예정)
       └── data/auto_rules.json (289개 자동 분류 규칙)
            ↓
       Gowid REST API (회사 공용 키)
```

## 핵심 파일

| 파일 | 역할 |
|------|------|
| `SKILL.md` | Claude Code 스킬 정의 — 트리거, 워크플로우, 용도 ID 참조표 |
| `scripts/gowid.sh` | API 헬퍼 7개 커맨드 (whoami, my-expenses, submit, detail, purposes, members, rules) |
| `data/auto_rules.json` | 가맹점→용도 자동 매칭 규칙 289개 (ash 직접 검수 완료) |
| `install.sh` | 원클릭 설치 (스킬 + API 키) |

## auto_rules 원칙 (ash 검수 기준)

**자동 매칭 가능 (conf ≥ 0.95):**
- IT서비스 구독 (SaaS명 확실), 통신비, 우편비, 노트북 대여, 사무실 임대료

**자동 매칭 불가 — 사용자에게 물어봐야 하는 것:**
- 식비: 점심/야근은 시간대로 구분, 참석자 필요 → classifier 위임, auto_rules에 넣지 않음
- 편의점/마트: 뭘 샀는지 모름 → 매핑 안 함
- 카페/커피: 식비인지 회의비인지 모름 → conf 0.5 또는 매핑 안 함
- 업무추진비: 반복될 수 없음 → 매핑 안 함
- 회의비/접대비: 장소가 카페라도 회의 아닐 수 있음 → 매핑 안 함
- 결제 대행사 (자동결제_N, 정기과금_N, 다날, NICE, 이니시스): 실제 서비스명 모름 → conf 0.5
- 도서구입비: 책 제목 직접 입력 필요 → 메모 자동입력 안 함
- 교보문고/알라딘/예스24: 도서구입비이지만 메모(책 제목) 필요 → 메모 null

**특수 규칙:**
- 페이레터 - 화이트큐브: 기타비용, 메모 "운동해이오" (고정)
- 한컴 자동결제: IT서비스, 메모 "한컴오피스 구독" (고정)
- SONIC.NET: US-사무실임대료관리비 (IT서비스 아님, 미국 인터넷)
- 타다(TADA)법인: 업무교통비 (US-여비교통비 아님, 한국에서 사용)
- 쿠팡 와우멤버십: 오사용 conf 0.5 (무조건 오사용 단정 불가)
- 카카오페이 보험: US-보험비, 메모 "미국 출장 여행자보험"

## Gowid API

- Base: `https://openapi.gowid.com`
- Auth: Header `Authorization: <GOWID_API_KEY>`
- 주의: not-submitted 리스트에 cardUserName이 비어있음 → detail API에서 card.cardUser.email로 식별 필수

## 오답노트

- Gowid API user 객체에 userId 없음 → email 기반 lookup 필수
- purposeRequirementAnswerMap API 500 에러 → 필수항목 제거 + 메모 기입으로 우회
- 식비 점심/야근 구분: auto_rules가 아니라 결제 시간(17시 기준)으로 동적 분류
- 결제처명을 메모에 그대로 쓰면 안 됨 (다날 → "다날 전자결제" X)

## 다음 할 일

- [ ] gowid.sh → gowid.py 전환 (Windows 호환: 윤환준, 김찬희, 김현아)
- [ ] 설치 명령어 통일 (npx 하나 + 첫 실행 시 API 키 가이드)
- [ ] 팀 공지 + 설치 안내
- [ ] Slack 봇 → 스킬 단독 전환 여부 최종 결정
