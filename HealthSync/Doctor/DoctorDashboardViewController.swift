//
//  DoctorDashboardViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DoctorDashboardViewController: UIViewController {
    
    private var doctorData: Doctor?
    private var pendingAppointments = 0
    private var todayAppointments = 0
    private var labResultsPending = 0
    
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
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pendingAppointmentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let todayAppointmentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let labResultsPendingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var appointmentsButton: DashboardButton = {
        let button = DashboardButton(title: "Appointments", icon: "calendar")
        button.addTarget(self, action: #selector(appointmentsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var patientsButton: DashboardButton = {
        let button = DashboardButton(title: "Patients", icon: "person.2")
        button.addTarget(self, action: #selector(patientsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var prescriptionsButton: DashboardButton = {
        let button = DashboardButton(title: "Prescriptions", icon: "doc.text")
        button.addTarget(self, action: #selector(prescriptionsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var labResultsButton: DashboardButton = {
        let button = DashboardButton(title: "Lab Results", icon: "cross.case")
        button.addTarget(self, action: #selector(labResultsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var profileButton: DashboardButton = {
        let button = DashboardButton(title: "Profile", icon: "person.crop.circle")
        button.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Dashboard"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupViews()
        setupActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDoctorData()
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
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(welcomeLabel)
        contentView.addSubview(statsContainer)
        
        statsContainer.addSubview(pendingAppointmentsLabel)
        statsContainer.addSubview(todayAppointmentsLabel)
        statsContainer.addSubview(labResultsPendingLabel)
        
        contentView.addSubview(appointmentsButton)
        contentView.addSubview(patientsButton)
        contentView.addSubview(prescriptionsButton)
        contentView.addSubview(labResultsButton)
        contentView.addSubview(profileButton)
        contentView.addSubview(logoutButton)
        
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
            
            welcomeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statsContainer.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            statsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            pendingAppointmentsLabel.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 15),
            pendingAppointmentsLabel.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 15),
            pendingAppointmentsLabel.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -15),
            
            todayAppointmentsLabel.topAnchor.constraint(equalTo: pendingAppointmentsLabel.bottomAnchor, constant: 10),
            todayAppointmentsLabel.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 15),
            todayAppointmentsLabel.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -15),
            
            labResultsPendingLabel.topAnchor.constraint(equalTo: todayAppointmentsLabel.bottomAnchor, constant: 10),
            labResultsPendingLabel.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 15),
            labResultsPendingLabel.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -15),
            labResultsPendingLabel.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -15),
            
            appointmentsButton.topAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: 30),
            appointmentsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            appointmentsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            appointmentsButton.heightAnchor.constraint(equalToConstant: 60),
            
            patientsButton.topAnchor.constraint(equalTo: appointmentsButton.bottomAnchor, constant: 15),
            patientsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            patientsButton.heightAnchor.constraint(equalToConstant: 60),
            
            prescriptionsButton.topAnchor.constraint(equalTo: patientsButton.bottomAnchor, constant: 15),
            prescriptionsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prescriptionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            prescriptionsButton.heightAnchor.constraint(equalToConstant: 60),
            
            labResultsButton.topAnchor.constraint(equalTo: prescriptionsButton.bottomAnchor, constant: 15),
            labResultsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            labResultsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            labResultsButton.heightAnchor.constraint(equalToConstant: 60),
            
            profileButton.topAnchor.constraint(equalTo: labResultsButton.bottomAnchor, constant: 15),
            profileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileButton.heightAnchor.constraint(equalToConstant: 60),
            
            logoutButton.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 30),
            logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func loadDoctorData() {
        guard let currentUser = Auth.auth().currentUser else {
            showAuthError()
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("doctors").document(currentUser.uid).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(message: "Error loading doctor data: \(error.localizedDescription)")
                self.activityIndicator.stopAnimating()
                return
            }
            
            guard let document = document, document.exists, let doctor = Doctor(document: document) else {
                self.showAuthError()
                self.activityIndicator.stopAnimating()
                return
            }
            
            self.doctorData = doctor
            self.welcomeLabel.text = "Welcome, Dr. \(doctor.name)"
            
            // Fetch doctor's statistics
            self.fetchDoctorStatistics()
        }
    }
    
    private func fetchDoctorStatistics() {
        guard let currentUser = Auth.auth().currentUser else {
            activityIndicator.stopAnimating()
            return
        }
        
        let db = Firestore.firestore()
        let appointmentsRef = db.collection("appointments")
        let labResultsRef = db.collection("labResults")
        
        let dispatchGroup = DispatchGroup()
        
        // Fetch pending appointments
        dispatchGroup.enter()
        appointmentsRef
            .whereField("doctorId", isEqualTo: currentUser.uid)
            .whereField("status", isEqualTo: AppointmentStatus.pending.rawValue)
            .getDocuments { [weak self] (snapshot, error) in
                defer { dispatchGroup.leave() }
                guard let self = self, error == nil else { return }
                
                self.pendingAppointments = snapshot?.documents.count ?? 0
            }
        
        // Fetch today's appointments
        dispatchGroup.enter()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        appointmentsRef
            .whereField("doctorId", isEqualTo: currentUser.uid)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { [weak self] (snapshot, error) in
                defer { dispatchGroup.leave() }
                guard let self = self, error == nil else { return }
                
                self.todayAppointments = snapshot?.documents.count ?? 0
            }
        
        // Fetch pending lab results
        dispatchGroup.enter()
        labResultsRef
            .whereField("doctorId", isEqualTo: currentUser.uid)
            .whereField("status", isEqualTo: LabResultStatus.pending.rawValue)
            .getDocuments { [weak self] (snapshot, error) in
                defer { dispatchGroup.leave() }
                guard let self = self, error == nil else { return }
                
                self.labResultsPending = snapshot?.documents.count ?? 0
            }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.pendingAppointmentsLabel.text = "📅 Pending Appointments: \(self.pendingAppointments)"
            self.todayAppointmentsLabel.text = "🕒 Today's Appointments: \(self.todayAppointments)"
            self.labResultsPendingLabel.text = "🧪 Lab Results to Review: \(self.labResultsPending)"
            
            // Add badge if there are pending items
            if self.pendingAppointments > 0 {
                self.appointmentsButton.showBadge(count: self.pendingAppointments)
            }
            
            if self.labResultsPending > 0 {
                self.labResultsButton.showBadge(count: self.labResultsPending)
            }
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    @objc private func appointmentsTapped() {
        let appointmentsVC = DoctorAppointmentsViewController()
        navigationController?.pushViewController(appointmentsVC, animated: true)
    }
    
    @objc private func patientsTapped() {
        let patientsVC = DoctorPatientsViewController()
        navigationController?.pushViewController(patientsVC, animated: true)
    }
    
    @objc private func prescriptionsTapped() {
        let prescriptionsVC = DoctorPrescriptionsViewController()
        navigationController?.pushViewController(prescriptionsVC, animated: true)
    }
    
    @objc private func labResultsTapped() {
        let labResultsVC = DoctorLabResultsViewController()
        navigationController?.pushViewController(labResultsVC, animated: true)
    }
    
    @objc private func profileTapped() {
        guard let doctorData = doctorData else { return }
        let profileVC = DoctorProfileViewController(doctor: doctorData)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch let error {
            showAlert(message: "Error signing out: \(error.localizedDescription)")
        }
    }
    
    private func showAuthError() {
        showAlert(message: "Authentication error. Please login again.") { [weak self] in
            do {
                try Auth.auth().signOut()
                self?.dismiss(animated: true)
            } catch {
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - Dashboard Button
class DashboardButton: UIButton {
    
    private let iconImageView = UIImageView()
    private let buttonTitleLabel = UILabel()  // Changed from titleLabel to buttonTitleLabel
    private let badgeLabel = UILabel()
    
    init(title: String, icon: String) {
        super.init(frame: .zero)
        setupView(title: title, iconName: icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(title: String, iconName: String) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemGray6
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        
        // Icon
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        
        // Title
        buttonTitleLabel.text = title  // Using buttonTitleLabel instead of titleLabel
        buttonTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonTitleLabel)
        
        // Badge
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.textColor = .white
        badgeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        badgeLabel.layer.cornerRadius = 10
        badgeLabel.layer.masksToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.isHidden = true
        addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            buttonTitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),  // Using buttonTitleLabel instead of titleLabel
            buttonTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),  // Using buttonTitleLabel instead of titleLabel
            
            badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            badgeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            badgeLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func showBadge(count: Int) {
        badgeLabel.text = "\(count)"
        badgeLabel.isHidden = false
    }
    
    func hideBadge() {
        badgeLabel.isHidden = true
    }
}
