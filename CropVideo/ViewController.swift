//
//  ViewController.swift
//  CropVideo
//
//  Created by Dipakbhai Valjibhai Makwana on 23/04/23.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Photos
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addTabView()
    }

    private func addTabView() {
        // Create a UIHostingController with your SwiftUI view
               let swiftUIView = MyTabView()
               let hostingController = UIHostingController(rootView: swiftUIView)

               // Add the hosting controller's view as a subview
               addChild(hostingController)
               view.addSubview(hostingController.view)
               hostingController.view.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                   hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
               ])
               hostingController.didMove(toParent: self)
           
    }

}

