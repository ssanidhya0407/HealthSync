//
//  DoctorPrescriptionsViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  DoctorPrescriptionsViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DoctorPrescriptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var prescriptions = [Prescription]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PrescriptionTableCell.self, forCellReuseIdentifier: "PrescriptionTableCell")
        return tableView
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()
    
    private lazy var newPrescriptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New Prescription", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(newPrescriptionTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Prescriptions"
        
        setupEmptyLabel()
        setupTableView()
        setupActivityIndicator()
        setupFloatingButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPrescriptions()
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "No prescriptions available"
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
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
    
    private func setupFloatingButton() {
        view.addSubview(newPrescriptionButton)
        
        NSLayoutConstraint.activate([
            newPrescriptionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newPrescriptionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            newPrescriptionButton.widthAnchor.constraint(equalToConstant: 170),
            newPrescriptionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func fetchPrescriptions() {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "You must be logged in to view prescriptions")
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("prescriptions")
            .whereField("doctorId", isEqualTo: currentUser.uid)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showAlert(message: "Error fetching prescriptions: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.emptyLabel.isHidden = false
                    return
                }
                
                self.prescriptions = documents.compactMap { document -> Prescription? in
                    return Prescription(document: document)
                }
                
                self.emptyLabel.isHidden = !self.prescriptions.isEmpty
                self.tableView.reloadData()
            }
    }
    
    @objc private func newPrescriptionTapped() {
        // Show patient selection alert or navigate to patient list
        let patientsVC = DoctorPatientsViewController()
        navigationController?.pushViewController(patientsVC, animated: true)
    }
    
    // MARK: - UITableViewDelegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prescriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionTableCell", for: indexPath) as? PrescriptionTableCell else {
            return UITableViewCell()
        }
        
        let prescription = prescriptions[indexPath.row]
        cell.configure(with: prescription)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let prescription = prescriptions[indexPath.row]
        let detailVC = PrescriptionDetailViewController(prescription: prescription)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class PrescriptionTableCell: UITableViewCell {
    
    private let patientNameLabel = UILabel()
    private let dateLabel = UILabel()
    private let medicinesLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        patientNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        dateLabel.font = UIFont.systemFont(ofSize: 15)
        dateLabel.textColor = .darkGray
        medicinesLabel.font = UIFont.systemFont(ofSize: 14)
        medicinesLabel.textColor = .darkGray
        medicinesLabel.numberOfLines = 2
        
        contentView.addSubview(patientNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(medicinesLabel)
        
        patientNameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        medicinesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            patientNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            patientNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: patientNameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            medicinesLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            medicinesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            medicinesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            medicinesLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with prescription: Prescription) {
        patientNameLabel.text = "Patient: \(prescription.patientName)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = "Prescribed on: \(dateFormatter.string(from: prescription.date))"
        
        // Join medicine names with commas
        let medicineNames = prescription.medicines.map { "\($0.name) (\($0.dosage))" }
        medicinesLabel.text = medicineNames.joined(separator: ", ")
    }
}