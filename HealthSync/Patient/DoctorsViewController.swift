//
//  DoctorsViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore

class DoctorsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var doctors = [Doctor]()
    private var filteredDoctors = [Doctor]()
    private var isSearchActive = false
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search doctors by name or specialization"
        controller.searchBar.delegate = self
        return controller
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "stethoscope")
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No doctors found"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let emptyStateSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Try adjusting your search criteria"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DoctorCell.self, forCellWithReuseIdentifier: DoctorCell.reuseIdentifier)
        collectionView.register(
            SpecialtyHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SpecialtyHeaderView.reuseIdentifier
        )
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 20, right: 16)
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private var specializations: [String] {
        let specs = Array(Set(doctors.map { $0.specialization })).sorted()
        return specs
    }
    
    // Group doctors by specialization
    private var doctorsBySpecialization: [(specialization: String, doctors: [Doctor])] {
        if isSearchActive {
            return [("Search Results", filteredDoctors)]
        } else {
            let grouped = Dictionary(grouping: doctors) { $0.specialization }
            return grouped.map { (specialization: $0.key, doctors: $0.value) }
                .sorted { $0.specialization < $1.specialization }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupRefreshControl()
        fetchDoctors()
    }
    
    // MARK: - UI Configuration
    
    private func configureUI() {
        // View setup
        view.backgroundColor = .systemBackground
        title = "Find Doctors"
        
        // Navigation setup
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add subviews
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateSubtitleLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateSubtitleLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateSubtitleLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    // MARK: - Data Fetching
    
    private func fetchDoctors() {
        loadingIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("doctors")
            .whereField("isActive", isEqualTo: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                if let error = error {
                    self.showAlert(
                        title: "Error",
                        message: "Could not load doctors: \(error.localizedDescription)"
                    )
                    return
                }
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    self.doctors = []
                    self.updateEmptyState(message: "No doctors available", subtitle: "Please check back later")
                    return
                }
                
                self.doctors = documents.compactMap { Doctor(document: $0) }
                    .sorted { $0.avgRating > $1.avgRating }
                
                self.filteredDoctors = self.doctors
                self.collectionView.reloadData()
                self.emptyStateView.isHidden = !self.doctors.isEmpty
            }
    }
    
    // MARK: - Actions & Helpers
    
    @objc private func refreshData() {
        fetchDoctors()
    }
    
    private func updateEmptyState(message: String, subtitle: String) {
        emptyStateLabel.text = message
        emptyStateSubtitleLabel.text = subtitle
        emptyStateView.isHidden = false
        collectionView.reloadData()
    }
    
    private func filterDoctors(with searchText: String) {
        if searchText.isEmpty {
            filteredDoctors = doctors
            isSearchActive = false
        } else {
            isSearchActive = true
            filteredDoctors = doctors.filter { doctor in
                return doctor.name.lowercased().contains(searchText.lowercased()) ||
                    doctor.specialization.lowercased().contains(searchText.lowercased())
            }
        }
        
        emptyStateView.isHidden = !filteredDoctors.isEmpty || searchText.isEmpty
        if filteredDoctors.isEmpty && !searchText.isEmpty {
            updateEmptyState(
                message: "No matching doctors",
                subtitle: "Try different search terms"
            )
        }
        
        collectionView.reloadData()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension DoctorsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return doctorsBySpecialization.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doctorsBySpecialization[section].doctors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DoctorCell.reuseIdentifier,
            for: indexPath
        ) as? DoctorCell else {
            return UICollectionViewCell()
        }
        
        let doctor = doctorsBySpecialization[indexPath.section].doctors[indexPath.item]
        cell.configure(with: doctor)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let doctor = doctorsBySpecialization[indexPath.section].doctors[indexPath.item]
        let detailVC = DoctorDetailViewController(doctor: doctor)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SpecialtyHeaderView.reuseIdentifier,
                for: indexPath
            ) as? SpecialtyHeaderView else {
                return UICollectionReusableView()
            }
            
            let specialization = doctorsBySpecialization[indexPath.section].specialization
            headerView.configure(with: specialization)
            return headerView
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DoctorsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32 // Accounting for left and right insets
        return CGSize(width: width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - UISearchResultsUpdating & UISearchBarDelegate

extension DoctorsViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterDoctors(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearchActive = false
        filteredDoctors = doctors
        emptyStateView.isHidden = !doctors.isEmpty
        collectionView.reloadData()
    }
}

// MARK: - Custom Collection View Cells & Headers

class DoctorCell: UICollectionViewCell {
    static let reuseIdentifier = "DoctorCell"
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray2
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let specializationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let starsView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let availabilityView = InfoView(icon: "calendar", title: "Available")
    private let patientsView = InfoView(icon: "person.2", title: "Patients")
    
    private let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Book Appointment", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = false // Let the cell handle the tap
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(specializationLabel)
        containerView.addSubview(starsView)
        containerView.addSubview(ratingLabel)
        containerView.addSubview(infoStackView)
        containerView.addSubview(bookButton)
        
        infoStackView.addArrangedSubview(availabilityView)
        infoStackView.addArrangedSubview(patientsView)
        
        // Setup ratings stars
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = .systemYellow
            starsView.addArrangedSubview(starImageView)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            specializationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            specializationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specializationLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            starsView.topAnchor.constraint(equalTo: specializationLabel.bottomAnchor, constant: 8),
            starsView.leadingAnchor.constraint(equalTo: specializationLabel.leadingAnchor),
            starsView.heightAnchor.constraint(equalToConstant: 16),
            starsView.widthAnchor.constraint(equalToConstant: 90),
            
            ratingLabel.centerYAnchor.constraint(equalTo: starsView.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: starsView.trailingAnchor, constant: 8),
            
            infoStackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            infoStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            infoStackView.heightAnchor.constraint(equalToConstant: 30),
            
            bookButton.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 12),
            bookButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            bookButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            bookButton.heightAnchor.constraint(equalToConstant: 36),
            bookButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
    }
    
    // MARK: - Configuration
    
    func configure(with doctor: Doctor) {
        nameLabel.text = "Dr. \(doctor.name)"
        specializationLabel.text = doctor.specialization
        
        // Configure rating stars
        let rating = doctor.avgRating
        for (index, view) in starsView.arrangedSubviews.enumerated() {
            if let starView = view as? UIImageView {
                if Double(index) + 0.5 <= rating {
                    starView.image = UIImage(systemName: "star.fill")
                } else if Double(index) < rating {
                    starView.image = UIImage(systemName: "star.leadinghalf.filled")
                } else {
                    starView.image = UIImage(systemName: "star")
                }
            }
        }
        
        ratingLabel.text = String(format: "%.1f", rating)
        availabilityView.valueLabel.text = doctor.availability
        patientsView.valueLabel.text = "\(doctor.totalPatients)"
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        specializationLabel.text = nil
        ratingLabel.text = nil
        availabilityView.valueLabel.text = nil
        patientsView.valueLabel.text = nil
        
        for view in starsView.arrangedSubviews {
            if let starView = view as? UIImageView {
                starView.image = UIImage(systemName: "star")
            }
        }
    }
}

class InfoView: UIView {
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    init(icon: String, title: String) {
        super.init(frame: .zero)
        
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 4),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SpecialtyHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SpecialtyHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
