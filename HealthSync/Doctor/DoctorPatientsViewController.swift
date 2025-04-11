//
//  DoctorPatientsViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  DoctorPatientsViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DoctorPatientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private struct PatientInfo {
        let id: String
        let name: String
        let email: String
        let appointmentCount: Int
    }
    
    private var patients = [PatientInfo]()
    private var filteredPatients = [PatientInfo]()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search by patient name"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PatientCell.self, forCellReuseIdentifier: "PatientCell")
        return tableView
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "My Patients"
        
        setupEmptyLabel()
        setupSearchBar()
        setupTableView()
        setupActivityIndicator()
        fetchPatients()
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "No patients found"
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
    
    private func setupSearchBar() {
        searchBar.delegate = self
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
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
    
    private func fetchPatients() {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "You must be logged in to view patients")
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        
        // Get all appointments for this doctor
        db.collection("appointments")
            .whereField("doctorId", isEqualTo: currentUser.uid)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(message: "Error fetching patients: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.activityIndicator.stopAnimating()
                    self.emptyLabel.isHidden = false
                    return
                }
                
                // Group appointments by patientId and count them
                var patientAppointmentCounts = [String: Int]()
                var patientIds = Set<String>()
                
                for document in documents {
                    if let patientId = document.data()["patientId"] as? String {
                        patientIds.insert(patientId)
                        patientAppointmentCounts[patientId, default: 0] += 1
                    }
                }
                
                // Fetch patient details for each patientId
                let dispatchGroup = DispatchGroup()
                var patientInfos = [PatientInfo]()
                
                for patientId in patientIds {
                    dispatchGroup.enter()
                    
                    db.collection("users").document(patientId).getDocument { (document, error) in
                        defer { dispatchGroup.leave() }
                        
                        if let document = document, document.exists,
                           let name = document.data()?["name"] as? String,
                           let email = document.data()?["email"] as? String {
                            let appointmentCount = patientAppointmentCounts[patientId] ?? 0
                            let patientInfo = PatientInfo(id: patientId, name: name, email: email, appointmentCount: appointmentCount)
                            patientInfos.append(patientInfo)
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.activityIndicator.stopAnimating()
                    
                    if patientInfos.isEmpty {
                        self.emptyLabel.isHidden = false
                        return
                    }
                    
                    self.emptyLabel.isHidden = true
                    self.patients = patientInfos.sorted { $0.name < $1.name }
                    self.filteredPatients = self.patients
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredPatients = patients
        } else {
            filteredPatients = patients.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        tableView.reloadData()
        emptyLabel.isHidden = !filteredPatients.isEmpty
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDelegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPatients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as? PatientCell else {
            return UITableViewCell()
        }
        
        let patient = filteredPatients[indexPath.row]
        cell.configure(with: patient.name, email: patient.email, appointmentCount: patient.appointmentCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let patient = filteredPatients[indexPath.row]
        let detailVC = PatientDetailViewController(patientId: patient.id, patientName: patient.name)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class PatientCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let appointmentCountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        emailLabel.font = UIFont.systemFont(ofSize: 15)
        emailLabel.textColor = .darkGray
        appointmentCountLabel.font = UIFont.systemFont(ofSize: 14)
        appointmentCountLabel.textColor = .systemBlue
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(appointmentCountLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        appointmentCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            appointmentCountLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            appointmentCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            appointmentCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            appointmentCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with name: String, email: String, appointmentCount: Int) {
        nameLabel.text = name
        emailLabel.text = email
        appointmentCountLabel.text = "Total appointments: \(appointmentCount)"
    }
}