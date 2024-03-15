//
//  ViewController.swift
//  Reps
//
//  Created by Simon Oh on 1/27/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var workoutTableView: UITableView!
    
    var workouts: [Workout] = [Workout(workoutName: "Dumbbell bench press", workoutWeight: 15), Workout(workoutName: "Dumbbell fly", workoutWeight: 15)]

    override func viewDidLoad() {
        super.viewDidLoad()
        workoutTableView.delegate = self
        workoutTableView.dataSource = self
        workoutTableView.register(UINib(nibName: Constants.cellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeGesture.direction = .left
        workoutTableView.addGestureRecognizer(swipeGesture)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let newWorkout = Workout(workoutName: "test", workoutWeight: 20)
        workouts.append(newWorkout)
        DispatchQueue.main.async {
            self.workoutTableView.reloadData()
            let indexPath = IndexPath(row: self.workouts.count - 1, section: 0)
            self.workoutTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func handleSwipeGesture(sender: UISwipeGestureRecognizer) {
        let swipedAtRow = sender.location(in: workoutTableView)
        if let indexPath = workoutTableView.indexPathForRow(at: swipedAtRow) {
            print("Swiped on cell at section \(indexPath.section), row \(indexPath.row)")
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workout = workouts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! SingleRepCell
        cell.viewController = self
        cell.contextMenuInteraction = UIContextMenuInteraction(delegate: self) // Adding contextMenu class to SingleRepCell
        cell.addInteraction(cell.contextMenuInteraction!) // Adding tap and hold gesture to SingleRepCell
        // Because the delegate is self (aka this ViewController object), when contextMenuInteraction is called, delegate method contextMenuInteraction from this class is called
        cell.workoutName.text = workout.workoutName
        cell.workoutWeight.text = String(workout.workoutWeight) + " lbs"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SingleRepCell {
            if (cell.markedDone) {
                cell.workoutNameCell.backgroundColor = UIColor.lightGray
                cell.workoutDetailCell.backgroundColor = UIColor.lightGray
                cell.markedDone = false
            }
            else {
                cell.workoutNameCell.backgroundColor = UIColor.green
                cell.workoutDetailCell.backgroundColor = UIColor.green
                cell.markedDone = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            workouts.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.workoutTableView.reloadData()
                let indexPath = IndexPath(row: self.workouts.count - 1, section: 0)
                self.workoutTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
}

extension ViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = interaction.view as? SingleRepCell else {
            return nil
        }
        guard let indexPath = workoutTableView.indexPath(for: cell) else {
            return nil
        }

        let workout = workouts[indexPath.row]
        let identifier = "\(indexPath.row)" as NSString
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                cell.enableWorkoutNameEdit()
                print("Edit action for \(workout.workoutName)")
            }
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.workouts.remove(at: indexPath.row)
                self.workoutTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        // No preview action in this example
    }
}
