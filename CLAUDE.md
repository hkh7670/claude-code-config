# Global Instructions

## 도구 호출
- 툴 호출 파라미터(JSON)의 한글 등 비ASCII 문자열은 항상 리터럴 UTF-8로 작성하고, \uXXXX 유니코드 이스케이프로 표기하지 않는다

## Java

- 들여쓰기는 4 spaces로 한다. 탭 문자를 쓰지 않는다.
- 한 줄은 100자를 넘기지 않는다.
- 여는 중괄호를 새 줄에 두지 않는다 (K&R). 같은 줄 끝에 붙인다.
- if/else/for/while/do 블록에서 중괄호를 생략하지 않는다. 한 줄이어도 생략하지 않는다.
- 여러 줄에 걸친 인수 목록의 닫는 괄호 `)`를 마지막 인수 끝에 붙이지 않는다. 새 줄에 단독으로 둔다.
- 와일드카드 import를 쓰지 않는다.
- `List`/`Set`/`Map` 변수명 끝에 `~s`를 쓰지 않는다. `~List`/`~Set`/`~Map`을 붙인다.
- 컬렉션 첫 요소 조회에 `get(0)`을 쓰지 않는다. `getFirst()`를 쓴다.

## Kotlin

- 들여쓰기는 4 spaces로 한다.
- 한 줄은 100자를 넘기지 않는다.
- 세미콜론을 붙이지 않는다.
- 코루틴에서 `GlobalScope`를 쓰지 않는다. 구조화된 동시성 스코프를 쓴다.

## Spring Boot

- 문자열 공백 체크에 `== null || isEmpty()/isBlank()`를 직접 조합하지 않는다. `StringUtils.hasText()`(spring-core)를 쓴다.
- 컬렉션 null/empty 체크를 직접 조합하지 않는다. `CollectionUtils.isEmpty()`(spring-core)를 쓴다.
- DTO의 String 필드에 `@NotNull`/`@NotEmpty`를 쓰지 않는다. `@NotBlank`만 쓴다.
- Controller에서 Repository를 직접 호출하지 않는다. Service를 거친다.
- `@Transactional`을 Service 레이어 밖(Controller/Repository)에 붙이지 않는다.
- Entity를 Controller 응답으로 직접 반환하지 않는다. DTO로 변환한다.
- `@RequestBody` DTO에 `@DateTimeFormat`을 쓰지 않는다 (Jackson이 인식 못함). `@JsonFormat`을 쓴다.
- SQL/JPQL 키워드(`SELECT`, `FROM`, `WHERE` 등)를 소문자로 쓰지 않는다.

### JPA

- `@ManyToOne`/`@OneToOne`의 기본 FetchType(EAGER)을 그대로 두지 않는다. `fetch = FetchType.LAZY`를 명시한다.
- 연관 컬렉션을 반복문 안에서 접근해 지연 로딩을 N번 트리거하지 않는다. Fetch Join이나 `@EntityGraph`로 한 번에 조회한다.
- 컬렉션을 Fetch Join하면서 동시에 `Pageable`로 페이징하지 않는다 (메모리 페이징 발생). 페이징이 필요하면 `@BatchSize`나 `default_batch_fetch_size`를 쓴다.
- `spring.jpa.open-in-view`를 기본값(true)으로 두지 않는다. `false`로 명시한다.
- 조회 전용 쿼리에서 Entity 전체를 가져오지 않는다. JPQL 생성자 표현식이나 Querydsl Projection으로 필요한 필드만 조회한다.
- 조회 전용 트랜잭션에 `@Transactional(readOnly = true)`를 생략하지 않는다.
- Entity의 `equals()`/`hashCode()`를 모든 필드로 생성하지 않는다. 식별자(id) 기준으로 구현한다.
- 연관관계에 `CascadeType.ALL`을 습관적으로 붙이지 않는다. 실제 필요한 cascade 옵션만 명시한다.

## React

- 리스트 렌더링 `key`에 배열 index를 쓰지 않는다. 안정적인 고유 id를 쓴다.
- 프레임워크가 요구하는 파일(Next.js `page.tsx`/`layout.tsx` 등)을 제외하고 `default export`를 쓰지 않는다.
