//
//  ArticleDetailViewController.swift
//  MBChallenge
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import UIKit
import Combine

class ArticleDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let sectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        return label
    }()
    
    private let bodyTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .label
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    private let imageLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    private let viewModel: ArticleDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(article: Article) {
        self.viewModel = ArticleDetailViewModel(article: article)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        configureWithArticle()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Article"
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(articleImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(sectionLabel)
        contentView.addSubview(bodyTextView)
        contentView.addSubview(imageLoadingIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            articleImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            articleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            articleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            articleImageView.heightAnchor.constraint(equalToConstant: 200),
            
            imageLoadingIndicator.centerXAnchor.constraint(equalTo: articleImageView.centerXAnchor),
            imageLoadingIndicator.centerYAnchor.constraint(equalTo: articleImageView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: articleImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            sectionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            bodyTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            bodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bodyTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        // Bind image data
        viewModel.$imageData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                if let data = data, let image = UIImage(data: data) {
                    self?.articleImageView.image = image
                }
            }
            .store(in: &cancellables)
        
        // Bind image loading state
        viewModel.$isLoadingImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.imageLoadingIndicator.startAnimating()
                } else {
                    self?.imageLoadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    private func configureWithArticle() {
        titleLabel.text = viewModel.articleTitle
        dateLabel.text = viewModel.formattedDate
        sectionLabel.text = viewModel.article.sectionName
        
        // Configure body text with proper formatting
        if let attributedBody = viewModel.articleBodyAttributed {
            bodyTextView.attributedText = attributedBody
        } else {
            let bodyText = viewModel.articleBody
            if !bodyText.isEmpty && bodyText != "No content available" {
                bodyTextView.text = bodyText
            } else {
                bodyTextView.text = "No content available for this article."
            }
        }
        
        // Hide image view if no image is available
        if viewModel.article.fields?.imageUrl == nil {
            articleImageView.isHidden = true
            // Update constraint to connect title to content view top
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        }
    }
} 