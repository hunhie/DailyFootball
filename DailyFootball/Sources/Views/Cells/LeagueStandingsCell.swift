//
//  LeagueStandingsCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/24.
//

import UIKit

final class LeagueStandingsCell: UITableViewCell {
  
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
  
  private let teamLabel: UILabel = {
    let view = UILabel()
    view.font = .monospacedDigitSystemFont(ofSize: 13 , weight: .regular)
    view.numberOfLines = 2
    return view
  }()
  
  private let mpLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    return view
  }()
  
  private let winLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    return view
  }()
  
  private let drawLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    return view
  }()
  
  private let loseLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    return view
  }()
  
  private let gfgaLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    return view
  }()
  
  private let gdLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    return view
  }()
  
  private let pointsLabel: UILabel = {
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
    teamLabel.text = nil
    mpLabel.text = nil
    winLabel.text = nil
    drawLabel.text = nil
    loseLabel.text = nil
    gdLabel.text = nil
    pointsLabel.text = nil
  }
  
  func setConstraints() {
    contentView.addSubview(containerView)
    containerView.addSubview(stackView)
    containerView.addSubview(dividerView)
    stackView.addArrangedSubview(rankLabel)
    stackView.addArrangedSubview(teamLabel)
    stackView.addArrangedSubview(mpLabel)
    stackView.addArrangedSubview(winLabel)
    stackView.addArrangedSubview(drawLabel)
    stackView.addArrangedSubview(loseLabel)
    stackView.addArrangedSubview(gdLabel)
    stackView.addArrangedSubview(pointsLabel)
    
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
      make.width.equalTo(23)
    }
    
    mpLabel.snp.makeConstraints { make in
      make.width.equalTo(23)
    }
    
    winLabel.snp.makeConstraints { make in
      make.width.equalTo(23)
    }
    
    drawLabel.snp.makeConstraints { make in
      make.width.equalTo(23)
    }
    
    loseLabel.snp.makeConstraints { make in
      make.width.equalTo(23)
    }
    
    gdLabel.snp.makeConstraints { make in
      make.width.equalTo(23)
    }
    
    pointsLabel.snp.makeConstraints { make in
      make.width.equalTo(23)
    }
  }
  
  
  func configureView(standing: Standing) {
    rankLabel.text = "\(standing.rank)"
    teamLabel.text = "\(standing.team.name)"
    mpLabel.text = "\(standing.all.played)"
    winLabel.text = "\(standing.all.win)"
    drawLabel.text = "\(standing.all.draw)"
    loseLabel.text = "\(standing.all.lose)"
    gdLabel.text = "\(standing.goalsDiff)"
    pointsLabel.text = "\(standing.point)"
  }
}
