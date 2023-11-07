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
- Architecture: `MVVM`
- iOS: `UIKit`, `UserDefaults`
- UI: `SnapKit`
- Reactive: `RxSwift`
- Network: `Moya`, `Codable`, `REST API`
- Database: `Realm`
- Image: `Kingfisher`, `SVGKit`
- Dependency Manager: `SwiftPackageManager`
- Firebase: `Crashlytics`, `Analytics`
- Etc: `Tabman`

### 이런 기능들이 있어요
- 전 세계 1000+ 축구 리그 목록 제공
- 리그 팔로우 기능
- 리그 및 국가 검색
- 리그 구단/선수 순위 데이터 제공
- 팔로우한 리그 경기 일정 제공
- 앱 내 테마 설정

### 트러블 슈팅

#### 1. Nested Scroll 구현 시 상 하위 스크롤 뷰 간의 스크롤 전환이 부자연스러운 문제

**문제 상황**:
Dynamic HeaderView with Tab Menu UI를 구현하고자 Tabman Library를 사용하여 수직 스크롤 뷰가 중첩되는 구조를 이루었습니다. HeaderView의 높이 값을 기준으로 상 하위 스크롤 뷰 간의 스크롤이 전환되도록 하기 위해 `scrollViewDidScroll` 메서드에서 조건에 따라 각 스크롤 뷰의 `isScrollEnabled` 속성을 컨트롤하도록 구현하였습니다. 그 결과 사용자가 한 번의 스크롤 제스처로 임계 값에 도달할 경우 스크롤이 끊기는 문제 현상이 발생하였습니다. 공식 문서를 확인해보니 UIScrollView는 내부적으로 `PanGestureRecognizer`를 통해 사용자의 제스처 이벤트를 스크롤로 반영하였습니다. 따라서 중첩된 스크롤 뷰가 각각의 PanGestureRecognizer를 가지게 되므로 `isScrollEnabled` 속성을 컨트롤하는 것으로는 제스처가 이어질 수 없었습니다.

**해결**:
하나의 PanGestureRecognizer로 2개의 스크롤 뷰를 컨트롤하면 되지 않을까? 라는 아이디어로 접근하여 상 하위 스크롤 뷰의 기본 스크롤을 비활성화하고 상위 스크롤 뷰에 구현한 `CustomPanGestureRecognizer`를 통해 하위 스크롤 뷰의 `contentOffset`를 직접 조절하는 방식으로 문제를 해결하였습니다.

```Swift
final class OuterScroll: ScrollDisabledScrollView {
  weak var innerScrollView: ScrollGestureRestrictable?
  private weak var customPanGesture: CustomPanGestureRecognizer?

  ...
  
  @objc private func handlePanGesture(_ sender: CustomPanGestureRecognizer) {
    let translation = sender.translation(in: self)
    let velocity = sender.velocity(in: self)
    
    switch sender.state {
    case .began:
      scrollAnimator.stop()
      updateInitialOffsets()
      handleContentOffset(translation.y)
      
    case .changed:
      handleContentOffset(translation.y)
      
    case .cancelled, .ended:
      handleContentOffset(translation.y)
      animateScrollVelocity(translation, velocity)
      
    default:
      break
    }
  }
  
  private func handleContentOffset(_ translation: CGFloat) {
    guard let innerScrollView = innerScrollView else { return }
    
    let calculation = calculateContentOffsets(translation)
    
    contentOffset.y = calculation.outerScrollViewOffset
    innerScrollView.contentOffset.y = calculation.innerScrollViewOffset
  }
  
  private func calculateContentOffsets(_ translation: CGFloat) -> ScrollOffsets { ... }
}
```

#### 2. 다수의 비동기 API 응답을 한 번에 처리해야하는 문제

**문제 상황**:
팔로우한 리그 경기 일정 기능 구현 도중 사용자가 여러 개의 리그를 팔로우할 수 있는 반면 API는 회당 1개의 리그 데이터만 요청할 수 있었습니다. 따라서 여러 비동기 작업들이 완전히 끝난 후에 응답을 뷰 계층이 요구하는 데이터로 처리할 필요성이 있었습니다.

**해결**:
여러 스레드로 분배된 비동기 작업들의 종료 시점을 추적하기 위해 `Dispatch Group` 를 사용하여 문제를 해결하였습니다.

```Swift
private func fetchFromDB(date: Date, targetCompetitions: [(id: Int, season: Int)], completion: @escaping (Result<[CompetitionFixtureTable], FixturesRepositoryError>) -> ()) {
    let dispatchGroup = DispatchGroup()
    var retrievedTables: [CompetitionFixtureTable] = []
    var outdatedCompetitions: [(id: Int, season: Int)] = []
    
    for (id, season) in targetCompetitions {
      dispatchGroup.enter()
      
      do {
        let dateRange = try date.betweenDate()
        let data = realm.objects(CompetitionFixtureTable.self)
                        .filter("competitionId == \(id) AND date BETWEEN %@", [dateRange.start, dateRange.end])

        ...
        
        dispatchGroup.leave()
      } catch {
        //Error Handling
      }
    }
    
    dispatchGroup.notify(queue: .main) { ... }
  }
```

#### 3. API 일일 Rate Limit 초과 문제
**문제 상황**:
본 프로젝트에서 사용하는 API Football 무료 플랜의 일일 호출 제한 횟수는 100회입니다. 앱의 기획 특성 상 API 호출이 빈번하게 일어나 제한 횟수를 초과하는 경우가 잦았습니다. Rate Limit을 떠나서 서버 자원 소모를 최소화하는 것이 서비스 운영 측면에서 효과적이라고 판단하였습니다.

**시도한 아이디어**:
API와 클라이언트 사이에 캐싱 서버를 두어 클라이언트가 캐싱 서버의 데이터를 우선적으로 조회하여 API 호출량을 대폭 감소할 수 있었습니다. 그러나 이는 단지 API 호출량을 줄일 뿐 그만큼 캐싱 서버의 자원을 소모하게 되었습니다. 결과적으로 API 응답을 서버에서 캐싱하는 것은 API 이용 약관을 위배하는 행위로 간주될 수 있기에 시도에 그쳤습니다.

**해결**:
Endpoint 별 데이터 업데이트 권장 주기에 따라 응답을 로컬 DB에 일정 시간 캐싱하여 API 호출 횟수를 줄일 수 있었습니다. 또한, 로컬에 저장된 데이터는 네트워크 환경에 영향을 받지 않아 쾌적한 사용자 경험을 제공할 수 있습니다.

```Swift
public func fetchData(season: Int, id: Int, completion: @escaping (Result<List<StandingTable>, StandingsRepositoryError>) -> ()) {
  fetchFromDB(season: season, id: id) { [weak self] result in
    guard let self = self else { return }
    switch result {
    case .success(let response):
      //SUCCESS
    case .failure:
      self.fetchFromAPIAndSave(season: season, id: id) { ... }
    }
  }
}

private func fetchFromDB(season: Int, id: Int, completion: @escaping (Result<Results<StandingsTable>, StandingsRepositoryError>) -> ()) {
  let data = realm.objects(StandingsTable.self).filter("season == \(season) AND id == \(id)")

  if let latestData = data.first {
    let currentDate = Date()
    let interval = currentDate.timeIntervalSince(latestData.update)
    
    if interval > 3600 {
      completion(.failure(.realmError(.outdatedData)))
    } else {
      completion(.success(data))
    }
  }
}
```
