//
//  PrescriptionDetailViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  PrescriptionDetailViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore

class PrescriptionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let prescription: Prescription
    
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
    
    private let patientNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
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
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let medicinesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Medicines:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let medicinesTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var medicinesTableViewHeightConstraint: NSLayoutConstraint?
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Prescription", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        return button
    }()
    
    init(prescription: Prescription) {
        self.prescription = prescription
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Prescription Details"
        
        setupTableView()
        setupViews()
        configureDetails()
    }
    
    private func setupTableView() {
        medicinesTableView.delegate = self
        medicinesTableView.dataSource = self
        medicinesTableView.register(PrescriptionMedicineCell.self, forCellReuseIdentifier: "PrescriptionMedicineCell")
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(patientNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(instructionsTitleLabel)
        contentView.addSubview(instructionsLabel)
        contentView.addSubview(medicinesTitleLabel)
        contentView.addSubview(medicinesTableView)
        contentView.addSubview(shareButton)
        
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
            
            patientNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            patientNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: patientNameLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            instructionsTitleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            instructionsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            instructionsLabel.topAnchor.constraint(equalTo: instructionsTitleLabel.bottomAnchor, constant: 10),
            instructionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            medicinesTitleLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            medicinesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            medicinesTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            medicinesTableView.topAnchor.constraint(equalTo: medicinesTitleLabel.bottomAnchor, constant: 10),
            medicinesTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            medicinesTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            shareButton.topAnchor.constraint(equalTo: medicinesTableView.bottomAnchor, constant: 30),
            shareButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 200),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        // Dynamic table height
        medicinesTableViewHeightConstraint = medicinesTableView.heightAnchor.constraint(equalToConstant: CGFloat(prescription.medicines.count * 80))
        medicinesTableViewHeightConstraint?.isActive = true
    }
    
    private func configureDetails() {
        patientNameLabel.text = "Patient: \(prescription.patientName)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        dateLabel.text = "Prescribed on: \(dateFormatter.string(from: prescription.date))"
        
        instructionsLabel.text = prescription.instructions
        
        medicinesTableView.reloadData()
    }
    
    @objc private func shareTapped() {
        // Create a formatted text of the prescription
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let dateString = dateFormatter.string(from: prescription.date)
        
        var medicinesList = ""
        for (index, medicine) in prescription.medicines.enumerated() {
            medicinesList += "\(index + 1). \(medicine.name) - \(medicine.dosage), \(medicine.frequency), for \(medicine.duration)\n"
        }
        
        let prescriptionText = """
        SRM Health App Prescription
        --------------------------
        Patient: \(prescription.patientName)
        Prescribed on: \(dateString)
        
        Instructions:
        \(prescription.instructions)
        
        Medicines:
        \(medicinesList)
        --------------------------
        """
        
        let activityViewController = UIActivityViewController(activityItems: [prescriptionText], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    // MARK: - UITableViewDelegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prescription.medicines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionMedicineCell", for: indexPath) as? PrescriptionMedicineCell else {
            return UITableViewCell()
        }
        
        let medicine = prescription.medicines[indexPath.row]
        cell.configure(with: medicine)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

class PrescriptionMedicineCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let dosageLabel = UILabel()
    private let frequencyAndDurationLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dosageLabel.font = UIFont.systemFont(ofSize: 14)
        frequencyAndDurationLabel.font = UIFont.systemFont(ofSize: 14)
        frequencyAndDurationLabel.textColor = .darkGray
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(dosageLabel)
        contentView.addSubview(frequencyAndDurationLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dosageLabel.translatesAutoresizingMaskIntoConstraints = false
        frequencyAndDurationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            dosageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            dosageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            dosageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            frequencyAndDurationLabel.topAnchor.constraint(equalTo: dosageLabel.bottomAnchor, constant: 5),
            frequencyAndDurationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            frequencyAndDurationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            frequencyAndDurationLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with medicine: Prescription.PrescriptionMedicine) {
        nameLabel.text = medicine.name
        dosageLabel.text = "Dosage: \(medicine.dosage)"
        frequencyAndDurationLabel.text = "\(medicine.frequency), for \(medicine.duration)"
    }
}