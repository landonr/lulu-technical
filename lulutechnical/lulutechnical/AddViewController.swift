//
//  AddViewController.swift
//  lulutechnical
//
//  Created by Landon Rohatensky on 2023-04-11.
//

import UIKit

class AddViewController: UIViewController {
    private var viewModel: ViewModel?
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "shey"
        button.action = #selector(barButtonAction)
        button.target = self
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "name:?"
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
    private func addTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.margin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "gmnt name"
        field.borderStyle = .roundedRect
        return field
    }()
    
    private func addTextField() {
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.margin).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.margin).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    func setViewModel(_ viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "hiAdd"
        
        navigationItem.setRightBarButton(saveButton, animated: false)
        view.backgroundColor = .white
        addTitleLabel()
        addTextField()
        // Do any additional setup after loading the view.
    }
    
    @objc func barButtonAction() {
       print("Button pressed")
        Task {
            do {
                guard let item = try await viewModel?.addItem(textField.text ?? "") else {
                    return
                }
                print("save success: \(item.title)")
                navigationController?.popViewController(animated: true)
            } catch {
                print("save failed: \(error)")
            }
        }
    }
}
