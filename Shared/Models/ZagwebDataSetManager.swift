//
//  BalanceList.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 8/27/17.
//
//

import Foundation


final class ZagwebDataSetManager {
    
    static var dataSets: [ZagwebDataSet] {
        get {
            return ZagwebDataSetList.loadDataSets()
        }
    }

    static func add(dataSet: ZagwebDataSet) {
        var tmp = dataSets
        tmp.append(dataSet)
        ZagwebDataSetList.save(dataSets: tmp)
    }
    
    static func purgeDataSets() {
        ZagwebDataSetList.save(dataSets: [])
    }
    
    
}

fileprivate final class ZagwebDataSetList: Codable {
    
    let dataSets: [ZagwebDataSet]
    
    init(dataSets: [ZagwebDataSet]) {
        self.dataSets = dataSets
    }
    
}


// MARK: Persistance
extension ZagwebDataSetList {
    
    static func loadDataSets() -> [ZagwebDataSet] {
        
        guard let data = UserDefaults.standard.object(forKey: "SavedZagwebDataSets") as? Data,
        let dataSets = try? JSONDecoder().decode([ZagwebDataSet].self, from: data) else {
            // Default
            return []
        }
        return dataSets
    }
    
    static func save(dataSets: [ZagwebDataSet]) -> Bool {
        
        if let pageData = try? JSONEncoder().encode(dataSets) {
            UserDefaults.standard.set(pageData, forKey: "SavedZagwebDataSets")
            return true
        }
        return false
    }
}


