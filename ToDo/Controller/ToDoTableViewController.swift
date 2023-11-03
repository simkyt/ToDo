//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by Arkadijs Makarenko on 30/10/2023.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    var managedObjectContext: NSManagedObjectContext?
    var toDoLists = [ToDo]()
    private var cellID = "toDoCell"
    var selectedRow: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        let addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addNewItem))
        self.navigationItem.rightBarButtonItem = addButton
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        view.addGestureRecognizer(longPressRecognizer)
        
        setupNavigationBarView()
    }
    
    private func setupNavigationBarView() {
        title = "ToDo"
        let titleImage = UIImage(systemName: "bag.badge.plus")
        let imageView = UIImageView(image: titleImage)
        self.navigationItem.titleView = imageView
        
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .label
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPath = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPath) {
                print(indexPath)
                basicActionSheet(title: toDoLists[indexPath.row].item, message: "Completed: \(toDoLists[indexPath.row].completed)")
            }
        }
    }
    
    @objc func addNewItem() {
        let alertController = UIAlertController(title: "Do To List", message: "Do you want to add new item?", preferredStyle: .alert)
        alertController.addTextField { titleFieldValue in
            titleFieldValue.placeholder = "Your title here..."
            titleFieldValue.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        alertController.addTextField { descFieldValue in
            descFieldValue.placeholder = "Your description here..."
            descFieldValue.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let textField = alertController.textFields?.first
            let description = alertController.textFields?.last
            
            let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            
            list.setValue(textField?.text, forKey: "item")
            list.setValue(description?.text, forKey: "desc")
            self.saveCoreData()
        }
        addActionButton.isEnabled = false
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        
        present(alertController, animated: true)
    }
    
//    @IBAction func toggleEditingMode(_ sender: UIBarButtonItem) {
//        let isEditing = self.tableView.isEditing
//        self.tableView.setEditing(!isEditing, animated: true)
//        self.tableView.allowsSelectionDuringEditing = true
//
//        sender.tintColor = isEditing ? .black : .red
//    }
    
//    @IBAction func addNewItemTapped(_ sender: Any) {
//        
//        let alertController = UIAlertController(title: "Do To List", message: "Do you want to add new item?", preferredStyle: .alert)
//        alertController.addTextField { titleFieldValue in
//            titleFieldValue.placeholder = "Your title here..."
//            titleFieldValue.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
//        }
//        
//        alertController.addTextField { descFieldValue in
//            descFieldValue.placeholder = "Your description here..."
//            descFieldValue.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
//        }
//        
//        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
//            let textField = alertController.textFields?.first
//            let description = alertController.textFields?.last
//            
//            let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: self.managedObjectContext!)
//            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
//            
//            list.setValue(textField?.text, forKey: "item")
//            list.setValue(description?.text, forKey: "desc")
//            self.saveCoreData()
//        }
//        addActionButton.isEnabled = false
//        
//        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
//        
//        alertController.addAction(addActionButton)
//        alertController.addAction(cancelActionButton)
//        
//        present(alertController, animated: true)
//    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let alertController = presentedViewController as? UIAlertController {
            let titleTextField = alertController.textFields?.first
            let descriptionTextField = alertController.textFields?.last
            let isTitleEmpty = titleTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
            let isDescriptionEmpty = descriptionTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
            alertController.actions.first { $0.title == "Add" }?.isEnabled = !isTitleEmpty && !isDescriptionEmpty
        }
    }

//    @IBAction func deleteAllTapped(_ sender: Any) {
//        if toDoLists.count == 0 {
//            let alertController = UIAlertController(title: "No items", message: "There are no items to delete.", preferredStyle: .alert)
//            let okButton = UIAlertAction(title: "OK", style: .default)
//            alertController.addAction(okButton)
//            present(alertController, animated: true)
//        } else {
//            let alertController = UIAlertController(title: "Delete all items", message: "Are you sure you want to delete all items?", preferredStyle: .alert)
//            
//            let deleteActionButton = UIAlertAction(title: "Confirm", style: .default) { _ in
//                self.deleteAllCoreData()
//            }
//            let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
//            alertController.addAction(deleteActionButton)
//            alertController.addAction(cancelActionButton)
//            
//            present(alertController, animated: true)
//        }
//    }
}

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont(name: "Futura-Medium", size: 18)
        
        messageLabel.textColor = UIColor.secondaryLabel
        messageLabel.font = UIFont(name: "Kefa", size: 16)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 0).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: 0).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
        
        self.backgroundView = emptyView
        self.separatorStyle = .singleLine
    }
    
    func restoreTableViewStyle() {
        self.backgroundView = nil
    }
}


// MARK: - CoreData logic
extension ToDoTableViewController {
    func loadCoreData(){
        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "indexOrder", ascending: true)]
        
        do {
            let result = try managedObjectContext?.fetch(request)
            toDoLists = result ?? []
            self.tableView.reloadData()
        } catch {
            fatalError("Error in loading item into core data")
        }
    }
    
    func saveCoreData(){
        do {
            try managedObjectContext?.save()
        } catch {
            fatalError("Error in saving item into core data")
        }
        loadCoreData()
    }
    
    func deleteAllCoreData(){
        
        /* more complex deletion, ensures that there's no inconsistencies between persistent store and managedObjectContext */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs // returns the deleted objects IDs
        
        do {
            let batchDelete = try managedObjectContext?.execute(deleteRequest) // performs the batch delete and returns NSBatchDeleteResult
                as? NSBatchDeleteResult
            
            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] // checks if IDs of the deleted objects were returned as an array
                else { return }
            
            let deletedObjects: [AnyHashable: Any] = [
                NSDeletedObjectsKey: deleteResult
            ]
            
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [managedObjectContext!]) // ensures that moc is fully updated with all of the deletions
        } catch {
            fatalError("Error deleting items from core data")
        }
        
        
        /* simpler deletion */
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        
//        do {
//            try managedObjectContext?.execute(deleteRequest)
//        } catch {
//            fatalError("Error deleting items from core data")
//        }
        
        saveCoreData()
    }
    
    func basicActionSheet(title: String?, message: String?) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.overrideUserInterfaceStyle = .dark
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
}



// MARK: - Table view data source
extension ToDoTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toDoLists.count == 0 {
            tableView.setEmptyView(title: "Your ToDo is empty", message: "Please press Add to create a new to do item")
        } else {
            tableView.restoreTableViewStyle()
        }
        
        return toDoLists.count
    }
    
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        let toDoList = toDoLists[indexPath.row]
        cell.textLabel?.text = toDoList.item
        cell.detailTextLabel?.text = toDoList.desc
        cell.accessoryType = toDoList.completed ? .checkmark : .none
        
        if let imageData = toDoList.image as Data?,
           let image = UIImage(data: imageData) {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = nil
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            selectedRow = indexPath
            tableView.deselectRow(at: indexPath, animated: true)
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: nil)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            toDoLists[indexPath.row].completed = !toDoLists[indexPath.row].completed
        }
        saveCoreData()
    }
   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            managedObjectContext?.delete(toDoLists[indexPath.row])
        }
        saveCoreData()
    }
    

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedItem = toDoLists.remove(at: fromIndexPath.row)
        toDoLists.insert(movedItem, at: to.row)
        
        for (index, item) in toDoLists.enumerated() {
            item.indexOrder = Int32(index)
        }
        
        saveCoreData()
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}



extension ToDoTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        if let indexPath = selectedRow {
            let toDoItem = toDoLists[indexPath.row]
            let imageData = selectedImage.jpegData(compressionQuality: 1.0)
            toDoItem.image = imageData
            saveCoreData()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        selectedRow = nil
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        selectedRow = nil
        dismiss(animated: true, completion: nil)
    }
}
