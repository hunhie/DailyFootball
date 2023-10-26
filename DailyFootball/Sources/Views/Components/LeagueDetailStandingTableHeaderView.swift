//
//  LeagueDetailStandingTableHeaderView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import UIKit

final class LeagueDetailStandingTableHeaderView: UITableViewHeaderFooterView {
  
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
  
  private let sectionTitleLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    return view
  }()
  
  private let mpLabel: UILabel = {
    let view = UILabel()
    view.text = LocalizedStrings.Leagues.LeagueDetailTab.standingsHeader.mp.localizedValue
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    return view
  }()
  
  private let winLabel: UILabel = {
    let view = UILabel()
    view.text = LocalizedStrings.Leagues.LeagueDetailTab.standingsHeader.win.localizedValue
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    return view
  }()
  
  private let drawLabel: UILabel = {
    let view = UILabel()
    view.text = LocalizedStrings.Leagues.LeagueDetailTab.standingsHeader.draw.localizedValue
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    return view
  }()
  
  private let loseLabel: UILabel = {
    let view = UILabel()
    view.text = LocalizedStrings.Leagues.LeagueDetailTab.standingsHeader.lose.localizedValue
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    return view
  }()
  
  private let gdLabel: UILabel = {
    let view = UILabel()
    view.text = LocalizedStrings.Leagues.LeagueDetailTab.standingsHeader.goalDiff.localizedValue
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    return view
  }()
  
  private let pointsLabel: UILabel = {
    let view = UILabel()
    view.text = LocalizedStrings.Leagues.LeagueDetailTab.standingsHeader.points.localizedValue
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
    stackView.addArrangedSubview(sectionTitleLabel)
    stackView.addArrangedSubview(UIView())
    stackView.addArrangedSubview(mpLabel)
    stackView.addArrangedSubview(winLabel)
    stackView.addArrangedSubview(drawLabel)
    stackView.addArrangedSubview(loseLabel)
    stackView.addArrangedSubview(gdLabel)
    stackView.addArrangedSubview(pointsLabel)
    
    containerView.snp.makeConstraints { make in
      make.height.equalTo(42)
      make.horizontalEdges.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.horizontalEdges.equalToSuperview().inset(14).priority(.high)
      make.bottom.equalToSuperview()
    }
    
    mpLabel.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(23)
    }
    
    winLabel.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(23)
    }
    
    drawLabel.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(23)
    }
    
    loseLabel.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(23)
    }
    
    gdLabel.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(23)
    }
    
    pointsLabel.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(23)
    }
  }
  
  
  func configureTitleLabel(title: String) {
    sectionTitleLabel.text = title
  }
}
