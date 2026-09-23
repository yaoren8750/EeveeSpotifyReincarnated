import SwiftUI

struct EeveeLyricsSettingsView: View {
    @StateObject var viewModel = EeveeLyricsSettingsViewModel()
    // Local mirror of UserDefaults.karaokeOptions — that's a plain computed
    // static var (backed by the @UserDefault property wrapper), not
    // @Published, so it can't be bound directly with $viewModel-style
    // syntax. Mirroring it into @State and writing back via onChange is the
    // standard way to give a plain UserDefaults-backed value SwiftUI
    // binding support without changing how @UserDefault itself works.
    @State private var karaokeOptions: KaraokeOptions = UserDefaults.karaokeOptions

    var body: some View {
        List {
            lyricsSourceSection()
            
            if viewModel.lyricsSource != .notReplaced {
                if viewModel.lyricsSource != .genius {
                    geniusFallbackSection()
                }
                
                hideOnErrorSection()
                romanizedLyricsSection()
                
                if viewModel.lyricsSource == .musixmatch {
                    musixmatchLanguageSection()
                }

                if viewModel.lyricsSource == .spicylyrics {
                    karaokeAppearanceSection()
                }
            }

            SpacerView()
        }
        .onReceive(viewModel.musixmatchTokenInputAlertPublisher) { showAnonymousTokenOption in
            showMusixmatchTokenAlert(UserDefaults.lyricsSource, showAnonymousTokenOption)
        }
        .listStyle(GroupedListStyle())
        .disabled(viewModel.isRequestingMusixmatchToken)
        .animation(.default, value: viewModel.animationValues)
        .onChange(of: karaokeOptions) { UserDefaults.karaokeOptions = $0 }
    }

    @ViewBuilder private func karaokeAppearanceSection() -> some View {
        Section {
            Picker("歌词对齐方式", selection: $karaokeOptions.textAlignment) {
                ForEach(KaraokeTextAlignment.allCases, id: \.self) { alignment in
                    Text(alignment.displayName).tag(alignment)
                }
            }

            Toggle(
                "反向滚动",
                isOn: $karaokeOptions.reversedDirection
            )
        } header: {
            Text("逐词同步歌词")
        } footer: {
            Text("反向模式会让歌词从下往上滚动，而不是从上往下滚动，同时当前歌词行会显示在屏幕下方。")
        }
    }
    
    @ViewBuilder private func geniusFallbackSection() -> some View {
        Section {
            Toggle(
                "genius_fallback".localized,
                isOn: $viewModel.lyricsOptions.geniusFallback
            )
            
            if viewModel.lyricsOptions.geniusFallback {
                Toggle(
                    "show_fallback_reasons".localized,
                    isOn: $viewModel.lyricsOptions.showFallbackReasons
                )
            }
        } footer: {
            Text("genius_fallback_description"
                .localizeWithFormat(viewModel.lyricsSource.description))
        }
    }
    
    @ViewBuilder private func romanizedLyricsSection() -> some View {
        Section {
            Toggle(
                "romanized_lyrics".localized,
                isOn: $viewModel.lyricsOptions.romanization
            )
        } footer: {
            Text("romanized_lyrics_description".localized)
        }
    }
    
    @ViewBuilder private func hideOnErrorSection() -> some View {
        Section {
            Toggle(
                "hide_lyrics_on_error".localized,
                isOn: $viewModel.lyricsOptions.hideOnError
            )
        } footer: {
            Text("hide_lyrics_on_error_description".localized)
        }
    }
    
    @ViewBuilder private func musixmatchLanguageSection() -> some View {
        Section {
            HStack {
                Text("musixmatch_language".localized)
                
                Spacer()
                
                TextField("en", text: $viewModel.lyricsOptions.musixmatchLanguage)
                    .frame(maxWidth: 20)
                    .foregroundColor(.gray)
            }
            .icon(
                "exclamationmark.triangle.fill",
                color: .yellow,
                when: $viewModel.showMusixmatchInvalidLanguageWarning
            )
        } footer: {
            Text("musixmatch_language_description".localized)
        }
    }
}
