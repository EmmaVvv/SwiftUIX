//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A proxy value allowing the collection views within a view hierarchy to be manipulated programmatically.
public struct CollectionViewProxy {
    private let _hostingCollectionViewController: WeakReferenceBox<AnyObject>
    
    var hostingCollectionViewController: _opaque_UIHostingCollectionViewController? {
        get {
            _hostingCollectionViewController.value as? _opaque_UIHostingCollectionViewController
        } set {
            _hostingCollectionViewController.value = newValue
        }
    }
    
    public var contentSize: CGSize {
        hostingCollectionViewController?.collectionViewContentSize ?? .zero
    }
    
    public var maximumCellSize: OptionalDimensions {
        hostingCollectionViewController?.maximumCollectionViewCellSize ?? nil
    }
    
    init(_ base: _opaque_UIHostingCollectionViewController? = nil) {
        self._hostingCollectionViewController = .init(base)
    }
    
    public func scrollToTop(anchor: UnitPoint? = nil, animated: Bool = true) {
        _assertResolutionOfCollectionView()
        
        hostingCollectionViewController?.scrollToTop(anchor: anchor, animated: animated)
    }
    
    public func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        _assertResolutionOfCollectionView()
        
        hostingCollectionViewController?.scrollTo(id, anchor: anchor)
    }
    
    public func selection<ID: Hashable>(for id: ID) -> Binding<Bool> {
        _assertResolutionOfCollectionView()
        
        return hostingCollectionViewController?.selection(for: id) ?? .constant(false)
    }
    
    public func select<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        _assertResolutionOfCollectionView()
        
        hostingCollectionViewController?.select(id, anchor: anchor)
    }
    
    public func selectNextItem(anchor: UnitPoint? = nil) {
        _assertResolutionOfCollectionView()
        
        hostingCollectionViewController?.selectNextItem(anchor: anchor)
    }
    
    public func selectPreviousItem(anchor: UnitPoint? = nil) {
        _assertResolutionOfCollectionView()
        
        hostingCollectionViewController?.selectPreviousItem(anchor: anchor)
    }
    
    public func deselect<ID: Hashable>(_ id: ID) {
        _assertResolutionOfCollectionView()
        
        hostingCollectionViewController?.deselect(id)
    }
    
    private func _assertResolutionOfCollectionView() {
        // assert(hostingCollectionViewController != nil, "CollectionViewProxy couldn't resolve a collection view")
    }
}

/// A view whose child is defined as a function of a `CollectionViewProxy` targeting the collection views within the child.
public struct CollectionViewReader<Content: View>: View {
    @Environment(\._collectionViewProxy) var _environment_collectionViewProxy
    
    public let content: (CollectionViewProxy) -> Content
    
    @State var _collectionViewProxy = CollectionViewProxy()
    
    public init(
        @ViewBuilder content: @escaping (CollectionViewProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(_environment_collectionViewProxy?.wrappedValue ?? _collectionViewProxy)
            .environment(\._collectionViewProxy, $_collectionViewProxy)
    }
}

// MARK: - Auxiliary Implementation -

extension CollectionViewProxy {
    fileprivate struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue: Binding<CollectionViewProxy>? = nil
    }
}

extension EnvironmentValues {
    @usableFromInline
    var _collectionViewProxy: Binding<CollectionViewProxy>? {
        get {
            self[CollectionViewProxy.EnvironmentKey]
        } set {
            self[CollectionViewProxy.EnvironmentKey] = newValue
        }
    }
}

#endif
