//
//  MoreViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/27.
//

import UIKit
import MessageUI
import WebKit

final class MoreViewController: BaseViewController {
  
  private let tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .grouped)
    view.rowHeight = 52
    view.separatorStyle = .singleLine
    view.register(MoreCell.self, forCellReuseIdentifier: MoreCell.identifier)
    return view
  }()
  
  private lazy var darkThemeSwitch: UISwitch = {
    let view = UISwitch(frame: .zero)
    let isDarkTheme = UserDefaults.standard.bool(forKey: "isDarkTheme")
    view.setOn(isDarkTheme, animated: true)
    view.onTintColor = UIColor.appColor(for: .accentColor)
    view.addTarget(self, action: #selector(themeSwitchToggled(_:)), for: .valueChanged)
    return view
  }()
  
  private typealias DataSource = UITableViewDiffableDataSource<Section, Item>
  private var datasource: DataSource?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigation()
    setBackgroundColor(with: .subBackground)
    setConstaints()
    setupTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    AppearanceCheck(self)
  }
  
  func setupNavigation() {
    self.navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
    self.navigationItem.hidesSearchBarWhenScrolling = false
    self.navigationItem.title = LocalizedStrings.TabBar.More.title.localizedValue
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController?.navigationBar.backgroundColor = UIColor.appColor(for: .background)
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.configureWithOpaqueBackground()
    navigationBarAppearance.backgroundColor = UIColor.appColor(for: .background)
    
    navigationItem.scrollEdgeAppearance = navigationBarAppearance
    navigationItem.standardAppearance = navigationBarAppearance
    navigationItem.compactAppearance = navigationBarAppearance
  }
  
  func setConstaints() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      make.horizontalEdges.bottom.equalToSuperview()
    }
  }
  
  func setupTableView() {
    tableView.delegate = self
    setDatasource()
    applySnapshot()
  }
  
  func setDatasource() {
    datasource = DataSource(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, item -> UITableViewCell? in
      guard let self else { return nil }
      guard let cell = tableView.dequeueReusableCell(withIdentifier: MoreCell.identifier, for: indexPath) as? MoreCell else { return nil }
      switch item {
      case .theme(let title):
        cell.textLabel?.text = title
        cell.accessoryView = darkThemeSwitch
      case .support(let title):
        cell.textLabel?.text = title
        cell.accessoryType = .disclosureIndicator
        cell.tapAction = { [weak self] in
          guard let self else { return }
          if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["huny98.dev@gmail.com"])
            mail.setMessageBody("<p>문의 내용을 작성해주세요.</p>", isHTML: true)
            
            present(mail, animated: true)
          } else {
            let alert = UIAlertController(title: "메일 전송 실패", message: "이메일이 설정되어 있지 않습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            self.present(alert, animated: true)
          }
        }
      case .lisence(let title):
        cell.textLabel?.text = title
        cell.accessoryType = .disclosureIndicator
        cell.tapAction = {
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
      case .privacy(let title):
        cell.textLabel?.text = title
        cell.accessoryType = .disclosureIndicator
        cell.tapAction = {
          guard let url = URL(string: "https://walkerhilla.notion.site/Daily-Football-ff20b36e46e44524aa4b89f4f670aa65?pvs=4") else { return }
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
        }
      case .version(let title):
        cell.textLabel?.text = title
        cell.accessoryView = {
          let label = UILabel()
          label.text = Utils.getAppVersion()
          label.textColor = UIColor.appColor(for: .accessory)
          label.font = UIFont.systemFont(ofSize: 14)
          label.sizeToFit()
          return label
        }()
      }
      return cell
    })
  }
  
  func applySnapshot() {
    guard let datasource else { return }
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.system, .support, .info])
    snapshot.appendItems([.theme(LocalizedStrings.More.SettingItem.theme.localizedValue)], toSection: .system)
    snapshot.appendItems([.support(LocalizedStrings.More.SettingItem.contact.localizedValue)], toSection: .support)
    snapshot.appendItems(
      [
        .privacy(LocalizedStrings.More.SettingItem.privacy.localizedValue),
        .lisence(LocalizedStrings.More.SettingItem.license.localizedValue),
        .version(LocalizedStrings.More.SettingItem.version.localizedValue)
      ], toSection: .info)
    
    datasource.apply(snapshot, animatingDifferences: true)
  }
  
  @objc func themeSwitchToggled(_ sender: UISwitch) {
    if sender.isOn {
      ThemeManager.shared.currentTheme = .dark
    } else {
      ThemeManager.shared.currentTheme = .light
    }
    self.viewWillAppear(true)
  }
}

extension MoreViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
}

extension MoreViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = MoreTableHeaderView()
    let title = LocalizedStrings.More.SettingSection.allCases[safe: section]?.localizedValue ?? ""
    header.configureTitle(title)
    return header
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    32
  }
}

extension MoreViewController {
  enum Section: Hashable {
    case system
    case support
    case info
  }
  
  enum Item: Hashable {
    case theme(String)
    case support(String)
    case lisence(String)
    case privacy(String)
    case version(String)
  }
}
