//
//  LabTestsViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  LabTestsViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class LabTestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var labTests = [LabTest]()
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lab Tests"
        view.backgroundColor = .white
        setupTableView()
        setupActivityIndicator()
        fetchLabTests()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LabTestCell.self, forCellReuseIdentifier: "LabTestCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchLabTests() {
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("labTests").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error fetching lab tests: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.showAlert(message: "No lab tests available")
                return
            }
            
            self.labTests = documents.compactMap { document -> LabTest? in
                return LabTest(document: document)
            }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labTests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabTestCell", for: indexPath) as? LabTestCell else {
            return UITableViewCell()
        }
        
        let labTest = labTests[indexPath.row]
        cell.configure(with: labTest)
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let labTest = labTests[indexPath.row]
        let detailVC = LabTestDetailViewController(labTest: labTest)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class LabTestCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        priceLabel.font = UIFont.systemFont(ofSize: 16)
        priceLabel.textColor = .systemGreen
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 2
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(descriptionLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with labTest: LabTest) {
        nameLabel.text = labTest.name
        priceLabel.text = "₹\(labTest.price)"
        descriptionLabel.text = labTest.description
    }
}
