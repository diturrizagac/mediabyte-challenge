//
//  ArticlesListViewController.swift
//  MBChallenge
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import UIKit
import Combine

class ArticlesListViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ArticleTableViewCell.self, forCellReuseIdentifier: "ArticleCell")
        table.register(LoadingTableViewCell.self, forCellReuseIdentifier: "LoadingCell")
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        return table
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Properties
    private let viewModel = ArticlesListViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchArticles()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "News Articles"
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup refresh control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        // Bind articles
        viewModel.$articles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // Bind loading state
        viewModel.$loadingState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(for state: LoadingState) {
        switch state {
        case .idle:
            loadingIndicator.stopAnimating()
            errorLabel.isHidden = true
            tableView.isHidden = false
            
        case .loading:
            loadingIndicator.startAnimating()
            errorLabel.isHidden = true
            tableView.isHidden = true
            
        case .loaded:
            loadingIndicator.stopAnimating()
            errorLabel.isHidden = true
            tableView.isHidden = false
            refreshControl.endRefreshing()
            
        case .loadingMore:
            // Don't hide table view when loading more
            loadingIndicator.stopAnimating()
            errorLabel.isHidden = true
            tableView.isHidden = false
            refreshControl.endRefreshing()
            
        case .error(let message):
            loadingIndicator.stopAnimating()
            errorLabel.text = "Error: \(message)\n\nPull to refresh to try again."
            errorLabel.isHidden = false
            tableView.isHidden = true
            refreshControl.endRefreshing()
        }
    }
    
    @objc private func refreshData() {
        viewModel.refreshArticles()
    }
}

// MARK: - UITableViewDataSource
extension ArticlesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let baseCount = viewModel.articles.count
        // Add loading cell if there are more pages to load
        return viewModel.hasMorePages ? baseCount + 1 : baseCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if this is the loading cell
        if indexPath.row == viewModel.articles.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingTableViewCell
            if viewModel.isLoadingMore {
                cell.startLoading()
            } else {
                cell.stopLoading()
            }
            return cell
        }
        
        // Regular article cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        let article = viewModel.articles[indexPath.row]
        cell.configure(with: article, dateFormatter: viewModel.formattedDate)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ArticlesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load more articles when user reaches the loading cell
        if indexPath.row == viewModel.articles.count && viewModel.canLoadMore {
            viewModel.loadMoreArticles()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Don't allow selection of loading cell
        if indexPath.row == viewModel.articles.count {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = viewModel.articles[indexPath.row]
        let detailViewController = ArticleDetailViewController(article: article)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
} 