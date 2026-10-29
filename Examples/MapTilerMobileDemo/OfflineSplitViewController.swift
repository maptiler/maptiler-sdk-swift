//
//  OfflineSplitViewController.swift
//  MapTilerMobileDemo
//

import UIKit
import SwiftUI

class OfflineSplitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let containerView = OfflineContainerView()
        let hostingController = UIHostingController(rootView: containerView)

        addChild(hostingController)
        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}

struct OfflineContainerView: View {
    @State private var selectedMode = 0
    @State private var showingPackTools = false

    var body: some View {
        ZStack(alignment: .top) {
            // The underlying map views
            if selectedMode == 0 {
                OfflineBasicView()
            } else {
                OfflineRoutingView()
            }

            // The floating switcher
            Picker("Mode", selection: $selectedMode) {
                Text("Basic").tag(0)
                Text("Route").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(8)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.top, 16)
            // Hidden entry to the pack estimator and calibration tools.
            .simultaneousGesture(LongPressGesture(minimumDuration: 1.5).onEnded { _ in showingPackTools = true })
        }
        .animation(.easeInOut, value: selectedMode)
        .fullScreenCover(isPresented: $showingPackTools) {
            PackToolsView()
        }
    }
}
