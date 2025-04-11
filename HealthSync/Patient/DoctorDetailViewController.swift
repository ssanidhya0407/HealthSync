//
//  DoctorDetailViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  DoctorDetailViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DoctorDetailViewController: UIViewController {
    
    private let doctor: Doctor
    private var availableSlots = [Date]()
    
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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let specializationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let availabilityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Availability:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let availabilityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patientsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        picker.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let slotTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Available Slots:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let slotsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 50)
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(SlotCell.self, forCellWithReuseIdentifier: "SlotCell")
        return cv
    }()
    
    private let reasonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reason for Visit:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let reasonTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter reason for appointment"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let bookAppointmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Book Appointment", for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(bookAppointmentTapped), for: .touchUpInside)
        return button
    }()
    
    private var selectedSlot: Date?
    
    init(doctor: Doctor) {
        self.doctor = doctor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Doctor Profile"
        
        setupViews()
        configureDoctorDetails()
        setupCollectionView()
        generateAvailableSlots()
        
        // Add target for date picker
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(specializationLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(availabilityTitleLabel)
        contentView.addSubview(availabilityLabel)
        contentView.addSubview(patientsLabel)
        contentView.addSubview(datePicker)
        contentView.addSubview(slotTitleLabel)
        contentView.addSubview(slotsCollectionView)
        contentView.addSubview(reasonTitleLabel)
        contentView.addSubview(reasonTextField)
        contentView.addSubview(bookAppointmentButton)
        
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
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            specializationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            specializationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            specializationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ratingLabel.topAnchor.constraint(equalTo: specializationLabel.bottomAnchor, constant: 10),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            patientsLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10),
            patientsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            availabilityTitleLabel.topAnchor.constraint(equalTo: patientsLabel.bottomAnchor, constant: 20),
            availabilityTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            availabilityTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            availabilityLabel.topAnchor.constraint(equalTo: availabilityTitleLabel.bottomAnchor, constant: 10),
            availabilityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            availabilityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            datePicker.topAnchor.constraint(equalTo: availabilityLabel.bottomAnchor, constant: 20),
            datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            slotTitleLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            slotTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            slotTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            slotsCollectionView.topAnchor.constraint(equalTo: slotTitleLabel.bottomAnchor, constant: 10),
            slotsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            slotsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            slotsCollectionView.heightAnchor.constraint(equalToConstant: 60),
            
            reasonTitleLabel.topAnchor.constraint(equalTo: slotsCollectionView.bottomAnchor, constant: 20),
            reasonTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reasonTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            reasonTextField.topAnchor.constraint(equalTo: reasonTitleLabel.bottomAnchor, constant: 10),
            reasonTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reasonTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            bookAppointmentButton.topAnchor.constraint(equalTo: reasonTextField.bottomAnchor, constant: 30),
            bookAppointmentButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bookAppointmentButton.widthAnchor.constraint(equalToConstant: 200),
            bookAppointmentButton.heightAnchor.constraint(equalToConstant: 50),
            bookAppointmentButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupCollectionView() {
        slotsCollectionView.delegate = self
        slotsCollectionView.dataSource = self
    }
    
    private func configureDoctorDetails() {
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
        
        availabilityLabel.text = doctor.availability
        patientsLabel.text = "Patients seen: \(doctor.totalPatients)"
    }
    
    @objc private func dateChanged() {
        generateAvailableSlots()
        selectedSlot = nil
        slotsCollectionView.reloadData()
    }
    
    private func generateAvailableSlots() {
        // This is a simplified implementation that generates time slots based on doctor availability
        // In a real app, you would check the doctor's calendar and existing appointments
        
        availableSlots = []
        
        // Parse the availability text and generate slots
        // This is a simplified version assuming the format is "Mon-Fri, 9AM-5PM"
        let selectedDate = datePicker.date
        let dayOfWeek = Calendar.current.component(.weekday, from: selectedDate)
        
        // If the selected day is within the doctor's working days
        // For simplicity, assuming the doctor works weekdays (Monday to Friday)
        if dayOfWeek >= 2 && dayOfWeek <= 6 {
            // Generate slots from 9 AM to 5 PM with 1-hour intervals
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            // Start at 9 AM
            var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            components.hour = 9
            components.minute = 0
            components.second = 0
            
            guard let startTime = calendar.date(from: components) else {
                return
            }
            
            // Generate slots until 5 PM
            for hour in 0..<8 {
                if let slotTime = calendar.date(byAdding: .hour, value: hour, to: startTime) {
                    availableSlots.append(slotTime)
                }
            }
        }
    }
    
    @objc private func bookAppointmentTapped() {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "You must be logged in to book an appointment")
            return
        }
        
        guard let selectedSlot = selectedSlot else {
            showAlert(message: "Please select an appointment time")
            return
        }
        
        guard let reason = reasonTextField.text, !reason.isEmpty else {
            showAlert(message: "Please enter a reason for your visit")
            return
        }
        
        // Fetch the patient's name
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(message: "Error: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let patientName = document.data()?["name"] as? String else {
                self.showAlert(message: "Could not retrieve your information")
                return
            }
            
            // Create the appointment in Firestore
            let appointmentId = UUID().uuidString
            let appointment: [String: Any] = [
                "id": appointmentId,
                "patientId": currentUser.uid,
                "doctorId": self.doctor.id,
                "patientName": patientName,
                "date": Timestamp(date: selectedSlot),
                "reason": reason,
                "status": AppointmentStatus.pending.rawValue,
                "updatedAt": Timestamp(date: Date())
            ]
            
            db.collection("appointments").document(appointmentId).setData(appointment) { error in
                if let error = error {
                    self.showAlert(message: "Error booking appointment: \(error.localizedDescription)")
                    return
                }
                
                self.showAlert(message: "Appointment booked successfully! The doctor will confirm your appointment.", isSuccess: true) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func showAlert(message: String, isSuccess: Bool = false, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: isSuccess ? "Success" : "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension DoctorDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableSlots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotCell", for: indexPath) as? SlotCell else {
            return UICollectionViewCell()
        }
        
        let slot = availableSlots[indexPath.item]
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        
        cell.configure(with: formatter.string(from: slot), isSelected: slot == selectedSlot)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSlot = availableSlots[indexPath.item]
        collectionView.reloadData()
    }
}

class SlotCell: UICollectionViewCell {
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -10),
            timeLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -10)
        ])
    }
    
    func configure(with time: String, isSelected: Bool) {
        timeLabel.text = time
        
        if isSelected {
            contentView.backgroundColor = .systemBlue
            timeLabel.textColor = .white
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            contentView.backgroundColor = .white
            timeLabel.textColor = .black
            contentView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}