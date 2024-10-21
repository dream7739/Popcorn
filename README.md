# Popcorn
TMDB API를 활용한 영화, 시리즈 열람할 수 있는 앱

## 프로젝트 환경
- 인원: 3인
- 기간: 24.10.08 ~ 24.10.14 (6일)
- 최소 버전: iOS 15.0+

## 협업관리

- 브랜치 전략: `Github Flow` + `develop` 브랜치를 추가한 형태로 사용
    - 각 기능은 별도의 `feature` 브랜치에서 개발되고, `develop` 브랜치에서 통합하여 테스트
    - 이로써 서로의 작업에 영향받지 않고 개발을 진행하며, 충돌 최소화 가능
    - 안정적인 `main` 브랜치 유지: 검증된 코드만 `main` 브랜치에 병합 및 항상 배포 가능한 상태 유지

- 컨벤션
    1. PR Template
    PR Template 통해 일관된 PR 형식 유지 
    2. 커밋 컨벤션
        널리 알려진 `Karma 컨벤션`을 채택
    3. 코드 컨벤션
        `swiftLint` 를 활용해 합의된 코드 컨벤션 공유
        
- 작업 분배
    1. 사용할 라이브러리 설치 및 프로젝트에 대한 구조 설정 및 폴더링 작업
    2. 공통 기능 - `Network`, `DB`, `ViewComponent`
    여러 화면에서 의존성이 존재하거나, 재사용 되는 기능 먼저 구성
    3. 구성원별 담당업무 분배
        - 김성민: DB 스키마 및 Repository 구성
        - 이승현: 네트워크 모듈화 및 오류처리
        - 홍정민: 커스텀뷰 및 공통 UI 작업
    3. 이후 작업은 `ViewController` 단위로 나누어 진행
    
- PR Flow
    1. PR 요청
    2. 코드리뷰 및 승인
    3. PR 승인
        리뷰가 완료된 PR은 `develop` 브랜치에 병합됩니다.

- Conflict 해결 과정
     - 프로젝트 파일 변경 최소화를 위해 새로운 파일 추가나 설정 변경 시 팀원들과 사전 협의 진행
    - 머지 타임 진행
    필요 시점에 `Merge time`을 지정하여 팀원들이 모여 병합 작업을 함께 수행
     > 적극적인 소통을 통한 실시간 충돌 해결 및 병합 과정에서의 생산성 향상
    - 선행과 후행 작업 고려
        서로 연관관계가 있는 선행 작업과 후행 작업을 구분하여 병합 순서 결정
     >  중요한 기능이나 공통 모듈은 우선적으로 병합하고 이에 의존하는 기능들을 그 이후에 병합하여 충돌 방지


## 기술 스택

| 분야               | 기술 스택                                  |
|--------------------|-------------------------------------------|
| 🏛️ Architecture     | `MVVM`<br>`+ Input & Output 패턴`         |
| ♻️ 비동기            | `RxSwift`                                 |
| 📡 네트워킹          | `Alamofire`<br>`+ Router 패턴`            |
| 📦 DB              | `RealmSwift`<br>`+ Repository 패턴`        |
| 🎨 UI              | `UIKit`<br>`SnapKit`<br>`Kingfisher`       |
| 📝 Code Convention | `SwiftLint`                               |
| 🎸 기타             | `WebKit`<br>`Then`                        |

## 핵심 기능
- 인기영화&시리즈 살펴보기
    - RxDataSources를 활용한 다중 섹션 컬렉션뷰 구성
 - 영화&시리즈 실시간 검색 및 추천 컨텐츠 제공
     - RxSwift의 오퍼레이터를 활용한 API 과호출 방지
  - 영화&시리즈 상세정보 제공 및 비슷한 컨텐츠 추천
  - 영화&시리즈 예고편 재생
      - WebKit을 사용한 유투브 플레이어 재생
  - 영화&시리즈 즐겨찾기
      - Realm Database + FileManager 로 로컬에 영화정보 저장

## 주요 기술
- DTO를 통한 API 모델과 Presentation 모델의 분리
- RxDataSources와 CompositionalLayout을 활용해 멀티 섹션 컬렉션 뷰 대응
- Realm Database 접근 시 Repository 패턴을 사용하여 콘텐츠 정보 로컬 저장
- 포스터 이미지 로컬 저장을 위해 FileManager 사용
- jpegData 메서드를 통한 이미지 압축 및 용량 최적화
- RxSwift의 debounce와 distinctUntilChanged를 활용한 API 과호출 방지
- 타입으로써의 protocol과 extension을 사용한 UIView의 identifier 관리
- Protocol을 사용해 ViewModel의 `Input-Output` 구조화
- String Catalog와 String Extension을 활용한 다국어 대응 (영어, 한국어)
- RxNotification을 통한 데이터 변경 실시간 감지 및 UI 업데이트
- Single 타입과 제네릭을 사용한 네트워크 추상화 및 재사용성 향상


## 트러블 슈팅
  ### RxDataSources로 여러 섹션을 대응하는 문제
 - sectionProvider를 통해 sectionIndex에 따른 분기 처리
 - AnimatableSectionModel 타입의 섹션 모델 생성
 - RxCollectionViewSectionedAnimatedDataSource를 구성해 Data Binding
 - "At least 1 subitem is required for a group" 에러 발생
```
let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [])
```
 - 셀 없이 헤더만 사용하기 위해 subitems가 없는 NSCollectionLayoutGroup을 사용한 것이 문제가 됨
 - heightDimension을 0.01로 설정한 NSCollectionLayoutItem을 subitems에 추가해줌으로써 해결
 
 
 
## 회고
 
 ### 협업에서의 아쉬움
 1. 네비게이션 방식에 대한 의사소통 부재
 사전에 공통화면에 대한 화면전환을 통일하지 않아 화면이 되지 않는 오류 발생. 화면전환 같은 부분들도 사전합의를 통해 수정사항을 줄일 수 있다는 점을 깨달음
 2. Realm 모델에 대한 공통합의 부족
프로젝트 중에 Realm 모델에 변경점이 발생. 관련된 로직을 모두 수정하고 Conflict를 해결하는 과정에서 초반 모델 설계의 중요성을 깨달음

### 프로젝트에서의 아쉬움
- FileManager 사용 시 오류 처리에 대한 부분의 핸들링이 되어있지 않아 아쉬움. 추후 에러 핸들링에 대한 부분이 개선되었으면 좋겠음
