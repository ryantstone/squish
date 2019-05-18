import Cocoa

class FileTableView: NSTableView {
    var fileData: FileData!


    let pasteBoardType = NSPasteboard.PasteboardType("fileData.file")
    let cellIdentifier = NSUserInterfaceItemIdentifier("cell")

    public func configure(_ fileData: FileData) {
        self.fileData   = fileData
        delegate        = self
        dataSource      = self
        registerForDraggedTypes([pasteBoardType])
    }

    private func saveFileToPasteboard(_ file: URL) -> NSPasteboardItem {
        let pastBoarditem = NSPasteboardItem()
        pastBoarditem.setString(file.path, forType: pasteBoardType)
        return pastBoarditem
    }
}

extension FileTableView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fileData.files.count
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let file = fileData.files[row]
        return saveFileToPasteboard(file)
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        } else {
            return []
        }
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard
            let item             = info.draggingPasteboard.pasteboardItems?.first,
            let fileString       = item.string(forType: pasteBoardType),
            let file             = fileData.files.first(where: { $0.path == fileString }),
            let originalRowIndex = fileData.files.firstIndex(of: file) else { return false }

        var newRowIndex = originalRowIndex < row ? row - 1 : row

        tableView.beginUpdates()
        tableView.moveRow(at: originalRowIndex, to: newRowIndex)
        tableView.endUpdates()

        fileData.moveFile(from: originalRowIndex, to: newRowIndex)

        return true
    }
}

extension FileTableView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < fileData.files.count else { return nil }
        let file = fileData.files[row]

        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = file.lastPathComponent
            return cell
        }
        return nil
    }
}
