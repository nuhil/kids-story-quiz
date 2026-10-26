import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var navigation: AppNavigationModel
    @State private var searchText: String = ""
    @State private var selectedTopic: Topic? = nil

    private var filteredStories: [Story] {
        appModel.stories.filter { story in
            let topicMatch = selectedTopic == nil || story.topic == selectedTopic
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let textMatch = query.isEmpty || story.title.localizedCaseInsensitiveContains(query) || story.subtitle.localizedCaseInsensitiveContains(query)
            return topicMatch && textMatch
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Explore")
                                .font(DSTypography.title())
                                .foregroundStyle(DSColor.textPrimary)
                            Text("Pick a story, learn cool facts, then take a quiz.")
                                .font(DSTypography.caption())
                                .foregroundStyle(DSColor.textSecondary)
                        }

                        Spacer()

                        Circle()
                            .fill(DSColor.coral.opacity(0.2))
                            .frame(width: DSLayout.smallAvatarSize, height: DSLayout.smallAvatarSize)
                            .overlay {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(DSColor.coral)
                            }
                    }

                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(DSColor.textSecondary)
                        TextField("Search stories", text: $searchText)
                            .font(DSTypography.body())
                    }
                    .playfulFieldChrome(accent: DSColor.oceanBlue)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSSpacing.xs) {
                            Button {
                                selectedTopic = nil
                            } label: {
                                Label("All", systemImage: "square.grid.2x2.fill")
                            }
                            .buttonStyle(SecondaryPillStyle(selected: selectedTopic == nil))

                            ForEach(Topic.allCases) { topic in
                                Button {
                                    selectedTopic = topic
                                } label: {
                                    Label(topic.title, systemImage: topic.icon)
                                }
                                .buttonStyle(SecondaryPillStyle(selected: selectedTopic == topic))
                            }
                        }
                    }

                    VStack(spacing: DSSpacing.md) {
                        ForEach(filteredStories) { story in
                            NavigationLink {
                                StoryDetailView(story: story)
                            } label: {
                                StoryCardView(story: story)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .screenContentPadding()
                .padding(.vertical, DSSpacing.md)
            }
            .screenBackground()
        }
        .id(navigation.exploreRequestID)
        .onAppear {
            applyRequestedTopicFilter()
        }
        .onChange(of: navigation.exploreRequestID) { _ in
            applyRequestedTopicFilter()
        }
    }

    private func applyRequestedTopicFilter() {
        guard let topic = navigation.requestedExploreTopic else { return }
        selectedTopic = topic
        searchText = ""
        navigation.requestedExploreTopic = nil
    }
}

private struct StoryCardView: View {
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            ZStack(alignment: .bottomTrailing) {
                TopicArtworkView(topic: story.topic, seed: story.pages.count, storyTitle: story.title, storyID: story.sourceStoryID)
                    .frame(height: DSLayout.artworkHeight)

                Circle()
                    .fill(DSColor.surface)
                    .frame(width: DSLayout.playButtonOuter, height: DSLayout.playButtonOuter)
                    .overlay {
                        Circle()
                            .fill(DSColor.coral)
                            .frame(width: DSLayout.playButtonInner, height: DSLayout.playButtonInner)
                            .overlay {
                                Image(systemName: "play.fill")
                                    .foregroundStyle(.white)
                            }
                    }
                    .offset(x: -12, y: -12)
            }

            Text(story.title)
                .font(DSTypography.subtitle())
                .foregroundStyle(DSColor.textPrimary)

            Text(story.subtitle)
                .font(DSTypography.caption())
                .foregroundStyle(DSColor.textSecondary)

            HStack(spacing: DSLayout.storyInfoChipRowSpacing) {
                StoryInfoChip(
                    icon: "book.closed.fill",
                    text: "\(story.pages.count) Pages",
                    tint: DSColor.oceanBlue
                )

                StoryInfoChip(
                    icon: "questionmark.circle.fill",
                    text: "\(story.quiz.count) Questions",
                    tint: DSColor.mint
                )
            }
        }
        .cardStyle()
    }
}

private struct StoryInfoChip: View {
    let icon: String
    let text: String
    let tint: Color

    var body: some View {
        HStack(spacing: DSSpacing.xs) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.22))

                Image(systemName: icon)
                    .font(.system(size: DSLayout.storyInfoChipIconSize, weight: .bold))
                    .foregroundStyle(tint)
            }
            .frame(
                width: DSLayout.storyInfoChipIconBadgeSize,
                height: DSLayout.storyInfoChipIconBadgeSize
            )

            Text(text)
                .font(DSTypography.tiny())
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, DSSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: DSLayout.storyInfoChipMinHeight, alignment: .leading)
        .background(tint.opacity(0.13))
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous))
    }
}

struct StoryDetailView: View {
    let story: Story

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                TopicArtworkView(topic: story.topic, seed: 3, storyTitle: story.title, storyID: story.sourceStoryID)
                    .frame(height: DSLayout.artworkHeight)

                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text(story.title)
                        .font(DSTypography.title())
                        .foregroundStyle(DSColor.textPrimary)

                    Text(story.subtitle)
                        .font(DSTypography.body())
                        .foregroundStyle(DSColor.textSecondary)
                }

                StoryQuickStatsPanel(story: story)

                NavigationLink {
                    StoryReaderView(story: story)
                } label: {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "book.pages.fill")
                        Text("Start Story")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(PrimaryCTAButtonStyle())
            }
            .screenContentPadding()
            .padding(.vertical, DSSpacing.md)
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StoryQuickStatsPanel: View {
    let story: Story

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                StoryStatTile(
                    title: "Pages",
                    valueText: "\(story.pages.count)",
                    symbol: "book.closed.fill",
                    tint: DSColor.oceanBlue
                )

                StoryStatTile(
                    title: "Points",
                    valueText: "\(story.estimatedPoints)",
                    symbol: "star.fill",
                    tint: DSColor.yellow
                )
            }

            StoryBadgeTile(story: story)
        }
        .cardStyle()
    }
}

private struct StoryStatTile: View {
    let title: String
    let valueText: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xs) {
                Text(title)
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColor.textSecondary)

                Spacer(minLength: DSSpacing.xs)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.36), tint.opacity(0.18)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: DSLayout.storyStatIconBadgeSize, height: DSLayout.storyStatIconBadgeSize)
                    Image(systemName: symbol)
                        .font(.system(size: DSLayout.storyStatIconSize, weight: .black))
                        .foregroundStyle(DSColor.textPrimary)
                }
            }

            Text(valueText)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .padding(DSSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: DSLayout.storyStatTileMinHeight, alignment: .leading)
        .background(tint.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
    }
}

private struct StoryBadgeTile: View {
    let story: Story

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            StoryBadgePreview(topic: story.topic)

            VStack(alignment: .leading, spacing: 4) {
                Text("Badge")
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColor.textSecondary)

                Text(story.badgeTitle)
                    .font(DSTypography.subtitle())
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }

            Spacer(minLength: 0)
        }
        .padding(DSSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: DSLayout.storyBadgeRowMinHeight, alignment: .leading)
        .background(DSColor.mint.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
    }
}

private struct StoryBadgePreview: View {
    let topic: Topic

    var body: some View {
        ZStack {
            Circle()
                .fill(DSColor.gradient(for: topic))

            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 30, height: 30)
                .offset(x: -11, y: -10)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.28))
                .frame(width: 30, height: 16)
                .rotationEffect(.degrees(-22))
                .offset(x: 12, y: 10)

            Triangle()
                .fill(Color.white.opacity(0.88))
                .frame(width: 16, height: 14)
                .offset(x: 10, y: -11)

            Circle()
                .fill(DSColor.yellow.opacity(0.95))
                .frame(width: 10, height: 10)
                .offset(x: -13, y: 14)
        }
        .frame(width: DSLayout.storyBadgePreviewSize, height: DSLayout.storyBadgePreviewSize)
    }
}

struct StoryReaderView: View {
    let story: Story

    @EnvironmentObject private var narration: NarrationManager
    @State private var pageIndex: Int = 0

    private var page: StoryPage {
        story.pages[pageIndex]
    }

    private var spokenRangeForCurrentPage: NSRange? {
        guard narration.spokenText == page.body else { return nil }
        return narration.spokenRange
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                StoryPageProgressHeader(
                    currentPage: pageIndex + 1,
                    totalPages: story.pages.count
                )

                TopicArtworkView(
                    topic: story.topic,
                    seed: pageIndex,
                    storyTitle: story.title,
                    storyID: story.sourceStoryID,
                    pageNumber: pageIndex + 1
                )
                    .aspectRatio(3 / 2, contentMode: .fit)

                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    SoftColorStoryText(
                        text: page.body,
                        topic: story.topic,
                        spokenRange: spokenRangeForCurrentPage
                    )
                }
                .cardStyle()

                StoryListeningPanel(topic: story.topic, pageText: page.body)

                HStack(spacing: DSSpacing.sm) {
                    Button {
                        guard pageIndex > 0 else { return }
                        pageIndex -= 1
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                    }
                    .buttonStyle(SoftTonalCTAButtonStyle(color: DSColor.lavender))
                    .disabled(pageIndex == 0)
                    .opacity(pageIndex == 0 ? 0.45 : 1)

                    if pageIndex == story.pages.count - 1 {
                        NavigationLink {
                            QuizView(story: story)
                        } label: {
                            HStack(spacing: DSSpacing.xs) {
                                Text("Start Quiz")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .buttonStyle(PrimaryCTAButtonStyle())
                    } else {
                        Button {
                            guard pageIndex < story.pages.count - 1 else { return }
                            pageIndex += 1
                        } label: {
                            HStack(spacing: DSSpacing.xs) {
                                Text("Next Page")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .buttonStyle(PrimaryCTAButtonStyle())
                    }
                }
            }
            .screenContentPadding()
            .padding(.top, DSSpacing.xs)
            .padding(.bottom, DSSpacing.md)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 86)
        }
        .screenBackground()
        .navigationTitle(story.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: pageIndex) { _ in
            narration.stop()
        }
        .onDisappear {
            narration.stop()
        }
    }

}

private struct StoryPageProgressHeader: View {
    let currentPage: Int
    let totalPages: Int

    private var progress: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage) / Double(totalPages)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Page \(currentPage) of \(totalPages)")
                    .font(DSTypography.tiny())
                    .foregroundStyle(DSColor.textSecondary)
                Spacer()
                Text("\(Int((progress * 100).rounded()))%")
                    .font(DSTypography.tiny())
                    .foregroundStyle(DSColor.textSecondary)
            }

            ProgressView(value: progress)
                .tint(DSColor.yellow)
        }
    }
}

private struct StoryListeningPanel: View {
    let topic: Topic
    let pageText: String

    @EnvironmentObject private var narration: NarrationManager

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                        .fill(listeningTint.opacity(0.2))
                        .frame(width: 34, height: 34)
                    Image(systemName: "waveform")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(listeningTint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Listen to this page")
                        .font(DSTypography.captionBold())
                        .foregroundStyle(DSColor.textPrimary)
                    Text(statusText)
                        .font(DSTypography.tiny())
                        .foregroundStyle(DSColor.textSecondary)
                }

                Spacer()

                Button {
                    narration.speak(text: pageText)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(DSColor.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.86))
                        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            ProgressView(value: narration.progress(for: pageText))
                .tint(listeningTint)
                .opacity(isCurrentPageActive ? 1 : 0.45)

            HStack(spacing: DSSpacing.xs) {
                Button {
                    handlePrimaryAction()
                } label: {
                    Label(primaryActionTitle, systemImage: primaryActionSymbol)
                        .font(DSTypography.captionBold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 42)
                        .background(listeningTint)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    narration.stop()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .font(DSTypography.captionBold())
                        .foregroundStyle(DSColor.textPrimary)
                        .frame(maxWidth: .infinity, minHeight: 42)
                        .background(Color.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!isCurrentPageActive)
                .opacity(isCurrentPageActive ? 1 : 0.55)
            }
        }
        .padding(DSSpacing.md)
        .background(
            LinearGradient(
                colors: [listeningTint.opacity(0.2), listeningTint.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(listeningTint.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: listeningTint.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    private var isCurrentPageActive: Bool {
        narration.spokenText == pageText && (narration.isSpeaking || narration.isPaused)
    }

    private var statusText: String {
        if narration.isSpeaking && isCurrentPageActive {
            return "Reading aloud with word highlights."
        }
        if narration.isPaused && isCurrentPageActive {
            return "Paused. Tap resume to continue."
        }
        return "Tap play for a slow, clear read-aloud."
    }

    private var primaryActionTitle: String {
        if narration.isSpeaking && isCurrentPageActive {
            return "Pause"
        }
        if narration.isPaused && isCurrentPageActive {
            return "Resume"
        }
        return "Play"
    }

    private var primaryActionSymbol: String {
        if narration.isSpeaking && isCurrentPageActive {
            return "pause.fill"
        }
        return "play.fill"
    }

    private var listeningTint: Color {
        switch topic {
        case .ocean: return DSColor.oceanBlue
        case .animals: return Color(hex: "3F8E4F")
        case .space: return DSColor.lavender
        case .science: return Color(hex: "2AA79A")
        case .math: return Color(hex: "C27A2D")
        case .culture: return Color(hex: "B75D54")
        case .emotionsSocial: return Color(hex: "9A5AA3")
        case .history: return Color(hex: "8A6748")
        case .geography: return Color(hex: "3B8F45")
        case .technologyMachines: return Color(hex: "4F67C0")
        }
    }

    private func handlePrimaryAction() {
        if narration.isSpeaking && isCurrentPageActive {
            narration.pause()
            return
        }
        if narration.isPaused && isCurrentPageActive {
            narration.resume()
            return
        }
        narration.speak(text: pageText)
    }
}

private struct SoftColorStoryText: View {
    let text: String
    let topic: Topic
    let spokenRange: NSRange?

    var body: some View {
        Text(highlightedText)
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundStyle(DSColor.textPrimary)
            .lineSpacing(8)
            .tracking(0.18)
            .padding(.leading, DSSpacing.md)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(accentBarColor.opacity(0.38))
                    .frame(width: 6)
                    .padding(.vertical, DSSpacing.xs)
            }
    }

    private var highlightedText: AttributedString {
        var attributed = AttributedString(text)
        guard let spokenRange,
              let range = Range(spokenRange, in: text),
              let lowerBound = AttributedString.Index(range.lowerBound, within: attributed),
              let upperBound = AttributedString.Index(range.upperBound, within: attributed),
              lowerBound < upperBound else {
            return attributed
        }

        attributed[lowerBound..<upperBound].backgroundColor = accentBarColor.opacity(0.35)
        attributed[lowerBound..<upperBound].foregroundColor = DSColor.textPrimary
        attributed[lowerBound..<upperBound].font = .system(size: 18, weight: .black, design: .rounded)
        return attributed
    }

    private var accentBarColor: Color {
        switch topic {
        case .ocean: return DSColor.oceanBlue
        case .animals: return Color(hex: "3F8E4F")
        case .space: return DSColor.lavender
        case .science: return Color(hex: "2AA79A")
        case .math: return Color(hex: "C27A2D")
        case .culture: return Color(hex: "B75D54")
        case .emotionsSocial: return Color(hex: "9A5AA3")
        case .history: return Color(hex: "8A6748")
        case .geography: return Color(hex: "3B8F45")
        case .technologyMachines: return Color(hex: "4F67C0")
        }
    }
}
