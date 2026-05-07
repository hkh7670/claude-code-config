# Global Claude Instructions

## Skills

Spring Boot 관련 작업에는 다음 everything-claude-code 스킬을 적극 활용한다:

- `everything-claude-code:springboot-patterns` — Spring Boot 아키텍처 및 레이어 패턴
- `everything-claude-code:springboot-tdd` — Spring Boot TDD 워크플로우
- `everything-claude-code:springboot-verification` — Spring Boot 빌드 및 검증
- `everything-claude-code:springboot-security` — Spring Security 패턴
- `everything-claude-code:jpa-patterns` — JPA/Hibernate 패턴
- `everything-claude-code:java-coding-standards` — Java 코딩 표준
- `everything-claude-code:gradle-build` — Gradle 빌드 문제 해결
- `everything-claude-code:kotlin-patterns` — Kotlin 패턴 (Kotlin 사용 시)
- `everything-claude-code:kotlin-testing` — Kotlin 테스트 (Kotlin 사용 시)
- `everything-claude-code:database-migrations` — DB 마이그레이션 패턴
- `everything-claude-code:backend-patterns` — 백엔드 공통 패턴
- `everything-claude-code:api-design` — REST API 설계

## Java/Kotlin Code Style

### Base: Google Java Style Guide (수정 적용)

Google Java Style Guide를 기본으로 하되, 아래 규칙이 우선한다.

### Indentation

- **들여쓰기: 4 spaces** (탭 문자 사용 금지)
- 연속 들여쓰기(continuation indent): 8 spaces

### Line Length

- **최대 120자**

### Brace Style: K&R

여는 중괄호는 같은 줄 끝에 위치한다. 닫는 중괄호는 새 줄에 단독으로 위치한다.

```java
// 올바른 예
public class Example {
    public void method() {
        if (condition) {
            doSomething();
        } else {
            doOther();
        }
    }
}

// 잘못된 예 (Allman 스타일 금지)
public void method()
{
    if (condition)
    {
        doSomething();
    }
}
```

### Braces: 항상 중괄호 사용 (필수)

`if`, `else`, `for`, `while`, `do` 블록은 **한 줄이어도 반드시 중괄호로 묶는다**.

```java
// 올바른 예
if (user == null) {
    return;
}

for (int i = 0; i < size; i++) {
    process(i);
}

// 잘못된 예 (중괄호 생략 금지)
if (user == null)
    return;

for (int i = 0; i < size; i++)
    process(i);
```

### 공백 규칙

- 키워드와 괄호 사이에 공백: `if (`, `for (`, `while (`
- 이항 연산자 양쪽에 공백: `a + b`, `x == y`
- 메서드 이름과 괄호 사이 공백 없음: `method()`
- 쉼표 뒤에 공백: `method(a, b, c)`

### 빈 줄 규칙

- 클래스 멤버 간 빈 줄 1개
- 연관된 로직 그룹 사이 빈 줄로 구분
- 연속 빈 줄 2개 이상 금지

### Import 정렬 순서 (Google Style 준수)

1. `java.*`, `javax.*`
2. 서드파티 라이브러리 (`org.*`, `com.*` 등)
3. 프로젝트 내부 패키지

각 그룹 사이 빈 줄 1개. 와일드카드 import 금지.

### 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스, 인터페이스 | UpperCamelCase | `UserService` |
| 메서드, 변수 | lowerCamelCase | `findById` |
| 상수 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| 패키지 | lowercase | `com.example.user` |
| 제네릭 타입 파라미터 | 단일 대문자 | `T`, `E`, `K`, `V` |

## SQL / JPQL 규칙

- **키워드는 반드시 대문자**로 작성한다: `SELECT`, `FROM`, `WHERE`, `ORDER BY`, `LIMIT`, `JOIN`, `AND`, `OR` 등
- 테이블명·컬럼명·엔티티명은 기존 네이밍 그대로 유지

```sql
-- 올바른 예
SELECT w FROM WatchIdSequence w WHERE w.seq < 100000 ORDER BY w.id LIMIT 1

-- 잘못된 예
select w from WatchIdSequence w where w.seq < 100000 order by w.id limit 1
```

## Spring Boot 규칙

- Controller → Service → Repository 레이어 엄격히 구분
- `@Transactional`은 Service 레이어에만 적용
- Entity 직접 노출 금지 — DTO/Record 사용
- `@RestControllerAdvice`로 예외 처리 중앙화
- 생성자 주입 사용 (`@Autowired` 필드 주입 금지)
