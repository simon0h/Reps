//
//  SingleRepCell.swift
//  Reps
//
//  Created by Simon Oh on 1/27/24.
//

import UIKit

class SingleRepCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var workoutWeight: UILabel!
    @IBOutlet weak var weightImageView: UIImageView!
    @IBOutlet weak var workoutNameCell: UIView!
    @IBOutlet weak var workoutDetailCell: UIView!
    @IBOutlet weak var workoutTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var lbsLabel: UILabel!
    
    var markedDone = false
    
    var viewController: ViewController?
    
    var contextMenuInteraction: UIContextMenuInteraction?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        workoutTextField.delegate = self
        workoutTextField.isHidden = true
        weightTextField.delegate = self
        weightTextField.isHidden = true
        workoutName.isUserInteractionEnabled = true
        workoutWeight.isUserInteractionEnabled = true
        //workoutTextField.addDoneButtonToKeyboard(myAction:  #selector(self.weightTextField.resignFirstResponder))
        weightTextField.addDoneButtonToKeyboard(myAction:  #selector(self.weightTextField.resignFirstResponder))

    }
    
    @objc func enableWorkoutNameEdit() {
        workoutName.isHidden = true
        workoutTextField.isHidden = false
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissEditing))
        //contentView.addGestureRecognizer(tapGesture)
        //workoutName.becomeFirstResponder()
        workoutTextField.text = workoutName.text
        workoutTextField.becomeFirstResponder()
    }
    
    @objc func enableWorkoutWeightEdit() {
        workoutWeight.isHidden = true
        lbsLabel.isHidden = true
        weightTextField.isHidden = false
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissEditing))
        //contentView.addGestureRecognizer(tapGesture)
        //workoutName.becomeFirstResponder()
        weightTextField.text = workoutWeight.text
        weightTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (textField == workoutTextField) {
            workoutTextField.isHidden = true
            workoutName.isHidden = false
            workoutName.text = workoutTextField.text
            if let indexPath = viewController?.workoutTableView.indexPath(for: self) {
                viewController?.workouts[indexPath.row].workoutName = workoutTextField.text ?? ""
            }
            workoutTextField.endEditing(true)
        }
        if (textField == weightTextField) {
            weightTextField.isHidden = true
            workoutWeight.isHidden = false
            workoutWeight.text = weightTextField.text
            if let indexPath = viewController?.workoutTableView.indexPath(for: self) {
                let tempWeight = weightTextField.text ?? ""
                viewController?.workouts[indexPath.row].workoutWeight = Int(tempWeight) ?? 0
            }
            weightTextField.endEditing(true)
        }
        return true
    }
    
//    @objc func dismissEditing() {
//        workoutTextField.resignFirstResponder()
//        workoutTextField.isHidden = true
//        workoutName.isHidden = false
//        workoutName.text = workoutTextField.text
//    }

//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        if let char = string.cString(using: String.Encoding.utf8) {
//            let isBackSpace = strcmp(char, "\\b")
//            if (isBackSpace == -92) {
//                print("Backspace was pressed")
//            }
//        }
//        return true
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension UITextField{

 func addDoneButtonToKeyboard(myAction:Selector?){
    let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
    doneToolbar.barStyle = UIBarStyle.default

     let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
     let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: myAction)

    var items = [UIBarButtonItem]()
    items.append(flexSpace)
    items.append(done)

    doneToolbar.items = items
    doneToolbar.sizeToFit()

    self.inputAccessoryView = doneToolbar
 }
}

