//
//  MainViewController.swift
//  Postboard
//
//  GIVEN - you do not need to change this file.
//
//  One screen, three parts, top to bottom:
//    - a Download button with a progress bar
//    - the list of posts (loads more as you scroll)
//    - the event log
//
//  It calls exactly three things that you write:
//    service.fetchPosts(page:limit:)     Tasks 2 and 3
//    service.createPost(_:)              Task 4
//    BackgroundDownloader.shared         Task 5
//

import UIKit

final class MainViewController: UIViewController {

    private let service: PostServiceProtocol

    private let downloadButton = UIButton(configuration: .tinted())
    private let progressView = UIProgressView()
    private let statusLabel = UILabel()
    private let tableView = UITableView()
    private let logView = UITextView()

    private var posts: [Post] = []
    private var nextPage = 1
    private var total: Int?
    private var isLoading = false

    init(service: PostServiceProtocol) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Postboard"
        view.backgroundColor = .systemBackground
        buildUI()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Clear log", style: .plain, target: self, action: #selector(clearLog))

        BackgroundDownloader.shared.onProgress = { [weak self] fraction in
            self?.progressView.setProgress(Float(fraction), animated: true)
            self?.statusLabel.text = String(format: "Downloading… %.0f%%", fraction * 100)
        }
        BackgroundDownloader.shared.onFinish = { [weak self] message in
            self?.statusLabel.text = message
        }

        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshLog), name: EventLog.didChange, object: nil)

        refreshLog()

        Task { await loadNextPage() }
    }

    // MARK: - Posts

    private func loadNextPage() async {
        guard !isLoading else { return }
        if let total, posts.count >= total { return }

        isLoading = true
        do {
            let page = try await service.fetchPosts(page: nextPage, limit: 10)
            posts += page.posts
            total = page.totalCount
            nextPage += 1
            tableView.reloadData()
            navigationItem.prompt = "showing \(posts.count) of \(page.totalCount)"
        } catch {
            show(title: "Could not load posts", message: message(for: error))
        }
        isLoading = false
    }

    @objc private func addTapped() {
        let alert = UIAlertController(title: "New post",
                                      message: "This does a POST to the API.",
                                      preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Title" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            let title = alert.textFields?.first?.text ?? ""
            self?.createPost(titled: title.isEmpty ? "Hello from Postboard" : title)
        })
        present(alert, animated: true)
    }

    private func createPost(titled title: String) {
        Task {
            do {
                let created = try await service.createPost(
                    NewPost(title: title, body: "Written on the assignment.", authorID: 1))
                posts.insert(created, at: 0)
                tableView.reloadData()
                show(title: "Created", message: "The server gave it id \(created.id).")
            } catch {
                show(title: "Could not create the post", message: message(for: error))
            }
        }
    }

    // MARK: - Helpers

    private func message(for error: Error) -> String {
        (error as? APIError)?.userMessage ?? error.localizedDescription
    }

    private func show(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func downloadTapped() {
        statusLabel.text = "Handed to the system…"
        progressView.setProgress(0, animated: false)
        BackgroundDownloader.shared.startDownload()
    }

    @objc private func clearLog() {
        EventLog.shared.clear()
        refreshLog()
    }

    @objc private func refreshLog() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let files = (try? FileManager.default.contentsOfDirectory(
            at: documents, includingPropertiesForKeys: [.fileSizeKey])) ?? []

        let listing = files.map { url -> String in
            let bytes = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return "  \(url.lastPathComponent) - \(bytes) bytes"
        }

        logView.text = "Documents:\n"
            + (listing.isEmpty ? "  (empty)" : listing.joined(separator: "\n"))
            + "\n\n" + EventLog.shared.lines.joined(separator: "\n")
    }

    // MARK: - Layout

    private func buildUI() {
        downloadButton.configuration?.title = "Download 100 MB file"
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)

        statusLabel.text = "Idle."
        statusLabel.font = .preferredFont(forTextStyle: .caption1)
        statusLabel.textColor = .secondaryLabel

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        logView.isEditable = false
        logView.font = .monospacedSystemFont(ofSize: 9, weight: .regular)
        logView.backgroundColor = .secondarySystemBackground
        logView.layer.cornerRadius = 6

        let stack = UIStackView(arrangedSubviews: [
            downloadButton, progressView, statusLabel, tableView, logView
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8),
            logView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}

// MARK: - Table view

extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let post = posts[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = post.title
        content.secondaryText = "#\(post.id) - author \(post.authorID)"
        content.textProperties.numberOfLines = 2
        cell.contentConfiguration = content
        return cell
    }

    /// When the last row appears, load the next page.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        guard indexPath.row == posts.count - 1 else { return }
        Task { await loadNextPage() }
    }
}
