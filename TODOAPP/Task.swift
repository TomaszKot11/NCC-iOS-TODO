//
//  Task.swift
//  TODOAPP
//
//  Created by Tomasz Kot on 10/07/2019.
//  Copyright © 2019 Tomasz Kot. All rights reserved.
//

import Foundation
import CoreData

public struct Task {
    var title: String
    var description: String
    var date: String
    var isDone: Bool
    //TODO: use UUID type
    var uuid: String
}
