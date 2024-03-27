//
//  ViewController.swift
//  Reps
//
//  Created by Simon Oh on 1/27/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var workoutTableView: UITableView!
    @IBOutlet weak var addNewButton: UIButton!
    
    var workouts: [WorkoutEntity] = []
    var managedContext: NSManagedObjectContext!
    var entity: NSEntityDescription!

    override func viewDidLoad() {
        super.viewDidLoad()
        workoutTableView.delegate = self
        workoutTableView.dataSource = self
        workoutTableView.register(UINib(nibName: Constants.cellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeGesture.direction = .left
        workoutTableView.addGestureRecognizer(swipeGesture)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "WorkoutEntity", in: managedContext)!
        fetchWorkouts()
    }
    
    func fetchWorkouts() {
        let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        do {
            workouts = try managedContext.fetch(fetchRequest)
        }
        catch {
            print("Failed to fetch workouts: \(error)")
        }
    }
    
    func saveContext() {
        do {
            try managedContext.save()
        }
        catch {
            print("Failed to save context: \(error)")
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if (workoutTableView.isEditing) {
            workoutTableView.isEditing = false
            addNewButton.setTitle("Add New", for: .normal)
        }
        else {
            let newWorkout = WorkoutEntity(context: managedContext)
            newWorkout.workoutName = "test"
            newWorkout.workoutWeight = 20
            workouts.append(newWorkout)
            saveContext()
            DispatchQueue.main.async {
                self.workoutTableView.reloadData()
                let indexPath = IndexPath(row: self.workouts.count - 1, section: 0)
                self.workoutTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
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
        cell.workout = workout
        cell.viewController = self
        cell.contextMenuInteraction = UIContextMenuInteraction(delegate: self) // Adding contextMenu class to SingleRepCell
        cell.addInteraction(cell.contextMenuInteraction!) // Adding tap and hold gesture to SingleRepCell
        // Because the delegate is self (aka this ViewController object), when contextMenuInteraction is called, delegate method contextMenuInteraction from this class is called
        cell.workoutName.text = workout.workoutName
        cell.workoutWeight.text = String(workout.workoutWeight)
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
            let workout = workouts[indexPath.row]
            managedContext.delete(workout)
            workouts.remove(at: indexPath.row)
            saveContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            DispatchQueue.main.async {
                self.workoutTableView.reloadData()
                let indexPath = IndexPath(row: self.workouts.count - 1, section: 0)
                self.workoutTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedWorkout = workouts[sourceIndexPath.row]
        workouts.remove(at: sourceIndexPath.row)
        workouts.insert(movedWorkout, at: destinationIndexPath.row)
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
        let identifier = "\(indexPath.row)" as NSString
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            let reorderAction = UIAction(title: "Reorder", image: UIImage(systemName: "arrow.up.arrow.down")) { _ in
                self.workoutTableView.isEditing = true
                self.addNewButton.setTitle("Done", for: .normal)
            }
            let editWorkoutAction = UIAction(title: "Edit Workout Name", image: UIImage(systemName: "character.bubble.fill")) { _ in
                cell.enableWorkoutNameEdit()
            }
            let editWeightAction = UIAction(title: "Edit Workout Weight", image: UIImage(systemName: "dumbbell.fill")) { _ in
                cell.enableWorkoutWeightEdit()
            }
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.workouts.remove(at: indexPath.row)
                self.workoutTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let divider = UIMenu(title: "", options: .displayInline, children: [reorderAction, editWorkoutAction, editWeightAction])
            return UIMenu(title: "", children: [divider, deleteAction])
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        // No preview action in this example
    }
}
