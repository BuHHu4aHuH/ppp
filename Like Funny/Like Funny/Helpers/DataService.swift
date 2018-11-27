//
//  DataService.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/4/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import Foundation

class DataService {
    
    private init() {}
    static let shared = DataService()
    
    func getData(completion: (Data) -> Void) {
        guard let path = Bundle.main.path(forResource: "pozdravleniya", ofType: ".json") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            completion(data)
        } catch {
            print(error)
        }
    }
}
