//
//  Setup.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/28/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import Foundation


//protocol variables need to specify get/set
protocol Setup {
    static var id: String { get }
    
    func setup()
    func setupAppearance()
}

extension Setup {
    static var id: String {
        return String(self)
    }
}
