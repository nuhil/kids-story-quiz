import Foundation

enum StoryRepository {
    static func makeStories() -> [Story] {
        let bundledStories = loadStoriesFromBundle()
        return bundledStories.isEmpty ? fallbackStories() : bundledStories
    }

    private static func loadStoriesFromBundle() -> [Story] {
        let urls = bundledStoryJSONURLs()
        guard !urls.isEmpty else { return [] }

        let decoder = JSONDecoder()
        var indexedStories: [(order: Int, story: Story)] = []
        var orderCounter = 0

        for url in urls {
            do {
                let data = try Data(contentsOf: url)
                let document = try decoder.decode(CategoryDocument.self, from: data)
                guard let topic = topic(for: document.category.categoryID) else { continue }

                for sourceStory in document.category.stories {
                    let pages = makePages(from: sourceStory.pages, objectives: sourceStory.learningObjectives)
                    let quiz = makeQuiz(from: sourceStory.quiz)
                    guard !pages.isEmpty, !quiz.isEmpty else { continue }

                    let story = Story(
                        sourceStoryID: normalizedStoryID(sourceStory.storyID, topic: topic, fallbackOrder: orderCounter + 1),
                        topic: topic,
                        title: sourceStory.title.trimmed,
                        subtitle: makeSubtitle(story: sourceStory, categoryName: document.category.categoryName),
                        pages: pages,
                        quiz: quiz,
                        badgeTitle: badgeTitle(for: sourceStory.title, topic: topic),
                        badgeSymbol: badgeSymbol(for: topic)
                    )
                    indexedStories.append((order: orderCounter, story: story))
                    orderCounter += 1
                }
            } catch {
                // Skip malformed files and continue loading remaining categories.
                continue
            }
        }

        return indexedStories
            .sorted {
                if $0.story.topic == $1.story.topic {
                    return $0.order < $1.order
                }
                return topicSortIndex($0.story.topic) < topicSortIndex($1.story.topic)
            }
            .map(\.story)
    }

    private static func bundledStoryJSONURLs() -> [URL] {
        if let folderURL = Bundle.main.url(forResource: "Stories", withExtension: nil),
           let urls = try? FileManager.default.contentsOfDirectory(
               at: folderURL,
               includingPropertiesForKeys: nil,
               options: [.skipsHiddenFiles]
           ) {
            let jsonURLs = urls.filter { $0.pathExtension.lowercased() == "json" }
            if !jsonURLs.isEmpty {
                return jsonURLs.sorted { $0.lastPathComponent < $1.lastPathComponent }
            }
        }

        let bundledJSON = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        return bundledJSON.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private static func makeSubtitle(story: SourceStory, categoryName: String) -> String {
        if let firstObjective = story.learningObjectives.first?.trimmed, !firstObjective.isEmpty {
            return firstObjective
        }
        return "Learn \(categoryName) with this story and quiz."
    }

    private static func makePages(from sourcePages: [SourcePage], objectives: [String]) -> [StoryPage] {
        let sortedPages = sourcePages.sorted { $0.pageNumber < $1.pageNumber }
        guard !sortedPages.isEmpty else { return [] }

        return sortedPages.enumerated().map { index, page in
            StoryPage(
                title: makePageTitle(from: page.text, pageNumber: page.pageNumber),
                body: page.text.trimmed,
                funFact: objectives[safe: index % max(objectives.count, 1)]?.trimmed ?? ""
            )
        }
    }

    private static func makePageTitle(from text: String, pageNumber: Int) -> String {
        let clean = text.trimmed
        guard !clean.isEmpty else { return "Page \(pageNumber)" }

        let firstSentence = clean.split(whereSeparator: { ".!?".contains($0) }).first.map(String.init)?.trimmed ?? clean
        let words = firstSentence.split(separator: " ").prefix(6).map(String.init).joined(separator: " ")
        if words.isEmpty { return "Page \(pageNumber)" }
        if firstSentence.split(separator: " ").count > 6 {
            return words + "..."
        }
        return words
    }

    private static func makeQuiz(from sourceQuiz: [SourceQuestion]) -> [QuizQuestion] {
        sourceQuiz.compactMap { item in
            let normalizedCorrect = normalizeAnswer(item.correctAnswer)
            guard !item.options.isEmpty else { return nil }

            var hasCorrect = false
            let options = item.options.map { optionText in
                let isCorrect = normalizeAnswer(optionText) == normalizedCorrect
                if isCorrect { hasCorrect = true }
                return QuizOption(text: optionText.trimmed, isCorrect: isCorrect)
            }

            let resolvedOptions: [QuizOption]
            if hasCorrect {
                resolvedOptions = options
            } else {
                resolvedOptions = options.enumerated().map { idx, option in
                    QuizOption(text: option.text, isCorrect: idx == 0)
                }
            }

            // Prevent "always A" bias by randomizing option order per question.
            let shuffledOptions = resolvedOptions.shuffled()

            return QuizQuestion(
                prompt: item.question.trimmed,
                options: shuffledOptions,
                factFeedbackCorrect: item.factFeedbackCorrect.trimmed,
                factFeedbackIncorrect: item.factFeedbackIncorrect.trimmed
            )
        }
    }

    private static func badgeTitle(for storyTitle: String, topic: Topic) -> String {
        let words = storyTitle.split(separator: " ").prefix(2).map(String.init).joined(separator: " ")
        if words.isEmpty {
            return "\(topic.title) Explorer"
        }
        return "\(words) Star"
    }

    private static func badgeSymbol(for topic: Topic) -> String {
        switch topic {
        case .ocean: return "drop.circle.fill"
        case .animals: return "pawprint.circle.fill"
        case .space: return "sparkles"
        case .science: return "atom"
        case .math: return "sum"
        case .culture: return "globe.europe.africa.fill"
        case .emotionsSocial: return "face.smiling.fill"
        case .history: return "clock.arrow.circlepath"
        case .geography: return "map.fill"
        case .technologyMachines: return "gearshape.2.fill"
        }
    }

    private static func topicSortIndex(_ topic: Topic) -> Int {
        Topic.allCases.firstIndex(of: topic) ?? 0
    }

    private static func normalizeAnswer(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private static func normalizedStoryID(_ raw: String, topic: Topic, fallbackOrder: Int) -> String {
        let cleaned = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
            .components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")).inverted)
            .joined()

        if !cleaned.isEmpty {
            return cleaned
        }

        return "\(topic.rawValue)_\(String(format: "%02d", fallbackOrder))"
    }

    private static func topic(for categoryID: String) -> Topic? {
        let normalized = categoryID
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if let direct = Topic(rawValue: normalized) {
            return direct
        }

        switch normalized {
        case "technology":
            return .technologyMachines
        default:
            return nil
        }
    }

    private static func fallbackStories() -> [Story] {
        let fallbackStory = Story(
            sourceStoryID: "fallback_ocean_01",
            topic: .ocean,
            title: "Ocean Starter Story",
            subtitle: "Story files are missing from app resources.",
            pages: [
                StoryPage(
                    title: "Welcome Explorer",
                    body: "Add the JSON story files to the app bundle under Stories to load full content.",
                    funFact: "Stories should be bundled in the app resources."
                )
            ],
            quiz: [
                QuizQuestion(
                    prompt: "Where should story JSON files be located?",
                    options: [
                        QuizOption(text: "Inside the app bundle Stories folder", isCorrect: true),
                        QuizOption(text: "Only on the web", isCorrect: false),
                        QuizOption(text: "Inside screenshots", isCorrect: false)
                    ],
                    factFeedbackCorrect: "Correct! Stories load from bundled JSON files.",
                    factFeedbackIncorrect: "Story JSON must be bundled with the app resources."
                )
            ],
            badgeTitle: "Ocean Starter",
            badgeSymbol: "drop.circle.fill"
        )
        return [fallbackStory]
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

private struct CategoryDocument: Decodable {
    let category: SourceCategory
}

private struct SourceCategory: Decodable {
    let categoryName: String
    let categoryID: String
    let stories: [SourceStory]

    enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case categoryID = "category_id"
        case stories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedCategoryName = try container.decode(String.self, forKey: .categoryName)
        let decodedCategoryID = try container.decode(String.self, forKey: .categoryID)
        categoryName = decodedCategoryName
        categoryID = decodedCategoryID

        if let fullStories = try? container.decode([SourceStory].self, forKey: .stories) {
            stories = fullStories
            return
        }

        if let storyRefs = try? container.decode([String].self, forKey: .stories) {
            stories = storyRefs.enumerated().map { idx, ref in
                SourceStory.makePlaceholder(storyID: ref, categoryName: decodedCategoryName, index: idx + 1)
            }
            return
        }

        stories = []
    }
}

private struct SourceStory: Decodable {
    let storyID: String
    let title: String
    let learningObjectives: [String]
    let pages: [SourcePage]
    let quiz: [SourceQuestion]

    enum CodingKeys: String, CodingKey {
        case storyID = "story_id"
        case title
        case learningObjectives = "learning_objectives"
        case pages
        case quiz
    }

    static func makePlaceholder(storyID: String, categoryName: String, index: Int) -> SourceStory {
        let baseTitle = storyID
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let title = baseTitle.isEmpty ? "\(categoryName) Story \(index)" : baseTitle
        let objective = "This \(categoryName.lowercased()) story content is being prepared."

        return SourceStory(
            storyID: storyID,
            title: title,
            learningObjectives: [objective],
            pages: [
                SourcePage(
                    pageNumber: 1,
                    text: "This story is listed in your updated data. Full page content will appear once detailed pages are added for \(title)."
                )
            ],
            quiz: [
                SourceQuestion(
                    questionID: 1,
                    question: "Is this \(categoryName.lowercased()) story ready for full reading yet?",
                    options: ["Not yet", "Yes, fully ready", "Only on paper"],
                    correctAnswer: "Not yet",
                    factFeedbackCorrect: "Correct. This placeholder confirms the story ID is recognized from your updated file.",
                    factFeedbackIncorrect: "This entry currently contains only a story ID reference. Add pages and quiz details to make it fully playable."
                )
            ]
        )
    }
}

private struct SourcePage: Decodable {
    let pageNumber: Int
    let text: String

    enum CodingKeys: String, CodingKey {
        case pageNumber = "page_number"
        case text
    }

    init(pageNumber: Int, text: String) {
        self.pageNumber = pageNumber
        self.text = text
    }
}

private struct SourceQuestion: Decodable {
    let questionID: Int
    let question: String
    let options: [String]
    let correctAnswer: String
    let factFeedbackCorrect: String
    let factFeedbackIncorrect: String

    enum CodingKeys: String, CodingKey {
        case questionID = "question_id"
        case question
        case options
        case correctAnswer = "correct_answer"
        case factFeedbackCorrect = "fact_feedback_correct"
        case factFeedbackIncorrect = "fact_feedback_incorrect"
    }

    init(
        questionID: Int,
        question: String,
        options: [String],
        correctAnswer: String,
        factFeedbackCorrect: String,
        factFeedbackIncorrect: String
    ) {
        self.questionID = questionID
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.factFeedbackCorrect = factFeedbackCorrect
        self.factFeedbackIncorrect = factFeedbackIncorrect
    }
}
