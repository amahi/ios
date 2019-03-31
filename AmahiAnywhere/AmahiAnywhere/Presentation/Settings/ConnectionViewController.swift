import UIKit

class ConnectionViewController: BaseUITableViewController {
    
    var connectionItem = ConnectionMode.allValues

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let footer = UIView()
        view.backgroundColor = UIColor.black
        tableView.tableFooterView = footer
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
        cell.textLabel?.textColor = UIColor.white
        
        if connectionItem[indexPath.row] == LocalStorage.shared.userConnectionPreference {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
