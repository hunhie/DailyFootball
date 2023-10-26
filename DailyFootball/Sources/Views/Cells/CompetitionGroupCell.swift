//
//  CompetitionGroupCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import UIKit
import Kingfisher
import SnapKit

final class CompetitionGroupCell: UITableViewCell {
  
  enum ExpansionState {
    case collapsed
    case expanded
  }
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.appColor(for: .background)
    return view
  }()
  
  private lazy var logoImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFill
    view.layer.cornerRadius = 12
    view.layer.borderColor = UIColor.systemGray6.cgColor
    view.layer.borderWidth = 0.5
    view.clipsToBounds = true
    view.tintColor = .black
    return view
  }()
  
  private lazy var titleLabel: UILabel = {
    let view = UILabel()
    view.font = .systemFont(ofSize: 15, weight: .medium)
    return view
  }()
  
  private lazy var expansionArrowView: StatefulImageView = {
    let view = StatefulImageView<ExpansionState>()
    view.contentMode = .scaleToFill
    view.tintColor = UIColor.appColor(for: .accessory)
    view.setImage(UIImage(named: "chevron.down"), forState: .collapsed)
    view.setImage(UIImage(named: "chevron.up"), forState: .expanded)
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setCellUI()
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    logoImageView.image = nil
    titleLabel.text = nil
  }
  
  var tapAction: (() -> ())?
  
  var isExpanded: Bool = false {
    didSet {
      updateExpansionArrowForExpansionState(isExpanded: isExpanded)
    }
  }
  
  var competitionGroup: CompetitionGroup?
  
  private var animationWorkItem: DispatchWorkItem?
  
  public func configureView(with competitionGroup: CompetitionGroup) {
    isExpanded = competitionGroup.isExpanded
    self.competitionGroup = competitionGroup
    setLogoImage(competitionGroup)
    setTitle(competitionGroup)
  }
  
  private func setCellUI() {
    backgroundColor = UIColor.appColor(for: .subBackground)
    selectionStyle = .none
  }
  
  private func setConstraints() {
    contentView.addSubview(containerView)
    containerView.addSubview(logoImageView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(expansionArrowView)
    
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(10)
      make.horizontalEdges.equalToSuperview()
      make.bottom.equalToSuperview().offset(0)
    }
    
    logoImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(20)
      make.size.equalTo(24)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(logoImageView.snp.trailing).offset(20)
    }
    
    expansionArrowView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().offset(-20)
      make.size.equalTo(12)
    }
  }
  
  private func setLogoImage(_ data: CompetitionGroup) {
    if let imageSource = URL(string: data.logoURL) {
      logoImageView.kf.setImage(with: imageSource, options: [.processor(SVGImageProcessor()), .transition(.fade(0.7))])
    }
  }
  
  private func setTitle(_ data: CompetitionGroup) {
    titleLabel.text = data.title
  }
  
  private func updateExpansionArrowForExpansionState(isExpanded: Bool) {
    expansionArrowView.currentState = isExpanded ? .expanded : .collapsed
  }
}

