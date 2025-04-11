//
//  MedicinesViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  MedicinesViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore

class MedicinesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    private var medicines = [Medicine]()
    private var filteredMedicines = [Medicine]()
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Medicines"
        view.backgroundColor = .white
        setupTableView()
        setupSearchController()
        setupActivityIndicator()
        fetchMedicines()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MedicineCell.self, forCellReuseIdentifier: "MedicineCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Medicines"
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
    
    private func fetchMedicines() {
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("medicines").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error fetching medicines: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.showAlert(message: "No medicines available")
                return
            }
            
            self.medicines = documents.compactMap { document -> Medicine? in
                return Medicine(document: document)
            }
            
            self.filteredMedicines = self.medicines
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredMedicines = medicines.filter { medicine in
                return medicine.name.lowercased().contains(searchText.lowercased()) ||
                    (medicine.manufacturer?.lowercased().contains(searchText.lowercased()) ?? false) ||
                    (medicine.category?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        } else {
            filteredMedicines = medicines
        }
        tableView.reloadData()
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMedicines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineCell", for: indexPath) as? MedicineCell else {
            return UITableViewCell()
        }
        
        let medicine = filteredMedicines[indexPath.row]
        cell.configure(with: medicine)
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let medicine = filteredMedicines[indexPath.row]
        let detailVC = MedicineDetailViewController(medicine: medicine)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class MedicineCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let manufacturerLabel = UILabel()
    private let stockLabel = UILabel()
    
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
        descriptionLabel.numberOfLines = 1
        manufacturerLabel.font = UIFont.systemFont(ofSize: 14)
        manufacturerLabel.textColor = .gray
        stockLabel.font = UIFont.systemFont(ofSize: 13)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(manufacturerLabel)
        contentView.addSubview(stockLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        manufacturerLabel.translatesAutoresizingMaskIntoConstraints = false
        stockLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            manufacturerLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            manufacturerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            manufacturerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            stockLabel.topAnchor.constraint(equalTo: manufacturerLabel.bottomAnchor, constant: 5),
            stockLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stockLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stockLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with medicine: Medicine) {
        nameLabel.text = medicine.name
        priceLabel.text = "₹\(medicine.price)"
        descriptionLabel.text = medicine.description
        
        if let manufacturer = medicine.manufacturer {
            manufacturerLabel.text = "By: \(manufacturer)"
        } else {
            manufacturerLabel.text = ""
        }
        
        stockLabel.text = medicine.inStock ? "✅ In Stock" : "❌ Out of Stock"
        stockLabel.textColor = medicine.inStock ? .systemGreen : .systemRed
    }
}