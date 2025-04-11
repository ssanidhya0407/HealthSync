//
//  DoctorAppointmentsViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  DoctorAppointmentsViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DoctorAppointmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var appointments = [Appointment]()
    private var filteredAppointments = [Appointment]()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Pending", "Today", "Upcoming", "All"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(AppointmentCell.self, forCellReuseIdentifier: "AppointmentCell")
        return tableView
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Appointments"
        
        setupEmptyLabel()
        setupSegmentedControl()
        setupTableView()
        setupActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAppointments()
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "No appointments found"
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
        filterAppointments()
    }
    
    private func fetchAppointments() {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "You must be logged in to view appointments")
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("appointments")
            .whereField("doctorId", isEqualTo: currentUser.uid)
            .order(by: "date", descending: false)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showAlert(message: "Error fetching appointments: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.emptyLabel.isHidden = false
                    return
                }
                
                self.appointments = documents.compactMap { document -> Appointment? in
                    return Appointment(document: document)
                }
                
                self.filterAppointments()
            }
    }
    
    private func filterAppointments() {
        let segmentIndex = segmentedControl.selectedSegmentIndex
        
        switch segmentIndex {
        case 0: // Pending
            filteredAppointments = appointments.filter { $0.status == .pending }
        case 1: // Today
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            filteredAppointments = appointments.filter { appointment in
                let appointmentDate = calendar.startOfDay(for: appointment.date)
                return appointmentDate >= today && appointmentDate < tomorrow
            }
        case 2: // Upcoming
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            filteredAppointments = appointments.filter { appointment in
                let appointmentDate = calendar.startOfDay(for: appointment.date)
                return appointmentDate > today && appointment.status != .cancelled
            }
        case 3: // All
            filteredAppointments = appointments
        default:
            filteredAppointments = appointments
        }
        
        tableView.reloadData()
        emptyLabel.isHidden = !filteredAppointments.isEmpty
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAppointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as? AppointmentCell else {
            return UITableViewCell()
        }
        
        let appointment = filteredAppointments[indexPath.row]
        cell.configure(with: appointment)
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let appointment = filteredAppointments[indexPath.row]
        let detailVC = AppointmentDetailViewController(appointment: appointment)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AppointmentDetailViewControllerDelegate
extension DoctorAppointmentsViewController: AppointmentDetailViewControllerDelegate {
    func appointmentStatusDidUpdate() {
        fetchAppointments()
    }
}

// MARK: - Appointment Cell
class AppointmentCell: UITableViewCell {
    
    private let patientNameLabel = UILabel()
    private let dateLabel = UILabel()
    private let reasonLabel = UILabel()
    private let statusLabel = UILabel()
    
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
        reasonLabel.font = UIFont.systemFont(ofSize: 14)
        reasonLabel.textColor = .darkGray
        reasonLabel.numberOfLines = 2
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        contentView.addSubview(patientNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(reasonLabel)
        contentView.addSubview(statusLabel)
        
        patientNameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            patientNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            patientNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: patientNameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            reasonLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            reasonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reasonLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: reasonLabel.bottomAnchor, constant: 5),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with appointment: Appointment) {
        patientNameLabel.text = appointment.patientName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: appointment.date)
        
        reasonLabel.text = "Reason: \(appointment.reason)"
        
        switch appointment.status {
        case .pending:
            statusLabel.text = "Status: Pending"
            statusLabel.textColor = .systemOrange
        case .confirmed:
            statusLabel.text = "Status: Confirmed"
            statusLabel.textColor = .systemBlue
        case .completed:
            statusLabel.text = "Status: Completed"
            statusLabel.textColor = .systemGreen
        case .cancelled:
            statusLabel.text = "Status: Cancelled"
            statusLabel.textColor = .systemRed
        }
    }
}