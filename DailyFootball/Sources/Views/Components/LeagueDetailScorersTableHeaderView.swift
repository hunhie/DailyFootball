//
//  LeagueDetailScorersTableHeaderView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import UIKit

final class LeagueDetalScorersTableHeaderView: UITableViewHeaderFooterView {
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.appColor(for: .background)
    return view
  }()
  
  private let stackView: UIStackView = {
    let view = UIStackView()
    view.axis = .horizontal
    view.spacing = 8
    view.alignment = .center
    view.distribution = .fill
    return view
  }()
  
  private let rankLabel: UILabel = {
    let view = UILabel()
    view.text = LocalizedStrings.Leagues.LeagueDetailTab.scorersHeader.rank.localizedValue
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    view.sizeToFit()
    return view
  }()
  
  private let goalsLabel: UILabel = {
    let view = UILabel()
    view.text = LocalizedStrings.Leagues.LeagueDetailTab.scorersHeader.goals.localizedValue
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 11, weight: .semibold)
    return view
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    setConstaints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setConstaints() {
    contentView.addSubview(containerView)
    containerView.addSubview(stackView)
    stackView.addArrangedSubview(rankLabel)
    stackView.addArrangedSubview(UIView())
    stackView.addArrangedSubview(goalsLabel)
    
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(20)
      make.horizontalEdges.bottom.equalToSuperview()
    }
    
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(14)
    }
    
    goalsLabel.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(22)
    }
  }
}
