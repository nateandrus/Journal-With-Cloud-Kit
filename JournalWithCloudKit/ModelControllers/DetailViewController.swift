//
//  DetailViewController.swift
//  JournalWithCloudKit
//
//  Created by Nathan Andrus on 2/25/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate {

    //Landing Pad
    var entry: Entry? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    @IBOutlet weak var entryTitleTextField: UITextField!
    @IBOutlet weak var entryTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryTitleTextField.delegate = self
        updateViews()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let title = entryTitleTextField.text, !title.isEmpty,
            let text = entryTextField.text, !text.isEmpty else { return }
        if let entry = entry {
            EntryController.shared.update(entry: entry, title: title, text: text) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            EntryController.shared.addEntryWith(title: title, text: text) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        entryTitleTextField.text = ""
        entryTextField.text = ""
    }
    
    func updateViews() {
        guard let entry = entry else { return }
        entryTitleTextField.text = entry.title
        entryTextField.text = entry.text
        self.title = entry.title
    }
}
