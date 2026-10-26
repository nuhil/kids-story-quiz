import SwiftUI

struct TopicArtworkView: View {
    let topic: Topic
    let seed: Int
    var storyTitle: String? = nil
    var storyID: String? = nil
    var pageNumber: Int? = nil
    var cornerRadius: CGFloat = DSRadii.md

    var body: some View {
        if let storyID, let pageNumber {
            if let pageImage = storyPageImage(for: storyID, pageNumber: pageNumber) {
                renderedImage(pageImage)
            } else {
                generatedArtwork
            }
        } else if let storyTitle, let coverImage = storyCoverImage(for: storyTitle, topic: topic) {
            renderedImage(coverImage)
        } else {
            generatedArtwork
        }
    }

    private func renderedImage(_ image: UIImage) -> some View {
        GeometryReader { _ in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var generatedArtwork: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DSColor.gradient(for: topic))

                switch topic {
                case .ocean:
                    oceanShapes(in: geo.size)
                case .animals:
                    animalShapes(in: geo.size)
                case .space:
                    spaceShapes(in: geo.size)
                case .science:
                    scienceShapes(in: geo.size)
                case .math:
                    mathShapes(in: geo.size)
                case .culture:
                    cultureShapes(in: geo.size)
                case .emotionsSocial:
                    emotionsShapes(in: geo.size)
                case .history:
                    historyShapes(in: geo.size)
                case .geography:
                    geographyShapes(in: geo.size)
                case .technologyMachines:
                    technologyShapes(in: geo.size)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private func storyCoverImage(for title: String, topic: Topic) -> UIImage? {
        let normalized = title
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "‑", with: "-")
            .replacingOccurrences(of: "–", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch (topic, normalized) {
        case (.ocean, "whaley the giant of the sea"):
            return UIImage(named: "StoryCoverOcean01")
        case (.ocean, "ollie the octopus with eight arms"):
            return UIImage(named: "StoryCoverOcean02")
        case (.ocean, "daisy the dolphin who uses echoes"):
            return UIImage(named: "StoryCoverOcean03")
        case (.ocean, "tina the sea turtle and the long swim"):
            return UIImage(named: "StoryCoverOcean04")
        case (.ocean, "rafi the reef builder"):
            return UIImage(named: "StoryCoverOcean05")
        case (.ocean, "sammy the seahorse holds on"):
            return UIImage(named: "StoryCoverOcean06")
        case (.ocean, "sia the shark and the many teeth"):
            return UIImage(named: "StoryCoverOcean07")
        case (.ocean, "jelly the jellyfish drifts"):
            return UIImage(named: "StoryCoverOcean08")
        case (.ocean, "angie the anglerfish and the tiny light"):
            return UIImage(named: "StoryCoverOcean09")
        case (.ocean, "otto the sea otter floats and eats"):
            return UIImage(named: "StoryCoverOcean10")
        case (.animals, "ellie the elephant and the splashy mud bath"):
            return UIImage(named: "StoryCoverAnimals01")
        case (.animals, "leo the lion and the evening roar"):
            return UIImage(named: "StoryCoverAnimals02")
        case (.animals, "gigi the giraffe and the treetop snack"):
            return UIImage(named: "StoryCoverAnimals03")
        case (.animals, "pip the penguin and the icy slide"):
            return UIImage(named: "StoryCoverAnimals04")
        case (.animals, "freddy the frog and the pond metamorphosis"):
            return UIImage(named: "StoryCoverAnimals05")
        case (.animals, "bea the bee and the flower message dance"):
            return UIImage(named: "StoryCoverAnimals06")
        case (.animals, "ping the panda and the bamboo breakfast"):
            return UIImage(named: "StoryCoverAnimals07")
        case (.animals, "benny the bat and the night echoes"):
            return UIImage(named: "StoryCoverAnimals08")
        case (.animals, "cami the camel and the desert water trick"):
            return UIImage(named: "StoryCoverAnimals09")
        case (.animals, "willa the wolf and the pack plan"):
            return UIImage(named: "StoryCoverAnimals10")
        case (.space, "sunny the star at the center"):
            return UIImage(named: "StoryCoverSpace01")
        case (.space, "luna the moon that travels"):
            return UIImage(named: "StoryCoverSpace02")
        case (.space, "earth spins: day and night"):
            return UIImage(named: "StoryCoverSpace03")
        case (.space, "the planet family"):
            return UIImage(named: "StoryCoverSpace04")
        case (.space, "gravity the gentle pull"):
            return UIImage(named: "StoryCoverSpace05")
        case (.space, "rocket rides to space"):
            return UIImage(named: "StoryCoverSpace06")
        case (.space, "astronauts work in space"):
            return UIImage(named: "StoryCoverSpace07")
        case (.space, "stars and constellations"):
            return UIImage(named: "StoryCoverSpace08")
        case (.space, "our home galaxy: the milky way"):
            return UIImage(named: "StoryCoverSpace09")
        case (.space, "earth is safe and special"):
            return UIImage(named: "StoryCoverSpace10")
        case (.science, "what is gravity?"):
            return UIImage(named: "StoryCoverScience01")
        case (.science, "how plants grow"):
            return UIImage(named: "StoryCoverScience02")
        case (.science, "human body basics"):
            return UIImage(named: "StoryCoverScience03")
        case (.science, "what are magnets?"):
            return UIImage(named: "StoryCoverScience04")
        case (.science, "states of matter"):
            return UIImage(named: "StoryCoverScience05")
        case (.science, "the water cycle"):
            return UIImage(named: "StoryCoverScience06")
        case (.science, "how a fuel engine works"):
            return UIImage(named: "StoryCoverScience07")
        case (.science, "what is electricity?"):
            return UIImage(named: "StoryCoverScience08")
        case (.science, "what is medicine?"):
            return UIImage(named: "StoryCoverScience09")
        case (.science, "viruses and bacteria"):
            return UIImage(named: "StoryCoverScience10")
        case (.history, "the first people long ago"):
            return UIImage(named: "StoryCoverHistory01")
        case (.history, "when humans learned to farm"):
            return UIImage(named: "StoryCoverHistory02")
        case (.history, "great builders of the ancient world"):
            return UIImage(named: "StoryCoverHistory03")
        case (.history, "how writing began"):
            return UIImage(named: "StoryCoverHistory04")
        case (.history, "ships that crossed the seas"):
            return UIImage(named: "StoryCoverHistory05")
        case (.history, "the age of big inventions"):
            return UIImage(named: "StoryCoverHistory06")
        case (.history, "how transportation changed"):
            return UIImage(named: "StoryCoverHistory07")
        case (.history, "how communication changed"):
            return UIImage(named: "StoryCoverHistory08")
        case (.history, "ancient games and sports"):
            return UIImage(named: "StoryCoverHistory09")
        case (.history, "the story of money and trade"):
            return UIImage(named: "StoryCoverHistory10")
        case (.math, "the story of numbers"):
            return UIImage(named: "StoryCoverMath01")
        case (.math, "the day we discovered bigger and smaller"):
            return UIImage(named: "StoryCoverMath02")
        case (.math, "the day we found shapes everywhere"):
            return UIImage(named: "StoryCoverMath03")
        case (.math, "the day we learned to sort and group"):
            return UIImage(named: "StoryCoverMath04")
        case (.math, "the day we discovered patterns"):
            return UIImage(named: "StoryCoverMath05")
        case (.math, "the picnic that grew bigger"):
            return UIImage(named: "StoryCoverMath06")
        case (.math, "the cookies that disappeared"):
            return UIImage(named: "StoryCoverMath07")
        case (.math, "building the tallest tower"):
            return UIImage(named: "StoryCoverMath08")
        case (.math, "the little shop and the shiny coins"):
            return UIImage(named: "StoryCoverMath09")
        case (.math, "sharing the cupcakes"):
            return UIImage(named: "StoryCoverMath10")
        case (.culture, "hello around the world"):
            return UIImage(named: "StoryCoverCulture01")
        case (.culture, "lights of celebration"):
            return UIImage(named: "StoryCoverCulture02")
        case (.culture, "music from many places"):
            return UIImage(named: "StoryCoverCulture03")
        case (.culture, "clothes for weather and special days"):
            return UIImage(named: "StoryCoverCulture04")
        case (.culture, "homes around the world"):
            return UIImage(named: "StoryCoverCulture05")
        case (.culture, "foods from many kitchens"):
            return UIImage(named: "StoryCoverCulture06")
        case (.culture, "family traditions big and small"):
            return UIImage(named: "StoryCoverCulture07")
        case (.culture, "market day around the world"):
            return UIImage(named: "StoryCoverCulture08")
        case (.culture, "stories that travel"):
            return UIImage(named: "StoryCoverCulture09")
        case (.culture, "manners that show respect"):
            return UIImage(named: "StoryCoverCulture10")
        case (.emotionsSocial, "happy, sad, and calm"):
            return UIImage(named: "StoryCoverEmotionsSocial01")
        case (.emotionsSocial, "when anger feels big"):
            return UIImage(named: "StoryCoverEmotionsSocial02")
        case (.emotionsSocial, "brave with new things"):
            return UIImage(named: "StoryCoverEmotionsSocial03")
        case (.emotionsSocial, "sharing and taking turns"):
            return UIImage(named: "StoryCoverEmotionsSocial04")
        case (.emotionsSocial, "listening ears, kind words"):
            return UIImage(named: "StoryCoverEmotionsSocial05")
        case (.emotionsSocial, "making a new friend"):
            return UIImage(named: "StoryCoverEmotionsSocial06")
        case (.emotionsSocial, "fixing a small conflict"):
            return UIImage(named: "StoryCoverEmotionsSocial07")
        case (.emotionsSocial, "teamwork at playtime"):
            return UIImage(named: "StoryCoverEmotionsSocial08")
        case (.emotionsSocial, "sorry and repair"):
            return UIImage(named: "StoryCoverEmotionsSocial09")
        case (.emotionsSocial, "gratitude and caring hearts"):
            return UIImage(named: "StoryCoverEmotionsSocial10")
        case (.geography, "milo the mountain and the tall view"):
            return UIImage(named: "StoryCoverGeography01")
        case (.geography, "ria the river and the long journey"):
            return UIImage(named: "StoryCoverGeography02")
        case (.geography, "sunny the desert and the dry land"):
            return UIImage(named: "StoryCoverGeography03")
        case (.geography, "fiona the forest and the green world"):
            return UIImage(named: "StoryCoverGeography04")
        case (.geography, "ivy the island surrounded by water"):
            return UIImage(named: "StoryCoverGeography05")
        case (.geography, "cody the continent and the big lands"):
            return UIImage(named: "StoryCoverGeography06")
        case (.geography, "polly the polar lands and the cold ends"):
            return UIImage(named: "StoryCoverGeography07")
        case (.geography, "vicky the volcano and the hot earth"):
            return UIImage(named: "StoryCoverGeography08")
        case (.geography, "wally the weather map and the moving sky"):
            return UIImage(named: "StoryCoverGeography09")
        case (.geography, "mia the map and finding places"):
            return UIImage(named: "StoryCoverGeography10")
        case (.technologyMachines, "wally the wi-fi router shares the signal"):
            return UIImage(named: "StoryCoverTechnology01")
        case (.technologyMachines, "milo the mobile phone on the move"):
            return UIImage(named: "StoryCoverTechnology02")
        case (.technologyMachines, "cody the computer that follows instructions"):
            return UIImage(named: "StoryCoverTechnology03")
        case (.technologyMachines, "tara the television shares stories"):
            return UIImage(named: "StoryCoverTechnology04")
        case (.technologyMachines, "robo the robot helps step by step"):
            return UIImage(named: "StoryCoverTechnology05")
        case (.technologyMachines, "iggy the internet connects the world"):
            return UIImage(named: "StoryCoverTechnology06")
        case (.technologyMachines, "ava the smart helper listens and learns"):
            return UIImage(named: "StoryCoverTechnology07")
        case (.technologyMachines, "milo the map knows the way"):
            return UIImage(named: "StoryCoverTechnology08")
        case (.technologyMachines, "pia the camera catches moments"):
            return UIImage(named: "StoryCoverTechnology09")
        case (.technologyMachines, "vivi the video call brings faces together"):
            return UIImage(named: "StoryCoverTechnology10")
        default:
            return nil
        }
    }

    private func storyPageImage(for storyID: String, pageNumber: Int) -> UIImage? {
        guard pageNumber > 0 else { return nil }
        let normalizedID = storyID
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "‑", with: "_")
            .replacingOccurrences(of: "–", with: "_")
            .replacingOccurrences(of: "-", with: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let clampedPage = min(max(pageNumber, 1), 99)
        let assetName = String(format: "StoryPage_%@_%02d", normalizedID, clampedPage)

        if let asset = UIImage(named: assetName) {
            return asset
        }
        return nil
    }

    @ViewBuilder
    private func oceanShapes(in size: CGSize) -> some View {
        Circle()
            .fill(Color.white.opacity(0.2))
            .frame(width: size.width * 0.65)
            .offset(x: size.width * 0.2, y: -size.height * 0.25)

        Capsule()
            .fill(Color(hex: "004C99").opacity(0.55))
            .frame(width: size.width * 0.5, height: size.height * 0.2)
            .offset(x: CGFloat((seed % 3) - 1) * 15, y: size.height * 0.05)

        ForEach(0..<6, id: \.self) { idx in
            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: CGFloat(6 + (idx % 3) * 4))
                .offset(
                    x: -size.width * 0.32 + CGFloat(idx) * (size.width * 0.1),
                    y: size.height * 0.2 - CGFloat((idx + seed) % 2) * 10
                )
        }

        Rectangle()
            .fill(Color(hex: "2A9D8F").opacity(0.8))
            .frame(width: size.width * 0.08, height: size.height * 0.35)
            .rotationEffect(.degrees(-8))
            .offset(x: -size.width * 0.3, y: size.height * 0.25)

        Rectangle()
            .fill(Color(hex: "52B788").opacity(0.7))
            .frame(width: size.width * 0.06, height: size.height * 0.3)
            .rotationEffect(.degrees(10))
            .offset(x: -size.width * 0.2, y: size.height * 0.25)
    }

    @ViewBuilder
    private func animalShapes(in size: CGSize) -> some View {
        Circle()
            .fill(Color(hex: "FFF1B6").opacity(0.9))
            .frame(width: size.width * 0.35)
            .offset(x: size.width * 0.24, y: -size.height * 0.22)

        ForEach(0..<4, id: \.self) { idx in
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "5D8C4A").opacity(0.7 + Double(idx) * 0.05))
                .frame(width: size.width * 0.17, height: size.height * 0.22)
                .offset(
                    x: -size.width * 0.35 + CGFloat(idx) * (size.width * 0.25),
                    y: size.height * 0.28
                )
        }

        Ellipse()
            .fill(Color(hex: "8D5524").opacity(0.8))
            .frame(width: size.width * 0.35, height: size.height * 0.2)
            .offset(x: -size.width * 0.1, y: size.height * 0.05)

        Circle()
            .fill(Color(hex: "C68642"))
            .frame(width: size.width * 0.13)
            .offset(x: size.width * 0.05, y: -size.height * 0.03)

        Circle()
            .fill(Color.white.opacity(0.85))
            .frame(width: size.width * 0.03)
            .offset(x: size.width * 0.07, y: -size.height * 0.05)
    }

    @ViewBuilder
    private func spaceShapes(in size: CGSize) -> some View {
        Circle()
            .fill(Color(hex: "A4D9FF").opacity(0.9))
            .frame(width: size.width * 0.3)
            .offset(x: -size.width * 0.25, y: -size.height * 0.15)

        Circle()
            .stroke(Color(hex: "FFD166"), lineWidth: 6)
            .frame(width: size.width * 0.22)
            .offset(x: size.width * 0.2, y: size.height * 0.05)

        ForEach(0..<8, id: \.self) { idx in
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: CGFloat(3 + (idx + seed) % 4))
                .offset(
                    x: -size.width * 0.4 + CGFloat((idx * 13) % 90),
                    y: -size.height * 0.35 + CGFloat((idx * 17) % 80)
                )
        }

        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color(hex: "FF7D7D").opacity(0.9))
            .frame(width: size.width * 0.22, height: size.height * 0.1)
            .rotationEffect(.degrees(-20))
            .offset(x: -size.width * 0.02, y: size.height * 0.2)
    }

    @ViewBuilder
    private func scienceShapes(in size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.22))
            .frame(width: size.width * 0.76, height: size.height * 0.62)
            .offset(y: -size.height * 0.05)

        ForEach(0..<3, id: \.self) { idx in
            Capsule()
                .fill([Color(hex: "FFD166"), Color(hex: "73D2DE"), Color(hex: "6C7BFF")][idx].opacity(0.85))
                .frame(width: size.width * 0.13, height: size.height * 0.33)
                .offset(x: -size.width * 0.2 + CGFloat(idx) * (size.width * 0.2), y: size.height * 0.05)
        }

        Triangle()
            .fill(Color(hex: "22A59A").opacity(0.85))
            .frame(width: size.width * 0.16, height: size.height * 0.15)
            .offset(x: size.width * 0.27, y: -size.height * 0.13)

        Circle()
            .fill(Color.white.opacity(0.95))
            .frame(width: size.width * 0.06)
            .offset(x: size.width * 0.27, y: -size.height * 0.13)
    }

    @ViewBuilder
    private func mathShapes(in size: CGSize) -> some View {
        ForEach(0..<6, id: \.self) { idx in
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(idx.isMultiple(of: 2) ? Color(hex: "FFB347").opacity(0.82) : Color(hex: "FFD166").opacity(0.82))
                .frame(width: size.width * 0.2, height: size.height * 0.2)
                .offset(
                    x: -size.width * 0.28 + CGFloat(idx % 3) * (size.width * 0.28),
                    y: -size.height * 0.15 + CGFloat(idx / 3) * (size.height * 0.28)
                )
        }

        Circle()
            .fill(Color(hex: "F3722C").opacity(0.9))
            .frame(width: size.width * 0.16)
            .offset(x: size.width * 0.3, y: -size.height * 0.24)

        Text("+")
            .font(.system(size: size.width * 0.16, weight: .black, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.95))
            .offset(x: -size.width * 0.3, y: size.height * 0.25)
    }

    @ViewBuilder
    private func cultureShapes(in size: CGSize) -> some View {
        ForEach(0..<4, id: \.self) { idx in
            Circle()
                .fill(Color.white.opacity(0.2 + Double(idx) * 0.08))
                .frame(width: size.width * (0.2 + CGFloat(idx) * 0.08))
                .offset(
                    x: -size.width * 0.3 + CGFloat(idx) * (size.width * 0.2),
                    y: -size.height * 0.18 + CGFloat(idx % 2) * 20
                )
        }

        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.white.opacity(0.35))
            .frame(width: size.width * 0.5, height: size.height * 0.18)
            .offset(y: size.height * 0.2)

        ForEach(0..<3, id: \.self) { idx in
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill([Color(hex: "FFD166"), Color(hex: "06D6A0"), Color(hex: "4D96FF")][idx].opacity(0.92))
                .frame(width: size.width * 0.13, height: size.height * 0.3)
                .offset(x: -size.width * 0.2 + CGFloat(idx) * (size.width * 0.2), y: size.height * 0.04)
        }
    }

    @ViewBuilder
    private func emotionsShapes(in size: CGSize) -> some View {
        Circle()
            .fill(Color.white.opacity(0.28))
            .frame(width: size.width * 0.66)
            .offset(x: -size.width * 0.05, y: -size.height * 0.14)

        Circle()
            .fill(Color(hex: "FFD166").opacity(0.92))
            .frame(width: size.width * 0.2)
            .offset(x: -size.width * 0.16, y: -size.height * 0.06)

        Circle()
            .fill(Color(hex: "06D6A0").opacity(0.92))
            .frame(width: size.width * 0.16)
            .offset(x: size.width * 0.03, y: -size.height * 0.02)

        Circle()
            .fill(Color(hex: "4D96FF").opacity(0.9))
            .frame(width: size.width * 0.14)
            .offset(x: size.width * 0.2, y: size.height * 0.03)

        Capsule()
            .fill(Color.white.opacity(0.32))
            .frame(width: size.width * 0.42, height: size.height * 0.14)
            .offset(y: size.height * 0.24)
    }

    @ViewBuilder
    private func historyShapes(in size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(hex: "F6E7CB").opacity(0.85))
            .frame(width: size.width * 0.62, height: size.height * 0.56)
            .offset(y: -size.height * 0.02)

        ForEach(0..<5, id: \.self) { idx in
            Capsule()
                .fill(Color(hex: "8D6E63").opacity(0.42))
                .frame(width: size.width * 0.42, height: 6)
                .offset(y: -size.height * 0.14 + CGFloat(idx) * 18)
        }

        Circle()
            .stroke(Color.white.opacity(0.8), lineWidth: 5)
            .frame(width: size.width * 0.2)
            .offset(x: size.width * 0.28, y: -size.height * 0.24)

        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.white.opacity(0.4))
            .frame(width: size.width * 0.28, height: size.height * 0.12)
            .offset(x: size.width * 0.26, y: size.height * 0.16)
    }

    @ViewBuilder
    private func geographyShapes(in size: CGSize) -> some View {
        Circle()
            .fill(Color.white.opacity(0.28))
            .frame(width: size.width * 0.6)
            .offset(x: -size.width * 0.1, y: -size.height * 0.08)

        Circle()
            .fill(Color(hex: "2F9E44").opacity(0.92))
            .frame(width: size.width * 0.42)
            .offset(x: -size.width * 0.1, y: -size.height * 0.08)

        Circle()
            .fill(Color(hex: "76D37F").opacity(0.92))
            .frame(width: size.width * 0.2)
            .offset(x: -size.width * 0.2, y: -size.height * 0.12)

        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.white.opacity(0.48))
            .frame(width: size.width * 0.28, height: size.height * 0.3)
            .offset(x: size.width * 0.26, y: size.height * 0.02)

        ForEach(0..<3, id: \.self) { idx in
            Capsule()
                .fill(Color(hex: "3A86FF").opacity(0.7))
                .frame(width: size.width * 0.2, height: 5)
                .offset(x: size.width * 0.26, y: -size.height * 0.08 + CGFloat(idx) * 12)
        }
    }

    @ViewBuilder
    private func technologyShapes(in size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.22))
            .frame(width: size.width * 0.72, height: size.height * 0.62)
            .offset(y: -size.height * 0.04)

        ForEach(0..<4, id: \.self) { idx in
            Circle()
                .fill([Color(hex: "7AA8FF"), Color(hex: "4A64D8"), Color(hex: "76E3C1"), Color(hex: "FFD75E")][idx].opacity(0.9))
                .frame(width: size.width * 0.12)
                .offset(
                    x: -size.width * 0.24 + CGFloat(idx) * (size.width * 0.16),
                    y: size.height * 0.08 + CGFloat((idx + seed) % 2) * 16
                )
        }

        Capsule()
            .fill(Color.white.opacity(0.4))
            .frame(width: size.width * 0.3, height: size.height * 0.08)
            .offset(x: size.width * 0.2, y: -size.height * 0.16)

        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.white.opacity(0.32))
            .frame(width: size.width * 0.24, height: size.height * 0.12)
            .offset(x: size.width * 0.22, y: size.height * 0.18)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
