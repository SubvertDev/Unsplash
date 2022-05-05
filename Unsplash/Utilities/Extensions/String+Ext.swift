//
//  String+Ext.swift
//  Unsplash
//
//  Created by  Subvert on 4/30/22.
//

import Foundation

extension String {
    
    func fromIsoDateToString() -> String {
        let isoFormatter = ISO8601DateFormatter()
        let isoDate = isoFormatter.date(from: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMM d, yyyy"
        let date = dateFormatter.string(from: isoDate ?? Date())
        return date
    }
}
