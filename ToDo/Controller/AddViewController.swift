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
    var stackViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
        setupConstraints()
        setupKeyboardNotifications()

    }
    
    func setupViews() {
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
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(descriptionTextField)
        stackView.addArrangedSubview(saveButton)

        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(stackView)
    }
    
    func setupConstraints() {
        let verticalCenterConstraint = stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        verticalCenterConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalCenterConstraint,
            stackView.widthAnchor.constraint(equalToConstant: 250)
        ])
        
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        stackViewBottomConstraint.isActive = true
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
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let safeAreaBottomInset = view.safeAreaInsets.bottom
            stackViewBottomConstraint.constant = -(keyboardHeight - safeAreaBottomInset)
            animateLayoutChanges()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        stackViewBottomConstraint.constant = -100
        animateLayoutChanges()
    }
    
    func animateLayoutChanges() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
