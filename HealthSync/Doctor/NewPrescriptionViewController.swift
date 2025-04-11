//
//  NewPrescriptionViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  NewPrescriptionViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewPrescriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let patientId: String
    private let patientName: String
    
    private var medicines = [PrescriptionMedicineItem]()
    
    private struct PrescriptionMedicineItem {
        var name: String
        var dosage: String
        var frequency: String
        var duration: String
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "New Prescription"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patientLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Instructions:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionsTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let medicinesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Medicines:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addMedicineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Medicine", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addMedicineTapped), for: .touchUpInside)
        return button
    }()
    
    private let medicinesTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var medicinesTableViewHeightConstraint: NSLayoutConstraint?
    
    private let savePrescriptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Prescription", for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(savePrescriptionTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
        title = "New Prescription"
        
        setupTableView()
        setupViews()
        setupActivityIndicator()
        setupTapGesture()
        updateMedicinesTableView()
        
        patientLabel.text = "For: \(patientName)"
    }
    
    private func setupTableView() {
        medicinesTableView.delegate = self
        medicinesTableView.dataSource = self
        medicinesTableView.register(MedicineItemCell.self, forCellReuseIdentifier: "MedicineItemCell")
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(patientLabel)
        contentView.addSubview(instructionsTitleLabel)
        contentView.addSubview(instructionsTextView)
        contentView.addSubview(medicinesTitleLabel)
        contentView.addSubview(addMedicineButton)
        contentView.addSubview(medicinesTableView)
        contentView.addSubview(savePrescriptionButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            patientLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            patientLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            instructionsTitleLabel.topAnchor.constraint(equalTo: patientLabel.bottomAnchor, constant: 20),
            instructionsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            instructionsTextView.topAnchor.constraint(equalTo: instructionsTitleLabel.bottomAnchor, constant: 10),
            instructionsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            instructionsTextView.heightAnchor.constraint(equalToConstant: 100),
            
            medicinesTitleLabel.topAnchor.constraint(equalTo: instructionsTextView.bottomAnchor, constant: 20),
            medicinesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            addMedicineButton.centerYAnchor.constraint(equalTo: medicinesTitleLabel.centerYAnchor),
            addMedicineButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addMedicineButton.widthAnchor.constraint(equalToConstant: 120),
            addMedicineButton.heightAnchor.constraint(equalToConstant: 36),
            
            medicinesTableView.topAnchor.constraint(equalTo: medicinesTitleLabel.bottomAnchor, constant: 10),
            medicinesTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            medicinesTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            savePrescriptionButton.topAnchor.constraint(equalTo: medicinesTableView.bottomAnchor, constant: 30),
            savePrescriptionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            savePrescriptionButton.widthAnchor.constraint(equalToConstant: 200),
            savePrescriptionButton.heightAnchor.constraint(equalToConstant: 50),
            savePrescriptionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        // Dynamic table height
        medicinesTableViewHeightConstraint = medicinesTableView.heightAnchor.constraint(equalToConstant: 0)
        medicinesTableViewHeightConstraint?.isActive = true
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
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func updateMedicinesTableView() {
        medicinesTableViewHeightConstraint?.constant = CGFloat(medicines.count * 110)
        medicinesTableView.reloadData()
    }
    
    @objc private func addMedicineTapped() {
        let alert = UIAlertController(title: "Add Medicine", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Medicine Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Dosage (e.g., 500mg)"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Frequency (e.g., twice daily)"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Duration (e.g., 7 days)"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let nameField = alert?.textFields?[0],
                  let dosageField = alert?.textFields?[1],
                  let frequencyField = alert?.textFields?[2],
                  let durationField = alert?.textFields?[3],
                  let name = nameField.text, !name.isEmpty,
                  let dosage = dosageField.text, !dosage.isEmpty,
                  let frequency = frequencyField.text, !frequency.isEmpty,
                  let duration = durationField.text, !duration.isEmpty else {
                self?.showAlert(message: "Please fill in all fields")
                return
            }
            
            let medicine = PrescriptionMedicineItem(
                name: name,
                dosage: dosage,
                frequency: frequency,
                duration: duration
            )
            
            self.medicines.append(medicine)
            self.updateMedicinesTableView()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func savePrescriptionTapped() {
        guard let instructions = instructionsTextView.text, !instructions.isEmpty else {
            showAlert(message: "Please provide instructions")
            return
        }
        
        guard !medicines.isEmpty else {
            showAlert(message: "Please add at least one medicine")
            return
        }
        
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "You must be logged in to create prescriptions")
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        
        // Get doctor's name
        db.collection("doctors").document(currentUser.uid).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "Error: \(error.localizedDescription)")
                return
            }
            
            let doctorName = document?.data()?["name"] as? String ?? "Dr. Unknown"
            
            // Create the prescription object
            let prescriptionId = UUID().uuidString
            let medicinesData = self.medicines.map { medicine -> [String: String] in
                return [
                    "name": medicine.name,
                    "dosage": medicine.dosage,
                    "frequency": medicine.frequency,
                    "duration": medicine.duration
                ]
            }
            
            let prescriptionData: [String: Any] = [
                "id": prescriptionId,
                "patientId": self.patientId,
                "patientName": self.patientName,
                "doctorId": currentUser.uid,
                "doctorName": doctorName,
                "date": Timestamp(date: Date()),
                "instructions": instructions,
                "medicines": medicinesData
            ]
            
            // Save the prescription
            db.collection("prescriptions").document(prescriptionId).setData(prescriptionData) { error in
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showAlert(message: "Error saving prescription: \(error.localizedDescription)")
                    return
                }
                
                self.showAlert(message: "Prescription saved successfully", isSuccess: true) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineItemCell", for: indexPath) as? MedicineItemCell else {
            return UITableViewCell()
        }
        
        let medicine = medicines[indexPath.row]
        cell.configure(with: medicine.name, dosage: medicine.dosage, frequency: medicine.frequency, duration: medicine.duration)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    private func showAlert(message: String, isSuccess: Bool = false, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: isSuccess ? "Success" : "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - MedicineItemCellDelegate
extension NewPrescriptionViewController: MedicineItemCellDelegate {
    func didTapDelete(at cell: MedicineItemCell) {
        guard let indexPath = medicinesTableView.indexPath(for: cell) else { return }
        medicines.remove(at: indexPath.row)
        updateMedicinesTableView()
    }
}

protocol MedicineItemCellDelegate: AnyObject {
    func didTapDelete(at cell: MedicineItemCell)
}

class MedicineItemCell: UITableViewCell {
    
    weak var delegate: MedicineItemCellDelegate?
    
    private let nameLabel = UILabel()
    private let dosageLabel = UILabel()
    private let frequencyLabel = UILabel()
    private let durationLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dosageLabel.font = UIFont.systemFont(ofSize: 14)
        frequencyLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(dosageLabel)
        contentView.addSubview(frequencyLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(deleteButton)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dosageLabel.translatesAutoresizingMaskIntoConstraints = false
        frequencyLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            
            dosageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            dosageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            dosageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            frequencyLabel.topAnchor.constraint(equalTo: dosageLabel.bottomAnchor, constant: 5),
            frequencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            frequencyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            durationLabel.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor, constant: 5),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            durationLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            deleteButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(with name: String, dosage: String, frequency: String, duration: String) {
        nameLabel.text = name
        dosageLabel.text = "Dosage: \(dosage)"
        frequencyLabel.text = "Frequency: \(frequency)"
        durationLabel.text = "Duration: \(duration)"
    }
    
    @objc private func deleteTapped() {
        delegate?.didTapDelete(at: self)
    }
}