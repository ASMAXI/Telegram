import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import Postbox
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences
import ItemListUI
import PresentationDataUtils
import AccountContext
import UndoUI
import EntityKeyboard
import PremiumUI
import ComponentFlow
import BundleIconComponent
import AnimatedTextComponent
import ViewControllerComponent
import ButtonComponent
import PremiumLockButtonSubtitleComponent
import ListItemComponentAdaptor
import ListSectionComponent
import MultilineTextComponent
import ThemeCarouselItem
import ListActionItemComponent
import EmojiStatusSelectionComponent
import EmojiStatusComponent
import DynamicCornerRadiusView
import ComponentDisplayAdapters

private final class EmojiActionIconComponent: Component {
    let context: AccountContext
    let color: UIColor
    let fileId: Int64?
    let file: TelegramMediaFile?
    
    init(
        context: AccountContext,
        color: UIColor,
        fileId: Int64?,
        file: TelegramMediaFile?
    ) {
        self.context = context
        self.color = color
        self.fileId = fileId
        self.file = file
    }
    
    static func ==(lhs: EmojiActionIconComponent, rhs: EmojiActionIconComponent) -> Bool {
        if lhs.context !== rhs.context {
            return false
        }
        if lhs.color != rhs.color {
            return false
        }
        if lhs.fileId != rhs.fileId {
            return false
        }
        if lhs.file != rhs.file {
            return false
        }
        return true
    }
    
    final class View: UIView {
        private var icon: ComponentView<Empty>?
        
        func update(component: EmojiActionIconComponent, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: Transition) -> CGSize {
            let size = CGSize(width: 24.0, height: 24.0)
            
            if let fileId = component.fileId {
                let icon: ComponentView<Empty>
                if let current = self.icon {
                    icon = current
                } else {
                    icon = ComponentView()
                    self.icon = icon
                }
                let _ = icon.update(
                    transition: .immediate,
                    component: AnyComponent(EmojiStatusComponent(
                        context: component.context,
                        animationCache: component.context.animationCache,
                        animationRenderer: component.context.animationRenderer,
                        content: .animation(
                            content: .customEmoji(fileId: fileId),
                            size: size,
                            placeholderColor: .lightGray,
                            themeColor: component.color,
                            loopMode: .forever
                        ),
                        isVisibleForAnimations: false,
                        action: nil
                    )),
                    environment: {},
                    containerSize: size
                )
                let iconFrame = CGRect(origin: CGPoint(), size: size)
                if let iconView = icon.view {
                    if iconView.superview == nil {
                        self.addSubview(iconView)
                    }
                    iconView.frame = iconFrame
                }
            } else {
                if let icon = self.icon {
                    self.icon = nil
                    icon.view?.removeFromSuperview()
                }
            }
            
            return size
        }
    }
    
    func makeView() -> View {
        return View(frame: CGRect())
    }
    
    func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: Transition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}

public func generateDisclosureActionBoostLevelBadgeImage(text: String) -> UIImage {
    let attributedText = NSAttributedString(string: text, attributes: [
        .font: Font.medium(12.0),
        .foregroundColor: UIColor.white
    ])
    let bounds = attributedText.boundingRect(with: CGSize(width: 100.0, height: 100.0), options: .usesLineFragmentOrigin, context: nil)
    let leftInset: CGFloat = 16.0
    let rightInset: CGFloat = 4.0
    let size = CGSize(width: leftInset + rightInset + ceil(bounds.width), height: 20.0)
    return generateImage(size, rotatedContext: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        context.addPath(UIBezierPath(roundedRect: CGRect(origin: CGPoint(), size: size), cornerRadius: 6.0).cgPath)
        context.clip()
        
        var locations: [CGFloat] = [0.0, 1.0]
        let colors: [CGColor] = [UIColor(rgb: 0x9076FF).cgColor, UIColor(rgb: 0xB86DEA).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: &locations)!
        context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: size.width, y: 0.0), options: CGGradientDrawingOptions())
        
        context.resetClip()
        
        UIGraphicsPushContext(context)
        
        if let image = generateTintedImage(image: UIImage(bundleImageName: "Chat/Input/Media/PanelBadgeLock"), color: .white) {
            let imageFit: CGFloat = 14.0
            let imageSize = image.size.aspectFitted(CGSize(width: imageFit, height: imageFit))
            let imageRect = CGRect(origin: CGPoint(x: 2.0, y: UIScreenPixel + floorToScreenPixels((size.height - imageSize.height) * 0.5)), size: imageSize)
            image.draw(in: imageRect)
        }
        
        attributedText.draw(at: CGPoint(x: leftInset, y: floorToScreenPixels((size.height - bounds.height) * 0.5)))
        
        UIGraphicsPopContext()
    })!
}

private final class BoostLevelIconComponent: Component {
    let strings: PresentationStrings
    let level: Int
    
    init(
        strings: PresentationStrings,
        level: Int
    ) {
        self.strings = strings
        self.level = level
    }
    
    static func ==(lhs: BoostLevelIconComponent, rhs: BoostLevelIconComponent) -> Bool {
        if lhs.strings !== rhs.strings {
            return false
        }
        if lhs.level != rhs.level {
            return false
        }
        return true
    }
    
    final class View: UIView {
        private let imageView: UIImageView
        
        private var component: BoostLevelIconComponent?
        
        override init(frame: CGRect) {
            self.imageView = UIImageView()
            
            super.init(frame: frame)
            
            self.addSubview(self.imageView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func update(component: BoostLevelIconComponent, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: Transition) -> CGSize {
            if self.component != component {
                //TODO:localize
                self.imageView.image = generateDisclosureActionBoostLevelBadgeImage(text: "Level \(component.level)")
            }
            self.component = component
            
            if let image = self.imageView.image {
                self.imageView.frame = CGRect(origin: CGPoint(), size: image.size)
                return image.size
            } else {
                return CGSize(width: 1.0, height: 20.0)
            }
        }
    }
    
    func makeView() -> View {
        return View(frame: CGRect())
    }
    
    func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: Transition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}

final class ChannelAppearanceScreenComponent: Component {
    typealias EnvironmentType = ViewControllerComponentContainer.Environment
    
    let context: AccountContext
    let peerId: EnginePeer.Id

    init(
        context: AccountContext,
        peerId: EnginePeer.Id
    ) {
        self.context = context
        self.peerId = peerId
    }

    static func ==(lhs: ChannelAppearanceScreenComponent, rhs: ChannelAppearanceScreenComponent) -> Bool {
        if lhs.context !== rhs.context {
            return false
        }
        if lhs.peerId != rhs.peerId {
            return false
        }

        return true
    }
    
    private final class ContentsData {
        let peer: EnginePeer?
        let subscriberCount: Int?
        let availableThemes: [TelegramTheme]
        
        init(peer: EnginePeer?, subscriberCount: Int?, availableThemes: [TelegramTheme]) {
            self.peer = peer
            self.subscriberCount = subscriberCount
            self.availableThemes = availableThemes
        }
        
        static func get(context: AccountContext, peerId: EnginePeer.Id) -> Signal<ContentsData, NoError> {
            return combineLatest(
                context.engine.data.subscribe(
                    TelegramEngine.EngineData.Item.Peer.Peer(id: peerId),
                    TelegramEngine.EngineData.Item.Peer.ParticipantCount(id: peerId)
                ),
                telegramThemes(postbox: context.account.postbox, network: context.account.network, accountManager: context.sharedContext.accountManager)
            )
            |> map { peerData, cloudThemes -> ContentsData in
                let (peer, subscriberCount) = peerData
                return ContentsData(
                    peer: peer,
                    subscriberCount: subscriberCount,
                    availableThemes: cloudThemes
                )
            }
        }
    }
    
    private final class ScrollView: UIScrollView {
        override func touchesShouldCancel(in view: UIView) -> Bool {
            return true
        }
    }
    
    final class View: UIView, UIScrollViewDelegate {
        private let scrollView: ScrollView
        private let actionButton = ComponentView<Empty>()
        private let bottomPanelBackgroundView: BlurredBackgroundView
        private let bottomPanelSeparator: SimpleLayer
        
        private let replySection = ComponentView<Empty>()
        private let wallpaperSection = ComponentView<Empty>()
        private let bannerSection = ComponentView<Empty>()
        private let resetColorSection = ComponentView<Empty>()
        private let emojiStatusSection = ComponentView<Empty>()
        
        private var chatPreviewItemNode: PeerNameColorChatPreviewItemNode?
        
        private var isUpdating: Bool = false
        
        private var component: ChannelAppearanceScreenComponent?
        private(set) weak var state: EmptyComponentState?
        private var environment: EnvironmentType?
        
        let isReady = ValuePromise<Bool>(false, ignoreRepeated: true)
        private var contentsData: ContentsData?
        private var contentsDataDisposable: Disposable?
        
        private var cachedIconFiles: [Int64: TelegramMediaFile] = [:]
        
        private var updatedPeerNameColor: PeerNameColor?
        private var updatedPeerNameEmoji: Int64??
        private var updatedPeerProfileColor: PeerNameColor??
        private var updatedPeerProfileEmoji: Int64??
        private var updatedPeerStatusEmoji: Int64??
        
        private var requiredLevel: Int?
        
        private var currentTheme: PresentationThemeReference?
        
        private var boostStatus: ChannelBoostStatus?
        private var boostStatusDisposable: Disposable?
        
        private var isApplyingSettings: Bool = false
        private var applyDisposable: Disposable?
        
        private weak var emojiStatusSelectionController: ViewController?
        private weak var currentUndoController: UndoOverlayController?
        
        override init(frame: CGRect) {
            self.scrollView = ScrollView()
            self.scrollView.showsVerticalScrollIndicator = true
            self.scrollView.showsHorizontalScrollIndicator = false
            self.scrollView.scrollsToTop = false
            self.scrollView.delaysContentTouches = false
            self.scrollView.canCancelContentTouches = true
            self.scrollView.contentInsetAdjustmentBehavior = .never
            if #available(iOS 13.0, *) {
                self.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
            }
            self.scrollView.alwaysBounceVertical = true
            
            self.bottomPanelBackgroundView = BlurredBackgroundView(color: .clear, enableBlur: true)
            self.bottomPanelSeparator = SimpleLayer()
            
            super.init(frame: frame)
            
            self.scrollView.delegate = self
            self.addSubview(self.scrollView)
            
            self.addSubview(self.bottomPanelBackgroundView)
            self.layer.addSublayer(self.bottomPanelSeparator)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            self.contentsDataDisposable?.dispose()
            self.applyDisposable?.dispose()
            self.boostStatusDisposable?.dispose()
        }

        func scrollToTop() {
            self.scrollView.setContentOffset(CGPoint(), animated: true)
        }
        
        func attemptNavigation(complete: @escaping () -> Void) -> Bool {
            return true
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.updateScrolling(transition: .immediate)
        }
        
        private func updateScrolling(transition: Transition) {
            let navigationAlphaDistance: CGFloat = 16.0
            let navigationAlpha: CGFloat = max(0.0, min(1.0, self.scrollView.contentOffset.y / navigationAlphaDistance))
            if let controller = self.environment?.controller(), let navigationBar = controller.navigationBar {
                transition.setAlpha(layer: navigationBar.backgroundNode.layer, alpha: navigationAlpha)
                transition.setAlpha(layer: navigationBar.stripeNode.layer, alpha: navigationAlpha)
            }
            
            let bottomNavigationAlphaDistance: CGFloat = 16.0
            let bottomNavigationAlpha: CGFloat = max(0.0, min(1.0, (self.scrollView.contentSize.height - self.scrollView.bounds.maxY) / bottomNavigationAlphaDistance))
            
            transition.setAlpha(view: self.bottomPanelBackgroundView, alpha: bottomNavigationAlpha)
            transition.setAlpha(layer: self.bottomPanelSeparator, alpha: bottomNavigationAlpha)
        }
        
        private func applySettings() {
            guard let component = self.component, let contentsData = self.contentsData, let peer = contentsData.peer, let requiredLevel = self.requiredLevel else {
                return
            }
            if self.isApplyingSettings {
                return
            }
            
            if let boostStatus = self.boostStatus, requiredLevel > boostStatus.level {
                self.displayPremiumScreen(requiredLevel: requiredLevel)
                return
            }
            
            self.isApplyingSettings = true
            self.state?.updated(transition: .immediate)
            
            self.applyDisposable?.dispose()
            
            let nameColor: PeerNameColor
            if let updatedPeerNameColor = self.updatedPeerNameColor {
                nameColor = updatedPeerNameColor
            } else if let peerNameColor = peer.nameColor {
                nameColor = peerNameColor
            } else {
                nameColor = .blue
            }
            
            let profileColor: PeerNameColor?
            if case let .some(value) = self.updatedPeerProfileColor {
                profileColor = value
            } else if let peerProfileColor = peer.profileColor {
                profileColor = peerProfileColor
            } else {
                profileColor = nil
            }
            
            let replyFileId: Int64?
            if case let .some(value) = self.updatedPeerNameEmoji {
                replyFileId = value
            } else {
                replyFileId = contentsData.peer?.backgroundEmojiId
            }
            
            let backgroundFileId: Int64?
            if case let .some(value) = self.updatedPeerProfileEmoji {
                backgroundFileId = value
            } else {
                backgroundFileId = contentsData.peer?.profileBackgroundEmojiId
            }
            
            let emojiStatus: PeerEmojiStatus?
            if case let .some(value) = self.updatedPeerStatusEmoji {
                if let value {
                    emojiStatus = PeerEmojiStatus(fileId: value, expirationDate: nil)
                } else {
                    emojiStatus = nil
                }
            } else {
                emojiStatus = contentsData.peer?.emojiStatus
            }
            let statusFileId = emojiStatus?.fileId
            
            let _ = statusFileId
            
            enum ApplyError {
                case generic
            }
            
            self.applyDisposable = (combineLatest([
                component.context.engine.peers.updatePeerNameColorAndEmoji(peerId: component.peerId, nameColor: nameColor, backgroundEmojiId: replyFileId, profileColor: profileColor, profileBackgroundEmojiId: backgroundFileId)
                |> mapError { _ -> ApplyError in
                    return .generic
                }
            ])
            |> deliverOnMainQueue).start(error: { [weak self] _ in
                guard let self else {
                    return
                }
                self.isApplyingSettings = false
                self.state?.updated(transition: .immediate)
            }, completed: { [weak self] in
                guard let self else {
                    return
                }
                self.environment?.controller()?.dismiss()
            })
        }
        
        private func displayPremiumScreen(requiredLevel: Int) {
            guard let component = self.component else {
                return
            }
            
            let _ = (component.context.engine.data.get(TelegramEngine.EngineData.Item.Peer.Peer(id: component.peerId))
            |> deliverOnMainQueue).startStandalone(next: { [weak self] peer in
                guard let self, let component = self.component, let peer, let status = self.boostStatus else {
                    return
                }
                
                let premiumConfiguration = PremiumConfiguration.with(appConfiguration: component.context.currentAppConfiguration.with { $0 })
                
                let link = status.url
                let controller = PremiumLimitScreen(context: component.context, subject: .storiesChannelBoost(peer: peer, boostSubject: .channelReactions(reactionCount: requiredLevel), isCurrent: true, level: Int32(status.level), currentLevelBoosts: Int32(status.currentLevelBoosts), nextLevelBoosts: status.nextLevelBoosts.flatMap(Int32.init), link: link, myBoostCount: 0, canBoostAgain: false), count: Int32(status.boosts), action: { [weak self] in
                    guard let self, let component = self.component else {
                        return true
                    }
                            
                    UIPasteboard.general.string = link
                    let presentationData = component.context.sharedContext.currentPresentationData.with { $0 }
                    self.environment?.controller()?.present(UndoOverlayController(presentationData: presentationData, content: .linkCopied(text: presentationData.strings.ChannelBoost_BoostLinkCopied), elevatedLayout: false, position: .bottom, animateInAsReplacement: false, action: { _ in return false }), in: .current)
                    return true
                }, openStats: { [weak self] in
                    guard let self else {
                        return
                    }
                    self.openBoostStats()
                }, openGift: premiumConfiguration.giveawayGiftsPurchaseAvailable ? { [weak self] in
                    guard let self, let component = self.component else {
                        return
                    }
                    let controller = createGiveawayController(context: component.context, peerId: component.peerId, subject: .generic)
                    self.environment?.controller()?.push(controller)
                } : nil)
                self.environment?.controller()?.push(controller)
                
                HapticFeedback().impact(.light)
            })
        }
        
        private func openBoostStats() {
            guard let component = self.component, let boostStatus = self.boostStatus else {
                return
            }
            let statsController = component.context.sharedContext.makeChannelStatsController(context: component.context, updatedPresentationData: nil, peerId: component.peerId, boosts: true, boostStatus: boostStatus)
            self.environment?.controller()?.push(statsController)
        }
        
        private enum EmojiSetupSubject {
            case reply
            case profile
            case status
        }
        
        private var previousEmojiSetupTimestamp: Double?
        private func openEmojiSetup(sourceView: UIView, currentFileId: Int64?, color: UIColor?, subject: EmojiSetupSubject) {
            guard let component = self.component, let environment = self.environment else {
                return
            }
            
            let currentTimestamp = CACurrentMediaTime()
            if let previousTimestamp = self.previousEmojiSetupTimestamp, currentTimestamp < previousTimestamp + 1.0 {
                return
            }
            self.previousEmojiSetupTimestamp = currentTimestamp
            
            self.emojiStatusSelectionController?.dismiss()
            var selectedItems = Set<MediaId>()
            if let currentFileId {
                selectedItems.insert(MediaId(namespace: Namespaces.Media.CloudFile, id: currentFileId))
            }
            
            let controller = EmojiStatusSelectionController(
                context: component.context,
                mode: .backgroundSelection(completion: { [weak self] result in
                    guard let self else {
                        return
                    }
                    switch subject {
                    case .reply:
                        self.updatedPeerNameEmoji = result
                    case .profile:
                        self.updatedPeerProfileEmoji = result
                    case .status:
                        self.updatedPeerStatusEmoji = result
                    }
                    self.state?.updated(transition: .spring(duration: 0.4))
                }),
                sourceView: sourceView,
                emojiContent: EmojiPagerContentComponent.emojiInputData(
                    context: component.context,
                    animationCache: component.context.animationCache,
                    animationRenderer: component.context.animationRenderer,
                    isStandalone: false,
                    subject: subject == .status ? .status : .backgroundIcon,
                    hasTrending: false,
                    topReactionItems: [],
                    areUnicodeEmojiEnabled: false,
                    areCustomEmojiEnabled: true,
                    chatPeerId: component.context.account.peerId,
                    selectedItems: selectedItems,
                    topStatusTitle: nil,
                    backgroundIconColor: color
                ),
                currentSelection: currentFileId,
                color: color,
                destinationItemView: { [weak sourceView] in
                    return sourceView
                }
            )
            self.emojiStatusSelectionController = controller
            environment.controller()?.present(controller, in: .window(.root))
        }
        
        func update(component: ChannelAppearanceScreenComponent, availableSize: CGSize, state: EmptyComponentState, environment: Environment<EnvironmentType>, transition: Transition) -> CGSize {
            self.isUpdating = true
            defer {
                self.isUpdating = false
            }
            
            let environment = environment[EnvironmentType.self].value
            let themeUpdated = self.environment?.theme !== environment.theme
            self.environment = environment
            
            self.component = component
            self.state = state
            
            if themeUpdated {
                self.backgroundColor = environment.theme.list.blocksBackgroundColor
            }
            
            if self.contentsDataDisposable == nil {
                self.contentsDataDisposable = (ContentsData.get(context: component.context, peerId: component.peerId)
                |> deliverOnMainQueue).start(next: { [weak self] contentsData in
                    guard let self else {
                        return
                    }
                    self.contentsData = contentsData
                    if !self.isUpdating {
                        self.state?.updated(transition: .immediate)
                    }
                    self.isReady.set(true)
                })
            }
            if self.boostStatusDisposable == nil {
                self.boostStatusDisposable = (component.context.engine.peers.getChannelBoostStatus(peerId: component.peerId)
                |> deliverOnMainQueue).start(next: { [weak self] boostStatus in
                    guard let self else {
                        return
                    }
                    self.boostStatus = boostStatus
                    if !self.isUpdating {
                        self.state?.updated(transition: .immediate)
                    }
                })
            }
            
            guard let contentsData = self.contentsData, var peer = contentsData.peer else {
                return availableSize
            }
            
            var requiredLevel = 1
            
            let replyIconLevel = 5
            let profileIconLevel = 7
            let emojiStatusLevel = 8
            let themeLevel = 9
            
            let nameColor: PeerNameColor
            if let updatedPeerNameColor = self.updatedPeerNameColor {
                nameColor = updatedPeerNameColor
            } else if let peerNameColor = peer.nameColor {
                nameColor = peerNameColor
            } else {
                nameColor = .blue
            }
            
            let profileColor: PeerNameColor?
            if case let .some(value) = self.updatedPeerProfileColor {
                profileColor = value
            } else if let peerProfileColor = peer.profileColor {
                profileColor = peerProfileColor
            } else {
                profileColor = nil
            }
            
            let replyFileId: Int64?
            if case let .some(value) = self.updatedPeerNameEmoji {
                replyFileId = value
            } else {
                replyFileId = contentsData.peer?.backgroundEmojiId
            }
            if replyFileId != nil {
                requiredLevel = max(requiredLevel, replyIconLevel)
            }
            
            let backgroundFileId: Int64?
            if case let .some(value) = self.updatedPeerProfileEmoji {
                backgroundFileId = value
            } else {
                backgroundFileId = contentsData.peer?.profileBackgroundEmojiId
            }
            if backgroundFileId != nil {
                requiredLevel = max(requiredLevel, profileIconLevel)
            }
            
            let emojiStatus: PeerEmojiStatus?
            if case let .some(value) = self.updatedPeerStatusEmoji {
                if let value {
                    emojiStatus = PeerEmojiStatus(fileId: value, expirationDate: nil)
                } else {
                    emojiStatus = nil
                }
            } else {
                emojiStatus = contentsData.peer?.emojiStatus
            }
            if emojiStatus != nil {
                requiredLevel = max(requiredLevel, emojiStatusLevel)
            }
            let statusFileId = emojiStatus?.fileId
            
            let cloudThemes: [PresentationThemeReference] = contentsData.availableThemes.map { .cloud(PresentationCloudTheme(theme: $0, resolvedWallpaper: nil, creatorAccountId: $0.isCreator ? component.context.account.id : nil)) }
            var chatThemes = cloudThemes.filter { $0.emoticon != nil }
            chatThemes.insert(.builtin(.dayClassic), at: 0)
            
            if !chatThemes.isEmpty {
                if self.currentTheme == nil {
                    self.currentTheme = chatThemes[0]
                }
            }
            
            if self.currentTheme != nil && self.currentTheme != chatThemes.first {
                requiredLevel = max(requiredLevel, themeLevel)
            }
            
            if case let .user(user) = peer {
                peer = .user(user
                    .withUpdatedNameColor(nameColor)
                    .withUpdatedProfileColor(profileColor)
                    .withUpdatedEmojiStatus(emojiStatus)
                    .withUpdatedBackgroundEmojiId(replyFileId)
                    .withUpdatedProfileBackgroundEmojiId(backgroundFileId)
                )
            } else if case let .channel(channel) = peer {
                peer = .channel(channel
                    .withUpdatedNameColor(nameColor)
                    .withUpdatedProfileColor(profileColor)
                    .withUpdatedEmojiStatus(emojiStatus)
                    .withUpdatedBackgroundEmojiId(replyFileId)
                    .withUpdatedProfileBackgroundEmojiId(backgroundFileId)
                )
            }
            
            self.requiredLevel = requiredLevel
            
            let topInset: CGFloat = 24.0
            let bottomContentInset: CGFloat = 24.0
            let bottomInset: CGFloat = 8.0
            let sideInset: CGFloat = 16.0 + environment.safeInsets.left
            let sectionSpacing: CGFloat = 32.0
            
            let listItemParams = ListViewItemLayoutParams(width: availableSize.width - sideInset * 2.0, leftInset: 0.0, rightInset: 0.0, availableHeight: 10000.0, isStandalone: true)
            
            var contentHeight: CGFloat = 0.0
            contentHeight += environment.navigationHeight
            contentHeight += topInset
            
            let presentationData = component.context.sharedContext.currentPresentationData.with { $0 }
            
            let messageItem = PeerNameColorChatPreviewItem.MessageItem(
                outgoing: false,
                peerId: EnginePeer.Id(namespace: peer.id.namespace, id: PeerId.Id._internalFromInt64Value(0)),
                author: peer.compactDisplayTitle,
                photo: peer.profileImageRepresentations,
                nameColor: nameColor,
                backgroundEmojiId: replyFileId,
                reply: (peer.compactDisplayTitle, environment.strings.NameColor_ChatPreview_ReplyText_Channel),
                linkPreview: (environment.strings.NameColor_ChatPreview_LinkSite, environment.strings.NameColor_ChatPreview_LinkTitle, environment.strings.NameColor_ChatPreview_LinkText),
                text: environment.strings.NameColor_ChatPreview_MessageText_Channel
            )
            
            var replyLogoContents: [AnyComponentWithIdentity<Empty>] = []
            replyLogoContents.append(AnyComponentWithIdentity(id: 0, component: AnyComponent(MultilineTextComponent(
                text: .plain(NSAttributedString(
                    string: "Replies Logo", //TODO:localize
                    font: Font.regular(presentationData.listsFontSize.baseDisplaySize),
                    textColor: environment.theme.list.itemPrimaryTextColor
                )),
                maximumNumberOfLines: 0
            ))))
            if replyFileId != nil, let boostStatus = self.boostStatus, boostStatus.level < replyIconLevel {
                replyLogoContents.append(AnyComponentWithIdentity(id: 1, component: AnyComponent(BoostLevelIconComponent(
                    strings: environment.strings,
                    level: replyIconLevel
                ))))
            }
            
            let replySectionSize = self.replySection.update(
                transition: transition,
                component: AnyComponent(ListSectionComponent(
                    theme: environment.theme,
                    header: nil,
                    footer: AnyComponent(MultilineTextComponent(
                        text: .plain(NSAttributedString(
                            string: "Choose a color for the name of your channel, the link it sends, and replies to its messages.", //TODO:localize
                            font: Font.regular(presentationData.listsFontSize.itemListBaseHeaderFontSize),
                            textColor: environment.theme.list.freeTextColor
                        )),
                        maximumNumberOfLines: 0
                    )),
                    items: [
                        AnyComponentWithIdentity(id: 0, component: AnyComponent(ListItemComponentAdaptor(
                            itemGenerator: PeerNameColorChatPreviewItem(
                                context: component.context,
                                theme: environment.theme,
                                componentTheme: environment.theme,
                                strings: environment.strings,
                                sectionId: 0,
                                fontSize: presentationData.chatFontSize,
                                chatBubbleCorners: presentationData.chatBubbleCorners,
                                wallpaper: presentationData.chatWallpaper,
                                dateTimeFormat: environment.dateTimeFormat,
                                nameDisplayOrder: presentationData.nameDisplayOrder,
                                messageItems: [messageItem]
                            ),
                            params: listItemParams
                        ))),
                        AnyComponentWithIdentity(id: 1, component: AnyComponent(ListItemComponentAdaptor(
                            itemGenerator: PeerNameColorItem(
                                theme: environment.theme,
                                colors: component.context.peerNameColors,
                                isProfile: false,
                                currentColor: nameColor,
                                updated: { [weak self] value in
                                    guard let self else {
                                        return
                                    }
                                    self.updatedPeerNameColor = value
                                    self.state?.updated(transition: .spring(duration: 0.4))
                                },
                                sectionId: 0
                            ),
                            params: listItemParams
                        ))),
                        AnyComponentWithIdentity(id: 2, component: AnyComponent(ListActionItemComponent(
                            theme: environment.theme,
                            title: AnyComponent(HStack(replyLogoContents, spacing: 6.0)),
                            icon: AnyComponentWithIdentity(id: 0, component: AnyComponent(EmojiActionIconComponent(
                                context: component.context,
                                color: component.context.peerNameColors.get(nameColor, dark: environment.theme.overallDarkAppearance).main,
                                fileId: replyFileId,
                                file: replyFileId.flatMap { self.cachedIconFiles[$0] }
                            ))),
                            action: { [weak self] view in
                                guard let self, let contentsData = self.contentsData, let view = view as? ListActionItemComponent.View, let iconView = view.iconView else {
                                    return
                                }
                                
                                let nameColor: PeerNameColor
                                if let updatedPeerNameColor = self.updatedPeerNameColor {
                                    nameColor = updatedPeerNameColor
                                } else if let peerNameColor = peer.nameColor {
                                    nameColor = peerNameColor
                                } else {
                                    nameColor = .blue
                                }
                                
                                let currentFileId: Int64?
                                if case let .some(value) = self.updatedPeerNameEmoji {
                                    currentFileId = value
                                } else {
                                    currentFileId = contentsData.peer?.backgroundEmojiId
                                }
                                
                                self.openEmojiSetup(sourceView: iconView, currentFileId: currentFileId, color: component.context.peerNameColors.get(nameColor, dark: environment.theme.overallDarkAppearance).main, subject: .reply)
                            }
                        )))
                    ]
                )),
                environment: {},
                containerSize: CGSize(width: availableSize.width - sideInset * 2.0, height: 1000.0)
            )
            let replySectionFrame = CGRect(origin: CGPoint(x: sideInset, y: contentHeight), size: replySectionSize)
            if let replySectionView = self.replySection.view {
                if replySectionView.superview == nil {
                    self.scrollView.addSubview(replySectionView)
                }
                transition.setFrame(view: replySectionView, frame: replySectionFrame)
            }
            contentHeight += replySectionSize.height
            
            contentHeight += sectionSpacing
            
            if !chatThemes.isEmpty, let currentTheme {
                var wallpaperLogoContents: [AnyComponentWithIdentity<Empty>] = []
                wallpaperLogoContents.append(AnyComponentWithIdentity(id: 0, component: AnyComponent(MultilineTextComponent(
                    text: .plain(NSAttributedString(
                        string: "Channel Wallpaper", //TODO:localize
                        font: Font.regular(presentationData.listsFontSize.baseDisplaySize),
                        textColor: environment.theme.list.itemPrimaryTextColor
                    )),
                    maximumNumberOfLines: 0
                ))))
                if currentTheme != chatThemes[0], let boostStatus = self.boostStatus, boostStatus.level < themeLevel {
                    wallpaperLogoContents.append(AnyComponentWithIdentity(id: 1, component: AnyComponent(BoostLevelIconComponent(
                        strings: environment.strings,
                        level: themeLevel
                    ))))
                }
                
                let wallpaperSectionSize = self.wallpaperSection.update(
                    transition: transition,
                    component: AnyComponent(ListSectionComponent(
                        theme: environment.theme,
                        header: nil,
                        footer: AnyComponent(MultilineTextComponent(
                            text: .plain(NSAttributedString(
                                string: "Set a wallpaper that will be visible to everyone reading your channel.", //TODO:localize
                                font: Font.regular(presentationData.listsFontSize.itemListBaseHeaderFontSize),
                                textColor: environment.theme.list.freeTextColor
                            )),
                            maximumNumberOfLines: 0
                        )),
                        items: [
                            AnyComponentWithIdentity(id: 0, component: AnyComponent(ListItemComponentAdaptor(
                                itemGenerator: ThemeCarouselThemeItem(
                                    context: component.context,
                                    theme: environment.theme,
                                    strings: environment.strings,
                                    sectionId: 0,
                                    themes: chatThemes,
                                    animatedEmojiStickers: component.context.animatedEmojiStickers,
                                    themeSpecificAccentColors: [:],
                                    themeSpecificChatWallpapers: [:],
                                    nightMode: false,
                                    currentTheme: currentTheme,
                                    updatedTheme: { [weak self] value in
                                        guard let self else {
                                            return
                                        }
                                        self.currentTheme = value
                                        self.state?.updated(transition: .spring(duration: 0.4))
                                    },
                                    contextAction: nil
                                ),
                                params: listItemParams
                            ))),
                            AnyComponentWithIdentity(id: 1, component: AnyComponent(ListActionItemComponent(
                                theme: environment.theme,
                                title: AnyComponent(HStack(wallpaperLogoContents, spacing: 6.0)),
                                icon: nil,
                                action: { [weak self] view in
                                    guard let self else {
                                        return
                                    }
                                    let _ = self
                                }
                            )))
                        ]
                    )),
                    environment: {},
                    containerSize: CGSize(width: availableSize.width - sideInset * 2.0, height: 1000.0)
                )
                let wallpaperSectionFrame = CGRect(origin: CGPoint(x: sideInset, y: contentHeight), size: wallpaperSectionSize)
                if let wallpaperSectionView = self.wallpaperSection.view {
                    if wallpaperSectionView.superview == nil {
                        self.scrollView.addSubview(wallpaperSectionView)
                    }
                    transition.setFrame(view: wallpaperSectionView, frame: wallpaperSectionFrame)
                }
                contentHeight += wallpaperSectionSize.height
                contentHeight += sectionSpacing
            }
            
            var profileLogoContents: [AnyComponentWithIdentity<Empty>] = []
            profileLogoContents.append(AnyComponentWithIdentity(id: 0, component: AnyComponent(MultilineTextComponent(
                text: .plain(NSAttributedString(
                    string: "Profile Logo", //TODO:localize
                    font: Font.regular(presentationData.listsFontSize.baseDisplaySize),
                    textColor: environment.theme.list.itemPrimaryTextColor
                )),
                maximumNumberOfLines: 0
            ))))
            if backgroundFileId != nil, let boostStatus = self.boostStatus, boostStatus.level < profileIconLevel {
                profileLogoContents.append(AnyComponentWithIdentity(id: 1, component: AnyComponent(BoostLevelIconComponent(
                    strings: environment.strings,
                    level: profileIconLevel
                ))))
            }
            
            let bannerBackground: ListSectionComponent.Background
            if profileColor != nil {
                bannerBackground = .range(from: 1, corners: DynamicCornerRadiusView.Corners(minXMinY: 0.0, maxXMinY: 0.0, minXMaxY: 11.0, maxXMaxY: 11.0))
            } else {
                bannerBackground = .range(from: 1, corners: DynamicCornerRadiusView.Corners(minXMinY: 11.0, maxXMinY: 11.0, minXMaxY: 11.0, maxXMaxY: 11.0))
            }
            let bannerSectionSize = self.bannerSection.update(
                transition: transition,
                component: AnyComponent(ListSectionComponent(
                    theme: environment.theme,
                    background: bannerBackground,
                    header: AnyComponent(MultilineTextComponent(
                        text: .plain(NSAttributedString(
                            string: "PROFILE PAGE COLOR", //TODO:localize
                            font: Font.regular(presentationData.listsFontSize.itemListBaseHeaderFontSize),
                            textColor: environment.theme.list.freeTextColor
                        )),
                        maximumNumberOfLines: 0
                    )),
                    footer: AnyComponent(MultilineTextComponent(
                        text: .plain(NSAttributedString(
                            string: "Choose a color and a logo for the channel's profile.", //TODO:localize
                            font: Font.regular(presentationData.listsFontSize.itemListBaseHeaderFontSize),
                            textColor: environment.theme.list.freeTextColor
                        )),
                        maximumNumberOfLines: 0
                    )),
                    items: [
                        AnyComponentWithIdentity(id: 0, component: AnyComponent(ListItemComponentAdaptor(
                            itemGenerator: PeerNameColorProfilePreviewItem(
                                context: component.context,
                                theme: environment.theme,
                                componentTheme: environment.theme,
                                strings: environment.strings,
                                sectionId: 0,
                                peer: peer,
                                subtitleString: contentsData.subscriberCount.flatMap { environment.strings.Conversation_StatusSubscribers(Int32($0)) },
                                files: self.cachedIconFiles,
                                nameDisplayOrder: presentationData.nameDisplayOrder
                            ),
                            params: listItemParams
                        ))),
                        AnyComponentWithIdentity(id: 1, component: AnyComponent(ListItemComponentAdaptor(
                            itemGenerator: PeerNameColorItem(
                                theme: environment.theme,
                                colors: component.context.peerNameColors,
                                isProfile: true,
                                currentColor: profileColor,
                                updated: { [weak self] value in
                                    guard let self else {
                                        return
                                    }
                                    self.updatedPeerProfileColor = value
                                    self.state?.updated(transition: .spring(duration: 0.4))
                                },
                                sectionId: 0
                            ),
                            params: listItemParams
                        ))),
                        AnyComponentWithIdentity(id: 2, component: AnyComponent(ListActionItemComponent(
                            theme: environment.theme,
                            title: AnyComponent(HStack(profileLogoContents, spacing: 6.0)),
                            icon: AnyComponentWithIdentity(id: 0, component: AnyComponent(EmojiActionIconComponent(
                                context: component.context,
                                color: profileColor.flatMap { profileColor in
                                    component.context.peerNameColors.getProfile(profileColor, dark: environment.theme.overallDarkAppearance, subject: .palette).main
                                } ?? environment.theme.list.itemAccentColor,
                                fileId: backgroundFileId,
                                file: backgroundFileId.flatMap { self.cachedIconFiles[$0] }
                            ))),
                            action: { [weak self] view in
                                guard let self, let contentsData = self.contentsData, let view = view as? ListActionItemComponent.View, let iconView = view.iconView else {
                                    return
                                }
                                
                                let currentFileId: Int64?
                                if case let .some(value) = self.updatedPeerProfileEmoji {
                                    currentFileId = value
                                } else {
                                    currentFileId = contentsData.peer?.profileBackgroundEmojiId
                                }
                                
                                let profileColor: PeerNameColor?
                                if case let .some(value) = self.updatedPeerProfileColor {
                                    profileColor = value
                                } else if let peerProfileColor = peer.profileColor {
                                    profileColor = peerProfileColor
                                } else {
                                    profileColor = nil
                                }
                                
                                self.openEmojiSetup(sourceView: iconView, currentFileId: currentFileId, color: profileColor.flatMap { profileColor in
                                    component.context.peerNameColors.getProfile(profileColor, dark: environment.theme.overallDarkAppearance, subject: .palette).main
                                } ?? environment.theme.list.itemAccentColor, subject: .profile)
                            }
                        )))
                    ]
                )),
                environment: {},
                containerSize: CGSize(width: availableSize.width - sideInset * 2.0, height: 1000.0)
            )
            let bannerSectionFrame = CGRect(origin: CGPoint(x: sideInset, y: contentHeight), size: bannerSectionSize)
            if let bannerSectionView = self.bannerSection.view {
                if bannerSectionView.superview == nil {
                    self.scrollView.addSubview(bannerSectionView)
                }
                transition.setFrame(view: bannerSectionView, frame: bannerSectionFrame)
            }
            contentHeight += bannerSectionSize.height
            contentHeight += sectionSpacing
            
            var emojiStatusContents: [AnyComponentWithIdentity<Empty>] = []
            emojiStatusContents.append(AnyComponentWithIdentity(id: 0, component: AnyComponent(MultilineTextComponent(
                text: .plain(NSAttributedString(
                    string: "Channel Emoji Status", //TODO:localize
                    font: Font.regular(presentationData.listsFontSize.baseDisplaySize),
                    textColor: environment.theme.list.itemPrimaryTextColor
                )),
                maximumNumberOfLines: 0
            ))))
            if emojiStatus != nil, let boostStatus = self.boostStatus, boostStatus.level < emojiStatusLevel {
                emojiStatusContents.append(AnyComponentWithIdentity(id: 1, component: AnyComponent(BoostLevelIconComponent(
                    strings: environment.strings,
                    level: emojiStatusLevel
                ))))
            }
            
            let resetColorSectionSize = self.resetColorSection.update(
                transition: transition,
                component: AnyComponent(ListSectionComponent(
                    theme: environment.theme,
                    header: nil,
                    footer: nil,
                    items: [
                        AnyComponentWithIdentity(id: 0, component: AnyComponent(ListActionItemComponent(
                            theme: environment.theme,
                            title: AnyComponent(MultilineTextComponent(
                                text: .plain(NSAttributedString(
                                    string: "Reset Profile Color", //TODO:localize
                                    font: Font.regular(presentationData.listsFontSize.baseDisplaySize),
                                    textColor: environment.theme.list.itemAccentColor
                                )),
                                maximumNumberOfLines: 0
                            )),
                            icon: nil,
                            hasArrow: false,
                            action: { [weak self] view in
                                guard let self else {
                                    return
                                }
                                
                                self.updatedPeerProfileColor = .some(nil)
                                self.updatedPeerProfileEmoji = .some(nil)
                                self.state?.updated(transition: .spring(duration: 0.4))
                            }
                        )))
                    ]
                )),
                environment: {},
                containerSize: CGSize(width: availableSize.width - sideInset * 2.0, height: 1000.0)
            )
            
            let displayResetProfileColor = profileColor != nil || backgroundFileId != nil
            
            let resetColorSectionFrame = CGRect(origin: CGPoint(x: sideInset, y: contentHeight), size: resetColorSectionSize)
            if let resetColorSectionView = self.resetColorSection.view {
                if resetColorSectionView.superview == nil {
                    self.scrollView.addSubview(resetColorSectionView)
                }
                transition.setPosition(view: resetColorSectionView, position: resetColorSectionFrame.center)
                transition.setBounds(view: resetColorSectionView, bounds: CGRect(origin: CGPoint(), size: resetColorSectionFrame.size))
                transition.setScale(view: resetColorSectionView, scale: displayResetProfileColor ? 1.0 : 0.001)
                transition.setAlpha(view: resetColorSectionView, alpha: displayResetProfileColor ? 1.0 : 0.0)
            }
            if displayResetProfileColor {
                contentHeight += resetColorSectionSize.height
                contentHeight += sectionSpacing
            }
            
            let emojiStatusSectionSize = self.emojiStatusSection.update(
                transition: transition,
                component: AnyComponent(ListSectionComponent(
                    theme: environment.theme,
                    header: nil,
                    footer: AnyComponent(MultilineTextComponent(
                        text: .plain(NSAttributedString(
                            string: "Choose a status that will be shown next to the channel's name.", //TODO:localize
                            font: Font.regular(presentationData.listsFontSize.itemListBaseHeaderFontSize),
                            textColor: environment.theme.list.freeTextColor
                        )),
                        maximumNumberOfLines: 0
                    )),
                    items: [
                        AnyComponentWithIdentity(id: 0, component: AnyComponent(ListActionItemComponent(
                            theme: environment.theme,
                            title: AnyComponent(HStack(emojiStatusContents, spacing: 6.0)),
                            icon: AnyComponentWithIdentity(id: 0, component: AnyComponent(EmojiActionIconComponent(
                                context: component.context,
                                color: environment.theme.list.itemAccentColor,
                                fileId: statusFileId,
                                file: statusFileId.flatMap { self.cachedIconFiles[$0] }
                            ))),
                            action: { [weak self] view in
                                guard let self, let contentsData = self.contentsData, let view = view as? ListActionItemComponent.View, let iconView = view.iconView else {
                                    return
                                }
                                
                                let currentFileId: Int64?
                                if case let .some(value) = self.updatedPeerStatusEmoji {
                                    currentFileId = value
                                } else {
                                    currentFileId = contentsData.peer?.emojiStatus?.fileId
                                }
                                
                                self.openEmojiSetup(sourceView: iconView, currentFileId: currentFileId, color: nil, subject: .status)
                            }
                        )))
                    ]
                )),
                environment: {},
                containerSize: CGSize(width: availableSize.width - sideInset * 2.0, height: 1000.0)
            )
            let emojiStatusSectionFrame = CGRect(origin: CGPoint(x: sideInset, y: contentHeight), size: emojiStatusSectionSize)
            if let emojiStatusSectionView = self.emojiStatusSection.view {
                if emojiStatusSectionView.superview == nil {
                    self.scrollView.addSubview(emojiStatusSectionView)
                }
                transition.setFrame(view: emojiStatusSectionView, frame: emojiStatusSectionFrame)
            }
            contentHeight += emojiStatusSectionSize.height
            
            contentHeight += bottomContentInset
            
            var buttonContents: [AnyComponentWithIdentity<Empty>] = []
            //TODO:localize
            buttonContents.append(AnyComponentWithIdentity(id: AnyHashable(0 as Int), component: AnyComponent(
                Text(text: "Apply Changes", font: Font.semibold(17.0), color: environment.theme.list.itemCheckColors.foregroundColor)
            )))
            
            if let boostStatus = self.boostStatus, requiredLevel > boostStatus.level {
                buttonContents.append(AnyComponentWithIdentity(id: AnyHashable(1 as Int), component: AnyComponent(PremiumLockButtonSubtitleComponent(
                    count: requiredLevel,
                    theme: environment.theme,
                    strings: environment.strings
                ))))
            }
            
            let buttonSize = self.actionButton.update(
                transition: transition,
                component: AnyComponent(ButtonComponent(
                    background: ButtonComponent.Background(
                        color: environment.theme.list.itemCheckColors.fillColor,
                        foreground: environment.theme.list.itemCheckColors.foregroundColor,
                        pressedColor: environment.theme.list.itemCheckColors.fillColor.withMultipliedAlpha(0.8)
                    ),
                    content: AnyComponentWithIdentity(id: AnyHashable(0 as Int), component: AnyComponent(
                        VStack(buttonContents, spacing: 3.0)
                    )),
                    isEnabled: true,
                    tintWhenDisabled: false,
                    displaysProgress: self.isApplyingSettings,
                    action: { [weak self] in
                        guard let self else {
                            return
                        }
                        self.applySettings()
                    }
                )),
                environment: {},
                containerSize: CGSize(width: availableSize.width - sideInset * 2.0, height: 50.0)
            )
            contentHeight += buttonSize.height
            
            contentHeight += bottomInset
            contentHeight += environment.safeInsets.bottom
            
            let buttonY = availableSize.height - bottomInset - environment.safeInsets.bottom - buttonSize.height
            
            let buttonFrame = CGRect(origin: CGPoint(x: sideInset, y: buttonY), size: buttonSize)
            if let buttonView = self.actionButton.view {
                if buttonView.superview == nil {
                    self.addSubview(buttonView)
                }
                transition.setFrame(view: buttonView, frame: buttonFrame)
                transition.setAlpha(view: buttonView, alpha: 1.0)
            }
            
            let bottomPanelFrame = CGRect(origin: CGPoint(x: 0.0, y: buttonY - 8.0), size: CGSize(width: availableSize.width, height: availableSize.height - buttonY + 8.0))
            transition.setFrame(view: self.bottomPanelBackgroundView, frame: bottomPanelFrame)
            self.bottomPanelBackgroundView.updateColor(color: environment.theme.rootController.navigationBar.blurredBackgroundColor, transition: .immediate)
            self.bottomPanelBackgroundView.update(size: bottomPanelFrame.size, transition: transition.containedViewLayoutTransition)
            
            self.bottomPanelSeparator.backgroundColor = environment.theme.rootController.navigationBar.separatorColor.cgColor
            transition.setFrame(layer: self.bottomPanelSeparator, frame: CGRect(origin: CGPoint(x: bottomPanelFrame.minX, y: bottomPanelFrame.minY), size: CGSize(width: bottomPanelFrame.width, height: UIScreenPixel)))
            
            let contentSize = CGSize(width: availableSize.width, height: contentHeight)
            if self.scrollView.frame != CGRect(origin: CGPoint(), size: availableSize) {
                self.scrollView.frame = CGRect(origin: CGPoint(), size: availableSize)
            }
            if self.scrollView.contentSize != contentSize {
                self.scrollView.contentSize = contentSize
            }
            let scrollInsets = UIEdgeInsets(top: environment.navigationHeight, left: 0.0, bottom: availableSize.height - bottomPanelFrame.minY, right: 0.0)
            if self.scrollView.scrollIndicatorInsets != scrollInsets {
                self.scrollView.scrollIndicatorInsets = scrollInsets
            }
            
            self.updateScrolling(transition: transition)
            
            return availableSize
        }
    }
    
    func makeView() -> View {
        return View()
    }
    
    func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<EnvironmentType>, transition: Transition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}

public class ChannelAppearanceScreen: ViewControllerComponentContainer {
    private let context: AccountContext
    
    private var didSetReady: Bool = false
    
    public init(
        context: AccountContext,
        updatedPresentationData: (initial: PresentationData, signal: Signal<PresentationData, NoError>)?,
        peerId: EnginePeer.Id
    ) {
        self.context = context
        
        super.init(context: context, component: ChannelAppearanceScreenComponent(
            context: context,
            peerId: peerId
        ), navigationBarAppearance: .default, theme: .default, updatedPresentationData: updatedPresentationData)
        
        //TODO:localize
        self.title = "Appearance"
        
        self.ready.set(.never())
        
        self.scrollToTop = { [weak self] in
            guard let self, let componentView = self.node.hostView.componentView as? ChannelAppearanceScreenComponent.View else {
                return
            }
            componentView.scrollToTop()
        }
        
        self.attemptNavigation = { [weak self] complete in
            guard let self, let componentView = self.node.hostView.componentView as? ChannelAppearanceScreenComponent.View else {
                return true
            }
            
            return componentView.attemptNavigation(complete: complete)
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    @objc private func cancelPressed() {
        self.dismiss()
    }
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        if let componentView = self.node.hostView.componentView as? ChannelAppearanceScreenComponent.View {
            if !self.didSetReady {
                self.didSetReady = true
                self.ready.set(componentView.isReady.get())
            }
        }
    }
}