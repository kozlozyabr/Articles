//
//  ViewController.swift
//  Articles
//
//  Created by Даниил Скибинский
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [Petition]()
    var newDB = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credit", style: .plain, target: self, action: #selector(showCredit))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterPetitions))
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterPetitions)),
            UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(clearFilters)) ]
        
        
//        let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self.parse(json: data)
                    return
                }
            }
            self.showError()
        }

        
        // Do any additional setup after loading the view.
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()

        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        newDB = petitions
    }
    
    func showError() {
        DispatchQueue.main.async {
            
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    @objc func showCredit() {
        let ac = UIAlertController(title: "This project is possible due to open source data from \"We The People API of the Whitehouse\"", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Thanks to them!", style: .default))
        present(ac, animated: true)
    }
    
    @objc func filterPetitions() {
        let ac = UIAlertController(title: "What are you looking for?", message: "Please, type it in:", preferredStyle: .alert)
        ac.addTextField()  { (textFeild) in
            textFeild.placeholder = "Search here" // placeholder
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Search", style: .default) { [weak self, weak ac] _ in
            guard let textField = ac!.textFields?.first, let text = textField.text else {
                return
            }
            self!.filtering(searchLine: text)
        })
        present(ac, animated: true)
    }
    
    @objc func clearFilters() {
        let ac = UIAlertController(title: "Filters cleared", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        newDB = petitions
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func filtering(searchLine: String) {
        newDB = []
        if searchLine.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            for pet in petitions {
                if pet.title.localizedCaseInsensitiveContains(searchLine) {
                    newDB.append(pet)
                }
            }
        } else {
            newDB = petitions
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newDB.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = newDB[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = newDB[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

