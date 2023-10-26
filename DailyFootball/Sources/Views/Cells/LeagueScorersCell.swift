//
//  LeagueScorersCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import UIKit

final class LeagueScorersCell: UITableViewCell {
  
  private let containerView: UIView = {
    let view = UIView()
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
  
  private let dividerView: DividerView = {
    let view = DividerView()
    view.setBackgroundColor(backgroundColor: UIColor.appColor(for: .subBackground))
    return view
  }()
  
  private let rankLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    return view
  }()
  
  private let playerLabel: UILabel = {
    let view = UILabel()
    view.font = .monospacedDigitSystemFont(ofSize: 13 , weight: .regular)
    view.numberOfLines = 2
    return view
  }()
  
  private let goalsLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    rankLabel.text = nil
    playerLabel.text = nil
    goalsLabel.text = nil
  }
  
  func setConstraints() {
    contentView.addSubview(containerView)
    containerView.addSubview(stackView)
    containerView.addSubview(dividerView)
    stackView.addArrangedSubview(rankLabel)
    stackView.addArrangedSubview(playerLabel)
    stackView.addArrangedSubview(goalsLabel)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(14)
    }
    
    dividerView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.height.equalTo(1)
      make.leading.trailing.equalToSuperview()
    }
    
    rankLabel.snp.makeConstraints { make in
      make.width.equalTo(22)
    }
    
    goalsLabel.snp.makeConstraints { make in
      make.width.equalTo(22)
    }
  }
  
  func configureView(scorers: Scorer) {
    rankLabel.text = "\(scorers.rank)"
    playerLabel.text = "\(scorers.player.name)"
    goalsLabel.text = "\(scorers.goals)"
  }
  
  func hideRankLabel() {
    rankLabel.text = nil
  }
}
