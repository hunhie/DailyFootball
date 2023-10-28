//
//  MatcheTableViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import UIKit

final class MatchesTableViewController: BaseViewController {
  
  private let tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .grouped)
    view.rowHeight = 42
    view.separatorStyle = .none
    return view
  }()
  
  let fixturesRepository = FixturesRepository()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let now = Date()

    fixturesRepository.fetchData(date: now, season: 2023, ids: [61,39], timezone: "Asia/Seoul", status: nil) { [weak self] (result: Result<[FixtureTable], FixturesRepository.FixturesRepositoryError>) in
      guard let self else { return }
      switch result {
      case .success(let response):
        dump(response)
      case .failure(let error):
        dump(error)
      }
    }
    
    setBackgroundColor(with: .subBackground)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    AppearanceCheck(self)
  }
}
