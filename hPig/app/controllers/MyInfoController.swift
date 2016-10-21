//
//  MyInfoController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreGraphics
import CoreData
import Charts

class MyInfoController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var mainScroller: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var passNameLabel: UILabel!
    @IBOutlet weak var passDurationLabel: UILabel!
    @IBOutlet weak var studyTotalDurationView: UIView!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var numberOfVideoLabel: UILabel!
    @IBOutlet weak var historyCollectionView: UICollectionView!
    @IBOutlet weak var historySegControl: UISegmentedControl!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var chartView: BarChartView!
    
    private var histories = [HISTORY]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "학습 현황"
        
        studyTotalDurationView.layer.cornerRadius = 5.0
        studyTotalDurationView.layer.borderColor = UIColor.lightGray.cgColor
        studyTotalDurationView.layer.borderWidth = 1.0
        
        let ratio: CGFloat = 0.85
        let margin: CGFloat = 18
        let width = (view.bounds.size.width / 2) - margin
        
        flowLayout.itemSize = CGSize(width: width, height: width * ratio)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AuthenticateService.shared.user { (user) in
            self.loadPersonalInfoView(user)
            
            let id = user?.id ?? Global.guestId
            let logReq: NSFetchRequest<TIME_LOG> = TIME_LOG.fetchRequest()
            logReq.predicate = NSPredicate(format: "uid = '\(id)'")
            
            CoreDataService.shared.select(request: logReq) { (items, error) in
                self.loadStudyTimeInfoView(logs: items)
            }
            
            let sixDaysLogReq: NSFetchRequest<TIME_LOG> = TIME_LOG.fetchRequest()
            let sixDaysAgo = self.daysFromNow(days: -6)
            sixDaysLogReq.predicate = NSPredicate(format: "uid = '\(id)' AND regdt >= %@", sixDaysAgo as NSDate)
            
            CoreDataService.shared.select(request: sixDaysLogReq) { (items, error) in
                self.loadChart(logs: items)
            }
        }
        
        historySegChanged(historySegControl)
    }
    
    override func viewWillLayoutSubviews() {
        LayoutService.shared.adjustContentSize(mainScroller, subScroller: historyCollectionView)
    }
    
    @IBAction func historySegChanged(_ sender: UISegmentedControl) {
        AuthenticateService.shared.user { (user) in
            let id = user?.id ?? Global.guestId
            let historyReq: NSFetchRequest<HISTORY> = HISTORY.fetchRequest()
            historyReq.sortDescriptors = [NSSortDescriptor(key: "lastdate", ascending: false)]
            
            switch sender.selectedSegmentIndex {
            case 1:
                historyReq.predicate = NSPredicate(format: "uid = '\(id)' AND position != maxposition")
            case 2:
                historyReq.predicate = NSPredicate(format: "uid = '\(id)' AND position == maxposition")
            default:
                historyReq.predicate = NSPredicate(format: "uid = '\(id)'")
            }
            
            CoreDataService.shared.select(request: historyReq) { (items, error) in
                self.histories = items
                self.historyCollectionView.reloadData()
            }
        }
    }
    
    private func loadPersonalInfoView(_ user: TubeUserInfo?) {
        let name = user?.nickname ?? "게스트"
        let id = user?.id ?? Global.guestId
        let url = user?.image ?? "https://ssl.pstatic.net/static/pwe/address/nodata_45x45.gif"
        
        nameLabel.text = "\(name) 님"
        idLabel.text = "| \(id)"
        
        ImageDownloadService.shared.get(
            url: url,
            filter: nil,
            completionHandler: { (res) in
                if let image = res.result.value {
                    self.profileImageView.image = image
                }
        })
    }
    
    private func loadStudyTimeInfoView(logs: [TIME_LOG]) {
        var totalTime: Double = 0
        var vids = Set<String>()
        
        logs.forEach({ (log) in
            totalTime += log.studytime
            
            if let vid = log.vid {
                vids.insert(vid)
            }
        })
        
        totalDurationLabel.text = secondsToHoursMinutesSeconds(seconds: Int(totalTime))
        numberOfVideoLabel.text = "\(vids.count)개"
    }
    
    private func loadChart(logs: [TIME_LOG]) {
        chartView.noDataText = ""
        chartView.descriptionText = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        
        var days = [String]()
        for day in -6...0 {
            let newDate = daysFromNow(days: day)
            let dateString = formatter.string(from: newDate)
            days.append(dateString)
        }
        
        var logMap = [String : [TIME_LOG]]()
        
        for log in logs {
            if let regdt = log.regdt {
                let dateString = formatter.string(from: regdt as Date)
                var dayLogs = logMap[dateString] ?? [TIME_LOG]()
                dayLogs.append(log)
                logMap[dateString] = dayLogs
            }
        }
        
        let studyTimes = days.map { (dateString) -> Double in
            let dayLogs = logMap[dateString] ?? [TIME_LOG]()
            var sum: Double = 0
            
            for log in dayLogs {
                sum += log.studytime
            }
            
            return sum / 60
        }
        
        setChartData(dataPoints: days, values: studyTimes)
    }
    
    private func daysFromNow(days: Int) -> Date {
        let date = Date()
        let interval = Double(days * 24 * 60 * 60)
        return date.addingTimeInterval(interval)
    }
    
    private func setChartData(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "학습시간(분)")
        chartDataSet.colors = [pointColor]
        
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.labelPosition = .bottom
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInExpo)
        
    }
    
    private func secondsToHoursMinutesSeconds(seconds : Int) -> String {
        let h = String(format: "%02d", seconds / 3600)
        let m = String(format: "%02d", (seconds % 3600) / 60)
        let s = String(format: "%02d", (seconds % 3600) % 60)
        return "\(h):\(m):\(s)"
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return histories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studyHistoryCell", for: indexPath) as! StudyHistoryCell
        
        if let history = histories.get(indexPath.row) {
            cell.update(history: history)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = (segue.destination as! UINavigationController).topViewController,
            let basic = viewController as? BasicStudyController,
            let cell = sender as? StudyHistoryCell,
            let history = cell.history {
            
            basic.session = Session(history)
            basic.currentIndex = Int(history.position ?? "0")!
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPaths = historyCollectionView.indexPathsForSelectedItems,
            let indexPath = indexPaths.first,
            let history = histories.get(indexPath.row),
            let session = Session(history) {
            
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: session)
        } else {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: nil)
        }
    }
    
    @IBAction func returnedFromBasicStudy(segue: UIStoryboardSegue) {
        
    }
}
