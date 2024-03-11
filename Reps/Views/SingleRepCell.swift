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
    
    var markedDone = false
    
    var viewController: ViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        workoutTextField.delegate = self
        workoutTextField.isHidden = true
        workoutName.isUserInteractionEnabled = true
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(workoutNameCellTapped))
        workoutNameCell.addGestureRecognizer(tapGesture)
        workoutTextField.backgroundColor = .clear
    }
    
    @objc func workoutNameCellTapped() {
        workoutName.isHidden = true
        workoutTextField.isHidden = false
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissEditing))
        //contentView.addGestureRecognizer(tapGesture)
        //workoutName.becomeFirstResponder()
        workoutTextField.text = workoutName.text
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        workoutTextField.isHidden = true
//        workoutName.isHidden = false
//        workoutName.text = workoutTextField.text
//        workoutTextField.endEditing(true)
//        return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        workoutTextField.isHidden = true
        workoutName.isHidden = false
        workoutName.text = workoutTextField.text

        // Find the corresponding Workout object in the viewController's workouts array
        if let viewController = self.viewController as? ViewController,
           let indexPath = viewController.workoutTableView.indexPath(for: self) {
            viewController.workouts[indexPath.row].workoutName = workoutTextField.text ?? ""
        }
        workoutTextField.endEditing(true)
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
