//
//  AddViewController.swift
//  ToDo
//
//  Created by Simonas Kytra on 05/11/2023.
//

import UIKit
import CoreData

protocol AddViewControllerDelegate: AnyObject {
    var managedObjectContext: NSManagedObjectContext? { get }
    func saveCoreData()
}

class AddViewController: UIViewController {

    weak var delegate: AddViewControllerDelegate?
    var stackView: UIStackView!
    var closeButton: UIButton!
    var titleLabel: UILabel!
    var titleTextField: UITextField!
    var descriptionTextField: UITextField!
    var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton = UIButton(type: .system)
        closeButton.setTitle("X", for: .normal)
        closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel = UILabel()
        titleLabel.text = "Add"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        
        titleTextField = UITextField()
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.placeholder = "Your title here..."
        titleTextField.borderStyle = .roundedRect
        titleTextField.textColor = .black
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        descriptionTextField = UITextField()
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.placeholder = "Your description here..."
        descriptionTextField.borderStyle = .roundedRect
        descriptionTextField.textColor = .black
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        saveButton = UIButton(type: .system)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemGray
        saveButton.layer.cornerRadius = 10
        saveButton.setTitleColor(.white, for: .disabled)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(saveToDoItem), for: .touchUpInside)
        saveButton.isEnabled = false
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(descriptionTextField)
        stackView.addArrangedSubview(saveButton)

        view.addSubview(closeButton)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stackView.widthAnchor.constraint(equalToConstant: 250),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

    }
    
    @objc func saveToDoItem() {
        if let context = delegate?.managedObjectContext {
            let newToDo = ToDo(context: context)
            newToDo.item = titleTextField.text
            newToDo.desc = descriptionTextField.text
            
            delegate?.saveCoreData()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let isTitleTextFieldNotEmpty = !(titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isDescriptionTextFieldNotEmpty = !(descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)

        saveButton.isEnabled = isTitleTextFieldNotEmpty && isDescriptionTextFieldNotEmpty
        UIView.animate(withDuration: 0.3) {
            self.saveButton.backgroundColor = (isTitleTextFieldNotEmpty && isDescriptionTextFieldNotEmpty) ? UIColor.systemGreen : UIColor.systemGray
        }
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
