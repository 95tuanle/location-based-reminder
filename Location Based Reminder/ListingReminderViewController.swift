import UIKit
import SafariServices
import CoreLocation

class ListingReminderViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Item] = []
    var item: Item!
    var selectedIndex: Int!
    var filteredData: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ask user to grant all permission
        LocalPushManager.shared.requestAuthorization() //Notification
        CLLocationManager().requestAlwaysAuthorization() //Location
        
        self.tableView.estimatedRowHeight = 10
        self.tableView.rowHeight = UITableView.automaticDimension
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addReminder))
        tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchData()
    }
    
    func fetchData() {
        
        do {
            items = try context.fetch(Item.fetchRequest())
            filteredData = items
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Couldn't Fetch Data")
            let alert = UIAlertController(title: "Couldn't load data", message: "Data cannot be loaded from storage", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//Custom table view cell contents
class HeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headlineImageView: UIImageView!
    @IBOutlet weak var headlineTitleLabel: UILabel!
    @IBOutlet weak var headlineLocationLabel: UILabel!
    @IBOutlet weak var headlineLatitudeLabel: UILabel!
    @IBOutlet weak var headlineLongitudeLabel: UILabel!
}

//Mandatory stuff to construct a table view cell
extension ListingReminderViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HeadlineTableViewCell
        
        cell.headlineTitleLabel.text = filteredData[indexPath.row].title!
        cell.headlineImageView.image = UIImage(data: filteredData[indexPath.row].image!)
        //        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnView))
        
        //        singleTap.numberOfTapsRequired = 1
        //        singleTap.numberOfTouchesRequired = 1
        //        cell.headlineImageView.addGestureRecognizer(singleTap)
        
        return cell
    }
    /*
     //Tap image in cell to open URL
     @objc func tappedOnView(onView gesture: UITapGestureRecognizer) {
     let location: CGPoint = gesture.location(in: tableView)
     let indexPath: IndexPath? = tableView.indexPathForRow(at: location)
     var urlString = filteredData[(indexPath?.row)!].url //open map with lat and long
     if (((urlString?.lowercased().range(of: "http://")) != nil) || ((urlString?.lowercased().range(of: "https://")) != nil)) {
     } else {
     urlString = "http://" + urlString!
     }
     let url: URL = URL(string: urlString!)!
     let safariViewController = SFSafariViewController(url: url)
     self.present(safariViewController, animated: true, completion: nil)
     }
     */
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "UpdateVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        if editing {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addReminder))
        }
    }
    @objc func addReminder() {
        
        self.performSegue(withIdentifier: "To Create", sender: nil)
    }
    //swipe left for delete/open url
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            
            let item = self.filteredData[indexPath.row]
            self.context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.filteredData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
        //        let openURL = UITableViewRowAction(style: .default, title: "Open URL") { (action, indexPath) in
        //            let item = self.filteredData[indexPath.row]
        //            var urlString = item.url
        //            if (((urlString?.lowercased().range(of: "http://")) != nil) || ((urlString?.lowercased().range(of: "https://")) != nil)) {
        //            } else {
        //                urlString = "http://" + urlString!
        //            }
        //            let url: URL = URL(string: urlString!)!
        //            let safariViewController = SFSafariViewController(url: url)
        //            self.present(safariViewController, animated: true, completion: nil)
        //        }
        //
        delete.backgroundColor = UIColor(red: 240/255, green: 52/255, blue: 52/255, alpha: 1.0)
        //        openURL.backgroundColor = UIColor(red: 3/255, green: 201/255, blue: 169/255, alpha: 1.0)
        
        return [delete]
    }
    
    //Pass data from table view to View/Edit through segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdateVC" {
            let detailView: EditReminderViewController = segue.destination as! EditReminderViewController
            detailView.item = filteredData[selectedIndex!]
        }
    }
}
