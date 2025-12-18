//
//  ComplicationController.swift
//  LifeDeckWatch Extension
//
//  Created on 2024
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {

    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "com.lifedeck.watch.complication", displayName: "LifeDeck", supportedFamilies: CLKComplicationFamily.allCases)
        ]

        handler(descriptors)
    }

    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary setup for shared complication descriptors
    }

    // MARK: - Timeline Configuration

    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Return the end date of the timeline
        handler(nil)
    }

    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Show the complication on the lock screen
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        getSnapshotData(for: complication) { data in
            if let template = data?.complicationTemplate {
                let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(entry)
            } else {
                handler(nil)
            }
        }
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // This app only shows the current entry
        handler(nil)
    }

    // MARK: - Placeholder Templates

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = createTemplate(for: complication.family, data: SampleData())
        handler(template)
    }

    // MARK: - Private Methods

    private func getSnapshotData(for complication: CLKComplication, handler: @escaping (ComplicationData?) -> Void) {
        // Get current user data from shared container or WatchConnectivity
        let data = ComplicationData(
            lifeScore: UserDefaults.standard.integer(forKey: "lifeScore"),
            streak: UserDefaults.standard.integer(forKey: "currentStreak"),
            nextCardTitle: UserDefaults.standard.string(forKey: "nextCardTitle") ?? "Complete daily card"
        )
        handler(data)
    }

    private func createTemplate(for family: CLKComplicationFamily, data: ComplicationData) -> CLKComplicationTemplate? {
        switch family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "\(data.lifeScore)")
            template.line2TextProvider = CLKSimpleTextProvider(text: "Life")
            return template

        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "LifeDeck")
            template.body1TextProvider = CLKSimpleTextProvider(text: "Score: \(data.lifeScore)")
            template.body2TextProvider = CLKSimpleTextProvider(text: "Streak: \(data.streak)")
            return template

        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "\(data.lifeScore)")
            return template

        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "LifeDeck: \(data.lifeScore)")
            return template

        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "\(data.lifeScore)")
            template.line2TextProvider = CLKSimpleTextProvider(text: "LD")
            return template

        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "\(data.lifeScore)")
            template.line2TextProvider = CLKSimpleTextProvider(text: "LifeDeck")
            return template

        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.innerTextProvider = CLKSimpleTextProvider(text: "\(data.lifeScore)")
            template.outerTextProvider = CLKSimpleTextProvider(text: "Life")
            return template

        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.textProvider = CLKSimpleTextProvider(text: "LifeDeck \(data.lifeScore)")
            return template

        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "\(data.lifeScore)")
            template.line2TextProvider = CLKSimpleTextProvider(text: "Life")
            return template

        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "LifeDeck")
            template.body1TextProvider = CLKSimpleTextProvider(text: "Score: \(data.lifeScore)")
            template.body2TextProvider = CLKSimpleTextProvider(text: "Streak: \(data.streak)")
            return template

        default:
            return nil
        }
    }
}

// MARK: - Data Models

struct ComplicationData {
    let lifeScore: Int
    let streak: Int
    let nextCardTitle: String
}

struct SampleData {
    let lifeScore = 75
    let streak = 7
    let nextCardTitle = "Morning meditation"
}