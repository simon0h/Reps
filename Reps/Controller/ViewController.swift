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
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        workoutTableView.addGestureRecognizer(longPressGesture)
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
        // Get location of swipe
        let location = sender.location(in: workoutTableView)
        
        // Get indexPath of cell at swipe location
        if let indexPath = workoutTableView.indexPathForRow(at: location) {
            // Perform actions based on indexPath
            print("Swiped on cell at section \(indexPath.section), row \(indexPath.row)")
        }
    }
    
    @objc func handleLongPressGesture(sender: UISwipeGestureRecognizer) {
        // Get location of swipe
        let location = sender.location(in: workoutTableView)
        
        // Get indexPath of cell at swipe location
        if let indexPath = workoutTableView.indexPathForRow(at: location) {
            // Perform actions based on indexPath
            print("Long pressed on cell at section \(indexPath.section), row \(indexPath.row)")
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
        cell.workoutName.text = workout.workoutName
        cell.workoutWeight.text = String(workout.workoutWeight) + " lbs"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SingleRepCell {
            if (cell.markedDone) {
                cell.workoutNameCell.backgroundColor = UIColor.gray
                cell.workoutDetailCell.backgroundColor = UIColor.gray
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
