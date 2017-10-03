//
//  ComplicationController.swift
//  Bulldog Buck Balance Extension
//
//  Created by Rudy Bermudez on 3/11/17.
//
//

import ClockKit
import WatchKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        if ZagwebDataSetManager.dataSets.isEmpty {
            handler([])
        } else {
            handler([.backward])
        }
       
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        
        guard let firstBalance = ZagwebDataSetManager.dataSets.first else {
            // No data is cached yet
            handler(nil)
            return
        }
        
        handler(firstBalance.date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        
        guard let lastBalance = ZagwebDataSetManager.dataSets.last else {
            // No data is cached yet
            handler(nil)
            return
        }
        
        handler(lastBalance.date)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        print("Get Current Timeline Entry Did Begin")
        
        handler(timelineEntryFor(ZagwebDataSetManager.dataSets.last, family: complication.family))
        
        
        print("Get Current Timeline Entry Did End")

    }

    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        
        
        var sortedBalances = ZagwebDataSetManager.dataSets.filter {
            $0.date.compare(date) == .orderedAscending
        }
        
        if sortedBalances.count > limit {
            // Remove from the front
            let numberToRemove = sortedBalances.count - limit
            sortedBalances.removeSubrange(0..<numberToRemove)
        }
    
        let entries = sortedBalances.flatMap { balance in
            self.timelineEntryFor(balance, family: complication.family)
        }

        handler(entries)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        
        
        var sortedBalances = ZagwebDataSetManager.dataSets.filter {
            $0.date.compare(date) == .orderedDescending
        }
        
        if sortedBalances.count > limit {
            // Remove from the back
            sortedBalances.removeSubrange(limit..<sortedBalances.count)
        }
        
        let entries = sortedBalances.flatMap { balance in
            timelineEntryFor(balance, family: complication.family)
        }
        
        handler(entries)
    }
    
    func getTimelineAnimationBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void) {
        handler(.never)
    }
    
    func reloadOrExtendData() {
        
        let server = CLKComplicationServer.sharedInstance()
        
        guard let complications = server.activeComplications,
            complications.count > 0 else { print("Complication is not running. No reloadOrExtendData");return }
        
        if ZagwebDataSetManager.dataSets.last?.date.compare(server.latestTimeTravelDate) == .orderedDescending {
            for complication in complications {
                server.extendTimeline(for: complication)
            }
        } else {
            
            for complication in complications  {
                server.reloadTimeline(for: complication)
            }
        }
        
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        var template: CLKComplicationTemplate?
        switch complication.family {
        case .modularSmall:
            let modularTemplate = CLKComplicationTemplateModularSmallSimpleText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            template = modularTemplate
        case .modularLarge:
            let modularTemplate = CLKComplicationTemplateModularLargeStandardBody()
            modularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "Bulldog Bucks")
            modularTemplate.body1TextProvider = CLKSimpleTextProvider(text: "Updating...")
            modularTemplate.body2TextProvider = CLKSimpleTextProvider(text: "")
            template = modularTemplate
        case .utilitarianSmall:
            break
        case .utilitarianSmallFlat:
            let utilitarianTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            template = utilitarianTemplate
        case .utilitarianLarge:
            let utilitarianTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "Updating...")
            template = utilitarianTemplate
        case .circularSmall:
            let circularTemplate = CLKComplicationTemplateCircularSmallSimpleText()
            circularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            template = circularTemplate
        case .extraLarge:
            break
        }
        handler(template)
    }
    
    // MARK: Template Creation
    func timelineEntryFor(_ dataSet: ZagwebDataSet?, family: CLKComplicationFamily) -> CLKComplicationTimelineEntry? {
        
        
        guard let dataSet = dataSet else {
            
            switch family {
            case .modularSmall:
                let modularTemplate = CLKComplicationTemplateModularSmallSimpleText()
                modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
                return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: modularTemplate)
                
            case .modularLarge:
                let modularTemplate = CLKComplicationTemplateModularLargeStandardBody()
                modularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "Bulldog Bucks")
                modularTemplate.body1TextProvider = CLKSimpleTextProvider(text: "Open to login")
                return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: modularTemplate)
                
            case .utilitarianSmallFlat:
                let utilitarianTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
                utilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "--")
                return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: utilitarianTemplate)
                
            case .utilitarianLarge:
                let utilitarianTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
                utilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "--")
                return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: utilitarianTemplate)
                
            case .circularSmall:
                let circularTemplate = CLKComplicationTemplateCircularSmallSimpleText()
                circularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
                return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: circularTemplate)
                
            default: return nil
                
            }
            
        }
        NSLog("Displaying Complication with balance \(dataSet.bucksRemaining) from \(dataSet.date.description)")
        switch family {
        case .modularSmall:
            let modularTemplate = CLKComplicationTemplateModularSmallSimpleText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "$\(dataSet.bucksRemaining.shortTextBucksForComplication)")
            return CLKComplicationTimelineEntry(date: dataSet.date, complicationTemplate: modularTemplate)
            
        case .modularLarge:
            let modularTemplate = CLKComplicationTemplateModularLargeStandardBody()
            modularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "Bulldog Bucks")
            modularTemplate.body1TextProvider = CLKSimpleTextProvider(text: "$\(dataSet.bucksRemaining.longTextBucksForComplication)")
            modularTemplate.body2TextProvider = CLKSimpleTextProvider(text: "\(dataSet.swipesRemaining) Swipes")
            return CLKComplicationTimelineEntry(date: dataSet.date, complicationTemplate: modularTemplate)
            
        case .utilitarianSmallFlat:
            let utilitarianTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "$\(dataSet.bucksRemaining.shortTextBucksForComplication)")
            return CLKComplicationTimelineEntry(date: dataSet.date, complicationTemplate: utilitarianTemplate)
            
        case .utilitarianLarge:
            let utilitarianTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "$ \(dataSet.bucksRemaining.longTextBucksForComplication)")
            return CLKComplicationTimelineEntry(date: dataSet.date, complicationTemplate: utilitarianTemplate)
            
        case .circularSmall:
            let circularTemplate = CLKComplicationTemplateCircularSmallSimpleText()
            circularTemplate.textProvider = CLKSimpleTextProvider(text: "$\(dataSet.bucksRemaining.shortTextBucksForComplication)")
            return CLKComplicationTimelineEntry(date: dataSet.date, complicationTemplate: circularTemplate)
            
        default: return nil
            
        }
        
        
    }
    
    // Deprecated Functions
    // This form of complication updating will become deprecated in watchOS 4
    
    func downloadData() {
        guard let credentials = BDBKeychain.watchKeychain.getCredentials() else {
            NSLog("Background: User is not logged in")
            return
        }
        NSLog("In Complication Controller. User is logged in, attempting to connect to zagweb")
        ZagwebClient.getBulldogBucks(withStudentID: credentials.studentID, withPIN: credentials.PIN).then { (bucks, _, _, swipes) -> Void in
            let date = Date()
            NSLog("Background: Data Successfully downloaded in background. \(bucks) at \(date.description)")
            let newDataSet = ZagwebDataSet(bucksRemaining: bucks, swipesRemaining: swipes, date: date)
            ZagwebDataSetManager.add(dataSet: newDataSet)
            
            self.reloadOrExtendData()
            }.catch { (error) in
                NSLog(error.localizedDescription)
        }
        NSLog("In Complication Controller. Download Data function complete")
    }
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        guard let lastUpdate = ZagwebDataSetManager.dataSets.last else {
            handler(Date())
            return
        }
        let minutesSinceLastUpdate = NSDate().minutes(fromDate: lastUpdate.date as NSDate)
        if  minutesSinceLastUpdate > 30 {
            handler(Date())
        } else {
            let nextUpdateInMin = Double(30 - minutesSinceLastUpdate)
            handler(Date(timeIntervalSinceNow: 60 * nextUpdateInMin))
        }
        
    }
    
    func requestedUpdateDidBegin() {
        downloadData()
    }
    
    func requestedUpdateBudgetExhausted() {
        downloadData()
    }
    
    
    
}
