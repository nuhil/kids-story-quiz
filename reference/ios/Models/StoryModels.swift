import Foundation
import AVFoundation

enum Topic: String, CaseIterable, Identifiable {
    case ocean = "ocean_life"
    case animals
    case space
    case science
    case math
    case culture
    case emotionsSocial = "emotions_social"
    case history
    case geography
    case technologyMachines = "technology_machines"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ocean: return "Ocean Life"
        case .animals: return "Animals"
        case .space: return "Space"
        case .science: return "Science"
        case .math: return "Math"
        case .culture: return "Culture"
        case .emotionsSocial: return "Emotions"
        case .history: return "History"
        case .geography: return "Geography"
        case .technologyMachines: return "Technology"
        }
    }

    var subtitle: String {
        switch self {
        case .ocean: return "Waves, reefs, and deep-sea wonders"
        case .animals: return "Habitats, sounds, and survival tricks"
        case .space: return "Planets, stars, and cosmic adventures"
        case .science: return "Experiments and how the world works"
        case .math: return "Patterns, numbers, and clever puzzles"
        case .culture: return "Traditions, greetings, and daily life"
        case .emotionsSocial: return "Feelings, empathy, and friendship skills"
        case .history: return "Then and now through simple time stories"
        case .geography: return "Maps, places, and environments around us"
        case .technologyMachines: return "How tools and machines help people"
        }
    }

    var icon: String {
        switch self {
        case .ocean: return "drop.fill"
        case .animals: return "pawprint.fill"
        case .space: return "sparkles"
        case .science: return "flask.fill"
        case .math: return "function"
        case .culture: return "globe.europe.africa.fill"
        case .emotionsSocial: return "face.smiling.fill"
        case .history: return "clock.fill"
        case .geography: return "map.fill"
        case .technologyMachines: return "gearshape.2.fill"
        }
    }
}

struct StoryPage: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let body: String
    let funFact: String
}

struct QuizOption: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isCorrect: Bool
}

struct QuizQuestion: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let options: [QuizOption]
    let factFeedbackCorrect: String
    let factFeedbackIncorrect: String

    var explanation: String {
        factFeedbackCorrect
    }
}

struct Story: Identifiable, Hashable {
    let id = UUID()
    let sourceStoryID: String
    let topic: Topic
    let title: String
    let subtitle: String
    let pages: [StoryPage]
    let quiz: [QuizQuestion]
    let badgeTitle: String
    let badgeSymbol: String

    var estimatedPoints: Int {
        quiz.count * 10
    }
}

struct QuizOutcome {
    let correctCount: Int
    let total: Int
    let pointsEarned: Int
    let gamePassesEarned: Int
    let badgesEarned: Int
    let badgeUnlocked: String?

    var scoreText: String {
        "\(correctCount)/\(total)"
    }
}

struct QuizReward {
    let pointsEarned: Int
    let gamePassesEarned: Int
    let badgesEarned: Int
}

struct UnlockedBadge: Identifiable, Hashable, Codable {
    let storySourceID: String
    let title: String
    let symbol: String

    var id: String { storySourceID }
}

struct BadgeInventoryItem: Identifiable, Hashable, Codable {
    let badgeKey: String
    let title: String
    let symbol: String
    var count: Int
    var lastEarnedAt: Date

    var id: String { badgeKey }
}

struct StoryQuizStats: Codable, Hashable {
    var questionCount: Int
    var attempts: Int = 0
    var totalCorrectAnswers: Int = 0
    var totalQuestionsAnswered: Int = 0
    var bestCorrectCount: Int = 0

    var weightedAccuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
    }

    var bestAccuracy: Double {
        guard questionCount > 0 else { return 0 }
        return Double(bestCorrectCount) / Double(questionCount)
    }

    mutating func registerAttempt(correctCount: Int, totalQuestions: Int) {
        let sanitizedCorrect = max(correctCount, 0)
        attempts += 1
        totalCorrectAnswers += sanitizedCorrect
        totalQuestionsAnswered += max(totalQuestions, 0)
        bestCorrectCount = max(bestCorrectCount, sanitizedCorrect)
    }
}

struct CategoryProgressSummary: Identifiable {
    let topic: Topic
    let totalStories: Int
    let startedStories: Int
    let masteredStories: Int
    let totalAttempts: Int
    let pointsEarned: Int
    let weightedAccuracy: Double

    var id: String { topic.id }

    var progressRatio: Double {
        guard totalStories > 0 else { return 0 }
        return Double(startedStories) / Double(totalStories)
    }

    var accuracyText: String {
        "\(Int((weightedAccuracy * 100).rounded()))%"
    }

    var progressText: String {
        "\(startedStories)/\(totalStories)"
    }

    var masteredText: String {
        "\(masteredStories)/\(totalStories)"
    }

    var performanceTitle: String {
        if totalAttempts == 0 { return "Ready to Explore" }
        if weightedAccuracy >= 0.86 { return "Master Explorer" }
        if weightedAccuracy >= 0.72 { return "Super Learner" }
        if weightedAccuracy >= 0.55 { return "Rising Star" }
        return "Brave Beginner"
    }

    var performanceMessage: String {
        if totalAttempts == 0 { return "Take your first quiz in this category." }
        if weightedAccuracy >= 0.86 { return "Amazing accuracy. Keep this streak!" }
        if weightedAccuracy >= 0.72 { return "Strong progress. One more story for mastery." }
        if weightedAccuracy >= 0.55 { return "Nice effort. Review fun facts and try again." }
        return "Great start. Practice makes it stronger."
    }
}

enum GameID: String, CaseIterable, Identifiable, Hashable {
    case balloonPop
    case snakeTrail
    case blockStack
    case ticTacToe
    case memoryMatch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .balloonPop: return "Balloon Pop"
        case .snakeTrail: return "Snake Trail"
        case .blockStack: return "Block Stack"
        case .ticTacToe: return "Tic-Tac-Toe"
        case .memoryMatch: return "Memory Match"
        }
    }

    var subtitle: String {
        switch self {
        case .balloonPop: return "Pop the right color bubbles fast."
        case .snakeTrail: return "Guide the snake and collect food."
        case .blockStack: return "Drop blocks and clear rows."
        case .ticTacToe: return "Play a quick strategy round."
        case .memoryMatch: return "Flip cards and match pairs."
        }
    }

    var icon: String {
        switch self {
        case .balloonPop: return "circle.grid.cross.fill"
        case .snakeTrail: return "arrow.trianglehead.turn.up.right.diamond.fill"
        case .blockStack: return "square.3.layers.3d.down.right"
        case .ticTacToe: return "grid"
        case .memoryMatch: return "rectangle.on.rectangle.angled"
        }
    }
}

enum GameUnlockSource {
    case pass
    case points
}

enum AppTab: Hashable {
    case home
    case quiz
    case play
    case goals
}

@MainActor
final class AppNavigationModel: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var requestedExploreTopic: Topic?
    @Published var exploreRequestID: UUID = UUID()

    func openExplore(topic: Topic?) {
        requestedExploreTopic = topic
        selectedTab = .home
        exploreRequestID = UUID()
    }
}

@MainActor
final class AppModel: ObservableObject {
    // Quick testing switch: set to false to restore normal lock/unlock behavior.
    let unlockAllGamesForTesting: Bool = true

    @Published var stories: [Story] = StoryRepository.makeStories()
    @Published var totalPoints: Int = 0
    @Published var unlockedBadges: [UnlockedBadge] = []
    @Published var badgeInventory: [BadgeInventoryItem] = []
    @Published var storyQuizStats: [String: StoryQuizStats] = [:]
    @Published var gamePassBalance: Int = 0
    @Published private(set) var gameUnlockExpirations: [GameID: Date] = [:]

    let quizPassThreshold: Double = 0.8
    let pointsPerGameUnlock: Int = 120
    let gameUnlockDuration: TimeInterval = 24 * 60 * 60
    private let categoryQuizBadgeKey = "category_quiz_master"
    private let categoryQuizBadgeTitle = "Quiz Challenger"
    private let categoryQuizBadgeSymbol = "brain.head.profile"
    private let progressStorageKey = "app_progress_snapshot_v2"

    init() {
        restoreProgress()
        expireGameUnlocks()
    }

    func completeQuiz(story: Story, correctCount: Int) -> QuizOutcome {
        let total = story.quiz.count
        let reward = applyQuizReward(correctCount: correctCount, totalQuestions: total)
        totalPoints += reward.pointsEarned
        gamePassBalance += reward.gamePassesEarned

        let storyKey = story.sourceStoryID
        var stats = storyQuizStats[storyKey] ?? StoryQuizStats(questionCount: total)
        stats.questionCount = total
        stats.registerAttempt(correctCount: correctCount, totalQuestions: total)
        storyQuizStats[storyKey] = stats

        let percent = total == 0 ? 0 : Double(correctCount) / Double(total)
        var badgeUnlocked: String?
        if percent >= quizPassThreshold {
            badgeUnlocked = awardBadge(
                badgeKey: storyKey,
                title: story.badgeTitle,
                symbol: story.badgeSymbol
            )
        }

        persistProgress()

        return QuizOutcome(
            correctCount: correctCount,
            total: total,
            pointsEarned: reward.pointsEarned,
            gamePassesEarned: reward.gamePassesEarned,
            badgesEarned: reward.badgesEarned,
            badgeUnlocked: badgeUnlocked
        )
    }

    func completeCategoryQuiz(correctCount: Int, totalQuestions: Int) -> QuizReward {
        let reward = applyQuizReward(correctCount: correctCount, totalQuestions: totalQuestions)
        totalPoints += reward.pointsEarned
        gamePassBalance += reward.gamePassesEarned
        if reward.gamePassesEarned > 0 {
            _ = awardBadge(
                badgeKey: categoryQuizBadgeKey,
                title: categoryQuizBadgeTitle,
                symbol: categoryQuizBadgeSymbol
            )
        }
        persistProgress()
        return reward
    }

    @discardableResult
    func unlockGame(_ game: GameID, source: GameUnlockSource, now: Date = Date()) -> Bool {
        if unlockAllGamesForTesting { return true }
        expireGameUnlocks(referenceDate: now)
        guard gameUnlockExpirations[game] == nil else { return false }

        switch source {
        case .pass:
            guard gamePassBalance > 0 else { return false }
            gamePassBalance -= 1
        case .points:
            guard totalPoints >= pointsPerGameUnlock else { return false }
            totalPoints -= pointsPerGameUnlock
        }

        gameUnlockExpirations[game] = now.addingTimeInterval(gameUnlockDuration)
        persistProgress()
        return true
    }

    func expireGameUnlocks(referenceDate: Date = Date()) {
        let filteredExpirations = gameUnlockExpirations.filter { $0.value > referenceDate }
        guard filteredExpirations != gameUnlockExpirations else { return }
        gameUnlockExpirations = filteredExpirations
        persistProgress()
    }

    func unlockExpiry(for game: GameID) -> Date? {
        if unlockAllGamesForTesting { return nil }
        return gameUnlockExpirations[game]
    }

    func isGameUnlocked(_ game: GameID, now: Date = Date()) -> Bool {
        if unlockAllGamesForTesting { return true }
        guard let expiry = gameUnlockExpirations[game] else { return false }
        return expiry > now
    }

    var activeGameUnlockCount: Int {
        if unlockAllGamesForTesting { return GameID.allCases.count }
        let referenceDate = Date()
        return gameUnlockExpirations.values.filter { $0 > referenceDate }.count
    }

    var totalBadgesEarnedCount: Int {
        badgeInventory.reduce(0) { $0 + $1.count }
    }

    func categoryProgressSummaries() -> [CategoryProgressSummary] {
        Topic.allCases.map { summary(for: $0) }
    }

    func summary(for topic: Topic) -> CategoryProgressSummary {
        let topicStories = stories.filter { $0.topic == topic }

        var startedStories = 0
        var masteredStories = 0
        var totalAttempts = 0
        var pointsEarned = 0
        var correctSum = 0
        var answeredSum = 0

        for story in topicStories {
            guard let stats = storyQuizStats[story.sourceStoryID], stats.attempts > 0 else { continue }
            startedStories += 1
            totalAttempts += stats.attempts
            pointsEarned += stats.totalCorrectAnswers * 10
            correctSum += stats.totalCorrectAnswers
            answeredSum += stats.totalQuestionsAnswered
            if stats.bestAccuracy >= 0.8 {
                masteredStories += 1
            }
        }

        let weightedAccuracy = answeredSum == 0 ? 0 : Double(correctSum) / Double(answeredSum)
        return CategoryProgressSummary(
            topic: topic,
            totalStories: topicStories.count,
            startedStories: startedStories,
            masteredStories: masteredStories,
            totalAttempts: totalAttempts,
            pointsEarned: pointsEarned,
            weightedAccuracy: weightedAccuracy
        )
    }

    func resetProgress() {
        totalPoints = 0
        unlockedBadges = []
        badgeInventory = []
        storyQuizStats = [:]
        gamePassBalance = 0
        gameUnlockExpirations = [:]
        persistProgress()
    }

    private func applyQuizReward(correctCount: Int, totalQuestions: Int) -> QuizReward {
        let boundedCorrect = max(0, min(correctCount, totalQuestions))
        let points = boundedCorrect * 10
        let accuracy = totalQuestions > 0 ? Double(boundedCorrect) / Double(totalQuestions) : 0
        let passes = accuracy >= quizPassThreshold ? 1 : 0
        let badges = accuracy >= quizPassThreshold ? 1 : 0
        return QuizReward(pointsEarned: points, gamePassesEarned: passes, badgesEarned: badges)
    }

    private func awardBadge(badgeKey: String, title: String, symbol: String) -> String? {
        var newlyUnlockedTitle: String?
        if !unlockedBadges.contains(where: { $0.storySourceID == badgeKey }) {
            unlockedBadges.append(
                UnlockedBadge(
                    storySourceID: badgeKey,
                    title: title,
                    symbol: symbol
                )
            )
            newlyUnlockedTitle = title
        }

        if let existingIndex = badgeInventory.firstIndex(where: { $0.badgeKey == badgeKey }) {
            badgeInventory[existingIndex].count += 1
            badgeInventory[existingIndex].lastEarnedAt = Date()
        } else {
            badgeInventory.append(
                BadgeInventoryItem(
                    badgeKey: badgeKey,
                    title: title,
                    symbol: symbol,
                    count: 1,
                    lastEarnedAt: Date()
                )
            )
        }

        badgeInventory.sort { lhs, rhs in
            if lhs.lastEarnedAt != rhs.lastEarnedAt {
                return lhs.lastEarnedAt > rhs.lastEarnedAt
            }
            return lhs.title < rhs.title
        }

        return newlyUnlockedTitle
    }

    private struct ProgressSnapshot: Codable {
        let totalPoints: Int
        let unlockedBadges: [UnlockedBadge]
        let badgeInventory: [BadgeInventoryItem]
        let storyQuizStats: [String: StoryQuizStats]
        let gamePassBalance: Int
        let gameUnlockExpirations: [String: Date]
    }

    private func persistProgress() {
        let snapshot = ProgressSnapshot(
            totalPoints: totalPoints,
            unlockedBadges: unlockedBadges,
            badgeInventory: badgeInventory,
            storyQuizStats: storyQuizStats,
            gamePassBalance: gamePassBalance,
            gameUnlockExpirations: Dictionary(
                uniqueKeysWithValues: gameUnlockExpirations.map { ($0.key.rawValue, $0.value) }
            )
        )

        do {
            let encoded = try JSONEncoder().encode(snapshot)
            UserDefaults.standard.set(encoded, forKey: progressStorageKey)
        } catch {
            assertionFailure("Failed to persist app progress: \(error.localizedDescription)")
        }
    }

    private func restoreProgress() {
        guard let storedSnapshot = UserDefaults.standard.data(forKey: progressStorageKey) else { return }
        guard let decoded = try? JSONDecoder().decode(ProgressSnapshot.self, from: storedSnapshot) else { return }

        totalPoints = max(0, decoded.totalPoints)
        unlockedBadges = decoded.unlockedBadges

        badgeInventory = decoded.badgeInventory
            .map { item in
                var sanitized = item
                sanitized.count = max(0, item.count)
                return sanitized
            }
            .filter { $0.count > 0 }

        storyQuizStats = decoded.storyQuizStats
            .mapValues { stats in
                var sanitized = stats
                sanitized.questionCount = max(0, stats.questionCount)
                sanitized.attempts = max(0, stats.attempts)
                sanitized.totalCorrectAnswers = max(0, stats.totalCorrectAnswers)
                sanitized.totalQuestionsAnswered = max(0, stats.totalQuestionsAnswered)
                sanitized.bestCorrectCount = max(0, stats.bestCorrectCount)
                return sanitized
            }

        gamePassBalance = max(0, decoded.gamePassBalance)

        let now = Date()
        gameUnlockExpirations = decoded.gameUnlockExpirations.reduce(into: [:]) { partialResult, entry in
            guard let game = GameID(rawValue: entry.key), entry.value > now else { return }
            partialResult[game] = entry.value
        }

        normalizeStoryStatsQuestionCounts()
        badgeInventory.sort { lhs, rhs in
            if lhs.lastEarnedAt != rhs.lastEarnedAt {
                return lhs.lastEarnedAt > rhs.lastEarnedAt
            }
            return lhs.title < rhs.title
        }
    }

    private func normalizeStoryStatsQuestionCounts() {
        let quizQuestionCountsByStory = Dictionary(
            uniqueKeysWithValues: stories.map { ($0.sourceStoryID, $0.quiz.count) }
        )

        for (storySourceID, questionCount) in quizQuestionCountsByStory {
            guard var stats = storyQuizStats[storySourceID] else { continue }
            if stats.questionCount != questionCount {
                stats.questionCount = questionCount
                storyQuizStats[storySourceID] = stats
            }
        }
    }
}

@MainActor
final class NarrationManager: NSObject, ObservableObject, @preconcurrency AVSpeechSynthesizerDelegate {
    @Published var isSpeaking: Bool = false
    @Published var isPaused: Bool = false
    @Published var spokenText: String = ""
    @Published var spokenRange: NSRange?
    @Published var speechProgress: Double = 0
    @Published var playbackRate: Float = 0.82

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        stop()
        spokenText = text
        spokenRange = nil
        speechProgress = 0

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * playbackRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.04
        utterance.postUtteranceDelay = 0.12
        utterance.voice = preferredVoice()

        synthesizer.speak(utterance)
        isSpeaking = true
        isPaused = false
    }

    func speak(title: String, body: String) {
        speak(text: "\(title). \(body)")
    }

    func pause() {
        guard synthesizer.isSpeaking else { return }
        if synthesizer.pauseSpeaking(at: .word) {
            isSpeaking = false
            isPaused = true
        }
    }

    func resume() {
        guard synthesizer.isPaused else { return }
        if synthesizer.continueSpeaking() {
            isSpeaking = true
            isPaused = false
        }
    }

    func togglePauseResume() {
        if synthesizer.isSpeaking {
            pause()
        } else if synthesizer.isPaused {
            resume()
        }
    }

    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        isPaused = false
        spokenRange = nil
        speechProgress = 0
    }

    func progress(for text: String) -> Double {
        guard spokenText == text, isSpeaking || isPaused else { return 0 }
        return speechProgress
    }

    private func preferredVoice() -> AVSpeechSynthesisVoice? {
        let fallback = AVSpeechSynthesisVoice(language: "en-US")
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "en-US" }

        let preferredIdentifiers = [
            "com.apple.ttsbundle.Samantha-compact",
            "com.apple.ttsbundle.Samantha-premium",
            "com.apple.ttsbundle.Ava-compact",
            "com.apple.ttsbundle.Allison-compact"
        ]

        for identifier in preferredIdentifiers {
            if let voice = voices.first(where: { $0.identifier == identifier }) {
                return voice
            }
        }

        let femaleNameHints = ["samantha", "ava", "allison", "karen", "moira", "susan"]
        if let femaleVoice = voices.first(where: { voice in
            let name = voice.name.lowercased()
            return femaleNameHints.contains(where: name.contains)
        }) {
            return femaleVoice
        }

        return fallback
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        guard utterance.speechString == spokenText else { return }
        spokenRange = characterRange
        let totalLength = utterance.speechString.utf16.count
        let spokenLength = characterRange.location + characterRange.length
        speechProgress = totalLength == 0 ? 0 : min(Double(spokenLength) / Double(totalLength), 1)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
        spokenRange = nil
        speechProgress = utterance.speechString == spokenText ? 1 : 0
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
        spokenRange = nil
        speechProgress = 0
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        isSpeaking = true
        isPaused = false
    }
}
