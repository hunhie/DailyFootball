# Daily Football - Football Results | 앱스토어 출시

### [App Store 바로가기](https://apps.apple.com/kr/app/%EB%8D%B0%EC%9D%BC%EB%A6%AC-%ED%92%8B%EB%B3%BC-%EC%B6%95%EA%B5%AC-%EA%B2%B0%EA%B3%BC/id6469016258)

### 프로젝트 개요
- 인원: 1명
- 기간: 2023.10.02 ~ 2023.10.31

### 한 줄 소개

- 전 세계 축구 리그의 소식과 통계들을 살펴볼 수 있는 iOS 앱 서비스

### 앱 동작 미리보기

<p align="center" witdh="100%">
<img src="https://i.imgur.com/Us3xn8T.gif" width="24%">
<img src="https://i.imgur.com/UCG6qBh.gif" width="24%">
<img src="https://i.imgur.com/yeUv1m5.gif" width="24%">
<img src="https://i.imgur.com/aTp5TtC.gif" width="24%">
</p>

### 이런 기술을 사용했어요
| Category | Stack |
|:----:|:-----:|
| Architecture | `MVVM` |
| iOS | UIKit, UserDefaults|
|  UI  | `SnapKit` |
| Reactive | `RxSwift` |
|  Network  | Moya, Codable, RESTAPI |
|  Database  | Realm |
|  Image  | Kingfisher, SVGKit |
|  Dependency Manager  | SwiftPackageManager |
|  Firebase  | Crashlytics, Analytics |
|  Etc  | Tabman |

### 이런 기능들이 있어요
1. 전 세계 1000+ 축구 리그 목록 제공
2. 리그 팔로우 기능
3. 리그 및 국가 검색
4. 리그 구단/선수 순위 데이터 제공
5. 팔로우한 리그 경기 일정 제공
6. 앱 내 테마 설정

### 트러블 슈팅

#### 1. Nested Scroll 구현 시 상 하위 스크롤 뷰 간의 스크롤 전환이 부자연스러운 문제

**문제 상황**:
Dynamic HeaderView with Tab Menu UI를 구현하고자 Tabman Library를 사용하여 수직 스크롤 뷰가 중첩되는 구조를 이루었습니다. HeaderView의 높이 값을 기준으로 상 하위 스크롤 뷰 간의 스크롤이 전환되도록 하기 위해 `scrollViewDidScroll` 메서드에서 조건에 따라 각 스크롤 뷰의 `isScrollEnabled` 속성을 컨트롤하도록 구현하였습니다. 그 결과 사용자가 한 번의 스크롤 제스처로 임계 값에 도달할 경우 스크롤이 끊기는 문제 현상이 발생하였습니다. 공식 문서를 확인해보니 UIScrollView는 내부적으로 `PanGestureRecognizer`를 통해 사용자의 제스처 이벤트를 스크롤로 반영하였습니다. 따라서 중첩된 스크롤 뷰가 각각의 PanGestureRecognizer를 가지게 되므로 `isScrollEnabled` 속성을 컨트롤하는 것으로는 제스처가 이어질 수 없었습니다.

**해결**:
하나의 PanGestureRecognizer로 2개의 스크롤 뷰를 컨트롤하면 되지 않을까? 라는 아이디어로 접근하여 상 하위 스크롤 뷰의 기본 스크롤을 비활성화하고 상위 스크롤 뷰가 `CustomPanGestureRecognizer`를 통해 하위 스크롤 뷰의 `contentOffset`를 직접 조절하는 방식으로 문제를 해결하였습니다.
