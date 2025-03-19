//
//  Benchmark.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK

class BenchmarkVC: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startStressTestButton: UIButton!
    @IBOutlet weak var benchmarkView: UIView!
    @IBOutlet weak var iterationsSegmentControl: UISegmentedControl!
    @IBOutlet weak var markersSwitch: UISwitch!
    @IBOutlet weak var logView: UIView!
    @IBOutlet weak var logTextView: UITextView!
    
    var benchmark: MTBenchmark!

    var iterations: Int {
        switch iterationsSegmentControl.selectedSegmentIndex {
            case 0: return 100
            case 1: return 1000
            case 2: return 10000
            case 3: return 100000
            default: return 1
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task { [weak self] in
            guard let self else {
                return
            }

            self.benchmark = await MTBenchmark(frame: self.view.frame)
            self.setAPIKey()

            self.view.addSubview(self.benchmark.mapView)
            self.view.bringSubviewToFront(self.benchmarkView)
            self.view.bringSubviewToFront(self.startStressTestButton)
            self.view.bringSubviewToFront(self.logView)

            self.benchmark.didUpdateStressTest = { log in
                self.logTextView.text = "\(self.logTextView.text ?? "")\n\(log)"
                let range = NSMakeRange(self.logTextView.text.count - 1, 1)
                self.logTextView.scrollRangeToVisible(range)
            }

            // Hidden
//            self.view.bringSubviewToFront(self.startButton)
        }
    }

    private func setAPIKey() {
        let placeholderKey = "YOUR_API_KEY_HERE"
        guard let mapTilerAPIKey = Bundle.main.object(forInfoDictionaryKey: "MapTilerAPIKey") as? String, mapTilerAPIKey != placeholderKey else {
            assertionFailure("API Key not entered in Info.plist file. Enter your API Key in Info.plist file under the key 'MapTilerAPIKey' field.")

            return
        }

        benchmark.setAPIKey(apiKey: mapTilerAPIKey)
    }

    private func performBenchmark() {
        Task {
            await benchmark.start()
        }
    }

    @IBAction func startButtonTouchUpInside(_ sender: UIButton) {
        startButton.isEnabled = false
        performBenchmark()
    }

    @IBAction func stressTestButtonTouchUpInside(_ sender: UIButton) {
        startStressTestButton.isEnabled = false
        Task {
            await benchmark.startStressTest(iterations: iterations, markersAreOn: markersSwitch.isOn)
        }
    }
}
