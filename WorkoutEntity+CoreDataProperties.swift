//
//  WorkoutEntity+CoreDataProperties.swift
//  Reps
//
//  Created by Simon Oh on 3/26/24.
//
//

import Foundation
import CoreData


extension WorkoutEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutEntity> {
        return NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
    }

    @NSManaged public var workoutName: String?
    @NSManaged public var workoutWeight: Int16

}

extension WorkoutEntity : Identifiable {

}
