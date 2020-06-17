import UIKit

class ConnectionViewController: BaseUITableViewController {
    
    var connectionItem = ConnectionMode.allValues

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
        } else {
            self.view.backgroundColor = UIColor(hex: "1E2023")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectionItem.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = connectionItem.index(of: LocalStorage.shared.userConnectionPreference) {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            cell?.accessoryType = .none
        }
        
        // update the checkmark for the current row
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        LocalStorage.shared.userConnectionPreference = connectionItem[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.connectionCell, for: indexPath)
        
        cell.textLabel?.text = connectionItem[indexPath.row].rawValue


        
        if #available(iOS 13.0, *) {
            cell.textLabel?.textColor = UIColor.label
        } else {
             cell.textLabel?.textColor = UIColor.white
            
        }
        
        let selectedBackgroundView = UIView()

        if #available(iOS 13.0, *) {
            selectedBackgroundView.backgroundColor = UIColor.secondarySystemBackground
        } else {
               selectedBackgroundView.backgroundColor = UIColor(hex: "1E2023")
        }

        cell.selectedBackgroundView = selectedBackgroundView
        
        if connectionItem[indexPath.row] == LocalStorage.shared.userConnectionPreference {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

