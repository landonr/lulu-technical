//
//  ViewController.swift
//  lulutechnical
//
//  Created by Landon Rohatensky on 2023-04-11.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private let viewModel = ViewModel()
    private var tableViewCancellable: AnyCancellable?
    private var dataSource: UITableViewDiffableDataSource<Int, LuluModel>?
    static private let cellIdentifier = "luluItem"
    
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "hey"
        button.action = #selector(barButtonAction)
        button.target = self
        return button
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["hey", "hi"])
        return control
    }()
    
    lazy var tableView: UITableView = {
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
    
    func setupDatasource() {
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
    
        tableViewCancellable = viewModel.items.publisher.sink { [weak self] item in
            var snapshot = NSDiffableDataSourceSnapshot<Int, LuluModel>()
            snapshot.appendSections([0])
            snapshot.appendItems(item)
            self?.dataSource?.apply(snapshot)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "hi"
        
        navigationItem.setRightBarButton(addButton, animated: false)
        addSegmentedControl()
        addTableView()
        setupDatasource()
        // Do any additional setup after loading the view.
    }
    
    @objc func barButtonAction() {
       print("Button pressed")
    }
}
