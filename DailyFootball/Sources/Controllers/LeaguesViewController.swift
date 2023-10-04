//
//  LeaguesViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/27.
//

import UIKit
import SnapKit

final class LeaguesViewController: BaseViewController {
  
  let leagueView = LeaguesView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    leagueView.collectionView.delegate = self
    setupNavigation()
    fetchData()
  }
  
  override func loadView() {
    view = leagueView
  }
  
  func fetchData() {
    let apiManager = APIFootballManager()
    apiManager.request(.leagues) { (result: Result<APIResponseLeagues, APIFootballError>) in
      switch result {
      case .success(let response):
        response.response.forEach{ dump($0.league.name) }
      case .failure(let error):
        switch error {
        case .noData:
          print("응답 데이터 없음")
        case .timeout:
          print("시간 초과")
        case .serverError:
          print("API 서버 에러")
        case .decodingError:
          print("디코딩 실패")
        case .unknown:
          print("알 수 없는 오류")
        }
      }
    }
  }
  
  func setupNavigation() {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchController.searchBar.placeholder = LocalizedStrings.TabBar.Leagues.searchbarPlaceholder.localizedValue
    searchController.searchResultsUpdater = self
    
    self.navigationItem.searchController = searchController
    self.navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
    self.navigationItem.hidesSearchBarWhenScrolling = false
    self.navigationItem.title = LocalizedStrings.TabBar.Leagues.title.localizedValue
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController?.navigationBar.backgroundColor = .white
    
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.backgroundColor = .systemBackground

    navigationItem.scrollEdgeAppearance = navigationBarAppearance
    navigationItem.standardAppearance = navigationBarAppearance
    navigationItem.compactAppearance = navigationBarAppearance
    
  }
}

extension LeaguesViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
//    dump(searchController.searchBar.text)
  }
}

extension LeaguesViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? CompetitionGroupCell else { return }
    cell.tapAction?()
  }
}
