//
//  FixtureGroupCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/29.
//

import UIKit
import Kingfisher
import SnapKit

final class FixtureGroupCell: UITableViewCell {
  
  enum ExpansionState {
    case collapsed
    case expanded
    case nonExpandable
  }
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.appColor(for: .background)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(tapGesture)
    return view
  }()
  
  private lazy var logoImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFill
    view.layer.cornerRadius = 7
    view.layer.borderColor = UIColor.systemGray6.cgColor
    view.layer.borderWidth = 0.5
    view.clipsToBounds = true
    view.tintColor = .black
    return view
  }()
  
  private lazy var titleLabel: UILabel = {
    let view = UILabel()
    view.font = .monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
    return view
  }()
  
  private lazy var countryCodeLabel: UILabel = {
    let view = UILabel()
    return view
  }()
  
  private lazy var expansionArrowView: StatefulImageView = {
    let view = StatefulImageView<ExpansionState>()
    view.contentMode = .scaleToFill
    view.tintColor = UIColor.appColor(for: .accessory)
    view.setImage(UIImage(named: "chevron.down"), forState: .collapsed)
    view.setImage(UIImage(named: "chevron.up"), forState: .expanded)
    view.setImage(UIImage(named: "minus"), forState: .nonExpandable)
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
  var state: ExpansionState = .collapsed {
    didSet {
      updateExpansionArrowForExpansionState(state: state)
    }
  }
  
  var fixtureGroup: FixtureGroupByCompetition?
  
  func configureView(with fixtureGroup: FixtureGroupByCompetition) {
    state = fixtureGroup.isExpanded ? .expanded : .collapsed
    self.fixtureGroup = fixtureGroup
    setLogoImage(fixtureGroup)
    setTitle(fixtureGroup)
  }
  
  private func setCellUI() {
    backgroundColor = UIColor.appColor(for: .subBackground)
    selectionStyle = .none
  }
  
  private func setConstraints() {
    contentView.addSubview(containerView)
    containerView.addSubview(logoImageView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(countryCodeLabel)
    containerView.addSubview(expansionArrowView)
    
    containerView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.horizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().offset(0)
    }
    
    logoImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(20)
      $0.size.equalTo(14)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(logoImageView.snp.trailing).offset(16)
//      $0.leading.equalToSuperview().offset(20)
    }
    
    countryCodeLabel.snp.makeConstraints {
      $0.trailing.equalTo(expansionArrowView.snp.leading).offset(-8)
      $0.centerY.equalToSuperview()
    }
    
    expansionArrowView.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-20)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(12)
    }
  }
  
  private func setLogoImage(_ fixtureGroup: FixtureGroupByCompetition) {
//    if let url = URL(string: fixtureGroup.info.logoURL) {
//      logoImageView.kf.setImage(with: url, options: [.transition(.fade(0.7))])
//    }
    dump(fixtureGroup)
    if let url = fixtureGroup.country.flagURL, let imageSource = URL(string: url) {
      logoImageView.kf.setImage(with: imageSource, options: [.processor(SVGImageProcessor())])
    } else if fixtureGroup.country.name == "World" {
      logoImageView.image = UIImage(named: "earth")
    }
  }
  
  private func setTitle(_ fixtureGroup: FixtureGroupByCompetition) {
    titleLabel.text = fixtureGroup.info.name
  }
  
  private func updateExpansionArrowForExpansionState(state: ExpansionState) {
    expansionArrowView.currentState = state
  }
  
  @objc private func cellTapped() {
    tapAction?()
  }
}
