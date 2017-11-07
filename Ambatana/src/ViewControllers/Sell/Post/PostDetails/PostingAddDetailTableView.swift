//
//  PostingAddDetailTableView.swift
//  LetGo
//
//  Created by Juan Iglesias on 10/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

protocol PostingAddDetailTableViewDelegate: class {
    func indexSelected(index: Int)
    func indexDeselected(index: Int)
    func findValueSelected() -> Int?
}


final class PostingAddDetailTableView: UIView, UITableViewDelegate, UITableViewDataSource, PostingViewConfigurable {
    
    static let cellIdentifier = "postingAddDetailCell"
    static let cellAddDetailHeight: CGFloat = 70
    static let checkMarkSize: CGSize = CGSize(width: 17, height: 12)
    
    private var detailInfo: [String]
    private let tableView = UITableView()
    private var selectedValue: IndexPath?
    weak var delegate: PostingAddDetailTableViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init(values: [String], delegate: PostingAddDetailTableViewDelegate) {
        self.detailInfo = values
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Layout
    
    private func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PostingAddDetailTableView.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = UIColor.clear
        tableView.tintColor = UIColor.white
        tableView.indicatorStyle = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.margin, right: 0)
        tableView.allowsMultipleSelection = true
    }
    
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        tableView.layout(with: self)
            .top()
            .bottom()
            .leading()
            .trailing()
        setupTableView(values: detailInfo)
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        tableView.accessibilityId = .postingAddDetailTableView
    }
    
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailInfo.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostingAddDetailTableView.cellAddDetailHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostingAddDetailTableView.cellIdentifier) else {
            return UITableViewCell()
        }
        let value = detailInfo[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = value
        cell.textLabel?.font = UIFont.selectableItem
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.grayLight
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let selectedValue = selectedValue else { return indexPath }
        deselectCell(indexPath: selectedValue)
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCell(indexPath: indexPath)
        delegate?.indexSelected(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        deselectCell(indexPath: indexPath)
    }
   
    func deselectCell(indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.textLabel?.textColor = UIColor.grayLight
        selectedValue = nil
        delegate?.indexDeselected(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func selectCell(indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let image = #imageLiteral(resourceName: "ic_checkmark").withRenderingMode(.alwaysTemplate)
        let checkmark  = UIImageView(frame:CGRect(x:0,
                                                  y:0,
                                                  width:PostingAddDetailTableView.checkMarkSize.width,
                                                  height:PostingAddDetailTableView.checkMarkSize.height))
        checkmark.image = image
        checkmark.tintColor = UIColor.white
        cell.accessoryView = checkmark
        
        cell.accessoryType = .checkmark
        cell.textLabel?.textColor = UIColor.white
        selectedValue = indexPath
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    func setupTableView(values: [String]) {
        detailInfo = values
        tableView.reloadData()
    }
    
    // MARK - PostingStepConfigurable
    
    func setupView(viewModel: PostingDetailsViewModel) {
        guard let positionSelected = viewModel.findValueSelected() else { return }
        selectCell(indexPath: IndexPath(item: positionSelected, section: 0))

    }
    
    
    func setupContainerView(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        layout(with: view).fill()
    }
    
}