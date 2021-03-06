//
//  Task.swift
//  BeyondViewControllers
//
//  Created by Joshua Sullivan on 11/4/16.
//  Copyright © 2016 Josh Sullivan. All rights reserved.
//

import Swift

/// An enumeration of the various user tasks that compose this app.
public enum Task {
    
    /// The state of the app on cold launch. This task cannot be switched to from another task.
    case startup
    
    /// Log the user in.
    case login
    
    /// Get a current weather forecast.
    case forecast
    
    /// Get help and information about the app.
    case help
}
