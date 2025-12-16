import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {

    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "com.lifedeck.score",
                displayName: "Life Score",
                supportedFamilies: [
                    .circularSmall,
                    .extraLarge,
                    .graphicBezel,
                    .graphicCircular,
                    .graphicCorner,
                    .graphicRectangular,
                    .modularLarge,
                    .modularSmall,
                    .utilitarianLarge,
                    .utilitarianSmall,
                    .utilitarianSmallFlat
                ]
            ),
            CLKComplicationDescriptor(
                identifier: "com.lifedeck.streak",
                displayName: "Current Streak",
                supportedFamilies: [
                    .circularSmall,
                    .extraLarge,
                    .modularSmall,
                    .utilitarianSmall,
                    .utilitarianSmallFlat
                ]
            )
        ]

        handler(descriptors)
    }

    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary setup for the shared complications
    }

    // MARK: - Timeline Configuration

    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Return the end date of the timeline
        handler(nil)
    }

    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Show complication data on the lock screen
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Get current data from shared storage or WatchDataManager
        let lifeScore = UserDefaults.standard.double(forKey: "lifeScore")
        let currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        let stepCount = UserDefaults.standard.integer(forKey: "stepCount")

        let entry: CLKComplicationTimelineEntry?

        switch complication.identifier {
        case "com.lifedeck.score":
            entry = createScoreEntry(for: complication, score: lifeScore)
        case "com.lifedeck.streak":
            entry = createStreakEntry(for: complication, streak: currentStreak)
        default:
            entry = nil
        }

        handler(entry)
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Return future timeline entries if needed
        handler(nil)
    }

    // MARK: - Sample Templates

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template: CLKComplicationTemplate?

        switch complication.identifier {
        case "com.lifedeck.score":
            template = createScoreTemplate(for: complication, score: 75.0)
        case "com.lifedeck.streak":
            template = createStreakTemplate(for: complication, streak: 5)
        default:
            template = nil
        }

        handler(template)
    }

    // MARK: - Private Methods

    private func createScoreEntry(for complication: CLKComplication, score: Double) -> CLKComplicationTimelineEntry? {
        let template = createScoreTemplate(for: complication, score: score)
        guard let template = template else { return nil }

        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
    }

    private func createStreakEntry(for complication: CLKComplication, streak: Int) -> CLKComplicationTimelineEntry? {
        let template = createStreakTemplate(for: complication, streak: streak)
        guard let template = template else { return nil }

        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
    }

    private func createScoreTemplate(for complication: CLKComplication, score: Double) -> CLKComplicationTemplate? {
        let scoreInt = Int(score)
        let fraction = score / 100.0

        switch complication.family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "\(scoreInt)")
            template.fillFraction = fraction
            template.ringStyle = .closed
            return template

        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeRingText()
            template.textProvider = CLKSimpleTextProvider(text: "\(scoreInt)")
            template.fillFraction = fraction
            template.ringStyle = .closed
            return template

        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "\(scoreInt)")
            template.fillFraction = fraction
            template.ringStyle = .closed
            return template

        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "\(scoreInt)")
            template.fillFraction = fraction
            template.ringStyle = .closed
            return template

        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            template.centerTextProvider = CLKSimpleTextProvider(text: "\(scoreInt)")
            template.gaugeProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColor: .green, fillFraction: fraction)
            return template

        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.circularTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeText(
                centerTextProvider: CLKSimpleTextProvider(text: "\(scoreInt)"),
                gaugeProvider: CLKSimpleGaugeProvider(style: .ring, gaugeColor: .green, fillFraction: fraction)
            )
            template.textProvider = CLKSimpleTextProvider(text: "LifeDeck")
            return template

        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Life Score")
            template.body1TextProvider = CLKSimpleTextProvider(text: "\(scoreInt)/100")
            template.body2TextProvider = CLKSimpleTextProvider(text: getScoreDescription(score))
            return template

        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "LifeDeck Score")
            template.body1TextProvider = CLKSimpleTextProvider(text: "\(scoreInt) points")
            template.body2TextProvider = CLKSimpleTextProvider(text: getScoreDescription(score))
            return template

        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            template.outerTextProvider = CLKSimpleTextProvider(text: "\(scoreInt)")
            template.gaugeProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColor: .green, fillFraction: fraction)
            template.leadingTextProvider = CLKSimpleTextProvider(text: "Life")
            return template

        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "Life Score: \(scoreInt)")
            return template

        @unknown default:
            return nil
        }
    }

    private func createStreakTemplate(for complication: CLKComplication, streak: Int) -> CLKComplicationTemplate? {
        switch complication.family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "\(streak)")
            return template

        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "\(streak)🔥")
            return template

        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "\(streak)")
            template.shortTextProvider = CLKSimpleTextProvider(text: "\(streak)")
            return template

        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "\(streak) day streak")
            return template

        default:
            return nil
        }
    }

    private func getScoreDescription(_ score: Double) -> String {
        switch score {
        case 0..<25: return "Getting started"
        case 25..<50: return "Building momentum"
        case 50..<75: return "Making progress"
        case 75..<90: return "Doing great"
        default: return "Excellent!"
        }
    }
}