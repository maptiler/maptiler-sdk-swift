//
//  Benchmark.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK

class BenchmarkVC: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startStressTestButton: UIButton!
    
    var benchmark: MTBenchmark!

    override func viewDidLoad() {
        super.viewDidLoad()

        Task { [weak self] in
            guard let self else {
                return
            }

            self.benchmark = await MTBenchmark(frame: self.view.frame)
            self.view.addSubview(self.benchmark.mapView)
            self.view.bringSubviewToFront(self.startButton)
            self.view.bringSubviewToFront(self.startStressTestButton)
        }
    }

    private func performBenchmark() {
        Task {
            await benchmark.start()
        }
    }

    @IBAction func startButtonTouchUpInside(_ sender: UIButton) {
        performBenchmark()
    }

    @IBAction func stressTestButtonTouchUpInside(_ sender: UIButton) {
        Task {
            await benchmark.startStressTest()
        }
    }
}
