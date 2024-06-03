//
//  IndexedItem.swift
//  FileChat
//
//  Created by Bean John on 30/5/2024.
//

import Foundation
import ExtensionKit
import SimilaritySearchKit
import SimilaritySearchKitDistilbert

extension IndexedDirectory {
	
	/// Declare IndexItem nested struct
	public struct IndexItem: Codable, Identifiable {
		
		public var id: UUID = UUID()
		
		/// Location of the original file
		public var url: URL
		/// Name of the original file
		public var name: String {
			return url.lastPathComponent
		}
		/// Returns false if the file is still at its last recorded path
		public var wasMoved: Bool {
			return !url.fileExists()
		}
		
		/// Function to create directory that houses the JSON file
		public func createDirectory(parentDirUrl: URL) {
			try! FileManager.default.createDirectory(at: parentDirUrl
				.appendingPathComponent("\(id.uuidString)"), withIntermediateDirectories: true)
		}
		
		/// Function to get URL of index items JSON file's parent directory
		private func getIndexDirUrl(parentDirUrl: URL) -> URL {
			return parentDirUrl
				.appendingPathComponent("\(id.uuidString)")
		}
		
		/// Function to get URL of index items JSON file
		private func getIndexUrl(parentDirUrl: URL) -> URL {
			return getIndexDirUrl(parentDirUrl: parentDirUrl)
				.appendingPathComponent("\(id.uuidString).json")
		}
		
		/// Function that returns index items in JSON file
		public func getIndexItems(parentDirUrl: URL) async -> [SimilarityIndex.IndexItem] {
			// Init index
			let similarityIndex: SimilarityIndex = await SimilarityIndex(
				model: DistilbertEmbeddings(),
				metric: DotProduct()
			)
			// Get index directory url
			let indexUrl: URL = getIndexUrl(parentDirUrl: parentDirUrl).deletingLastPathComponent()
			// Load index items
			let indexItems: [SimilarityIndex.IndexItem] = (
				try? similarityIndex.loadIndex(fromDirectory: indexUrl) ?? []
			) ?? []
			// Return index
			return indexItems
		}
		
		/// Function that saves a similarity index
		private func saveIndex(parentDirUrl: URL, similarityIndex: SimilarityIndex) {
			let _ = try! similarityIndex.saveIndex(toDirectory: getIndexDirUrl(parentDirUrl: parentDirUrl))
		}
		
		/// Function that re-scans the file, then saves the updated similarity index
		public mutating func updateIndex(parentDirUrl: URL) async {
			// Switch flag
			indexState.startIndex()
			// Extract text from file
			let fileText: String = await (try? TextExtractor.extractText(url: url)) ?? ""
			// Split text
			let splitTexts: [String] = fileText.split(every: 512)
			// Init new similarity index
			let similarityIndex: SimilarityIndex = await SimilarityIndex(
				model: DistilbertEmbeddings(),
				metric: DotProduct()
			)
			// Add texts to index
			for (index, splitText) in splitTexts.enumerated() {
				let indexItemId: String = "\(id.uuidString)_\(index)"
				let filename: String = url.lastPathComponent
				async let _ = similarityIndex.addItem(
					id: indexItemId,
					text: splitText,
					metadata: ["Source": "\(filename)"]
				)
			}
			// Save index
			saveIndex(parentDirUrl: parentDirUrl, similarityIndex: similarityIndex)
			// Switch flag
			indexState.finishIndex()
		}
		
		/// The current indexing state, used to prevent duplicate indexes
		public var indexState: IndexState = .noIndex
		
		public enum IndexState: CaseIterable, Codable {
			
			case noIndex, indexing, indexed
			
			// Functions to toggle state
			mutating func startIndex() {
				self = .indexing
			}
			mutating func finishIndex() {
				self = .indexed
			}
			
		}
		
	}
	
}
