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
    var selectedRow: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
    }
    
    @IBAction func toggleEditingMode(_ sender: UIBarButtonItem) {
        let isEditing = self.tableView.isEditing
        self.tableView.setEditing(!isEditing, animated: true)
        self.tableView.allowsSelectionDuringEditing = true

        sender.tintColor = isEditing ? .black : .red
    }
    
    @IBAction func addNewItemTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Do To List", message: "Do you want to add new item?", preferredStyle: .alert)
        alertController.addTextField { titleFieldValue in
            titleFieldValue.placeholder = "Your title here..."
            titleFieldValue.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        #warning("message/subtitle")
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let alertController = presentedViewController as? UIAlertController {
            let titleTextField = alertController.textFields?.first
            let descriptionTextField = alertController.textFields?.last
            let isTitleNotEmpty = !(titleTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            let isDescriptionNotEmpty = !(descriptionTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            alertController.actions.first { $0.title == "Add" }?.isEnabled = isTitleNotEmpty && isDescriptionNotEmpty
        }
    }

    @IBAction func deleteAllTapped(_ sender: Any) {
        if toDoLists.count == 0 {
            let alertController = UIAlertController(title: "No items", message: "There are no items to delete.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okButton)
            present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(title: "Delete all items", message: "Are you sure you want to delete all items?", preferredStyle: .alert)
            
            let deleteActionButton = UIAlertAction(title: "Confirm", style: .default) { _ in
                self.deleteAllCoreData()
            }
            let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
            alertController.addAction(deleteActionButton)
            alertController.addAction(cancelActionButton)
            
            present(alertController, animated: true)
        }
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
    #warning("delete All CoreData")
        
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
    
}



// MARK: - Table view data source
extension ToDoTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoLists.count
    }
    
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)

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
