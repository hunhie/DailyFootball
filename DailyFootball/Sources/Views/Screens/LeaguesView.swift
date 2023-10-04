//
//  LeaguesView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/27.
//

import UIKit
import SnapKit

final class LeaguesView: UIView {
  
  enum Section: CaseIterable {
    case followingCompetition
    case allCompetition
  }
  
  enum Item: Hashable {
    case competition(Competition, isLast: Bool = false)
    case competitionGroup(CompetitionGroup)
  }
  
  lazy var collectionView: UICollectionView = {
    let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    view.backgroundColor = .systemGray5
    return view
  }()
  
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  private var dataSource: DataSource?
  
  var followingCompetition: [Competition] = [
    Competition(title: "Premier League", logoURL: "https://example.com/images/premier-league-logo.png"),
    Competition(title: "La Liga", logoURL: "https://example.com/images/la-liga-logo.png"),
    Competition(title: "Bundesliga", logoURL: "https://example.com/images/bundesliga-logo.png")
  ]
  
  var competitionGroups: [CompetitionGroup] = [
    CompetitionGroup(title: "England", logoURL: "https://example.com/images/england-flag.png", competitions: [
      Competition(title: "Premier League", logoURL: "https://example.com/images/premier-league-logo.png"),
      Competition(title: "EFL Championship", logoURL: "https://example.com/images/efl-championship-logo.png"),
      Competition(title: "EFL Championship", logoURL: "https://example.com/images/efl-championship-logo.png"),
      Competition(title: "EFL Championship", logoURL: "https://example.com/images/efl-championship-logo.png"),
      Competition(title: "EFL Championship", logoURL: "https://example.com/images/efl-championship-logo.png"),
    ]),
    CompetitionGroup(title: "Spain", logoURL: "https://example.com/images/spain-flag.png", competitions: [
      Competition(title: "La Liga", logoURL: "https://example.com/images/la-liga-logo.png"),
      Competition(title: "Segunda División", logoURL: "https://example.com/images/segunda-division-logo.png")
    ]),
    CompetitionGroup(title: "Germany", logoURL: "https://example.com/images/germany-flag.png", competitions: [
      Competition(title: "Bundesliga", logoURL: "https://example.com/images/bundesliga-logo.png"),
      Competition(title: "2. Bundesliga", logoURL: "https://example.com/images/2-bundesliga-logo.png")
    ])
  ]
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureView()
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureView() {
    setCollectionView()
  }
  
  func setConstraints() {
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func setCollectionView() {
    addSubview(collectionView)
    
    let followingCompetitionCellRegistration = UICollectionView.CellRegistration<FollowingCompetitionCell, Competition> { (cell, indexPath, item) in
      cell.configureView(with: item)
    }
    
    let competitionGroupCellRegistration = UICollectionView.CellRegistration<CompetitionGroupCell, CompetitionGroup> { (cell, indexPath, item) in
      cell.configureView(with: item)
      cell.tapAction = {
        if let index = self.competitionGroups.firstIndex(where: { $0.id == item.id }) {
          self.competitionGroups[index].isExpanded.toggle()
          cell.isExpended = self.competitionGroups[index].isExpanded
          self.applySnapshot()
        }
      }
    }
    
    let competitionCellRegistration = UICollectionView.CellRegistration<CompetitionCell, Competition> { (cell, indexPath, item) in
      cell.configureView(with: item)
    }
    
    dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
      switch item {
      case .competition(let competition, _) where indexPath.section == 0:
        return collectionView.dequeueConfiguredReusableCell(using: followingCompetitionCellRegistration, for: indexPath, item: competition)
      case .competition(let competition, let isLast):
        let cell = collectionView.dequeueConfiguredReusableCell(using: competitionCellRegistration, for: indexPath, item: competition)
        cell.applyRoundedCorners(isLast: isLast)
        return cell
      case .competitionGroup(let competition):
        return collectionView.dequeueConfiguredReusableCell(using: competitionGroupCellRegistration, for: indexPath, item: competition)
      }
    }
    
    applySnapshot()
  }
  
  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.followingCompetition])
    snapshot.appendItems(followingCompetition.map { Item.competition($0) }, toSection: .followingCompetition)
    snapshot.appendSections([.allCompetition])
    
    for competitionGroup in competitionGroups {
      if competitionGroup.isExpanded {
        var items = [Item.competitionGroup(competitionGroup)]
        for (index, competition) in competitionGroup.competitions.enumerated() {
          let isLast = index == competitionGroup.competitions.count - 1
          items.append(Item.competition(competition, isLast: isLast))
        }
        snapshot.appendItems(items, toSection: .allCompetition)
      } else {
        snapshot.appendItems([.competitionGroup(competitionGroup)], toSection: .allCompetition)
      }
    }
    
    dataSource?.apply(snapshot, animatingDifferences: true)
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
      switch Section.allCases[sectionIndex] {
      case .followingCompetition:
        return self.createFollowingCompetitionSection()
      case .allCompetition:
        return self.createAllCompetitionSection()
      }
    }
    return layout
  }
  
  private func createFollowingCompetitionSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    section.contentInsets = .init(top: 10, leading: 10, bottom: 0, trailing: 10)
    return section
  }
  
  private func createAllCompetitionSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 0
    section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
    return section
  }
}
