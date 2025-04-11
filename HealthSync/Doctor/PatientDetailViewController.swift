//
//  PatientDetailViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  PatientDetailViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore

class PatientDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let patientId: String
    private let patientName: String
    
    private var appointments = [Appointment]()
    private var prescriptions = [Prescription]()
    private var labResults = [LabTestResult]()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Appointments", "Prescriptions", "Lab Results"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
    
    init(patientId: String, patientName: String) {
        self.patientId = patientId
        self.patientName = patientName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = patientName
        
        setupEmptyLabel()
        setupSegmentedControl()
        setupTableView()
        setupActivityIndicator()
        setupFloatingButton()
        
        loadPatientData()
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "No data available"
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
        
        // Register cell types for different segments
        tableView.register(AppointmentCell.self, forCellReuseIdentifier: "AppointmentCell")
        tableView.register(PrescriptionCell.self, forCellReuseIdentifier: "PrescriptionCell")
        tableView.register(LabResultCell.self, forCellReuseIdentifier: "LabResultCell")
        
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
    
    private func setupFloatingButton() {
        view.addSubview(newPrescriptionButton)
        
        NSLayoutConstraint.activate([
            newPrescriptionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newPrescriptionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            newPrescriptionButton.widthAnchor.constraint(equalToConstant: 170),
            newPrescriptionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func segmentChanged() {
        updateEmptyLabelText()
        tableView.reloadData()
        
        // Only show the new prescription button when on the prescriptions tab
        newPrescriptionButton.isHidden = segmentedControl.selectedSegmentIndex != 1
    }
    
    private func updateEmptyLabelText() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            emptyLabel.text = "No appointments available"
            emptyLabel.isHidden = !appointments.isEmpty
        case 1:
            emptyLabel.text = "No prescriptions available"
            emptyLabel.isHidden = !prescriptions.isEmpty
        case 2:
            emptyLabel.text = "No lab results available"
            emptyLabel.isHidden = !labResults.isEmpty
        default:
            emptyLabel.text = "No data available"
        }
    }
    
    private func loadPatientData() {
        activityIndicator.startAnimating()
        
        let dispatchGroup = DispatchGroup()
        let db = Firestore.firestore()
        
        // Load appointments
        dispatchGroup.enter()
        db.collection("appointments")
            .whereField("patientId", isEqualTo: patientId)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] (snapshot, error) in
                defer { dispatchGroup.leave() }
                guard let self = self, error == nil else { return }
                
                if let documents = snapshot?.documents {
                    self.appointments = documents.compactMap { Appointment(document: $0) }
                }
            }
        
        // Load prescriptions
        dispatchGroup.enter()
        db.collection("prescriptions")
            .whereField("patientId", isEqualTo: patientId)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] (snapshot, error) in
                defer { dispatchGroup.leave() }
                guard let self = self, error == nil else { return }
                
                if let documents = snapshot?.documents {
                    self.prescriptions = documents.compactMap { Prescription(document: $0) }
                }
            }
        
        // Load lab results
        dispatchGroup.enter()
        db.collection("labResults")
            .whereField("patientId", isEqualTo: patientId)
            .order(by: "testDate", descending: true)
            .getDocuments { [weak self] (snapshot, error) in
                defer { dispatchGroup.leave() }
                guard let self = self, error == nil else { return }
                
                if let documents = snapshot?.documents {
                    self.labResults = documents.compactMap { LabTestResult(document: $0) }
                }
            }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
            self.updateEmptyLabelText()
            
            // Only show the new prescription button when on the prescriptions tab
            self.newPrescriptionButton.isHidden = self.segmentedControl.selectedSegmentIndex != 1
        }
    }
    
    @objc private func newPrescriptionTapped() {
        let newPrescriptionVC = NewPrescriptionViewController(patientId: patientId, patientName: patientName)
        navigationController?.pushViewController(newPrescriptionVC, animated: true)
    }
    
    // MARK: - UITableViewDelegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return appointments.count
        case 1:
            return prescriptions.count
        case 2:
            return labResults.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as? AppointmentCell else {
                return UITableViewCell()
            }
            cell.configure(with: appointments[indexPath.row])
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionCell", for: indexPath) as? PrescriptionCell else {
                return UITableViewCell()
            }
            cell.configure(with: prescriptions[indexPath.row])
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabResultCell", for: indexPath) as? LabResultCell else {
                return UITableViewCell()
            }
            cell.configure(with: labResults[indexPath.row])
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return 120 // Appointments
        case 1:
            return 100 // Prescriptions
        case 2:
            return 110 // Lab results
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let appointment = appointments[indexPath.row]
            let detailVC = AppointmentDetailViewController(appointment: appointment)
            navigationController?.pushViewController(detailVC, animated: true)
            
        case 1:
            let prescription = prescriptions[indexPath.row]
            let detailVC = PrescriptionDetailViewController(prescription: prescription)
            navigationController?.pushViewController(detailVC, animated: true)
            
        case 2:
            let labResult = labResults[indexPath.row]
            let detailVC = LabResultDetailViewController(labResult: labResult)
            navigationController?.pushViewController(detailVC, animated: true)
            
        default:
            break
        }
    }
}

// MARK: - PrescriptionCell
class PrescriptionCell: UITableViewCell {
    
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
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dateLabel.textColor = .darkGray
        
        medicinesLabel.font = UIFont.systemFont(ofSize: 15)
        medicinesLabel.numberOfLines = 3
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(medicinesLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        medicinesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            medicinesLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            medicinesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            medicinesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            medicinesLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with prescription: Prescription) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = "Prescribed on: \(dateFormatter.string(from: prescription.date))"
        
        // Join medicine names with commas
        let medicineNames = prescription.medicines.map { "\($0.name) (\($0.dosage))" }
        medicinesLabel.text = medicineNames.joined(separator: ", ")
    }
}

// MARK: - LabResultCell
class LabResultCell: UITableViewCell {
    
    private let testNameLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        testNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        dateLabel.font = UIFont.systemFont(ofSize: 15)
        dateLabel.textColor = .darkGray
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        contentView.addSubview(testNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(statusLabel)
        
        testNameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            testNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            testNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: testNameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with labResult: LabTestResult) {
        testNameLabel.text = labResult.labTest.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = "Test date: \(dateFormatter.string(from: labResult.testDate))"
        
        switch labResult.status {
        case .pending:
            statusLabel.text = "Status: Pending"
            statusLabel.textColor = .systemOrange
        case .completed:
            statusLabel.text = "Status: Completed"
            statusLabel.textColor = .systemGreen
        }
    }
}