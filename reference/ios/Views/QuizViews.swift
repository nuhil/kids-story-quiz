import SwiftUI

struct QuizView: View {
    let story: Story

    @EnvironmentObject private var appModel: AppModel
    @State private var questionIndex: Int = 0
    @State private var selectedOptionID: UUID?
    @State private var isChecked: Bool = false
    @State private var correctCount: Int = 0
    @State private var showFeedbackPopup: Bool = false
    @State private var lastAnswerWasCorrect: Bool = false
    @State private var isWaitingForFeedback: Bool = false
    @State private var feedbackPopupTask: Task<Void, Never>?
    @State private var outcome: QuizOutcome?
    private let feedbackPopupDelayNs: UInt64 = 1_000_000_000

    private var question: QuizQuestion {
        story.quiz[questionIndex]
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    if let outcome {
                        QuizResultView(story: story, outcome: outcome)
                    } else {
                        HStack(spacing: DSSpacing.xs) {
                            ForEach(Array(story.quiz.indices), id: \.self) { idx in
                                Capsule()
                                    .fill(idx <= questionIndex ? DSColor.yellow : Color.black.opacity(0.1))
                                    .frame(height: 6)
                            }
                        }

                        TopicArtworkView(topic: story.topic, seed: questionIndex + 20, storyTitle: story.title, storyID: story.sourceStoryID)
                            .frame(height: DSLayout.artworkHeight)

                        Text(question.prompt)
                            .font(DSTypography.subtitle())
                            .foregroundStyle(DSColor.textPrimary)

                        VStack(spacing: DSSpacing.sm) {
                            ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                                QuizOptionRow(
                                    index: index,
                                    option: option,
                                    isSelected: selectedOptionID == option.id,
                                    isChecked: isChecked
                                )
                                .onTapGesture {
                                    guard !isChecked else { return }
                                    selectedOptionID = option.id
                                }
                            }
                        }

                        Button {
                            handlePrimaryAction()
                        } label: {
                            if isWaitingForFeedback {
                                HStack(spacing: DSSpacing.xs) {
                                    ProgressView()
                                        .tint(.white)
                                    Text("Loading Facts...")
                                }
                            } else {
                                HStack(spacing: DSSpacing.xs) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Check Answer")
                                }
                            }
                        }
                        .buttonStyle(PrimaryCTAButtonStyle())
                        .disabled(selectedOptionID == nil || isChecked || isWaitingForFeedback)
                    }
                }
                .screenContentPadding()
                .padding(.vertical, DSSpacing.md)
            }
            .disabled(showFeedbackPopup)

            if showFeedbackPopup {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()

                QuizFeedbackPopup(
                    isCorrect: lastAnswerWasCorrect,
                    explanation: lastAnswerWasCorrect ? question.factFeedbackCorrect : question.factFeedbackIncorrect,
                    isLastQuestion: isLastQuestion
                ) {
                    advanceAfterFeedback()
                }
                .padding(.horizontal, DSLayout.horizontalMargin)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showFeedbackPopup)
        .screenBackground()
        .navigationTitle(story.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            feedbackPopupTask?.cancel()
            isWaitingForFeedback = false
        }
    }

    private var isLastQuestion: Bool {
        questionIndex == story.quiz.count - 1
    }

    private func handlePrimaryAction() {
        guard !isChecked, let selectedOptionID else { return }
        guard let selected = question.options.first(where: { $0.id == selectedOptionID }) else { return }

        isChecked = true
        lastAnswerWasCorrect = selected.isCorrect
        if selected.isCorrect {
            correctCount += 1
        }

        isWaitingForFeedback = true
        feedbackPopupTask?.cancel()
        feedbackPopupTask = Task {
            try? await Task.sleep(nanoseconds: feedbackPopupDelayNs)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                isWaitingForFeedback = false
                showFeedbackPopup = true
            }
        }
    }

    private func advanceAfterFeedback() {
        feedbackPopupTask?.cancel()
        feedbackPopupTask = nil
        isWaitingForFeedback = false
        showFeedbackPopup = false

        if isLastQuestion {
            outcome = appModel.completeQuiz(story: story, correctCount: correctCount)
            return
        }

        questionIndex += 1
        selectedOptionID = nil
        isChecked = false
    }
}

private struct QuizFeedbackPopup: View {
    let isCorrect: Bool
    let explanation: String
    let isLastQuestion: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack(spacing: DSSpacing.sm) {
                ZStack {
                    Circle()
                        .fill((isCorrect ? DSColor.mint : DSColor.yellow).opacity(0.32))
                        .frame(width: 42, height: 42)
                    Image(systemName: isCorrect ? "checkmark.seal.fill" : "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(DSColor.textPrimary)
                }

                Text(isCorrect ? "Great job!" : "Nice try!")
                    .font(DSTypography.subtitle())
                    .foregroundStyle(DSColor.textPrimary)
            }

            Text(explanation)
                .font(DSTypography.body())
                .foregroundStyle(DSColor.textSecondary)

            Button {
                onContinue()
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Text(isLastQuestion ? "See Results" : "Next Question")
                    Image(systemName: isLastQuestion ? "trophy.fill" : "arrow.right")
                }
            }
            .buttonStyle(PrimaryCTAButtonStyle())
        }
        .cardStyle()
    }
}

private struct QuizOptionRow: View {
    let index: Int
    let option: QuizOption
    let isSelected: Bool
    let isChecked: Bool

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Text(letter)
                .font(DSTypography.body())
                .foregroundStyle(isSelected ? DSColor.textPrimary : DSColor.textSecondary)
                .frame(width: 24)

            Text(option.text)
                .font(DSTypography.body())
                .foregroundStyle(DSColor.textPrimary)

            Spacer()

            if isChecked && option.isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.green)
            }
        }
        .padding(DSSpacing.md)
        .frame(minHeight: DSLayout.controlHeight)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .stroke(strokeColor, lineWidth: 1.5)
        )
    }

    private var letter: String {
        guard let scalar = UnicodeScalar(65 + index) else {
            return "A"
        }
        return String(Character(scalar))
    }

    private var backgroundColor: Color {
        if isChecked && option.isCorrect {
            return Color.green.opacity(0.15)
        }
        if isSelected {
            return DSColor.yellow.opacity(0.24)
        }
        return DSColor.surface
    }

    private var strokeColor: Color {
        if isChecked && option.isCorrect {
            return Color.green.opacity(0.75)
        }
        if isSelected {
            return DSColor.yellow.opacity(0.9)
        }
        return Color.black.opacity(0.08)
    }
}

struct QuizResultView: View {
    let story: Story
    let outcome: QuizOutcome
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .center, spacing: DSSpacing.md) {
            ZStack {
                Circle()
                    .fill(DSColor.yellow.opacity(0.4))
                    .frame(width: 120, height: 120)
                Image(systemName: "star.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(DSColor.coral)
            }

            Text("Great Job!")
                .font(DSTypography.title())
                .foregroundStyle(DSColor.textPrimary)

            Text("Score: \(outcome.scoreText)")
                .font(DSTypography.subtitle())
                .foregroundStyle(DSColor.textPrimary)

            Text("You earned \(outcome.pointsEarned) points.")
                .font(DSTypography.body())
                .foregroundStyle(DSColor.textSecondary)

            if outcome.gamePassesEarned > 0 {
                Label(
                    "Game Pass +\(outcome.gamePassesEarned) earned",
                    systemImage: "ticket.fill"
                )
                .font(DSTypography.captionBold())
                .foregroundStyle(DSColor.coral)
            }

            if outcome.badgesEarned > 0 {
                Label(
                    "Badge +\(outcome.badgesEarned) added to your collection",
                    systemImage: "medal.fill"
                )
                .font(DSTypography.captionBold())
                .foregroundStyle(DSColor.mint)
            }

            if let badge = outcome.badgeUnlocked {
                Label("Badge unlocked: \(badge)", systemImage: story.badgeSymbol)
                    .font(DSTypography.body())
                    .foregroundStyle(DSColor.textPrimary)
                    .padding(DSSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(DSColor.mint.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
            } else {
                Text("Score 80% or higher to unlock the story badge.")
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColor.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                dismiss()
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.left.circle.fill")
                    Text("Back To Story")
                }
            }
            .buttonStyle(PrimaryCTAButtonStyle())
        }
        .cardStyle()
        .padding(.top, DSSpacing.xl)
    }
}

private struct CategoryQuizQuestion: Identifiable {
    let id = UUID()
    let topic: Topic
    let storyTitle: String
    let question: QuizQuestion
}

private struct CategoryQuizOutcome {
    let correctCount: Int
    let totalQuestions: Int
    let pointsEarned: Int
    let gamePassesEarned: Int
    let badgesEarned: Int

    var scoreText: String {
        "\(correctCount)/\(totalQuestions)"
    }
}

struct CategoryQuizHubView: View {
    @EnvironmentObject private var appModel: AppModel

    @State private var selectedTopics: Set<Topic> = []
    @State private var preparedQuestions: [CategoryQuizQuestion] = []
    @State private var showQuizSession: Bool = false

    private let questionTargetCount: Int = 10

    private var selectionQuestionPool: [CategoryQuizQuestion] {
        appModel.stories
            .filter { selectedTopics.contains($0.topic) }
            .flatMap { story in
                story.quiz.map { quizQuestion in
                    CategoryQuizQuestion(topic: story.topic, storyTitle: story.title, question: quizQuestion)
                }
            }
    }

    private var availableQuestionCount: Int {
        selectionQuestionPool.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Quiz")
                        .font(DSTypography.title())
                        .foregroundStyle(DSColor.textPrimary)

                    Text("Pick one or more story categories, then start a mixed 10-question challenge.")
                        .font(DSTypography.body())
                        .foregroundStyle(DSColor.textSecondary)

                    HStack(spacing: DSSpacing.sm) {
                        Button {
                            selectedTopics = Set(Topic.allCases)
                        } label: {
                            Label("Select All", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(SecondaryPillStyle(selected: selectedTopics.count == Topic.allCases.count))

                        Button {
                            selectedTopics.removeAll()
                        } label: {
                            Label("Clear", systemImage: "xmark.circle")
                        }
                        .buttonStyle(SecondaryPillStyle(selected: selectedTopics.isEmpty))
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.sm) {
                        ForEach(Topic.allCases) { topic in
                            Button {
                                toggle(topic)
                            } label: {
                                CategoryTopicSelectionCard(
                                    topic: topic,
                                    isSelected: selectedTopics.contains(topic)
                                )
                                .contentShape(Rectangle())
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        startQuiz()
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "play.fill")
                            Text("Start \(questionTargetCount)-Question Quiz")
                        }
                    }
                    .buttonStyle(PrimaryCTAButtonStyle())
                    .disabled(!canStartQuiz)
                    .opacity(canStartQuiz ? 1 : 0.6)
                }
                .screenContentPadding()
                .padding(.vertical, DSSpacing.md)
            }
            .screenBackground()
            .navigationDestination(isPresented: $showQuizSession) {
                CategoryMixQuizView(
                    questions: preparedQuestions,
                    selectedTopics: selectedTopics.sorted { $0.title < $1.title }
                )
            }
        }
    }

    private var canStartQuiz: Bool {
        !selectedTopics.isEmpty && availableQuestionCount > 0
    }

    private func toggle(_ topic: Topic) {
        if selectedTopics.contains(topic) {
            selectedTopics.remove(topic)
        } else {
            selectedTopics.insert(topic)
        }
    }

    private func startQuiz() {
        guard canStartQuiz else { return }
        preparedQuestions = Array(selectionQuestionPool.shuffled().prefix(questionTargetCount))
        guard !preparedQuestions.isEmpty else { return }
        showQuizSession = true
    }
}

private struct CategoryTopicSelectionCard: View {
    let topic: Topic
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(alignment: .center, spacing: DSSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(DSColor.gradient(for: topic))
                        .frame(width: 36, height: 36)

                    Image(systemName: topic.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(topic.title)
                    .font(DSTypography.captionBold())
                    .foregroundStyle(isSelected ? Color.white : DSColor.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: isSelected ? Color.black.opacity(0.42) : .clear, radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal, isSelected ? DSSpacing.xs : 0)
        .padding(.vertical, isSelected ? 6 : 0)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.black.opacity(0.3))
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .topLeading)
        .background {
            ZStack {
                Image(categoryBackdropImageName)
                    .resizable()
                    .scaledToFill()
                    .opacity(isSelected ? 1.0 : 0.42)

                LinearGradient(
                    colors: isSelected
                        ? [Color.white.opacity(0.06), Color.white.opacity(0.16)]
                        : [Color.white.opacity(0.52), Color.white.opacity(0.66)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if isSelected {
                    LinearGradient(
                        colors: [Color.black.opacity(0.04), Color.black.opacity(0.22)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .stroke(isSelected ? DSColor.coral.opacity(0.52) : Color.black.opacity(0.08), lineWidth: 1.2)
        )
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var categoryBackdropImageName: String {
        switch topic {
        case .ocean: return "HomeOceanBackdrop"
        case .animals: return "HomeAnimalsBackdrop"
        case .space: return "HomeSpaceBackdrop"
        case .science: return "HomeScienceBackdrop"
        case .math: return "HomeMathBackdrop"
        case .culture: return "HomeCultureBackdrop"
        case .emotionsSocial: return "HomeEmotionsBackdrop"
        case .history: return "HomeHistoryBackdrop"
        case .geography: return "HomeGeographyBackdrop"
        case .technologyMachines: return "HomeTechnologyBackdrop"
        }
    }
}

private struct CategoryMixQuizView: View {
    let questions: [CategoryQuizQuestion]
    let selectedTopics: [Topic]

    @EnvironmentObject private var appModel: AppModel

    @State private var questionIndex: Int = 0
    @State private var selectedOptionID: UUID?
    @State private var isChecked: Bool = false
    @State private var correctCount: Int = 0
    @State private var showFeedbackPopup: Bool = false
    @State private var lastAnswerWasCorrect: Bool = false
    @State private var isWaitingForFeedback: Bool = false
    @State private var feedbackPopupTask: Task<Void, Never>?
    @State private var outcome: CategoryQuizOutcome?

    private let feedbackPopupDelayNs: UInt64 = 1_000_000_000

    private var currentItem: CategoryQuizQuestion {
        questions[questionIndex]
    }

    private var isLastQuestion: Bool {
        questionIndex == questions.count - 1
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    if questions.isEmpty {
                        Text("No quiz questions available for this selection.")
                            .font(DSTypography.body())
                            .foregroundStyle(DSColor.textSecondary)
                            .cardStyle()
                    } else if let outcome {
                        CategoryMixQuizResultView(outcome: outcome, selectedTopics: selectedTopics)
                    } else {
                        HStack(spacing: DSSpacing.xs) {
                            ForEach(Array(questions.indices), id: \.self) { idx in
                                Capsule()
                                    .fill(idx <= questionIndex ? DSColor.yellow : Color.black.opacity(0.1))
                                    .frame(height: 6)
                            }
                        }

                        TopicArtworkView(
                            topic: currentItem.topic,
                            seed: questionIndex + 3000,
                            storyTitle: currentItem.storyTitle
                        )
                        .frame(height: DSLayout.artworkHeight)

                        HStack(spacing: DSSpacing.xs) {
                            Label(currentItem.topic.title, systemImage: currentItem.topic.icon)
                                .font(DSTypography.captionBold())
                                .foregroundStyle(DSColor.textPrimary)

                            Text("•")
                                .foregroundStyle(DSColor.textSecondary)

                            Text(currentItem.storyTitle)
                                .font(DSTypography.caption())
                                .foregroundStyle(DSColor.textSecondary)
                                .lineLimit(1)
                        }

                        Text(currentItem.question.prompt)
                            .font(DSTypography.subtitle())
                            .foregroundStyle(DSColor.textPrimary)

                        VStack(spacing: DSSpacing.sm) {
                            ForEach(Array(currentItem.question.options.enumerated()), id: \.element.id) { index, option in
                                QuizOptionRow(
                                    index: index,
                                    option: option,
                                    isSelected: selectedOptionID == option.id,
                                    isChecked: isChecked
                                )
                                .onTapGesture {
                                    guard !isChecked else { return }
                                    selectedOptionID = option.id
                                }
                            }
                        }

                        Button {
                            handlePrimaryAction()
                        } label: {
                            if isWaitingForFeedback {
                                HStack(spacing: DSSpacing.xs) {
                                    ProgressView()
                                        .tint(.white)
                                    Text("Loading Facts...")
                                }
                            } else {
                                HStack(spacing: DSSpacing.xs) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Check Answer")
                                }
                            }
                        }
                        .buttonStyle(PrimaryCTAButtonStyle())
                        .disabled(selectedOptionID == nil || isChecked || isWaitingForFeedback)
                    }
                }
                .screenContentPadding()
                .padding(.vertical, DSSpacing.md)
            }
            .disabled(showFeedbackPopup)

            if showFeedbackPopup && !questions.isEmpty {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()

                QuizFeedbackPopup(
                    isCorrect: lastAnswerWasCorrect,
                    explanation: lastAnswerWasCorrect ? currentItem.question.factFeedbackCorrect : currentItem.question.factFeedbackIncorrect,
                    isLastQuestion: isLastQuestion
                ) {
                    advanceAfterFeedback()
                }
                .padding(.horizontal, DSLayout.horizontalMargin)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showFeedbackPopup)
        .screenBackground()
        .navigationTitle("Category Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            feedbackPopupTask?.cancel()
            isWaitingForFeedback = false
        }
    }

    private func handlePrimaryAction() {
        guard !questions.isEmpty, !isChecked, let selectedOptionID else { return }
        guard let selected = currentItem.question.options.first(where: { $0.id == selectedOptionID }) else { return }

        isChecked = true
        lastAnswerWasCorrect = selected.isCorrect
        if selected.isCorrect {
            correctCount += 1
        }

        isWaitingForFeedback = true
        feedbackPopupTask?.cancel()
        feedbackPopupTask = Task {
            try? await Task.sleep(nanoseconds: feedbackPopupDelayNs)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                isWaitingForFeedback = false
                showFeedbackPopup = true
            }
        }
    }

    private func advanceAfterFeedback() {
        feedbackPopupTask?.cancel()
        feedbackPopupTask = nil
        isWaitingForFeedback = false
        showFeedbackPopup = false

        if isLastQuestion {
            let reward = appModel.completeCategoryQuiz(correctCount: correctCount, totalQuestions: questions.count)
            outcome = CategoryQuizOutcome(
                correctCount: correctCount,
                totalQuestions: questions.count,
                pointsEarned: reward.pointsEarned,
                gamePassesEarned: reward.gamePassesEarned,
                badgesEarned: reward.badgesEarned
            )
            return
        }

        questionIndex += 1
        selectedOptionID = nil
        isChecked = false
    }
}

private struct CategoryMixQuizResultView: View {
    let outcome: CategoryQuizOutcome
    let selectedTopics: [Topic]

    @Environment(\.dismiss) private var dismiss

    private var topicSummary: String {
        let titles = selectedTopics.map(\.title)
        if titles.count <= 2 {
            return titles.joined(separator: ", ")
        }
        return "\(titles.prefix(2).joined(separator: ", ")) +\(titles.count - 2) more"
    }

    var body: some View {
        VStack(alignment: .center, spacing: DSSpacing.md) {
            ZStack {
                Circle()
                    .fill(DSColor.yellow.opacity(0.4))
                    .frame(width: 120, height: 120)
                Image(systemName: "sparkles")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(DSColor.coral)
            }

            Text("Quiz Complete!")
                .font(DSTypography.title())
                .foregroundStyle(DSColor.textPrimary)

            Text("Score: \(outcome.scoreText)")
                .font(DSTypography.subtitle())
                .foregroundStyle(DSColor.textPrimary)

            Text("You earned \(outcome.pointsEarned) points.")
                .font(DSTypography.body())
                .foregroundStyle(DSColor.textSecondary)

            if outcome.gamePassesEarned > 0 {
                Label(
                    "Game Pass +\(outcome.gamePassesEarned) earned",
                    systemImage: "ticket.fill"
                )
                .font(DSTypography.captionBold())
                .foregroundStyle(DSColor.coral)
            }

            if outcome.badgesEarned > 0 {
                Label(
                    "Badge +\(outcome.badgesEarned) added to your collection",
                    systemImage: "medal.fill"
                )
                .font(DSTypography.captionBold())
                .foregroundStyle(DSColor.mint)
            }

            Text("Categories: \(topicSummary)")
                .font(DSTypography.caption())
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.left.circle.fill")
                    Text("Back To Quiz Home")
                }
            }
            .buttonStyle(PrimaryCTAButtonStyle())
        }
        .cardStyle()
        .padding(.top, DSSpacing.xl)
    }
}
