//
//  ViewController.swift
//  lulutechnical
//
//  Created by Landon Rohatensky on 2023-04-11.
//

import UIKit
import Combine
import Foundation

class ViewController: UIViewController {
    enum ItemSection: Hashable {
        case main
    }
    
    private let viewModel = ViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private var dataSource: UITableViewDiffableDataSource<ItemSection, LuluModel>?
    static private let cellIdentifier = "luluItem"
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(barButtonAction))
        return button
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: SortOrder.allCases.map { $0.localizedName })
        return control
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private func addSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    private func addTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    fileprivate func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            var cell : UITableViewCell!
            cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: ViewController.cellIdentifier)
            }
            var content = cell.defaultContentConfiguration()
            content.text = itemIdentifier.title
            cell.contentConfiguration = content
            return cell
        })
        
        viewModel.items
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                print("done)")
            }, receiveValue: { [weak self] model in
                var snapshot = NSDiffableDataSourceSnapshot<ItemSection, LuluModel>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model)
                self?.dataSource?.apply(snapshot)
            }).store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("list", comment: "")
        
        navigationItem.setRightBarButton(addButton, animated: false)
        addSegmentedControl()
        addTableView()
        setupDataSource()
        viewModel.sortOrder
            .receive(on: RunLoop.main).sink { [weak segmentedControl] order in
                switch order {
                case .alphabetical:
                    segmentedControl?.selectedSegmentIndex = 0
                case .date:
                    segmentedControl?.selectedSegmentIndex = 1
                }
            }.store(in: &cancellables)
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func barButtonAction() {
        let addViewController = AddViewController()
        addViewController.setViewModel(viewModel)
        DispatchQueue.main.async { [weak navigationController] in
            navigationController?.pushViewController(addViewController, animated: true)
        }
    }

    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.sortOrder.send(.alphabetical)
        case 1:
            viewModel.sortOrder.send(.date)
        default:
            break;
        }
    }
}
