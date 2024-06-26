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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "WorkoutEntity", in: managedContext)!
        fetchWorkouts()
    }
    
    func fetchWorkouts() {
        let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor] // Uses an array because more than one sortDescriptions can be used
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
            newWorkout.workoutName = "Long press to edit"
            newWorkout.workoutWeight = 0
            newWorkout.order = Int16(workouts.count)
            workouts.append(newWorkout)
            saveContext()
            DispatchQueue.main.async {
                self.workoutTableView.reloadData()
                let indexPath = IndexPath(row: self.workouts.count - 1, section: 0)
                self.workoutTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
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
        if (!workout.doneness) {
            cell.workoutNameCell.backgroundColor = UIColor.lightGray
            cell.workoutDetailCell.backgroundColor = UIColor.lightGray
        }
        else {
            cell.workoutNameCell.backgroundColor = UIColor.green
            cell.workoutDetailCell.backgroundColor = UIColor.green
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SingleRepCell {
            //let workout = workouts[indexPath.row]
            cell.changeDoneness()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let workout = workouts[indexPath.row]
            workouts.remove(at: indexPath.row)
            managedContext.delete(workout)
            saveContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            DispatchQueue.main.async {
                self.workoutTableView.reloadData()
                //let indexPath = IndexPath(row: self.workouts.count - 1, section: 0)
                //self.workoutTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
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
        for (index, workout) in workouts.enumerated() {
            workout.order = Int16(index)
        }
        saveContext()
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
            let divider = UIMenu(title: "", options: .displayInline, children: [reorderAction, editWorkoutAction, editWeightAction])
            return UIMenu(title: "", children: [divider])
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
    }
}
