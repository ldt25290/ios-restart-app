
final class DropdownSection {
    private let header: DropdownCellRepresentable
    private let items: [DropdownCellRepresentable]
    var isExpanded: Bool
    var isShowingAll: Bool
    
    init(withHeader header: DropdownCellRepresentable,
         items: [DropdownCellRepresentable],
         isExpanded: Bool,
         isShowingAll: Bool) {
        self.header = header
        self.items = items
        self.isExpanded = isExpanded
        self.isShowingAll = isShowingAll
    }
    
    private var selectedItemCount: Int {
        return items.filter({ $0.state == .selected }).count
    }
    
    private var allItems: [DropdownCellRepresentable] {
        return [header] + items
    }
    
    private var allHighlightedItems: [DropdownCellRepresentable] {
        return [header] + items.filter({ $0.isHighlighted })
    }
    
    private var visibleItems: [DropdownCellRepresentable] {
        if isExpanded {
            return isShowingAll ? allItems : allHighlightedItems
        }
        return [header]
    }
    
    var sectionId: String {
        return header.content.id
    }
    
    var count: Int {
        return visibleItems.count
    }
    
    var selectedItems: DropdownSelectedItems? {
        guard header.state == .selected || header.state == .semiSelected else { return nil }
        let selectedItemIds = items.filter({ $0.state == .selected }).map({ $0.content.id })
        return (header.content.id, selectedItemIds)
    }
    
    func item(forIndex index: Int) -> DropdownCellRepresentable? {
        
        if index == 0 {
            return header
        }
        
        return items[safeAt: index-1]
    }
    
    func updateState(state: DropdownCellState,
                     forItemId itemId: String) {
        allItems.filter({ $0.content.id == itemId }).first?.update(withState: state)
        refreshHeaderState()
    }

    private func updateAllItems(toState state: DropdownCellState) {
        allItems.forEach( { $0.update(withState: state) } )
    }
    
    private func updateHeader(toState state: DropdownCellState) {
        header.update(withState: state)
    }
    
    func absorb(ids: [String]) {
        allItems.forEach { (item) in
            if ids.contains(item.content.id) {
                item.update(withState: .selected)
            }
        }
        
        refreshHeaderState()
    }
    
    private func refreshHeaderState() {
        switch selectedItemCount {
        case 0:
            updateHeader(toState: .deselected)
        case items.count:
            updateHeader(toState: .selected)
        default:
            updateHeader(toState: .semiSelected)
        }
    }
}


// MARK: Selection and Deselection

extension DropdownSection {
    
    func deselectAllItems() {
        updateAllItems(toState: .deselected)
    }
    
    func selectAllItems() {
        updateAllItems(toState: .selected)
    }
}


// MARK: Handle expansion and contraction of sections

extension DropdownSection {
    
    func toggleExpansionState(forId id: String) {
        guard header.content.id == id else { return }
        isExpanded = !isExpanded
        
        if !isExpanded {
            isShowingAll = false
        }
    }
}

extension Collection where Element == DropdownSection {
    
    var selectedSectionItems: DropdownSelectedItems? {
        return first(where: { $0.selectedItems != nil })?.selectedItems
    }
    
    func toggleExpansionState(forId id: String) {
        forEach { $0.toggleExpansionState(forId: id) }
    }
    
    func expansionState(forId id: String) -> Bool {
        return filter( { $0.sectionId == id }).first?.isExpanded ?? false
    }
}


// MARK: DropdownSection Collection selection and deselection

extension Collection where Element == DropdownSection {
    
    func selectSection(withHeaderId id: String) {
        forEach { section in
            if section.sectionId == id {
                section.selectAllItems()
            } else {
                section.deselectAllItems()
            }
        }
    }
    
    func deselectSection(withHeaderId id: String) {
        deselectAllItems()
    }
    
    func selectItem(withItemId id: String,
                    inSection section: DropdownSection) {
        forEach({
            if $0.sectionId != section.sectionId {
                $0.deselectAllItems()
            }
        })
        updateState(state: .selected, forItemId: id)
    }
    
    func deselectItem(withItemId id: String) {
        updateState(state: .deselected, forItemId: id)
    }
    
    func deselectAllItems() {
        forEach( { $0.deselectAllItems() } )
    }
    
    private func updateState(state: DropdownCellState,
                             forItemId itemId: String) {
        forEach { $0.updateState(state: state, forItemId: itemId) }
    }
}
