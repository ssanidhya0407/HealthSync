//
//  DoctorLabResultsViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  DoctorLabResultsViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DoctorLabResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var labResults = [LabTestResult]()
    private var filteredResults = [LabTestResult]()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Pending", "Completed", "All"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LabResultCell.self, forCellReuseIdentifier: "LabResultCell")
        return tableView
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Lab Results"
        
        setupEmptyLabel()
        setupSegmentedControl()
        setupTableView()
        setupActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLabResults()
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "No lab results found"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .darkGray
        emptyLabel.font = UIFont.systemFont(ofSize: 18)
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
    
    @objc private func segmentChanged() {
        filterResults()
    }
    
    private func fetchLabResults() {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "You must be logged in to view lab results")
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("labResults")
            .whereField("doctorId", isEqualTo: currentUser.uid)
            .order(by: "testDate", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showAlert(message: "Error fetching lab results: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.emptyLabel.isHidden = false
                    return
                }
                
                self.labResults = documents.compactMap { document -> LabTestResult? in
                    return LabTestResult(document: document)
                }
                
                self.filterResults()
            }
    }
    
    private func filterResults() {
        let segmentIndex = segmentedControl.selectedSegmentIndex
        
        switch segmentIndex {
        case 0: // Pending
            filteredResults = labResults.filter { $0.status == .pending }
        case 1: // Completed
            filteredResults = labResults.filter { $0.status == .completed }
        case 2: // All
            filteredResults = labResults
        default:
            filteredResults = labResults
        }
        
        tableView.reloadData()
        emptyLabel.isHidden = !filteredResults.isEmpty
    }
    
    // MARK: - UITableViewDelegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabResultCell", for: indexPath) as? LabResultCell else {
            return UITableViewCell()
        }
        
        let labResult = filteredResults[indexPath.row]
        cell.configure(with: labResult)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let labResult = filteredResults[indexPath.row]
        let detailVC = LabResultDetailViewController(labResult: labResult)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}