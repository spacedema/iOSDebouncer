//
//  ViewController.swift
//  debouncer
//
//  Created by sfilippov on 09.01.2023.
//

import UIKit
// https://github.com/apple/swift-async-algorithms
class ViewController: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    let debouncer = Debouncer(timeIntervat: 5)
    let throttler = Throttler(timeIntervat: 1)

    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearController()
    }

    func configureSearController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.barStyle = .default
    }

    func doApiCall(with searchText: String) async -> [String] {
        print("api call with: \(searchText)")
        try? await Task.sleep(seconds: 1)
        return ["result", "result \(searchText)"]
    }

    func debounce(searchText: String) {
        Task {
            await debouncer.debounce {
                let result = await self.doApiCall(with: searchText)
                print(result)
                await MainActor.run {
                    self.label.text = result.joined(separator: ",")
                }
            }
        }
    }

    func throttle(searchText: String) {
        Task {
            await throttler.throttle {
                print("throttled: \(searchText)")
            }
        }
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        print(searchText)
        debounce(searchText: searchText)
        throttle(searchText: searchText)
    }
}
