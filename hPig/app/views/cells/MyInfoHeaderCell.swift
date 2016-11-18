//
//  MyInfoHeaderCell.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreGraphics
import Charts
import CoreData

class MyInfoHeaderCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var passNameLabel: UILabel!
    @IBOutlet weak var passDurationLabel: UILabel!
    @IBOutlet weak var studyTotalDurationView: UIView!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var numberOfVideoLabel: UILabel!
    @IBOutlet weak var historySegControl: UISegmentedControl!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var passInfoTitleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passInfoView: UIStackView!
    
    weak var viewController: UIViewController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        studyTotalDurationView.layer.cornerRadius = 5.0
        studyTotalDurationView.layer.borderColor = UIColor.lightGray.cgColor
        studyTotalDurationView.layer.borderWidth = 1.0
        
        loginButton.layer.borderColor = UIColor.black.cgColor
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(self.login), for: .touchUpInside)
        
        self.contentView.isUserInteractionEnabled = false        
    }
    
    func loadUserInfo(_ user: TubeUserInfo?) {
        self.loadPersonalInfoView(user)

        let id = user?.id ?? kGuestId
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

        self.presentPassInfoButton(user)
    }
    
    private func loadPersonalInfoView(_ user: TubeUserInfo?) {
        let name = user?.nickname ?? "게스트"
        let id = user?.id ?? kGuestId
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
    
    private func presentPassInfoButton(_ user: TubeUserInfo?) {
        if let tubeUser = user {
            self.passInfoTitleLabel.text = "보유 이용권 정보"

            if let endDate = tubeUser.enddt {
                self.loginButton.isHidden = true
                self.passInfoView.isHidden = false
                self.passDurationLabel.text = "\(endDate) 까지"
            }
        } else {
            self.passInfoTitleLabel.text = ""
            self.passInfoView.isHidden = true
            self.loginButton.isHidden = false
        }
    }
    
    private func daysFromNow(days: Int) -> Date {
        let date = Date()
        let interval = Double(days * 24 * 60 * 60)
        return date.addingTimeInterval(interval)
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
        chartView.chartDescription?.text = ""

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
    
    func login() {
        if let controller = viewController {
            AuthenticateService.shared.tryLogin(controller) { (user) in
                self.loadUserInfo(user)
            }
        }
    }


    private func setChartData(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(values: dataEntries, label: "학습시간(분)")
        chartDataSet.colors = [pointColor]

        let chartData = BarChartData(dataSet: chartDataSet)
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

}
