//
//  LeaguesTableViewHeaderView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/10.
//

import UIKit
import SnapKit

final class LeaguesTableViewHeaderView: UITableViewHeaderFooterView {
  
  enum EditButtonState {
    case done
    case editing
  }
  
  private lazy var containerView: UIView = {
    let view = UIView()
    return view
  }()
  
  private lazy var titleLabel: UILabel = {
    let view = UILabel()
    view.textColor = .black
    view.font = .systemFont(ofSize: 18, weight: .bold)
    return view
  }()
  
  private lazy var editButton: StatefulButton = {
    var config = UIButton.Configuration.plain()
    config.contentInsets = .zero
    let view = StatefulButton<EditButtonState>(config: config)
    
    var doneAttrString = AttributedString.init("편집")
    doneAttrString.font = .systemFont(ofSize: 17, weight: .regular)
    
    var editingAttrString = AttributedString.init("완료")
    editingAttrString.font = .systemFont(ofSize: 17, weight: .regular)
    
    view.setAttributedTitleWithColor(doneAttrString, .systemBlue, forState: .done)
    view.setAttributedTitleWithColor(editingAttrString, .systemBlue, forState: .editing)
    view.currentState = .done
    
    view.isHidden = true
    view.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    return view
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    contentView.backgroundColor = .systemGray5
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  weak var delegate: TableViewEditableDelegate?
  
  var isEdit: Bool = false {
    didSet {
      setEditButton(isEdit)
    }
  }
  
  private func setConstraints() {
    contentView.addSubview(containerView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(editButton)
    
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.horizontalEdges.equalToSuperview()
      make.bottom.equalToSuperview().priority(999)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.centerY.equalToSuperview()
    }
    
    editButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-20)
      make.centerY.equalToSuperview()
    }
  }
  
  func setHeaderTitle(title: String) {
    self.titleLabel.text = title
  }
  
  func showEditButton(_ show: Bool) {
    editButton.isHidden = !show
  }
  
  func setVisibility(isHidden: Bool) {
    self.containerView.isHidden = isHidden
    self.contentView.subviews.forEach {
      $0.isHidden = isHidden
    }
  }
  
  private func setEditButton(_ isEdit: Bool) {
    editButton.currentState = isEdit ? .editing : .done
  }
  
  @objc private func editButtonTapped() {
    isEdit.toggle()
    delegate?.didTapEditButton(isEdit)
  }
}
