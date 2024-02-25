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
        var cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! SingleRepCell
        cell.backgroundColor = UIColor(UIColor.green)
        
    }
}
