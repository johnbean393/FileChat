//
//  IndexList.swift
//  FileChat
//
//  Created by Bean John on 3/6/2024.
//

import ExtensionKit
import SwiftUI

struct IndexPicker: View {
	
	@Binding var selectedDir: IndexedDirectory?
	
	var body: some View {
		VStack(spacing: 0) {
			IndexList(selectedDir: $selectedDir)
			IndexListToolbar(selectedDir: $selectedDir)
		}
		.border(Color(NSColor.gridColor), width: 1)
		.onAppear {
			selectedDir = IndexStore.shared.selectedDirectory
		}
	}
}

struct IndexList: View {
	
	@EnvironmentObject private var indexStore: IndexStore
	@Binding var selectedDir: IndexedDirectory?
	
	var body: some View {
		List(indexStore.values, selection: $selectedDir) { indexedDir in
			IndexListRow(indexedDir: indexedDir)
		}
	}
}

struct IndexListRow: View {
	
	var indexedDir: IndexedDirectory
	
	var body: some View {
		Text(indexedDir.url.lastPathComponent)
			.tag(indexedDir)
			.help(indexedDir.url.posixPath())
			.contextMenu {
				Button("Show in Finder") {
					NSWorkspace.shared.activateFileViewerSelecting([indexedDir.url])
				}
				Button("Show Index in Finder") {
					indexedDir.showIndexDirectory()
				}
				Button("Update Index") {
					Task {
						await IndexStore.shared.updateIndex()
					}
				}
			}
	}
}

struct IndexListToolbar: View {
	
	@Binding var selectedDir: IndexedDirectory?
	
	var body: some View {
		HStack(spacing: 0) {
			IndexListButton(selectedDir: $selectedDir, imageName: "plus")
			Divider()
			IndexListButton(selectedDir: $selectedDir, imageName: "minus")
			Divider()
			Spacer()
		}
		.frame(height: 20)
	}
	
}

struct IndexListButton: View {
	
	@EnvironmentObject private var indexStore: IndexStore
	@Binding var selectedDir: IndexedDirectory?
	
	var imageName: String
	
	var body: some View {
		Button(imageName == "plus" ? "+" : "-") {
			Task {
				if imageName == "plus" {
					var url: URL? = nil
					repeat {
						url = try FileSystemTools.openPanel(
							url: URL.desktopDirectory,
							files: false,
							folders: true,
							dialogTitle: "Select a directory"
						)
						IndexStore.shared.addIndexedDirectory(url: url!)
					} while url == nil
				} else {
					if selectedDir != nil {
						IndexStore.shared.removeIndex(indexedDir: selectedDir!)
					}
				}
			}
		}
		.buttonStyle(BorderlessButtonStyle())
		.frame(width: 20, height: 20)
	}
}
