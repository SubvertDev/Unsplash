//
//  UIViewController+Ext.swift
//  Unsplash
//
//  Created by  Subvert on 4/30/22.
//

import UIKit

extension UIViewController {
    
    func showErrorOnMainThread(_ error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
