//
//  DoctorsViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  DoctorsViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore

class DoctorsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private var doctors = [Doctor]()
    private var filteredDoctors = [Doctor]()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Find Doctor"
        view.backgroundColor = .white
        setupSearchBar()
        setupTableView()
        setupActivityIndicator()
        fetchDoctors()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search by name or specialization"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DoctorCell.self, forCellReuseIdentifier: "DoctorCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
    
    private func fetchDoctors() {
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("doctors").whereField("isActive", isEqualTo: true).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error fetching doctors: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.showAlert(message: "No doctors available")
                return
            }
            
            self.doctors = documents.compactMap { document -> Doctor? in
                return Doctor(document: document)
            }
            
            self.filteredDoctors = self.doctors
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredDoctors = doctors
        } else {
            filteredDoctors = doctors.filter { doctor in
                return doctor.name.lowercased().contains(searchText.lowercased()) ||
                    doctor.specialization.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDoctors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCell", for: indexPath) as? DoctorCell else {
            return UITableViewCell()
        }
        
        let doctor = filteredDoctors[indexPath.row]
        cell.configure(with: doctor)
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let doctor = filteredDoctors[indexPath.row]
        let detailVC = DoctorDetailViewController(doctor: doctor)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class DoctorCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let specializationLabel = UILabel()
    private let ratingLabel = UILabel()
    private let availabilityLabel = UILabel()
    private let experienceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        specializationLabel.font = UIFont.systemFont(ofSize: 16)
        specializationLabel.textColor = .systemBlue
        ratingLabel.font = UIFont.systemFont(ofSize: 14)
        ratingLabel.textColor = .darkGray
        availabilityLabel.font = UIFont.systemFont(ofSize: 14)
        availabilityLabel.textColor = .darkGray
        experienceLabel.font = UIFont.systemFont(ofSize: 14)
        experienceLabel.textColor = .darkGray
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(specializationLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(availabilityLabel)
        contentView.addSubview(experienceLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        specializationLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        availabilityLabel.translatesAutoresizingMaskIntoConstraints = false
        experienceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            specializationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            specializationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            specializationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ratingLabel.topAnchor.constraint(equalTo: specializationLabel.bottomAnchor, constant: 5),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            availabilityLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 5),
            availabilityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            availabilityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            experienceLabel.topAnchor.constraint(equalTo: availabilityLabel.bottomAnchor, constant: 5),
            experienceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            experienceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            experienceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with doctor: Doctor) {
        nameLabel.text = "Dr. \(doctor.name)"
        specializationLabel.text = doctor.specialization
        
        // Display rating with stars
        let filledStars = Int(doctor.avgRating)
        let halfStar = doctor.avgRating.truncatingRemainder(dividingBy: 1) >= 0.5
        var ratingText = ""
        for _ in 0..<filledStars {
            ratingText += "★"
        }
        if halfStar {
            ratingText += "½"
        }
        for _ in 0..<(5 - filledStars - (halfStar ? 1 : 0)) {
            ratingText += "☆"
        }
        ratingLabel.text = "\(ratingText) (\(doctor.avgRating)/5)"
        
        availabilityLabel.text = "Available: \(doctor.availability)"
        experienceLabel.text = "Patients: \(doctor.totalPatients)"
    }
}