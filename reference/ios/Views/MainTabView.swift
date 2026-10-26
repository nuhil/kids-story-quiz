import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private enum LaunchPhase {
    case splash
    case profile
    case app
}

private extension AnyTransition {
    static var softSwap: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 1.01)),
            removal: .opacity.combined(with: .scale(scale: 0.98))
        )
    }
}

struct AppRootView: View {
    @AppStorage("kid_profile_complete") private var kidProfileComplete: Bool = false
    @State private var phase: LaunchPhase = .splash
    @State private var hasStartedFlow: Bool = false

    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                SplashScreenView()
                    .transition(.opacity)
            case .profile:
                KidProfileOnboardingView {
                    withAnimation(.spring(response: 0.62, dampingFraction: 0.92)) {
                        phase = .app
                    }
                }
                .transition(.softSwap)
            case .app:
                MainTabView()
                    .transition(.softSwap)
            }
        }
        .animation(.easeInOut(duration: 0.55), value: phase)
        .onAppear {
            startFlowIfNeeded()
        }
        .onChange(of: kidProfileComplete) { isComplete in
            guard hasStartedFlow, phase != .splash else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                phase = isComplete ? .app : .profile
            }
        }
    }

    private func startFlowIfNeeded() {
        guard !hasStartedFlow else { return }
        hasStartedFlow = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.55) {
            withAnimation(.easeInOut(duration: 0.62)) {
                phase = kidProfileComplete ? .app : .profile
            }
        }
    }
}

private struct SplashScreenView: View {
    @State private var pulse = false
    @State private var textAssembled = false

    var body: some View {
        ZStack {
            splashBackground

            LinearGradient(
                colors: [Color.black.opacity(0.06), Color.black.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(Color.white.opacity(0.2))
                .frame(width: 304, height: 226)
                .scaleEffect(pulse ? 1.015 : 0.985)

            VStack(spacing: DSSpacing.lg) {
                VStack(spacing: DSSpacing.xs) {
                    Text("StorySpark")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: Color.black.opacity(0.24), radius: 6, x: 0, y: 3)
                        .offset(y: textAssembled ? 0 : -28)
                        .opacity(textAssembled ? 1 : 0)
                        .scaleEffect(textAssembled ? 1 : 0.95)

                    Text("Read. Learn. Play.")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(DSColor.splashDeepTeal)
                        .shadow(color: Color.white.opacity(0.35), radius: 2, x: 0, y: 1)
                        .offset(y: textAssembled ? 0 : 24)
                        .opacity(textAssembled ? 1 : 0)
                }

                HStack(spacing: DSSpacing.xs) {
                    Dot(fill: DSColor.coral)
                    Dot(fill: DSColor.yellow)
                    Dot(fill: DSColor.mint)
                }
                .opacity(textAssembled ? (pulse ? 1 : 0.45) : 0)
            }
            .padding(.horizontal, DSSpacing.lg)
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.82).delay(0.12)) {
                textAssembled = true
            }
            withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    @ViewBuilder
    private var splashBackground: some View {
        #if canImport(UIKit)
        if let image = UIImage(named: "SplashHero") {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [Color(hex: "FFF2DB"), Color(hex: "FFDCCC")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        #else
        LinearGradient(
            colors: [Color(hex: "FFF2DB"), Color(hex: "FFDCCC")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        #endif
    }
}

private struct KidProfileOnboardingView: View {
    @AppStorage("kid_name") private var storedKidName: String = ""
    @AppStorage("kid_age") private var storedKidAge: Int = 5
    @AppStorage("kid_profile_complete") private var kidProfileComplete: Bool = false

    let onContinue: () -> Void

    @State private var kidNameInput: String = ""
    @State private var kidAgeInput: Int = 5
    private let maxNameLength: Int = 7
    private let alphabet: [String] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init)
    private let nameTilePalette: [Color] = [
        DSColor.coral,
        DSColor.oceanBlue,
        DSColor.mint,
        DSColor.yellow,
        DSColor.lavender,
        Color(hex: "FF9DBB"),
        Color(hex: "7AA8FF")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    VStack(spacing: DSSpacing.xs) {
                        Text("Let's Meet Our Explorer")
                            .font(DSTypography.title())
                            .foregroundStyle(DSColor.textPrimary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        Text("Tell us your name and age to begin.")
                            .font(DSTypography.body())
                            .foregroundStyle(DSColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, DSLayout.onboardingHeaderTopInset)

                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Group {
                            if kidNameInput.isEmpty {
                                Text("Tap colorful letters to spell your name")
                                    .font(DSTypography.body())
                                    .foregroundStyle(DSColor.textSecondary)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: DSSpacing.xs) {
                                        ForEach(Array(kidNameInput.enumerated()), id: \.offset) { index, character in
                                            Text(character == " " ? "•" : String(character))
                                                .font(.system(size: 18, weight: .black, design: .rounded))
                                                .foregroundStyle(DSColor.textPrimary)
                                                .frame(width: DSLayout.onboardingNameTileSize, height: DSLayout.onboardingNameTileSize)
                                                .background(tileColor(at: index).opacity(0.28))
                                                .clipShape(RoundedRectangle(cornerRadius: DSRadii.sm, style: .continuous))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: DSRadii.sm, style: .continuous)
                                                        .stroke(tileColor(at: index).opacity(0.45), lineWidth: 1.1)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: DSLayout.onboardingNamePreviewMinHeight, alignment: .leading)
                        .playfulFieldChrome(accent: DSColor.coral)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 42), spacing: DSSpacing.xs)], spacing: DSSpacing.xs) {
                            ForEach(Array(alphabet.enumerated()), id: \.offset) { index, letter in
                                Button {
                                    appendLetter(letter)
                                } label: {
                                    Text(letter)
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundStyle(DSColor.textPrimary)
                                        .frame(maxWidth: .infinity, minHeight: DSLayout.onboardingLetterButtonHeight)
                                        .background(tileColor(at: index).opacity(0.23))
                                        .clipShape(RoundedRectangle(cornerRadius: DSRadii.sm, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DSRadii.sm, style: .continuous)
                                                .stroke(tileColor(at: index).opacity(0.4), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        HStack(spacing: DSSpacing.sm) {
                            nameActionButton(
                                title: "Undo",
                                icon: "delete.left.fill",
                                tint: DSColor.oceanBlue,
                                action: removeLastCharacter
                            )
                            nameActionButton(
                                title: "Space",
                                icon: "arrow.left.and.right",
                                tint: DSColor.mint,
                                action: appendSpace
                            )
                            nameActionButton(
                                title: "Clear",
                                icon: "xmark.circle.fill",
                                tint: DSColor.yellow,
                                action: clearName
                            )
                        }
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Pick your age")
                            .font(DSTypography.caption())
                            .foregroundStyle(DSColor.textSecondary)

                        HStack(spacing: DSSpacing.md) {
                            Picker("Age", selection: $kidAgeInput) {
                                ForEach(4...14, id: \.self) { age in
                                    Text("\(age)").tag(age)
                                }
                            }
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .frame(height: DSLayout.onboardingAgeWheelHeight)
                            .clipped()

                            VStack(spacing: DSSpacing.xs) {
                                Image(systemName: "birthday.cake.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(DSColor.coral)

                                Text("\(kidAgeInput)")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(DSColor.textPrimary)

                                Text("years")
                                    .font(DSTypography.caption())
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                            .frame(width: 88)
                            .padding(.vertical, DSSpacing.sm)
                            .background(DSColor.yellow.opacity(0.22))
                            .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
                        }
                    }
                    .cardStyle()

                    Button {
                        saveProfileAndContinue()
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "sparkles")
                            Text("Start Exploring")
                        }
                    }
                    .buttonStyle(PrimaryCTAButtonStyle(font: DSTypography.bodyBold()))
                    .disabled(sanitizedKidName.isEmpty)
                    .opacity(sanitizedKidName.isEmpty ? 0.6 : 1)
                }
                .screenContentPadding()
                .padding(.vertical, DSSpacing.md)
            }
            .navigationBarBackButtonHidden(true)
            .screenBackground()
        }
        .onAppear {
            kidNameInput = String(storedKidName.prefix(maxNameLength))
            kidAgeInput = max(4, min(14, storedKidAge))
        }
    }

    private var trimmedKidName: String {
        kidNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var sanitizedKidName: String {
        String(trimmedKidName.prefix(maxNameLength))
    }

    private func tileColor(at index: Int) -> Color {
        nameTilePalette[index % nameTilePalette.count]
    }

    private func appendLetter(_ letter: String) {
        guard kidNameInput.count < maxNameLength else { return }
        kidNameInput.append(letter)
    }

    private func appendSpace() {
        guard !kidNameInput.isEmpty else { return }
        guard !kidNameInput.hasSuffix(" ") else { return }
        guard kidNameInput.count < maxNameLength else { return }
        kidNameInput.append(" ")
    }

    private func removeLastCharacter() {
        guard !kidNameInput.isEmpty else { return }
        kidNameInput.removeLast()
    }

    private func clearName() {
        kidNameInput = ""
    }

    private func nameActionButton(
        title: String,
        icon: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: icon)
                Text(title)
                    .lineLimit(1)
            }
            .font(DSTypography.captionBold())
            .foregroundStyle(DSColor.textPrimary)
            .frame(maxWidth: .infinity, minHeight: DSLayout.onboardingActionButtonHeight)
            .background(tint.opacity(0.22))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(tint.opacity(0.38), lineWidth: 1.1)
            )
        }
        .buttonStyle(.plain)
    }

    private func saveProfileAndContinue() {
        storedKidName = sanitizedKidName
        storedKidAge = kidAgeInput
        kidProfileComplete = true
        onContinue()
    }
}

private struct Dot: View {
    let fill: Color

    var body: some View {
        Circle()
            .fill(fill)
            .frame(width: 10, height: 10)
    }
}

struct MainTabView: View {
    @EnvironmentObject private var navigation: AppNavigationModel

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            HomeView()
                .tag(AppTab.home)
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }

            CategoryQuizHubView()
                .tag(AppTab.quiz)
                .tabItem {
                    Label("Quiz", systemImage: "lightbulb.max.fill")
                }

            PlayZoneView()
                .tag(AppTab.play)
                .tabItem {
                    Label("Play", systemImage: "gamecontroller.fill")
                }

            AchievementsView()
                .tag(AppTab.goals)
                .tabItem {
                    Label("Goals", systemImage: "trophy.fill")
                }
        }
        .tint(DSColor.coral)
    }
}

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @AppStorage("kid_name") private var kidName: String = ""
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Hi, \(displayName)")
                            .font(DSTypography.subtitle())
                            .foregroundStyle(DSColor.coral)

                        Text("StorySpark")
                            .font(.system(size: 46, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DSColor.oceanBlue, Color(hex: "FF9A4C"), DSColor.coral],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: DSColor.coral.opacity(0.14), radius: 3, x: 0, y: 1)

                        HomeSearchField(text: $searchText)
                    }

                    if recentlyExploredStories.isEmpty && storiesByTopic.isEmpty {
                        Text("No stories found for \"\(searchText)\".")
                            .font(DSTypography.caption())
                            .foregroundStyle(DSColor.textSecondary)
                    } else {
                        HomeRecentStoriesSection(
                            stories: recentlyExploredStories,
                            metadataForStory: metadata(for:)
                        )

                        ForEach(storiesByTopic, id: \.0.id) { topic, stories in
                            HomeCategoryStoriesSection(
                                topic: topic,
                                stories: stories,
                                metadataForStory: metadata(for:)
                            )
                        }
                    }
                }
                .screenContentPadding()
                .padding(.vertical, DSSpacing.md)
            }
            .navigationBarTitleDisplayMode(.inline)
            .screenBackground()
            .navigationDestination(for: Story.self) { story in
                StoryDetailView(story: story)
            }
            .navigationDestination(for: Topic.self) { topic in
                HomeTopicStoriesView(topic: topic)
            }
        }
    }

    private var recentlyExploredStories: [Story] {
        let exploredStories = filteredStories
            .compactMap { story -> (story: Story, stats: StoryQuizStats)? in
                guard let stats = appModel.storyQuizStats[story.sourceStoryID], stats.attempts > 0 else { return nil }
                return (story, stats)
            }
            .sorted { lhs, rhs in
                if lhs.stats.attempts != rhs.stats.attempts {
                    return lhs.stats.attempts > rhs.stats.attempts
                }
                if lhs.stats.bestCorrectCount != rhs.stats.bestCorrectCount {
                    return lhs.stats.bestCorrectCount > rhs.stats.bestCorrectCount
                }
                return lhs.story.title < rhs.story.title
            }
            .map(\.story)

        if exploredStories.isEmpty {
            return Array(filteredStories.prefix(8))
        }
        return Array(exploredStories.prefix(8))
    }

    private var storiesByTopic: [(Topic, [Story])] {
        Topic.allCases.compactMap { topic in
            let stories = filteredStories.filter { $0.topic == topic }
            guard !stories.isEmpty else { return nil }
            return (topic, stories)
        }
    }

    private var filteredStories: [Story] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return appModel.stories }
        return appModel.stories.filter { story in
            story.title.localizedCaseInsensitiveContains(query) ||
            story.subtitle.localizedCaseInsensitiveContains(query) ||
            story.topic.title.localizedCaseInsensitiveContains(query)
        }
    }

    private var displayName: String {
        let trimmed = kidName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Explorer" : trimmed
    }

    private func metadata(for story: Story) -> HomeStoryCardStats {
        let stats = appModel.storyQuizStats[story.sourceStoryID]
        let readCount = stats?.attempts ?? 0
        let totalCorrect = stats?.totalCorrectAnswers ?? 0
        let bestCorrect = stats?.bestCorrectCount ?? 0
        let questionCount = max(stats?.questionCount ?? story.quiz.count, 1)
        let bestScore = Int((Double(bestCorrect) / Double(questionCount) * 100).rounded())
        let points = totalCorrect * 10
        return HomeStoryCardStats(readCount: readCount, points: points, bestScore: bestScore)
    }
}

private struct HomeSearchField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    private var hasQuery: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isFocused || hasQuery ? DSColor.coral : DSColor.textSecondary.opacity(0.9))
                .frame(width: 20)

            TextField(
                "",
                text: $text,
                prompt: Text("Search for stories you want to read")
                    .foregroundColor(DSColor.oceanBlue.opacity(0.62))
            )
                .font(DSTypography.body())
                .foregroundStyle(DSColor.textPrimary)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .focused($isFocused)

            if hasQuery {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(DSColor.textSecondary.opacity(0.7))
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 58)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(hex: "FAF8F2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isFocused ? DSColor.oceanBlue.opacity(0.55) : Color.black.opacity(0.08), lineWidth: 1.2)
        )
        .shadow(color: DSColor.oceanBlue.opacity(0.08), radius: 8, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.18), value: hasQuery)
    }
}

private struct HomeStoryCardStats {
    let readCount: Int
    let points: Int
    let bestScore: Int
}

private extension Topic {
    var homeStoryTint: Color {
        switch self {
        case .ocean: return DSColor.oceanBlue
        case .animals: return Color(hex: "3F8E4F")
        case .space: return Color(hex: "6A70E8")
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

private struct HomeStoryTitleLabel: View {
    let title: String
    let topic: Topic
    let compact: Bool

    var body: some View {
        Text(title)
            .font(compact ? DSTypography.body() : DSTypography.subtitle())
            .foregroundStyle(topic.homeStoryTint)
            .lineLimit(2)
    }
}

private struct HomeStoryMetricsRow: View {
    let topic: Topic
    let stats: HomeStoryCardStats
    let compact: Bool

    var body: some View {
        HStack(spacing: compact ? 8 : 10) {
            metricChip(icon: "book.closed.fill", value: "\(stats.readCount)")
            metricChip(icon: "star.fill", value: "\(stats.points)")
            metricChip(icon: "chart.line.uptrend.xyaxis", value: "\(stats.bestScore)%")
        }
    }

    private func metricChip(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: compact ? 10 : 11, weight: .bold))
            Text(value)
                .font(compact ? DSTypography.tiny() : DSTypography.caption())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(topic.homeStoryTint)
    }
}

private struct HomeRecentStoriesSection: View {
    let stories: [Story]
    let metadataForStory: (Story) -> HomeStoryCardStats

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Recently Explored Stories")
                .font(DSTypography.title())
                .foregroundStyle(DSColor.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DSSpacing.md) {
                    ForEach(stories) { story in
                        NavigationLink(value: story) {
                            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                                TopicArtworkView(
                                    topic: story.topic,
                                    seed: abs(story.sourceStoryID.hashValue),
                                    storyTitle: story.title,
                                    cornerRadius: 12
                                )
                                .frame(width: 300, height: 170)
                                .clipped()

                                VStack(alignment: .leading, spacing: 4) {
                                    HomeStoryTitleLabel(
                                        title: story.title,
                                        topic: story.topic,
                                        compact: false
                                    )

                                    HomeStoryMetricsRow(
                                        topic: story.topic,
                                        stats: metadataForStory(story),
                                        compact: false
                                    )
                                }
                            }
                            .frame(width: 300, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct HomeCategoryStoriesSection: View {
    let topic: Topic
    let stories: [Story]
    let metadataForStory: (Story) -> HomeStoryCardStats

    private let rows = [
        GridItem(.fixed(158), spacing: DSSpacing.md, alignment: .top),
        GridItem(.fixed(158), spacing: DSSpacing.md, alignment: .top)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(topic.title)
                        .font(DSTypography.subtitle())
                        .foregroundStyle(DSColor.textPrimary)
                    Text(topic.subtitle)
                        .font(DSTypography.caption())
                        .foregroundStyle(DSColor.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                NavigationLink(value: topic) {
                    Text("See All")
                        .font(DSTypography.captionBold())
                        .foregroundStyle(DSColor.coral)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: DSSpacing.md) {
                    ForEach(stories) { story in
                        NavigationLink(value: story) {
                            HomeCompactStoryCard(
                                story: story,
                                stats: metadataForStory(story)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(height: 328)
        }
    }
}

private struct HomeTopicStoriesView: View {
    @EnvironmentObject private var appModel: AppModel
    let topic: Topic

    private var topicStories: [Story] {
        appModel.stories.filter { $0.topic == topic }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text(topic.subtitle)
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColor.textSecondary)

                ForEach(topicStories) { story in
                    NavigationLink(value: story) {
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            TopicArtworkView(
                                topic: story.topic,
                                seed: abs(story.sourceStoryID.hashValue),
                                storyTitle: story.title,
                                cornerRadius: 12
                            )
                            .frame(height: 166)
                            .clipped()

                            Text(story.title)
                                .font(DSTypography.subtitle())
                                .foregroundStyle(DSColor.textPrimary)

                            Text(story.subtitle)
                                .font(DSTypography.caption())
                                .foregroundStyle(DSColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
            .screenContentPadding()
            .padding(.vertical, DSSpacing.md)
        }
        .screenBackground()
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HomeCompactStoryCard: View {
    let story: Story
    let stats: HomeStoryCardStats

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            TopicArtworkView(
                topic: story.topic,
                seed: abs(story.sourceStoryID.hashValue),
                storyTitle: story.title,
                cornerRadius: 10
            )
            .frame(width: 188, height: 96)
            .clipped()

            VStack(alignment: .leading, spacing: 3) {
                HomeStoryTitleLabel(
                    title: story.title,
                    topic: story.topic,
                    compact: true
                )

                HomeStoryMetricsRow(
                    topic: story.topic,
                    stats: stats,
                    compact: true
                )
            }
        }
        .frame(width: 188, alignment: .leading)
    }
}

private struct HomeJourneyStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.34))
                        .frame(
                            width: DSLayout.homeJourneyStatIconBadgeSize,
                            height: DSLayout.homeJourneyStatIconBadgeSize
                        )
                    Circle()
                        .stroke(color.opacity(0.38), lineWidth: 1.1)
                        .frame(
                            width: DSLayout.homeJourneyStatIconBadgeSize,
                            height: DSLayout.homeJourneyStatIconBadgeSize
                        )
                    Image(systemName: symbol)
                        .font(.system(size: DSLayout.homeJourneyStatIconSize, weight: .black))
                        .foregroundStyle(DSColor.textPrimary)
                }

                Text(title)
                    .font(DSTypography.statLabel())
                    .foregroundStyle(DSColor.textPrimary.opacity(0.84))
            }

            Text(value)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(subtitle)
                .font(DSTypography.caption())
                .foregroundStyle(DSColor.textPrimary.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: DSLayout.homeJourneyStatMinHeight, alignment: .topLeading)
        .padding(DSSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.34), color.opacity(0.14)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.24))
                        .frame(width: 86, height: 86)
                        .offset(x: 26, y: -34)
                }
                .overlay(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 76, height: 24)
                        .rotationEffect(.degrees(-9))
                        .offset(x: -22, y: 12)
                }
        }
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.16), radius: 8, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
}

private struct HomeJourneyCategoryCard: View {
    let topic: Topic
    let summary: CategoryProgressSummary
    let subtitle: String

    var body: some View {
        VStack(spacing: 0) {
            HomeCategoryBackdrop(topic: topic)
                .opacity(DSLayout.homeCategoryBackdropTintOpacity)
                .frame(height: DSLayout.homeCategoryBackdropHeight)
                .frame(maxWidth: .infinity)
                .clipped()

            HStack(spacing: DSSpacing.sm) {
                HStack(spacing: DSSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(DSColor.gradient(for: topic))
                            .frame(width: DSLayout.homeCategoryIconSize, height: DSLayout.homeCategoryIconSize)
                        Image(systemName: topic.icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(topic.title)
                            .font(DSTypography.body())
                            .foregroundStyle(DSColor.textPrimary)

                        Text(subtitle)
                            .font(DSTypography.caption())
                            .foregroundStyle(DSColor.textSecondary)
                            .lineLimit(2)
                    }
                    .layoutPriority(1)
                }

                Spacer(minLength: DSSpacing.xs)

                HStack(spacing: DSLayout.homeRightClusterSpacing) {
                    HomeCategoryPointsBadge(points: summary.pointsEarned)
                    TopicProgressBadge(topic: topic, progress: summary.progressRatio)
                }
                .frame(minWidth: DSLayout.homeRightClusterMinWidth, alignment: .trailing)
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(DSSpacing.md)
            .background(DSColor.surface)
        }
        .frame(maxWidth: .infinity, minHeight: DSLayout.categoryCardMinHeight, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

private struct HomeCategoryBackdrop: View {
    let topic: Topic

    var body: some View {
        GeometryReader { geo in
            #if canImport(UIKit)
            if let imageName = backdropAssetName(for: topic),
               let backdropImage = UIImage(named: imageName) {
                Image(uiImage: backdropImage)
                    .resizable()
                    .scaledToFill()
            } else {
                fallbackBackdrop(in: geo.size)
            }
            #else
            fallbackBackdrop(in: geo.size)
            #endif
        }
    }

    @ViewBuilder
    private func fallbackBackdrop(in size: CGSize) -> some View {
        switch topic {
        case .ocean:
            oceanBackdrop(in: size)
        case .animals:
            animalsBackdrop(in: size)
        case .space:
            spaceBackdrop(in: size)
        default:
            genericBackdrop(in: size)
        }
    }

    private func backdropAssetName(for topic: Topic) -> String? {
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

    @ViewBuilder
    private func oceanBackdrop(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E1F6FF"), Color(hex: "F4FCFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(DSColor.oceanBlue.opacity(0.26))
                .frame(width: size.width * 0.5)
                .offset(x: size.width * 0.28, y: -size.height * 0.3)

            Capsule()
                .fill(Color(hex: "89D6FF").opacity(0.42))
                .frame(width: size.width * 0.66, height: size.height * 0.42)
                .offset(x: -size.width * 0.2, y: size.height * 0.34)

            Capsule()
                .fill(Color(hex: "46B6FF").opacity(0.4))
                .frame(width: size.width * 0.5, height: size.height * 0.34)
                .offset(x: size.width * 0.08, y: size.height * 0.36)

            ForEach(0..<7, id: \.self) { idx in
                Circle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: CGFloat(5 + (idx % 3) * 3))
                    .offset(
                        x: -size.width * 0.38 + CGFloat(idx) * (size.width * 0.11),
                        y: size.height * 0.15 + CGFloat((idx % 2) * 9)
                    )
            }

            Image(systemName: "drop.fill")
                .font(.system(size: min(size.height, 26), weight: .bold))
                .foregroundStyle(DSColor.oceanBlue.opacity(DSLayout.homeCategoryBackdropSymbolOpacity))
                .offset(x: size.width * 0.34, y: size.height * 0.03)
        }
    }

    @ViewBuilder
    private func animalsBackdrop(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E9F8E1"), Color(hex: "F8FCEC")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(hex: "BFEA8A").opacity(0.44))
                .frame(width: size.width * 0.48)
                .offset(x: size.width * 0.24, y: -size.height * 0.26)

            Ellipse()
                .fill(Color(hex: "7CC86A").opacity(0.44))
                .frame(width: size.width * 0.66, height: size.height * 0.42)
                .offset(x: -size.width * 0.22, y: size.height * 0.35)

            Ellipse()
                .fill(Color(hex: "56B957").opacity(0.4))
                .frame(width: size.width * 0.5, height: size.height * 0.35)
                .offset(x: size.width * 0.1, y: size.height * 0.38)

            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color(hex: "6FB96C").opacity(0.36))
                .frame(width: size.width * 0.06, height: size.height * 0.34)
                .offset(x: -size.width * 0.35, y: size.height * 0.18)

            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color(hex: "5EAE5A").opacity(0.33))
                .frame(width: size.width * 0.05, height: size.height * 0.3)
                .offset(x: -size.width * 0.27, y: size.height * 0.2)

            Image(systemName: "pawprint.fill")
                .font(.system(size: min(size.height, 28), weight: .bold))
                .foregroundStyle(Color(hex: "4A8E48").opacity(DSLayout.homeCategoryBackdropSymbolOpacity))
                .offset(x: size.width * 0.33, y: size.height * 0.02)
        }
    }

    @ViewBuilder
    private func spaceBackdrop(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "EAEFFF"), Color(hex: "F7F2FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(hex: "8DA0FF").opacity(0.4))
                .frame(width: size.width * 0.5)
                .offset(x: size.width * 0.26, y: -size.height * 0.3)

            Ellipse()
                .fill(Color(hex: "A5B2FF").opacity(0.37))
                .frame(width: size.width * 0.68, height: size.height * 0.42)
                .offset(x: -size.width * 0.18, y: size.height * 0.35)

            ForEach(0..<8, id: \.self) { idx in
                Circle()
                    .fill(Color.white.opacity(0.72))
                    .frame(width: CGFloat(3 + (idx % 3) * 2))
                    .offset(
                        x: -size.width * 0.36 + CGFloat(idx) * (size.width * 0.1),
                        y: -size.height * 0.22 + CGFloat((idx % 2) * 12)
                    )
            }

            Image(systemName: "sparkles")
                .font(.system(size: min(size.height, 26), weight: .bold))
                .foregroundStyle(Color(hex: "5E6BDB").opacity(DSLayout.homeCategoryBackdropSymbolOpacity))
                .offset(x: size.width * 0.33, y: size.height * 0.03)
        }
    }

    @ViewBuilder
    private func genericBackdrop(in size: CGSize) -> some View {
        ZStack {
            DSColor.gradient(for: topic)
                .opacity(0.2)

            Circle()
                .fill(Color.white.opacity(0.32))
                .frame(width: size.width * 0.45)
                .offset(x: size.width * 0.25, y: -size.height * 0.24)

            Ellipse()
                .fill(Color.white.opacity(0.24))
                .frame(width: size.width * 0.62, height: size.height * 0.46)
                .offset(x: -size.width * 0.18, y: size.height * 0.3)

            Image(systemName: topic.icon)
                .font(.system(size: min(size.height, 28), weight: .bold))
                .foregroundStyle(DSColor.textPrimary.opacity(0.22))
                .offset(x: size.width * 0.34, y: size.height * 0.02)
        }
    }
}

private struct HomeCategoryPointsBadge: View {
    let points: Int

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DSColor.yellow.opacity(0.52), DSColor.coral.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "star.fill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Color(hex: "A86600"))
            }
            .frame(width: DSLayout.homePointsBubbleSize, height: DSLayout.homePointsBubbleSize)

            Text(formattedPoints)
                .font(DSTypography.tiny())
                .foregroundStyle(DSColor.textPrimary)
        }
    }

    private var formattedPoints: String {
        if points >= 1000 {
            let value = Double(points) / 1000.0
            return String(format: "%.1fk", value)
        }
        return "\(points)"
    }
}

private struct TopicProgressBadge: View {
    let topic: Topic
    let progress: Double

    private var value: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(DSColor.gradient(for: topic))

                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.white.opacity(0.95))
            }
            .frame(width: DSLayout.miniProgressRingSize, height: DSLayout.miniProgressRingSize)

            Text("\(Int((value * 100).rounded()))%")
                .font(DSTypography.tiny())
                .foregroundStyle(DSColor.textPrimary)
        }
    }
}

private enum PlayBubbleTone: String, CaseIterable {
    case sun
    case ocean
    case mint
    case berry

    var title: String {
        switch self {
        case .sun: return "Sun"
        case .ocean: return "Ocean"
        case .mint: return "Mint"
        case .berry: return "Berry"
        }
    }

    var color: Color {
        switch self {
        case .sun: return DSColor.yellow
        case .ocean: return DSColor.oceanBlue
        case .mint: return DSColor.mint
        case .berry: return DSColor.coral
        }
    }

    var symbol: String {
        switch self {
        case .sun: return "sun.max.fill"
        case .ocean: return "drop.fill"
        case .mint: return "leaf.fill"
        case .berry: return "heart.fill"
        }
    }
}

private struct PlayBubble: Identifiable {
    let id: UUID
    var tone: PlayBubbleTone
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var isVisible: Bool

    init(
        id: UUID = UUID(),
        tone: PlayBubbleTone,
        x: CGFloat,
        y: CGFloat,
        size: CGFloat,
        isVisible: Bool = true
    ) {
        self.id = id
        self.tone = tone
        self.x = x
        self.y = y
        self.size = size
        self.isVisible = isVisible
    }

    static func random(id: UUID = UUID()) -> PlayBubble {
        PlayBubble(
            id: id,
            tone: PlayBubbleTone.allCases.randomElement() ?? .ocean,
            x: CGFloat.random(in: 0.1...0.9),
            y: CGFloat.random(in: 0.15...0.9),
            size: CGFloat.random(in: 54...86),
            isVisible: true
        )
    }
}

private enum PlayHaptics {
#if canImport(UIKit)
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let notification = UINotificationFeedbackGenerator()
#endif

    static func prepare() {
#if canImport(UIKit)
        lightImpact.prepare()
        softImpact.prepare()
        notification.prepare()
#endif
    }

    static func tap() {
#if canImport(UIKit)
        lightImpact.impactOccurred(intensity: 0.7)
        lightImpact.prepare()
#endif
    }

    static func correct() {
#if canImport(UIKit)
        notification.notificationOccurred(.success)
        notification.prepare()
#endif
    }

    static func miss() {
#if canImport(UIKit)
        notification.notificationOccurred(.warning)
        notification.prepare()
#endif
    }

    static func pauseResume() {
#if canImport(UIKit)
        softImpact.impactOccurred(intensity: 0.8)
        softImpact.prepare()
#endif
    }

    static func roundComplete() {
#if canImport(UIKit)
        notification.notificationOccurred(.success)
        notification.prepare()
#endif
    }
}

private struct PlayHudChip: View {
    let title: String
    let value: String
    let tint: Color
    let symbol: String
    let valueFontSize: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let minHeight: CGFloat

    init(
        title: String,
        value: String,
        tint: Color,
        symbol: String,
        valueFontSize: CGFloat = 24,
        topPadding: CGFloat = 10,
        bottomPadding: CGFloat = 10,
        minHeight: CGFloat = DSLayout.playHudStatMinHeight
    ) {
        self.title = title
        self.value = value
        self.tint = tint
        self.symbol = symbol
        self.valueFontSize = valueFontSize
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.minHeight = minHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.33))
                        .frame(
                            width: DSLayout.playHudStatIconBadgeSize,
                            height: DSLayout.playHudStatIconBadgeSize
                        )
                    Circle()
                        .stroke(tint.opacity(0.36), lineWidth: 1)
                        .frame(
                            width: DSLayout.playHudStatIconBadgeSize,
                            height: DSLayout.playHudStatIconBadgeSize
                        )
                    Image(systemName: symbol)
                        .font(.system(size: DSLayout.playHudStatIconSize, weight: .black))
                        .foregroundStyle(DSColor.textPrimary)
                }

                Text(title)
                    .font(DSTypography.tiny())
                    .foregroundStyle(DSColor.textPrimary.opacity(0.82))
            }

            Text(value)
                .font(.system(size: valueFontSize, weight: .black, design: .rounded))
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: minHeight, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.34), tint.opacity(0.14)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 42, height: 42)
                        .offset(x: 13, y: -12)
                }
                .overlay(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 36, height: 12)
                        .rotationEffect(.degrees(-8))
                        .offset(x: -8, y: 5)
                }
        }
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: tint.opacity(0.14), radius: 6, x: 0, y: 3)
        .shadow(color: Color.black.opacity(0.07), radius: 4, x: 0, y: 2)
    }
}

struct BalloonPopGameView: View {
    @State private var bubbles: [PlayBubble] = (0..<10).map { _ in PlayBubble.random() }
    @State private var targetTone: PlayBubbleTone = PlayBubbleTone.allCases.randomElement() ?? .ocean
    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var level: Int = 1
    @State private var timeLeft: Int = 60
    @State private var isRunning: Bool = false

    @AppStorage("play_zone_best_score") private var bestScore: Int = 0

    private let roundDuration: Int = 60
    private let movementInterval: TimeInterval = 2.1
    private let movementTimer = Timer.publish(every: 2.1, on: .main, in: .common).autoconnect()
    private let countdownTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack(spacing: DSSpacing.sm) {
                PlayHudChip(title: "Score", value: "\(score)", tint: DSColor.yellow, symbol: "star.fill")
                PlayHudChip(title: "Best", value: "\(bestScore)", tint: DSColor.lavender, symbol: "trophy.fill")
                PlayHudChip(title: "Time", value: "\(timeLeft)s", tint: DSColor.mint, symbol: "clock.fill")
            }

            HStack(spacing: DSSpacing.sm) {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: targetTone.symbol)
                        .foregroundStyle(targetTone.color)
                    Text("Pop \(targetTone.title)")
                        .font(DSTypography.body())
                        .foregroundStyle(DSColor.textPrimary)
                }
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .background(targetTone.color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous))

                Spacer()

                Text("Streak \(streak)  •  Lv \(level)")
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColor.textSecondary)
            }

            PlayZoneBoard(
                bubbles: bubbles,
                targetTone: targetTone,
                isRunning: isRunning,
                isRoundOver: timeLeft == 0,
                score: score,
                onBubbleTap: hitBubble
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: DSSpacing.sm) {
                Button {
                    handlePrimaryAction()
                } label: {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: primaryActionIcon)
                        Text(primaryActionTitle)
                    }
                }
                .buttonStyle(PrimaryCTAButtonStyle())

                Button {
                    startRound(resetScore: true)
                } label: {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                        Text("New Round")
                    }
                }
                .buttonStyle(SoftTonalCTAButtonStyle(color: DSColor.oceanBlue))
            }
        }
        .screenContentPadding()
        .padding(.top, DSSpacing.md)
        .padding(.bottom, DSSpacing.md)
        .screenBackground()
        .onReceive(movementTimer) { _ in
            guard isRunning else { return }
            driftBubbles()
        }
        .onReceive(countdownTimer) { _ in
            guard isRunning else { return }
            tickRound()
        }
        .onAppear {
            PlayHaptics.prepare()
            ensureTargetToneAvailable()
        }
    }

    private var primaryActionTitle: String {
        if timeLeft == 0 { return "Play Again" }
        return isRunning ? "Pause" : "Start"
    }

    private var primaryActionIcon: String {
        if timeLeft == 0 { return "gobackward" }
        return isRunning ? "pause.fill" : "play.fill"
    }

    private func handlePrimaryAction() {
        if timeLeft == 0 {
            PlayHaptics.pauseResume()
            startRound(resetScore: true)
            return
        }
        if isRunning {
            PlayHaptics.pauseResume()
            isRunning = false
        } else {
            PlayHaptics.pauseResume()
            startRound(resetScore: false)
        }
    }

    private func startRound(resetScore: Bool) {
        if resetScore || timeLeft == 0 {
            score = 0
            streak = 0
            level = 1
            timeLeft = roundDuration
            bubbles = bubbles.map { PlayBubble.random(id: $0.id) }
        }
        if !isRunning {
            targetTone = nextAvailableTargetTone()
            isRunning = true
        } else {
            ensureTargetToneAvailable()
        }
    }

    private func tickRound() {
        guard timeLeft > 0 else { return }
        timeLeft -= 1
        if timeLeft <= 0 {
            timeLeft = 0
            isRunning = false
            bestScore = max(bestScore, score)
            PlayHaptics.roundComplete()
        }
    }

    private func driftBubbles() {
        withAnimation(.easeInOut(duration: movementInterval * 0.82)) {
            for idx in bubbles.indices where bubbles[idx].isVisible {
                let nextX = bubbles[idx].x + CGFloat.random(in: -0.05...0.05)
                let nextY = bubbles[idx].y + CGFloat.random(in: -0.045...0.045)
                bubbles[idx].x = nextX.clamped(to: 0.1...0.9)
                bubbles[idx].y = nextY.clamped(to: 0.15...0.9)
            }
        }
        ensureTargetToneAvailable()
    }

    private func hitBubble(_ bubbleID: UUID) {
        guard isRunning else { return }
        guard let idx = bubbles.firstIndex(where: { $0.id == bubbleID && $0.isVisible }) else { return }

        let isMatch = bubbles[idx].tone == targetTone
        let previousTarget = targetTone
        withAnimation(.spring(response: 0.2, dampingFraction: 0.78)) {
            bubbles[idx].isVisible = false
        }
        PlayHaptics.tap()

        if isMatch {
            streak += 1
            score += 10 + min(streak, 6)
            if streak.isMultiple(of: 5) {
                level += 1
            }
            targetTone = nextAvailableTargetTone(excluding: previousTarget)
            PlayHaptics.correct()
        } else {
            streak = 0
            score = max(0, score - 2)
            PlayHaptics.miss()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard let respawnIdx = bubbles.firstIndex(where: { $0.id == bubbleID }) else { return }
            withAnimation(.easeInOut(duration: 0.38)) {
                bubbles[respawnIdx] = PlayBubble.random(id: bubbleID)
            }
            ensureTargetToneAvailable()
        }
    }

    private func visibleTones() -> [PlayBubbleTone] {
        bubbles.compactMap { bubble in
            guard bubble.isVisible else { return nil }
            return bubble.tone
        }
    }

    private func nextAvailableTargetTone(excluding excludedTone: PlayBubbleTone? = nil) -> PlayBubbleTone {
        let available = Array(Set(visibleTones()))
        guard !available.isEmpty else { return targetTone }

        if let excludedTone, available.count > 1 {
            let filtered = available.filter { $0 != excludedTone }
            if let tone = filtered.randomElement() {
                return tone
            }
        }
        return available.randomElement() ?? targetTone
    }

    private func ensureTargetToneAvailable() {
        let available = Set(visibleTones())
        guard !available.isEmpty else { return }
        if !available.contains(targetTone) {
            targetTone = available.randomElement() ?? targetTone
        }
    }
}

private struct PlayZoneBoard: View {
    let bubbles: [PlayBubble]
    let targetTone: PlayBubbleTone
    let isRunning: Bool
    let isRoundOver: Bool
    let score: Int
    let onBubbleTap: (UUID) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [DSColor.oceanBlue.opacity(0.2), DSColor.lavender.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                ForEach(bubbles) { bubble in
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [bubble.tone.color.opacity(0.96), bubble.tone.color.opacity(0.7)],
                                    center: .topLeading,
                                    startRadius: bubble.size * 0.08,
                                    endRadius: bubble.size * 0.58
                                )
                            )

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.56), Color.white.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.screen)

                        Circle()
                            .fill(Color.white.opacity(0.44))
                            .frame(width: bubble.size * 0.28, height: bubble.size * 0.28)
                            .offset(x: -bubble.size * 0.18, y: -bubble.size * 0.2)

                        Circle()
                            .stroke(Color.white.opacity(0.52), lineWidth: 1.2)
                    }
                    .frame(width: bubble.size, height: bubble.size)
                    .shadow(color: bubble.tone.color.opacity(0.34), radius: 9, x: 0, y: 6)
                        .position(x: geo.size.width * bubble.x, y: geo.size.height * bubble.y)
                        .scaleEffect(bubble.isVisible ? 1 : 0.2)
                        .opacity(bubble.isVisible ? 1 : 0)
                        .onTapGesture {
                            onBubbleTap(bubble.id)
                        }
                }

                if !isRunning && !isRoundOver {
                    overlayText(
                        title: "Ready to Play?",
                        subtitle: "Pop only \(targetTone.title) bubbles."
                    )
                }

                if isRoundOver {
                    overlayText(
                        title: "Round Complete!",
                        subtitle: "Final score: \(score)"
                    )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous))
    }

    private func overlayText(title: String, subtitle: String) -> some View {
        VStack(spacing: DSSpacing.xs) {
            Text(title)
                .font(DSTypography.subtitle())
                .foregroundStyle(DSColor.textPrimary)
            Text(subtitle)
                .font(DSTypography.caption())
                .foregroundStyle(DSColor.textSecondary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(DSColor.surface.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

struct AchievementsView: View {
    @EnvironmentObject private var appModel: AppModel

    @AppStorage("kid_name") private var kidName: String = ""
    @AppStorage("kid_age") private var kidAge: Int = 5
    @AppStorage("kid_profile_complete") private var kidProfileComplete: Bool = false

    @State private var showSignOutAlert: Bool = false
    @State private var sparkPreviewStory: Story?
    @State private var sparkPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $sparkPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Goals")
                        .font(DSTypography.title())
                        .foregroundStyle(DSColor.textPrimary)

                    Text("Your profile, points, badges, and milestones all in one place.")
                        .font(DSTypography.body())
                        .foregroundStyle(DSColor.textSecondary)

                    HStack(spacing: DSSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(DSColor.lavender.opacity(0.3))
                                .frame(width: DSLayout.avatarSize, height: DSLayout.avatarSize)
                            Image(systemName: "face.smiling")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(DSColor.textPrimary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(kidName.isEmpty ? "Explorer" : kidName)
                                .font(DSTypography.subtitle())
                                .foregroundStyle(DSColor.textPrimary)
                            Text("Age \(kidAge)")
                                .font(DSTypography.caption())
                                .foregroundStyle(DSColor.textSecondary)
                        }

                        Spacer()
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            Text("Today's Spark")
                                .font(DSTypography.subtitle())
                                .foregroundStyle(DSColor.textPrimary)
                            Spacer()
                            Button {
                                refreshSparkPreview()
                            } label: {
                                HStack(spacing: DSSpacing.xs) {
                                    ZStack {
                                        Circle()
                                            .fill(DSColor.coral.opacity(0.18))
                                            .frame(width: 26, height: 26)
                                        Image(systemName: "shuffle")
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundStyle(DSColor.coral)
                                    }
                                    Text("Try Another")
                                        .font(DSTypography.captionBold())
                                        .foregroundStyle(DSColor.textPrimary)
                                }
                                .padding(.horizontal, DSSpacing.sm)
                                .frame(minWidth: 126, minHeight: 44)
                                .background(DSColor.surface.opacity(0.96))
                                .clipShape(RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous)
                                        .stroke(DSColor.coral.opacity(0.28), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .shadow(color: DSColor.coral.opacity(0.2), radius: 6, x: 0, y: 3)
                        }

                        if let sparkStory = sparkPreviewStory {
                            HStack(spacing: DSSpacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(DSColor.gradient(for: sparkStory.topic))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: sparkStory.topic.icon)
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sparkStory.title)
                                        .font(DSTypography.body())
                                        .foregroundStyle(DSColor.textPrimary)
                                    Text("\(sparkStory.topic.title) • \(sparkStory.pages.count) pages")
                                        .font(DSTypography.caption())
                                        .foregroundStyle(DSColor.textSecondary)
                                }

                                Spacer()
                            }
                        } else {
                            Text("Tap shuffle to pick a surprise story.")
                                .font(DSTypography.caption())
                                .foregroundStyle(DSColor.textSecondary)
                        }

                        Button {
                            openCurrentSparkStory()
                        } label: {
                            HStack(spacing: DSSpacing.xs) {
                                Image(systemName: "book.pages.fill")
                                Text("Start Spark")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .buttonStyle(PrimaryCTAButtonStyle())
                    }
                    .cardStyle()

                    HStack(spacing: DSSpacing.md) {
                        HomeJourneyStatCard(
                            title: "Points",
                            value: "\(appModel.totalPoints)",
                            subtitle: "Total Earned",
                            color: DSColor.yellow,
                            symbol: "star.fill"
                        )
                        HomeJourneyStatCard(
                            title: "Badges",
                            value: "\(appModel.totalBadgesEarnedCount)",
                            subtitle: "Collected",
                            color: DSColor.mint,
                            symbol: "medal.fill"
                        )
                    }

                    HStack(spacing: DSSpacing.md) {
                        HomeJourneyStatCard(
                            title: "Game Passes",
                            value: "\(appModel.gamePassBalance)",
                            subtitle: "Ready To Use",
                            color: DSColor.oceanBlue,
                            symbol: "ticket.fill"
                        )
                        HomeJourneyStatCard(
                            title: "Active Games",
                            value: "\(appModel.activeGameUnlockCount)",
                            subtitle: "Unlocked Now",
                            color: DSColor.mint,
                            symbol: "lock.open.fill"
                        )
                    }

                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Badge Collection")
                            .font(DSTypography.subtitle())
                            .foregroundStyle(DSColor.textPrimary)
                        Text("Unique \(appModel.unlockedBadges.count) • Total earned \(appModel.totalBadgesEarnedCount)")
                            .font(DSTypography.caption())
                            .foregroundStyle(DSColor.textSecondary)

                        if appModel.unlockedBadges.isEmpty {
                            VStack(spacing: DSSpacing.md) {
                                Image(systemName: "medal")
                                    .font(.system(size: 44))
                                    .foregroundStyle(DSColor.textSecondary)
                                Text("No badges yet. Start a story and ace a quiz to unlock one.")
                                    .font(DSTypography.body())
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .cardStyle()
                        } else {
                            ForEach(appModel.unlockedBadges) { badge in
                                let badgeCount = appModel.badgeInventory.first(where: { $0.badgeKey == badge.storySourceID })?.count ?? 0
                                HStack(spacing: DSSpacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(DSColor.yellow.opacity(0.35))
                                            .frame(width: DSLayout.avatarInnerSize, height: DSLayout.avatarInnerSize)
                                        Image(systemName: badge.symbol)
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(DSColor.coral)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(badge.title)
                                            .font(DSTypography.body())
                                            .foregroundStyle(DSColor.textPrimary)
                                        Text(badgeCount > 0 ? "Collected \(badgeCount)x" : "Achievement unlocked")
                                            .font(DSTypography.caption())
                                            .foregroundStyle(DSColor.textSecondary)
                                    }

                                    Spacer()
                                }
                                .cardStyle()
                            }
                        }
                    }

                    Button {
                        showSignOutAlert = true
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "figure.walk.circle.fill")
                            Text("I Am Done Exploring")
                        }
                    }
                    .buttonStyle(PrimaryCTAButtonStyle())
                    .alert("Switch Explorer?", isPresented: $showSignOutAlert) {
                        Button("Keep Exploring", role: .cancel) {}
                        Button("Leave for Now", role: .destructive) {
                            signOutCurrentKid()
                        }
                    } message: {
                        Text("Want to let another explorer play? We’ll start a fresh adventure and ask for their name and age.")
                    }
                }
                .screenContentPadding()
                .padding(.vertical, DSSpacing.md)
            }
            .screenBackground()
            .navigationDestination(for: Story.self) { story in
                StoryDetailView(story: story)
            }
        }
        .onAppear {
            appModel.expireGameUnlocks()
            if sparkPreviewStory == nil {
                refreshSparkPreview()
            }
        }
    }

    private func signOutCurrentKid() {
        kidName = ""
        kidAge = 5
        kidProfileComplete = false
        appModel.resetProgress()
    }

    private func randomStoryFromRandomCategory() -> Story? {
        let topics = Set(appModel.stories.map(\.topic))
        guard let topic = topics.randomElement() else { return nil }
        let storiesInTopic = appModel.stories.filter { $0.topic == topic }
        return storiesInTopic.randomElement()
    }

    private func refreshSparkPreview() {
        guard let randomStory = randomStoryFromRandomCategory() else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            sparkPreviewStory = randomStory
        }
    }

    private func openCurrentSparkStory() {
        if sparkPreviewStory == nil {
            refreshSparkPreview()
        }
        guard let story = sparkPreviewStory else { return }
        sparkPath.append(story)
    }
}

private struct StatPill: View {
    let title: String
    let value: String
    let color: Color
    let symbol: String?

    init(title: String, value: String, color: Color, symbol: String? = nil) {
        self.title = title
        self.value = value
        self.color = color
        self.symbol = symbol
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xs) {
                Text(title)
                    .font(DSTypography.statLabel())
                    .foregroundStyle(DSColor.textSecondary)

                Spacer(minLength: DSSpacing.xs)

                if let symbol {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.36), color.opacity(0.18)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: DSLayout.statPillIconBadgeSize, height: DSLayout.statPillIconBadgeSize)
                        Image(systemName: symbol)
                            .font(.system(size: DSLayout.statPillIconSize, weight: .black))
                            .foregroundStyle(DSColor.textPrimary)
                    }
                }
            }
            Text(value)
                .font(DSTypography.title())
                .foregroundStyle(DSColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: DSLayout.statPillMinHeight)
        .padding(DSSpacing.md)
        .background(color.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
    }
}

private extension GameID {
    var accentColor: Color {
        switch self {
        case .balloonPop: return DSColor.coral
        case .snakeTrail: return DSColor.mint
        case .blockStack: return DSColor.oceanBlue
        case .ticTacToe: return DSColor.lavender
        case .memoryMatch: return DSColor.yellow
        }
    }

    var coverGradient: LinearGradient {
        switch self {
        case .balloonPop:
            return LinearGradient(
                colors: [Color(hex: "FFB36A"), Color(hex: "FF845E"), Color(hex: "FFD37A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .snakeTrail:
            return LinearGradient(
                colors: [Color(hex: "7DE7B6"), Color(hex: "41B38D"), Color(hex: "A4E884")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blockStack:
            return LinearGradient(
                colors: [Color(hex: "6FC4FF"), Color(hex: "4D7FFF"), Color(hex: "89D3F8")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ticTacToe:
            return LinearGradient(
                colors: [Color(hex: "CEB6FF"), Color(hex: "9C84FF"), Color(hex: "BDA2F0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .memoryMatch:
            return LinearGradient(
                colors: [Color(hex: "FFE18B"), Color(hex: "FFC85F"), Color(hex: "FFECAA")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var coverAccentSymbol: String {
        switch self {
        case .balloonPop: return "sparkles"
        case .snakeTrail: return "leaf.fill"
        case .blockStack: return "square.2.layers.3d"
        case .ticTacToe: return "xmark"
        case .memoryMatch: return "brain.head.profile"
        }
    }

    var coverImageAssetName: String? {
        switch self {
        case .snakeTrail:
            return "GameCoverSnakeTrail"
        case .blockStack:
            return "GameCoverBlockStack"
        case .ticTacToe:
            return "GameCoverTicTacToe"
        case .memoryMatch:
            return "GameCoverMemoryMatch"
        default:
            return nil
        }
    }
}

struct PlayZoneView: View {
    @EnvironmentObject private var appModel: AppModel

    @State private var navigationPath = NavigationPath()
    @State private var now = Date()
    private let secondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Play Library")
                        .font(DSTypography.title())
                        .foregroundStyle(DSColor.textPrimary)

                    Text("Pass a quiz to earn a game pass. Unlock a game for 24 hours, then play.")
                        .font(DSTypography.body())
                        .foregroundStyle(DSColor.textSecondary)

                    HStack(spacing: DSSpacing.sm) {
                        playStatCard(
                            title: "Game Passes",
                            value: "\(appModel.gamePassBalance)",
                            subtitle: "Ready To Use",
                            symbol: "ticket.fill",
                            tint: DSColor.coral
                        )

                        playStatCard(
                            title: "Active Games",
                            value: "\(appModel.activeGameUnlockCount)",
                            subtitle: "Unlocked Now",
                            symbol: "lock.open.fill",
                            tint: DSColor.mint
                        )
                    }

                    HStack(spacing: DSSpacing.sm) {
                        playStatCard(
                            title: "Points",
                            value: "\(appModel.totalPoints)",
                            subtitle: "Spend To Unlock",
                            symbol: "star.fill",
                            tint: DSColor.yellow
                        )

                        playStatCard(
                            title: "Unlock Cost",
                            value: "\(appModel.pointsPerGameUnlock)",
                            subtitle: "Points / Game",
                            symbol: "bolt.fill",
                            tint: DSColor.oceanBlue
                        )
                    }

                    Text("Games")
                        .font(DSTypography.subtitle())
                        .foregroundStyle(DSColor.textPrimary)

                    VStack(spacing: DSSpacing.lg) {
                        ForEach(GameID.allCases) { game in
                            let isUnlocked = appModel.isGameUnlocked(game, now: now)
                            let expiry = appModel.unlockExpiry(for: game)

                        PlayGameCard(
                            game: game,
                            isUnlocked: isUnlocked,
                            remainingText: appModel.unlockAllGamesForTesting
                                ? "Testing Mode"
                                : remainingText(expiry: expiry, now: now),
                            canUnlockWithPass: appModel.gamePassBalance > 0,
                            canUnlockWithPoints: appModel.totalPoints >= appModel.pointsPerGameUnlock,
                            pointsCost: appModel.pointsPerGameUnlock,
                                onPlay: {
                                    navigationPath.append(game)
                                },
                                onUnlockWithPass: {
                                    _ = appModel.unlockGame(game, source: .pass, now: now)
                                },
                                onUnlockWithPoints: {
                                    _ = appModel.unlockGame(game, source: .points, now: now)
                                }
                            )
                        }
                    }
                }
                .screenContentPadding()
                .padding(.vertical, DSSpacing.md)
            }
            .screenBackground()
            .navigationDestination(for: GameID.self) { game in
                gameDestination(for: game)
            }
            .onAppear {
                appModel.expireGameUnlocks(referenceDate: now)
            }
            .onReceive(secondTimer) { date in
                now = date
                appModel.expireGameUnlocks(referenceDate: date)
            }
        }
    }

    @ViewBuilder
    private func gameDestination(for game: GameID) -> some View {
        switch game {
        case .balloonPop:
            BalloonPopGameView()
                .navigationTitle(game.title)
                .navigationBarTitleDisplayMode(.inline)
        case .snakeTrail:
            SnakeTrailGameView()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
        case .blockStack:
            BlockStackGameView()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
        case .ticTacToe:
            TicTacToeGameView()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
        case .memoryMatch:
            MemoryMatchGameView()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func playStatCard(
        title: String,
        value: String,
        subtitle: String,
        symbol: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(DSTypography.tiny())
                    .foregroundStyle(DSColor.textSecondary)
            }

            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Text(subtitle)
                .font(DSTypography.tiny())
                .foregroundStyle(DSColor.textSecondary)
        }
        .padding(DSSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
    }

    private func remainingText(expiry: Date?, now: Date) -> String {
        guard let expiry else { return "Locked" }
        let remaining = expiry.timeIntervalSince(now)
        guard remaining > 0 else { return "Locked" }

        let totalSeconds = Int(remaining.rounded(.down))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return "\(hours)h \(minutes)m left"
    }
}

private struct PlayGameCard: View {
    let game: GameID
    let isUnlocked: Bool
    let remainingText: String
    let canUnlockWithPass: Bool
    let canUnlockWithPoints: Bool
    let pointsCost: Int
    let onPlay: () -> Void
    let onUnlockWithPass: () -> Void
    let onUnlockWithPoints: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            GameCoverPreview(game: game, isUnlocked: isUnlocked)
                .frame(height: 160)

            HStack(alignment: .top, spacing: DSSpacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(game.title)
                        .font(DSTypography.bodyBold())
                        .foregroundStyle(DSColor.textPrimary)
                    Text(game.subtitle)
                        .font(DSTypography.caption())
                        .foregroundStyle(DSColor.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Label(isUnlocked ? "Ready" : "Locked", systemImage: isUnlocked ? "lock.open.fill" : "lock.fill")
                    .font(DSTypography.tiny())
                    .foregroundStyle(isUnlocked ? Color(hex: "1E9F66") : DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 5)
                    .background((isUnlocked ? Color(hex: "1E9F66") : DSColor.textSecondary).opacity(isUnlocked ? 0.22 : 0.14))
                    .clipShape(Capsule())
            }

            if isUnlocked {
                HStack(spacing: DSSpacing.sm) {
                    Label(remainingText, systemImage: "clock.fill")
                        .font(DSTypography.captionBold())
                        .foregroundStyle(DSColor.textPrimary)

                    Spacer()

                    Button {
                        onPlay()
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "play.fill")
                            Text("Play")
                        }
                    }
                    .buttonStyle(SoftTonalCTAButtonStyle(color: game.accentColor))
                    .frame(width: 120)
                }
            } else {
                HStack(spacing: DSSpacing.sm) {
                    Button {
                        onUnlockWithPass()
                    } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            Image(systemName: "ticket.fill")
                            Text("Use Pass")
                        }
                    }
                    .buttonStyle(SoftTonalCTAButtonStyle(color: DSColor.coral))
                    .frame(maxWidth: .infinity)
                    .disabled(!canUnlockWithPass)
                    .opacity(canUnlockWithPass ? 1 : 0.5)

                    Button {
                        onUnlockWithPoints()
                    } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            Image(systemName: "star.fill")
                            Text("\(pointsCost) Pts")
                        }
                    }
                    .buttonStyle(SoftTonalCTAButtonStyle(color: DSColor.oceanBlue))
                    .frame(maxWidth: .infinity)
                    .disabled(!canUnlockWithPoints)
                    .opacity(canUnlockWithPoints ? 1 : 0.5)
                }
            }
        }
        .padding(.bottom, DSSpacing.sm)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 1)
        }
    }
}

private struct GameCoverPreview: View {
    let game: GameID
    let isUnlocked: Bool
    
    private var hasCustomCover: Bool {
        game.coverImageAssetName != nil
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let assetName = game.coverImageAssetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                        .fill(game.coverGradient)
                        .frame(width: geo.size.width, height: geo.size.height)
                }

                RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: hasCustomCover
                                ? [Color.white.opacity(0.02), Color.black.opacity(0.08)]
                                : [Color.white.opacity(0.06), Color.black.opacity(0.14)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geo.size.width, height: geo.size.height)

                if !hasCustomCover {
                    previewPattern

                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        HStack {
                            Image(systemName: game.coverAccentSymbol)
                                .font(.system(size: 14, weight: .bold))
                            Text("Mini Game")
                                .font(DSTypography.tiny())
                        }
                        .foregroundStyle(.white.opacity(0.92))

                        Spacer()

                        HStack(alignment: .bottom) {
                            Text(game.title)
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Spacer()

                            Image(systemName: game.icon)
                                .font(.system(size: 26, weight: .black))
                                .foregroundStyle(.white.opacity(0.92))
                        }
                    }
                    .padding(DSSpacing.md)
                }

                if !isUnlocked {
                    RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                        .fill(Color.black.opacity(0.2))
                        .frame(width: geo.size.width, height: geo.size.height)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(.white.opacity(0.92))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private var previewPattern: some View {
        GeometryReader { geo in
            switch game {
            case .balloonPop:
                ZStack {
                    ForEach(0..<8, id: \.self) { idx in
                        Circle()
                            .fill(
                                [Color.white.opacity(0.3), Color(hex: "FFDDAA").opacity(0.6), Color(hex: "FF9A7A").opacity(0.56)][idx % 3]
                            )
                            .frame(width: CGFloat(24 + (idx % 4) * 12), height: CGFloat(24 + (idx % 4) * 12))
                            .position(
                                x: geo.size.width * [0.15, 0.32, 0.5, 0.7, 0.85, 0.24, 0.62, 0.78][idx],
                                y: geo.size.height * [0.22, 0.46, 0.26, 0.58, 0.33, 0.7, 0.76, 0.18][idx]
                            )
                    }
                }
            case .snakeTrail:
                Path { path in
                    let unit = min(geo.size.width, geo.size.height) / 8
                    path.addRoundedRect(in: CGRect(x: unit * 1.4, y: unit * 4.5, width: unit * 4.8, height: unit), cornerSize: CGSize(width: unit / 2, height: unit / 2))
                    path.addRoundedRect(in: CGRect(x: unit * 6.0, y: unit * 3.3, width: unit, height: unit * 2.2), cornerSize: CGSize(width: unit / 2, height: unit / 2))
                    path.addRoundedRect(in: CGRect(x: unit * 4.8, y: unit * 3.3, width: unit * 1.2, height: unit), cornerSize: CGSize(width: unit / 2, height: unit / 2))
                }
                .fill(Color.white.opacity(0.34))
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 11, height: 11)
                    .position(x: geo.size.width * 0.78, y: geo.size.height * 0.52)
            case .blockStack:
                VStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 6) {
                            ForEach(0..<(4 - row), id: \.self) { col in
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.white.opacity(0.26 + Double((row + col) % 3) * 0.09))
                                    .frame(width: 32, height: 18)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .ticTacToe:
                ZStack {
                    Path { path in
                        let w = geo.size.width
                        let h = geo.size.height
                        path.move(to: CGPoint(x: w * 0.38, y: h * 0.24))
                        path.addLine(to: CGPoint(x: w * 0.38, y: h * 0.76))
                        path.move(to: CGPoint(x: w * 0.62, y: h * 0.24))
                        path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.76))
                        path.move(to: CGPoint(x: w * 0.24, y: h * 0.4))
                        path.addLine(to: CGPoint(x: w * 0.76, y: h * 0.4))
                        path.move(to: CGPoint(x: w * 0.24, y: h * 0.6))
                        path.addLine(to: CGPoint(x: w * 0.76, y: h * 0.6))
                    }
                    .stroke(Color.white.opacity(0.5), lineWidth: 4)

                    Text("X")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.88))
                        .position(x: geo.size.width * 0.32, y: geo.size.height * 0.32)

                    Text("O")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.88))
                        .position(x: geo.size.width * 0.68, y: geo.size.height * 0.68)
                }
            case .memoryMatch:
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white.opacity(idx % 2 == 0 ? 0.56 : 0.28))
                            .frame(width: 34, height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
}

private struct SnakeTrailGameView: View {
    private struct GridPoint: Hashable {
        let row: Int
        let col: Int
    }

    private enum Direction {
        case up, down, left, right

        var symbolName: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .left: return "arrow.left"
            case .right: return "arrow.right"
            }
        }
    }

    @State private var snake: [GridPoint] = [GridPoint(row: 6, col: 6), GridPoint(row: 6, col: 5), GridPoint(row: 6, col: 4)]
    @State private var direction: Direction = .right
    @State private var queuedDirection: Direction?
    @State private var food: GridPoint = GridPoint(row: 3, col: 3)
    @State private var score: Int = 0
    @State private var applesEaten: Int = 0
    @State private var isRunning: Bool = true
    @State private var isGameOver: Bool = false
    @State private var foodPulse: Bool = false
    @State private var lastStepDate: Date = .distantPast
    @AppStorage("snake_trail_best_score") private var bestScore: Int = 0

    private let rows = 12
    private let cols = 16
    private let boardHeight: CGFloat = 206
    private let tickTimer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            snakeHeader

            HStack(spacing: DSSpacing.xs) {
                PlayHudChip(
                    title: "Score",
                    value: "\(score)",
                    tint: DSColor.mint,
                    symbol: "star.fill",
                    valueFontSize: 17,
                    topPadding: 8,
                    bottomPadding: 4,
                    minHeight: 74
                )
                PlayHudChip(
                    title: "Best",
                    value: "\(bestScore)",
                    tint: DSColor.oceanBlue,
                    symbol: "trophy.fill",
                    valueFontSize: 17,
                    topPadding: 8,
                    bottomPadding: 4,
                    minHeight: 74
                )
                PlayHudChip(
                    title: "Length",
                    value: "\(snake.count)",
                    tint: DSColor.lavender,
                    symbol: "ruler.fill",
                    valueFontSize: 17,
                    topPadding: 8,
                    bottomPadding: 4,
                    minHeight: 74
                )
            }

            HStack(spacing: DSSpacing.xs) {
                Image(systemName: statusIcon)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(statusTint)
                Text(statusText)
                    .font(DSTypography.captionBold())
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Spacer(minLength: 8)
                Text("Apples \(applesEaten)")
                    .font(DSTypography.tiny())
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, 8)
            .background(DSColor.surface.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )

            snakeBoard
                .frame(maxWidth: .infinity)
                .frame(height: boardHeight)
                .padding(.bottom, 4)

            HStack(alignment: .center, spacing: DSSpacing.xs) {
                directionalControlButton(
                    for: .left,
                    width: 74,
                    height: 118
                )

                VStack(spacing: 5) {
                    actionControlButton(width: 172, height: 36)
                    directionalControlButton(for: .up, width: 172, height: 36)
                    directionalControlButton(for: .down, width: 172, height: 36)
                }

                directionalControlButton(
                    for: .right,
                    width: 74,
                    height: 118
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .screenContentPadding()
        .padding(.top, -30)
        .padding(.bottom, DSSpacing.sm)
        .screenBackground()
        .onAppear {
            PlayHaptics.prepare()
            foodPulse = true
            if !snake.contains(food) {
                placeFood()
            }
            lastStepDate = Date()
        }
        .onReceive(tickTimer) { _ in
            guard isRunning, !isGameOver else { return }
            let now = Date()
            guard now.timeIntervalSince(lastStepDate) >= snakeStepInterval else { return }
            lastStepDate = now
            tick()
        }
    }

    private var snakeHeader: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DSColor.mint.opacity(0.25), DSColor.oceanBlue.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 38, height: 38)
                .offset(x: 10, y: -10)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(DSColor.mint.opacity(0.22))
                            .frame(width: 26, height: 26)
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(DSColor.mint)
                    }

                    ZStack {
                        Circle()
                            .fill(DSColor.coral.opacity(0.2))
                            .frame(width: 22, height: 22)
                        Image(systemName: "apple.logo")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(DSColor.coral)
                    }
                }

                Text("Snake Trail")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSColor.textPrimary, DSColor.oceanBlue, DSColor.coral],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Collect apples, grow longer, and avoid the walls.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, DSSpacing.xs)
            .padding(.top, 4)
            .padding(.bottom, 0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 98)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(Color.white.opacity(0.34), lineWidth: 1)
        )
        .shadow(color: DSColor.lavender.opacity(0.14), radius: 6, x: 0, y: 3)
    }

    private var snakeBoard: some View {
        let segmentIndex = Dictionary(uniqueKeysWithValues: snake.enumerated().map { ($1, $0) })
        let dragGesture = DragGesture(minimumDistance: 12)
            .onEnded { value in
                let dx = value.translation.width
                let dy = value.translation.height
                guard abs(dx) > 8 || abs(dy) > 8 else { return }
                if abs(dx) > abs(dy) {
                    setDirection(dx > 0 ? .right : .left)
                } else {
                    setDirection(dy > 0 ? .down : .up)
                }
            }

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: cols), spacing: 3) {
            ForEach(0..<(rows * cols), id: \.self) { index in
                let row = index / cols
                let col = index % cols
                let point = GridPoint(row: row, col: col)
                snakeCell(for: point, segmentIndex: segmentIndex)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "E9F8ED"), Color(hex: "DDF1E5")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
        .gesture(dragGesture)
    }

    @ViewBuilder
    private func snakeCell(for point: GridPoint, segmentIndex: [GridPoint: Int]) -> some View {
        if point == food {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(0.28))
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FF8FA2"), DSColor.coral],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(4)
                    .scaleEffect(foodPulse ? 1 : 0.88)
                    .animation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true), value: foodPulse)

                Capsule(style: .continuous)
                    .fill(Color(hex: "5A7D3A"))
                    .frame(width: 5, height: 9)
                    .offset(x: 0, y: -8)

                Ellipse()
                    .fill(Color(hex: "85C76B"))
                    .frame(width: 8, height: 5)
                    .rotationEffect(.degrees(-25))
                    .offset(x: 5, y: -8)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.white.opacity(0.42), lineWidth: 1)
            )
        } else if let segment = segmentIndex[point] {
            if segment == 0 {
                snakeHeadCell
            } else {
                snakeBodyCell(segment: segment)
            }
        } else {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "F4FBF6"), Color(hex: "E5F5EA")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        }
    }

    private var snakeHeadCell: some View {
        let eyes = eyeOffsets(for: direction)
        let tongue = tongueOffset(for: direction)

        return ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "87E6B2"), Color(hex: "4BCB7F"), Color(hex: "2EA36A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.white.opacity(0.18))
                .padding(4)

            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: 6, height: 6)
                .offset(eyes.0)
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: 6, height: 6)
                .offset(eyes.1)

            Circle()
                .fill(DSColor.textPrimary)
                .frame(width: 2.2, height: 2.2)
                .offset(CGSize(width: eyes.0.width * 1.03, height: eyes.0.height * 1.03))
            Circle()
                .fill(DSColor.textPrimary)
                .frame(width: 2.2, height: 2.2)
                .offset(CGSize(width: eyes.1.width * 1.03, height: eyes.1.height * 1.03))

            Capsule(style: .continuous)
                .fill(DSColor.coral.opacity(isRunning ? 0.95 : 0.65))
                .frame(width: tongue.width, height: tongue.height)
                .offset(tongue.offset)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(Color.white.opacity(0.36), lineWidth: 1)
        )
    }

    private func snakeBodyCell(segment: Int) -> some View {
        let shade = min(Double(segment) * 0.03, 0.36)
        return RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "74D89F").opacity(0.95 - shade),
                        Color(hex: "43BA7A").opacity(0.9 - shade * 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 7, height: 7)
                    .offset(x: -3, y: -3)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.white.opacity(0.26), lineWidth: 1)
            )
    }

    private func eyeOffsets(for direction: Direction) -> (CGSize, CGSize) {
        switch direction {
        case .up:
            return (CGSize(width: -4.5, height: -5), CGSize(width: 4.5, height: -5))
        case .down:
            return (CGSize(width: -4.5, height: 5), CGSize(width: 4.5, height: 5))
        case .left:
            return (CGSize(width: -5, height: -4), CGSize(width: -5, height: 4))
        case .right:
            return (CGSize(width: 5, height: -4), CGSize(width: 5, height: 4))
        }
    }

    private func tongueOffset(for direction: Direction) -> (width: CGFloat, height: CGFloat, offset: CGSize) {
        switch direction {
        case .up:
            return (4, 10, CGSize(width: 0, height: -9))
        case .down:
            return (4, 10, CGSize(width: 0, height: 9))
        case .left:
            return (10, 4, CGSize(width: -9, height: 0))
        case .right:
            return (10, 4, CGSize(width: 9, height: 0))
        }
    }

    private func directionalControlButton(
        for controlDirection: Direction,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Button {
            setDirection(controlDirection)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [DSColor.oceanBlue.opacity(0.85), DSColor.lavender.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.56), lineWidth: 1)
                    )

                Image(systemName: controlDirection.symbolName)
                    .font(.system(size: height >= 100 ? 30 : 24, weight: .black))
                    .foregroundStyle(Color.white)
            }
            .opacity(activeDirection == controlDirection ? 1 : 0.9)
            .scaleEffect(activeDirection == controlDirection ? 1.015 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isGameOver)
        .opacity(isGameOver ? 0.45 : 1)
    }

    private func actionControlButton(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: centerButtonColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )

            Image(systemName: centerButtonSymbol)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(Color.white)
                .offset(x: centerButtonSymbol == "play.fill" ? 2 : 0)
        }
        .onTapGesture {
            handleCenterControlTap()
        }
        .onLongPressGesture(minimumDuration: 0.55) {
            resetGame()
        }
    }

    private var centerButtonSymbol: String {
        if isGameOver { return "arrow.clockwise" }
        return isRunning ? "pause.fill" : "play.fill"
    }

    private var centerButtonColors: [Color] {
        if isGameOver {
            return [DSColor.mint.opacity(0.92), DSColor.oceanBlue.opacity(0.82)]
        }
        return [DSColor.coral.opacity(0.94), DSColor.yellow.opacity(0.8)]
    }

    private var activeDirection: Direction {
        queuedDirection ?? direction
    }

    private var statusText: String {
        if isGameOver { return "Game over. Try a new route." }
        if isRunning { return "Stay on trail and grab apples" }
        return "Paused"
    }

    private var statusIcon: String {
        if isGameOver { return "xmark.octagon.fill" }
        if isRunning { return "bolt.fill" }
        return "pause.fill"
    }

    private var statusTint: Color {
        if isGameOver { return DSColor.coral }
        if isRunning { return DSColor.mint }
        return DSColor.lavender
    }

    private var snakeStepInterval: TimeInterval {
        let speedBoost = Double(min(score / 40, 10)) * 0.01
        return max(0.11, 0.23 - speedBoost)
    }

    private func handleCenterControlTap() {
        if isGameOver {
            resetGame()
        } else {
            togglePauseResume()
        }
    }

    private func setDirection(_ newDirection: Direction) {
        guard !isGameOver else { return }
        let referenceDirection = queuedDirection ?? direction
        if !isOpposite(referenceDirection, newDirection) {
            queuedDirection = newDirection
            PlayHaptics.tap()
        }
    }

    private func isOpposite(_ lhs: Direction, _ rhs: Direction) -> Bool {
        switch (lhs, rhs) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            return true
        default:
            return false
        }
    }

    private func togglePauseResume() {
        guard !isGameOver else { return }
        isRunning.toggle()
        lastStepDate = Date()
        PlayHaptics.pauseResume()
    }

    private func nextHead(from currentHead: GridPoint, using direction: Direction) -> GridPoint {
        switch direction {
        case .up:
            return GridPoint(row: currentHead.row - 1, col: currentHead.col)
        case .down:
            return GridPoint(row: currentHead.row + 1, col: currentHead.col)
        case .left:
            return GridPoint(row: currentHead.row, col: currentHead.col - 1)
        case .right:
            return GridPoint(row: currentHead.row, col: currentHead.col + 1)
        }
    }

    private func tick() {
        if let nextDirection = queuedDirection, !isOpposite(direction, nextDirection) {
            direction = nextDirection
        }
        queuedDirection = nil

        guard let head = snake.first else { return }
        let nextHead = nextHead(from: head, using: direction)
        let willGrow = nextHead == food

        let outOfBounds = nextHead.row < 0 || nextHead.row >= rows || nextHead.col < 0 || nextHead.col >= cols
        let occupied = willGrow ? snake : Array(snake.dropLast())

        if outOfBounds || occupied.contains(nextHead) {
            isGameOver = true
            isRunning = false
            bestScore = max(bestScore, score)
            PlayHaptics.miss()
            return
        }

        snake.insert(nextHead, at: 0)
        if willGrow {
            score += 10
            applesEaten += 1
            bestScore = max(bestScore, score)
            PlayHaptics.correct()
            placeFood()
        } else {
            _ = snake.popLast()
        }
    }

    private func placeFood() {
        var candidate = GridPoint(row: Int.random(in: 0..<rows), col: Int.random(in: 0..<cols))
        while snake.contains(candidate) {
            candidate = GridPoint(row: Int.random(in: 0..<rows), col: Int.random(in: 0..<cols))
        }
        food = candidate
    }

    private func resetGame() {
        snake = [GridPoint(row: 6, col: 6), GridPoint(row: 6, col: 5), GridPoint(row: 6, col: 4)]
        direction = .right
        queuedDirection = nil
        score = 0
        applesEaten = 0
        isRunning = true
        isGameOver = false
        lastStepDate = Date()
        placeFood()
        PlayHaptics.pauseResume()
    }
}

private struct BlockStackGameView: View {
    private let columns = 6
    private let maxHeight = 10
    private let bottomBarClearance: CGFloat = 52
    private let lanePalette: [Color] = [
        DSColor.oceanBlue,
        DSColor.mint,
        DSColor.lavender,
        DSColor.yellow,
        DSColor.coral,
        Color(hex: "7AA8FF")
    ]

    @State private var heights: [Int] = Array(repeating: 0, count: 6)
    @State private var activeColumn: Int = 0
    @State private var movingRight: Bool = true
    @State private var score: Int = 0
    @State private var clearedRows: Int = 0
    @State private var isGameOver: Bool = false
    @State private var isRunning: Bool = true
    @State private var isClearingRow: Bool = false
    @State private var clearSparkleProgress: CGFloat = 0
    @State private var clearCycleID: Int = 0
    @AppStorage("block_stack_best_score") private var bestScore: Int = 0

    private let moveTimer = Timer.publish(every: 0.42, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            blockHeader

            HStack(spacing: DSSpacing.sm) {
                PlayHudChip(
                    title: "Score",
                    value: "\(score)",
                    tint: DSColor.oceanBlue,
                    symbol: "star.fill"
                )
                PlayHudChip(
                    title: "Best",
                    value: "\(bestScore)",
                    tint: DSColor.lavender,
                    symbol: "trophy.fill"
                )
                PlayHudChip(
                    title: "Clears",
                    value: "\(clearedRows)",
                    tint: DSColor.mint,
                    symbol: "square.stack.3d.up.fill"
                )
            }

            HStack(spacing: DSSpacing.xs) {
                Image(systemName: statusIcon)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(statusTint)

                Text(statusText)
                    .font(DSTypography.captionBold())
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 8)

                Text("Lane \(activeColumn + 1)/\(columns)")
                    .font(DSTypography.tiny())
                    .foregroundStyle(DSColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, 8)
            .background(DSColor.surface.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )

            blockBoard
        }
        .screenContentPadding()
        .padding(.top, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: DSSpacing.xs) {
                HStack(spacing: DSSpacing.sm) {
                    Button(isRunning ? "Pause" : "Resume") {
                        if !isGameOver {
                            isRunning.toggle()
                            PlayHaptics.pauseResume()
                        }
                    }
                    .buttonStyle(SoftTonalCTAButtonStyle(color: DSColor.lavender))
                    .disabled(isGameOver || isClearingRow)

                    Button("Restart") {
                        restart()
                    }
                    .buttonStyle(SoftTonalCTAButtonStyle(color: DSColor.mint))
                }

                Button("Drop") {
                    dropBlock()
                }
                .buttonStyle(PrimaryCTAButtonStyle(font: DSTypography.captionBold()))
                .disabled(isGameOver || !isRunning || isClearingRow)
            }
            .padding(.horizontal, DSLayout.horizontalMargin)
            .padding(.top, DSSpacing.xxs)
            .padding(.bottom, bottomBarClearance)
        }
        .screenBackground()
        .onAppear {
            PlayHaptics.prepare()
        }
        .onReceive(moveTimer) { _ in
            guard isRunning, !isGameOver else { return }
            moveActiveColumn()
        }
    }

    private var blockHeader: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DSColor.oceanBlue.opacity(0.22), DSColor.lavender.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 50, height: 50)
                .offset(x: 10, y: -10)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack(spacing: DSSpacing.xs) {
                    ZStack {
                        Circle()
                            .fill(DSColor.oceanBlue.opacity(0.2))
                            .frame(width: 34, height: 34)
                        Image(systemName: "square.2.layers.3d")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(DSColor.oceanBlue)
                    }

                    ZStack {
                        Circle()
                            .fill(DSColor.coral.opacity(0.2))
                            .frame(width: 28, height: 28)
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(DSColor.coral)
                    }
                }

                Text("Block Stack")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSColor.textPrimary, DSColor.oceanBlue, DSColor.coral],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Drop blocks, clear rows, and keep every lane under control.")
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(DSSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: DSColor.lavender.opacity(0.14), radius: 6, x: 0, y: 3)
    }

    private var blockBoard: some View {
        VStack(spacing: DSSpacing.xs) {
            HStack(spacing: 6) {
                ForEach(0..<columns, id: \.self) { idx in
                    Capsule(style: .continuous)
                        .fill(
                            idx == activeColumn
                                ? lanePalette[idx % lanePalette.count].opacity(0.95)
                                : Color.black.opacity(0.14)
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: idx == activeColumn ? 15 : 9)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(
                                    idx == activeColumn
                                        ? Color.white.opacity(0.65)
                                        : Color.white.opacity(0.18),
                                    lineWidth: 1
                                )
                        )
                }
            }

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<columns, id: \.self) { column in
                    VStack(spacing: 3) {
                        ForEach((0..<maxHeight).reversed(), id: \.self) { level in
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(blockFill(for: column, level: level))
                                .frame(height: 13)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .stroke(Color.white.opacity(level < heights[column] ? 0.28 : 0.12), lineWidth: 1)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 2)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadii.sm, style: .continuous)
                            .fill(column == activeColumn ? lanePalette[column % lanePalette.count].opacity(0.16) : Color.black.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadii.sm, style: .continuous)
                            .stroke(
                                column == activeColumn
                                    ? lanePalette[column % lanePalette.count].opacity(0.5)
                                    : Color.black.opacity(0.1),
                                lineWidth: 1
                            )
                    )
                }
            }
        }
        .padding(DSSpacing.sm)
        .background(DSColor.surface.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
        .overlay {
            if isClearingRow {
                GeometryReader { geo in
                    ZStack {
                        ForEach(0..<12, id: \.self) { idx in
                            Image(systemName: sparkleSymbol(for: idx))
                                .font(.system(size: sparkleSize(for: idx), weight: .black))
                                .foregroundStyle(sparkleColor(for: idx))
                                .position(
                                    x: geo.size.width * sparkleBaseX(for: idx) + sparkleDriftX(for: idx) * clearSparkleProgress,
                                    y: geo.size.height - 18 - sparkleLift(for: idx) * clearSparkleProgress
                                )
                                .opacity(max(0, 1 - Double(clearSparkleProgress)))
                                .scaleEffect(0.72 + (0.5 * clearSparkleProgress))
                        }

                        VStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(DSColor.yellow)
                            Text("Row Clear!")
                                .font(DSTypography.captionBold())
                                .foregroundStyle(DSColor.textPrimary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.78))
                        .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                                .stroke(DSColor.yellow.opacity(0.7), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                    }
                    .clipped()
                    .allowsHitTesting(false)
                }
            }
        }
    }

    private var statusText: String {
        if isClearingRow {
            return "Nice! Clearing a full row..."
        }
        if isGameOver {
            return "Game over at stack \(highestStack)/\(maxHeight)"
        }
        if isRunning {
            return "Tap Drop at the right lane to keep stacks balanced"
        }
        return "Paused"
    }

    private var statusIcon: String {
        if isClearingRow { return "sparkles" }
        if isGameOver { return "xmark.octagon.fill" }
        if isRunning { return "arrow.left.and.right.circle.fill" }
        return "pause.circle.fill"
    }

    private var statusTint: Color {
        if isClearingRow { return DSColor.yellow }
        if isGameOver { return DSColor.coral }
        if isRunning { return DSColor.oceanBlue }
        return DSColor.lavender
    }

    private var highestStack: Int {
        heights.max() ?? 0
    }

    private func blockFill(for column: Int, level: Int) -> Color {
        guard level < heights[column] else {
            return DSColor.surface.opacity(0.55)
        }
        if isClearingRow, level == 0 {
            return DSColor.yellow.opacity(0.95)
        }
        let tint = lanePalette[column % lanePalette.count]
        let alpha = 0.9 - (Double(level) * 0.04)
        return tint.opacity(max(0.5, alpha))
    }

    private func sparkleSymbol(for index: Int) -> String {
        switch index % 3 {
        case 0: return "sparkles"
        case 1: return "star.fill"
        default: return "circle.fill"
        }
    }

    private func sparkleColor(for index: Int) -> Color {
        switch index % 4 {
        case 0: return DSColor.yellow
        case 1: return DSColor.coral
        case 2: return DSColor.mint
        default: return DSColor.oceanBlue
        }
    }

    private func sparkleSize(for index: Int) -> CGFloat {
        [10, 12, 9, 13, 11, 9, 12, 10, 13, 11, 9, 12][index]
    }

    private func sparkleBaseX(for index: Int) -> CGFloat {
        [0.08, 0.16, 0.24, 0.32, 0.4, 0.48, 0.56, 0.64, 0.72, 0.8, 0.88, 0.94][index]
    }

    private func sparkleLift(for index: Int) -> CGFloat {
        [56, 72, 64, 84, 66, 74, 62, 78, 68, 82, 60, 76][index]
    }

    private func sparkleDriftX(for index: Int) -> CGFloat {
        [-18, -10, -6, -2, 2, 8, 14, 18, 10, 4, -12, -4][index]
    }

    private func moveActiveColumn() {
        if movingRight {
            activeColumn += 1
            if activeColumn >= columns - 1 {
                activeColumn = columns - 1
                movingRight = false
            }
        } else {
            activeColumn -= 1
            if activeColumn <= 0 {
                activeColumn = 0
                movingRight = true
            }
        }
    }

    private func dropBlock() {
        guard !isGameOver else { return }
        if heights[activeColumn] >= maxHeight {
            finishGame()
            return
        }

        heights[activeColumn] += 1
        score += 5
        bestScore = max(bestScore, score)
        PlayHaptics.tap()

        if heights.allSatisfy({ $0 > 0 }) {
            triggerRowClear()
            return
        }

        if heights.contains(where: { $0 >= maxHeight }) {
            finishGame()
        }
    }

    private func finishGame() {
        isGameOver = true
        isRunning = false
        bestScore = max(bestScore, score)
        PlayHaptics.miss()
    }

    private func triggerRowClear() {
        isClearingRow = true
        isRunning = false
        clearSparkleProgress = 0
        clearCycleID += 1
        let cycle = clearCycleID
        PlayHaptics.correct()

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.45)) {
                clearSparkleProgress = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard cycle == clearCycleID else { return }
            withAnimation(.easeInOut(duration: 0.24)) {
                heights = heights.map { max(0, $0 - 1) }
            }
            score += 25
            clearedRows += 1
            bestScore = max(bestScore, score)
            isClearingRow = false
            clearSparkleProgress = 0

            if heights.contains(where: { $0 >= maxHeight }) {
                finishGame()
            } else {
                isRunning = true
            }
        }
    }

    private func restart() {
        clearCycleID += 1
        heights = Array(repeating: 0, count: columns)
        activeColumn = 0
        movingRight = true
        score = 0
        clearedRows = 0
        isGameOver = false
        isClearingRow = false
        clearSparkleProgress = 0
        isRunning = true
        PlayHaptics.pauseResume()
    }
}

private struct TicTacToeGameView: View {
    private enum AIDifficulty: String, CaseIterable, Identifiable {
        case easy
        case medium
        case hard

        var id: String { rawValue }

        var title: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            }
        }

        var symbol: String {
            switch self {
            case .easy: return "leaf.fill"
            case .medium: return "bolt.fill"
            case .hard: return "flame.fill"
            }
        }

        var tint: Color {
            switch self {
            case .easy: return DSColor.mint
            case .medium: return DSColor.oceanBlue
            case .hard: return DSColor.coral
            }
        }
    }

    @State private var board: [Int] = Array(repeating: 0, count: 9)
    @State private var isHumanTurn: Bool = true
    @State private var statusText: String = "Your turn"
    @State private var difficulty: AIDifficulty = .medium
    @State private var winningLine: [Int] = []
    @State private var playerWins: Int = 0
    @State private var botWins: Int = 0
    @State private var draws: Int = 0
    private let bottomBarClearance: CGFloat = 52

    private let winningLines: [[Int]] = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
    ]

    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            ticTacHeader

            HStack(spacing: DSSpacing.xs) {
                ticTacStatChip(
                    title: "You",
                    value: "\(playerWins)",
                    tint: DSColor.mint,
                    symbol: "person.fill"
                )
                ticTacStatChip(
                    title: "Bot",
                    value: "\(botWins)",
                    tint: DSColor.coral,
                    symbol: "cpu"
                )
                ticTacStatChip(
                    title: "Draws",
                    value: "\(draws)",
                    tint: DSColor.lavender,
                    symbol: "equal.circle.fill"
                )
            }

            difficultySelector

            HStack(spacing: DSSpacing.xs) {
                Image(systemName: isHumanTurn ? "person.fill.checkmark" : "hourglass")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(isHumanTurn ? DSColor.mint : DSColor.oceanBlue)
                Text(statusText)
                    .font(DSTypography.captionBold())
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, 8)
            .background(DSColor.surface.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                ForEach(0..<9, id: \.self) { idx in
                    Button {
                        tapCell(idx)
                    } label: {
                        RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                            .fill(cellBackground(for: idx))
                            .overlay {
                                Group {
                                    if board[idx] == 0 {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 20, weight: .black))
                                            .foregroundStyle(DSColor.textSecondary.opacity(0.4))
                                    } else {
                                        Image(systemName: board[idx] == 1 ? "xmark" : "circle")
                                            .font(.system(size: 38, weight: .black, design: .rounded))
                                            .foregroundStyle(board[idx] == 1 ? DSColor.coral : DSColor.oceanBlue)
                                    }
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(height: 84)
                    .disabled(board[idx] != 0 || winner() != nil || !isHumanTurn)
                }
            }
        }
        .screenContentPadding()
        .padding(.top, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .safeAreaInset(edge: .bottom) {
            Button("Restart") {
                reset()
            }
            .buttonStyle(PrimaryCTAButtonStyle(font: DSTypography.captionBold()))
            .padding(.horizontal, DSLayout.horizontalMargin)
            .padding(.top, DSSpacing.xxs)
            .padding(.bottom, bottomBarClearance)
        }
        .screenBackground()
    }

    private func ticTacStatChip(title: String, value: String, tint: Color, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.33))
                        .frame(width: 30, height: 30)
                    Circle()
                        .stroke(tint.opacity(0.38), lineWidth: 1)
                        .frame(width: 30, height: 30)
                    Image(systemName: symbol)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(DSColor.textPrimary)
                }

                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(DSColor.textPrimary.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .minimumScaleFactor(0.35)
                .lineLimit(1)
                .foregroundStyle(DSColor.textPrimary)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 58, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.34), tint.opacity(0.14)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 30, height: 30)
                        .offset(x: 9, y: -8)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                        .stroke(Color.white.opacity(0.26), lineWidth: 1)
                )
        }
    }

    private var difficultySelector: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: 5) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(DSColor.textSecondary)
                Text("Difficulty")
                    .font(DSTypography.tiny())
                    .foregroundStyle(DSColor.textSecondary)
            }

            HStack(spacing: DSSpacing.xs) {
                ForEach(AIDifficulty.allCases) { level in
                    Button {
                        setDifficulty(level)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: level.symbol)
                                .font(.system(size: 11, weight: .black))
                            Text(level.title)
                                .font(DSTypography.tiny())
                                .lineLimit(1)
                        }
                        .foregroundStyle(difficulty == level ? DSColor.textPrimary : DSColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                                .fill(
                                    difficulty == level
                                        ? level.tint.opacity(0.28)
                                        : DSColor.surface.opacity(0.8)
                                )
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                                .stroke(
                                    difficulty == level
                                        ? level.tint.opacity(0.55)
                                        : Color.black.opacity(0.09),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var ticTacHeader: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DSColor.lavender.opacity(0.25), DSColor.oceanBlue.opacity(0.17)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 46, height: 46)
                .offset(x: 10, y: -10)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack(spacing: DSSpacing.xs) {
                    ZStack {
                        Circle()
                            .fill(DSColor.lavender.opacity(0.28))
                            .frame(width: 32, height: 32)
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(DSColor.coral)
                    }

                    ZStack {
                        Circle()
                            .fill(DSColor.oceanBlue.opacity(0.2))
                            .frame(width: 28, height: 28)
                        Image(systemName: "circle")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(DSColor.oceanBlue)
                    }
                }

                Text("Tic-Tac-Toe")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSColor.textPrimary, DSColor.oceanBlue, DSColor.coral],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Read the board, choose a level, and beat the bot.")
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(DSSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(Color.white.opacity(0.32), lineWidth: 1)
        )
        .shadow(color: DSColor.lavender.opacity(0.14), radius: 6, x: 0, y: 3)
    }

    private func tapCell(_ index: Int) {
        guard board[index] == 0, isHumanTurn, winner() == nil else { return }
        board[index] = 1
        if finishRoundIfNeeded() {
            return
        }

        isHumanTurn = false
        statusText = "Bot thinking..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            botMove()
        }
    }

    private func botMove() {
        guard let move = chooseBotMove() else {
            if !finishRoundIfNeeded() {
                statusText = "It's a draw"
                draws += 1
                isHumanTurn = false
            }
            return
        }
        board[move] = -1

        if finishRoundIfNeeded() {
            return
        }
        isHumanTurn = true
        statusText = "Your turn"
    }

    private func finishRoundIfNeeded() -> Bool {
        if let result = winnerResult(on: board) {
            winningLine = result.line
            if result.winner == 1 {
                playerWins += 1
                statusText = "You win!"
                PlayHaptics.roundComplete()
            } else {
                botWins += 1
                statusText = "Bot wins!"
                PlayHaptics.miss()
            }
            isHumanTurn = false
            return true
        }

        if !board.contains(0) {
            statusText = "It's a draw"
            draws += 1
            isHumanTurn = false
            winningLine = []
            PlayHaptics.pauseResume()
            return true
        }

        winningLine = []
        return false
    }

    private func setDifficulty(_ level: AIDifficulty) {
        guard difficulty != level else { return }
        difficulty = level
        reset()
    }

    private func chooseBotMove() -> Int? {
        switch difficulty {
        case .easy:
            return easyBotMove()
        case .medium:
            return mediumBotMove()
        case .hard:
            return hardBotMove()
        }
    }

    private func easyBotMove() -> Int? {
        let empty = board.indices.filter { board[$0] == 0 }
        guard !empty.isEmpty else { return nil }

        if Int.random(in: 0..<100) < 18, let winNow = immediateWinningMove(for: -1, on: board) {
            return winNow
        }
        if Int.random(in: 0..<100) < 22, let block = immediateWinningMove(for: 1, on: board) {
            return block
        }
        return empty.randomElement()
    }

    private func mediumBotMove() -> Int? {
        let empty = board.indices.filter { board[$0] == 0 }
        guard !empty.isEmpty else { return nil }

        if let winNow = immediateWinningMove(for: -1, on: board) {
            return winNow
        }
        if let blockNow = immediateWinningMove(for: 1, on: board) {
            return blockNow
        }
        if let fork = forkMove(for: -1, on: board) {
            return fork
        }

        let humanForkThreats = empty.filter { idx in
            var trial = board
            trial[idx] = 1
            return countImmediateWinningMoves(for: 1, on: trial) >= 2
        }
        if let blockFork = humanForkThreats.first {
            return blockFork
        }

        if board[4] == 0 {
            return 4
        }
        if let oppositeCorner = oppositeCornerMove(on: board) {
            return oppositeCorner
        }
        if let corner = preferredCornerMove(on: board) {
            return corner
        }
        if let side = preferredSideMove(on: board) {
            return side
        }

        return empty.randomElement()
    }

    private func hardBotMove() -> Int? {
        let emptyIndices = board.indices.filter { board[$0] == 0 }
        guard !emptyIndices.isEmpty else { return nil }

        var bestScore = Int.min
        var bestMoves: [Int] = []

        for move in emptyIndices {
            var trial = board
            trial[move] = -1
            let score = minimax(board: trial, isBotTurn: false, depth: 1, alpha: Int.min, beta: Int.max)
            if score > bestScore {
                bestScore = score
                bestMoves = [move]
            } else if score == bestScore {
                bestMoves.append(move)
            }
        }

        let priorityOrder = [4, 0, 2, 6, 8, 1, 3, 5, 7]
        for move in priorityOrder where bestMoves.contains(move) {
            return move
        }
        return bestMoves.randomElement()
    }

    private func immediateWinningMove(for player: Int, on board: [Int]) -> Int? {
        for idx in board.indices where board[idx] == 0 {
            var trial = board
            trial[idx] = player
            if winnerResult(on: trial)?.winner == player {
                return idx
            }
        }
        return nil
    }

    private func forkMove(for player: Int, on board: [Int]) -> Int? {
        for idx in board.indices where board[idx] == 0 {
            var trial = board
            trial[idx] = player
            if countImmediateWinningMoves(for: player, on: trial) >= 2 {
                return idx
            }
        }
        return nil
    }

    private func countImmediateWinningMoves(for player: Int, on board: [Int]) -> Int {
        var count = 0
        for idx in board.indices where board[idx] == 0 {
            var trial = board
            trial[idx] = player
            if winnerResult(on: trial)?.winner == player {
                count += 1
            }
        }
        return count
    }

    private func oppositeCornerMove(on board: [Int]) -> Int? {
        let oppositeMap = [0: 8, 2: 6, 6: 2, 8: 0]
        for (corner, opposite) in oppositeMap where board[corner] == 1 && board[opposite] == 0 {
            return opposite
        }
        return nil
    }

    private func preferredCornerMove(on board: [Int]) -> Int? {
        let corners = [0, 2, 6, 8]
        return corners.first(where: { board[$0] == 0 })
    }

    private func preferredSideMove(on board: [Int]) -> Int? {
        let sides = [1, 3, 5, 7]
        return sides.first(where: { board[$0] == 0 })
    }

    private func minimax(board: [Int], isBotTurn: Bool, depth: Int, alpha: Int, beta: Int) -> Int {
        if let result = winnerResult(on: board) {
            if result.winner == -1 {
                return 10 - depth
            }
            return depth - 10
        }
        if !board.contains(0) {
            return 0
        }

        var alpha = alpha
        var beta = beta

        if isBotTurn {
            var bestScore = Int.min
            for idx in board.indices where board[idx] == 0 {
                var next = board
                next[idx] = -1
                let score = minimax(board: next, isBotTurn: false, depth: depth + 1, alpha: alpha, beta: beta)
                bestScore = max(bestScore, score)
                alpha = max(alpha, bestScore)
                if beta <= alpha { break }
            }
            return bestScore
        } else {
            var bestScore = Int.max
            for idx in board.indices where board[idx] == 0 {
                var next = board
                next[idx] = 1
                let score = minimax(board: next, isBotTurn: true, depth: depth + 1, alpha: alpha, beta: beta)
                bestScore = min(bestScore, score)
                beta = min(beta, bestScore)
                if beta <= alpha { break }
            }
            return bestScore
        }
    }

    private func cellBackground(for index: Int) -> Color {
        if winningLine.contains(index) {
            return DSColor.yellow.opacity(0.3)
        }
        if board[index] == 0 {
            return DSColor.lavender.opacity(0.72)
        }
        return DSColor.surface
    }

    private func winnerResult(on board: [Int]) -> (winner: Int, line: [Int])? {
        for line in winningLines {
            let sum = line.reduce(0) { $0 + board[$1] }
            if sum == 3 { return (1, line) }
            if sum == -3 { return (-1, line) }
        }
        return nil
    }

    private func winner() -> Int? {
        winnerResult(on: board)?.winner
    }

    private func reset() {
        board = Array(repeating: 0, count: 9)
        isHumanTurn = true
        statusText = "Your turn"
        winningLine = []
    }
}

private struct MemoryMatchGameView: View {
    private struct MemoryCard: Identifiable {
        let id: Int
        let imageName: String
    }

    @State private var cards: [MemoryCard] = []
    @State private var revealed: Set<Int> = []
    @State private var matched: Set<Int> = []
    @State private var firstSelection: Int?
    @State private var lockBoard: Bool = false
    @State private var turns: Int = 0

    private let pairCount = 8
    private let imagePool: [String] = (1...36).map { index in
        String(format: "MemoryCard%02d", index)
    }

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            memoryHeader

            HStack(spacing: DSSpacing.sm) {
                PlayHudChip(
                    title: "Matches",
                    value: "\(matched.count / 2)/\(pairCount)",
                    tint: DSColor.mint,
                    symbol: "checkmark.circle.fill"
                )
                PlayHudChip(
                    title: "Turns",
                    value: "\(turns)",
                    tint: DSColor.lavender,
                    symbol: "arrow.triangle.2.circlepath"
                )
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                ForEach(cards) { card in
                    Button {
                        tap(cardID: card.id)
                    } label: {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(cardFaceColor(cardID: card.id))
                            .overlay {
                                if revealed.contains(card.id) || matched.contains(card.id) {
                                    Image(card.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(6)
                                } else {
                                    Image(systemName: "photo.stack.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(Color.white.opacity(0.9))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .frame(height: 74)
                    .allowsHitTesting(!lockBoard)
                }
            }

            if matched.count == cards.count && !cards.isEmpty {
                Text("Great memory! You matched all cards.")
                    .font(DSTypography.captionBold())
                    .foregroundStyle(DSColor.mint)
            }

            Button("Restart") {
                setupCards()
            }
            .buttonStyle(PrimaryCTAButtonStyle(font: DSTypography.captionBold()))
        }
        .screenContentPadding()
        .padding(.vertical, DSSpacing.sm)
        .screenBackground()
        .onAppear {
            if cards.isEmpty {
                setupCards()
            }
        }
    }

    private var memoryHeader: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DSColor.lavender.opacity(0.24), DSColor.mint.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 52, height: 52)
                .offset(x: 10, y: -10)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack(spacing: DSSpacing.xs) {
                    ZStack {
                        Circle()
                            .fill(DSColor.coral.opacity(0.2))
                            .frame(width: 34, height: 34)
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(DSColor.coral)
                    }

                    ZStack {
                        Circle()
                            .fill(DSColor.oceanBlue.opacity(0.16))
                            .frame(width: 28, height: 28)
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(DSColor.oceanBlue)
                    }
                }

                Text("Memory Match")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSColor.textPrimary, DSColor.oceanBlue, DSColor.coral],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Find the same picture pairs and boost your memory power.")
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(DSSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: DSColor.lavender.opacity(0.14), radius: 6, x: 0, y: 3)
    }

    private func cardFaceColor(cardID: Int) -> Color {
        if matched.contains(cardID) {
            return DSColor.yellow.opacity(0.26)
        }
        if revealed.contains(cardID) {
            return DSColor.yellow.opacity(0.26)
        }
        return DSColor.lavender.opacity(0.9)
    }

    private func setupCards() {
        let selected = Array(imagePool.shuffled().prefix(pairCount))
        let doubled = (selected + selected).shuffled()
        cards = doubled.enumerated().map { index, imageName in
            MemoryCard(id: index, imageName: imageName)
        }
        revealed = []
        matched = []
        firstSelection = nil
        lockBoard = false
        turns = 0
    }

    private func tap(cardID: Int) {
        guard !revealed.contains(cardID), !matched.contains(cardID), !lockBoard else { return }
        revealed.insert(cardID)

        guard let first = firstSelection else {
            firstSelection = cardID
            return
        }

        turns += 1
        let firstCard = cards.first(where: { $0.id == first })
        let secondCard = cards.first(where: { $0.id == cardID })
        if firstCard?.imageName == secondCard?.imageName {
            matched.insert(first)
            matched.insert(cardID)
            firstSelection = nil
        } else {
            lockBoard = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                revealed.remove(first)
                revealed.remove(cardID)
                firstSelection = nil
                lockBoard = false
            }
        }
    }
}
