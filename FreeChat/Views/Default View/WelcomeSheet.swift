//
//  WelcomeSheet.swift
//  FileChat
//
//  Created by Peter Sugihara on 9/28/23.
//

import SwiftUI

struct WelcomeSheet: View {
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Model.size, ascending: false)]
  )
  private var models: FetchedResults<Model>
  
  @Binding var isPresented: Bool
  @State var showModels = false
  
  @Environment(\.managedObjectContext) private var viewContext
  @AppStorage("selectedModelId") private var selectedModelId: String?

  @StateObject var downloadManager = DownloadManager.shared
  
  
  var body: some View {
    VStack {
      if models.count == 0 {
        Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
        Text("Welcome to FileChat").font(.largeTitle)

        Text("Download a model to get started")
          .font(.title3)
        Text("FileChat runs AI locally on your Mac for maximum privacy and security. You can chat with different AI models, which vary in terms of training data and knowledge base.\n\nThe default model is general purpose, small, and works on most computers. Larger models are slower but wiser. Some models specialize in certain tasks like coding Python. FileChat is compatible with most models in the GGUF format. [Find new models](https://huggingface.co/models?search=GGUF)")
          .font(.callout)
          .lineLimit(10)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.vertical, 16)
        
        ForEach(downloadManager.tasks, id: \.self) { t in
          ProgressView(t.progress).padding(5)
        }
      } else {
        Image(systemName: "checkmark.circle.fill")
          .resizable()
          .frame(width: 60, height: 60)
          .foregroundColor(.green)
          .imageScale(.large)
        
        Text("Success!").font(.largeTitle)

        Text("The model was installed.")
          .font(.title3)
        
        Button("Continue") {
          isPresented = false
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.top, 16)
        .padding(.horizontal, 40)
        .keyboardShortcut(.defaultAction)
      }

      if models.count == 0, downloadManager.tasks.count == 0 {
        Button(action: downloadDefault) {
          HStack {
            Text("Download default model")
            Text("6.6 GB").foregroundStyle(.white.opacity(0.7))
          }.padding(.horizontal, 20)
        }
        .keyboardShortcut(.defaultAction)
        .controlSize(.large)
        .padding(.top, 6)
        .padding(.horizontal)
        
        Button("Load custom model") {
          showModels = true
        }.buttonStyle(.link)
          .padding(.top, 4)
          .font(.callout)
      } else {

      }
    }
    .interactiveDismissDisabled()
    .frame(maxWidth: 480)
    .padding(.vertical, 40)
    .padding(.horizontal, 60)
    .sheet(isPresented: $showModels) {
      EditModels(selectedModelId: $selectedModelId)
    }
  }
  
  private func downloadDefault() {
    downloadManager.viewContext = viewContext
    downloadManager.startDownload(url: Model.defaultModelUrl)
  }
}
