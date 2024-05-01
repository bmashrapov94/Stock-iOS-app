import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = ContentViewViewModel()
    @State private var showNotePopover = false
    @State private var currentNote = ""
    @State private var editingStockEntity: StockEntity?

    var body: some View {
        NavigationView {
            List {
                HStack {
                    TextField("Enter Stock Symbol", text: $viewModel.symbol)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Add") {
                        viewModel.addStock()
                    }
                    .padding(.trailing, 10)
                }

                ForEach(viewModel.stockEntities, id: \.self) { stockEntity in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(stockEntity.symbol ?? "Unknown Symbol")
                                .font(.headline)
                            Spacer()
                            Button("Add Note") {
                                self.editingStockEntity = stockEntity
                                self.currentNote = stockEntity.note ?? ""
                                self.showNotePopover = true
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .frame(width: 100, height: 30)
                        }
                        if let note = stockEntity.note, !note.isEmpty {
                            Text(note)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        if let stockData = viewModel.stockData.first(where: { $0.metaData.symbol == stockEntity.symbol }) {
                            HStack {
                                // Assuming you have a LineChart view
                                LineChart(values: stockData.closeValues.map { CGFloat($0) })
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2))
                                    .frame(height: 100)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Latest Close: \(stockData.latestClose)")
                                    Text("Change: \(stockData.change)")
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: { indices in
                    viewModel.deleteStock(at: indices)
                })
            }
            .navigationTitle("My Stocks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        }
        .popover(isPresented: $showNotePopover) {
            NotePopover(noteText: $currentNote, onSave: {
                if let stockEntity = self.editingStockEntity {
                    // Assuming updateNoteForStock exists in ContentViewViewModel
                    viewModel.updateNoteForStock(stockEntity: stockEntity, newNote: currentNote)
                }
                showNotePopover = false
            }, onCancel: {
                showNotePopover = false
            })
        }
    }
}

struct NotePopover: View {
    @Binding var noteText: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add Note")
                .font(.headline)
                .padding()

            TextEditor(text: $noteText)
                .border(Color.gray, width: 1)
                .padding()

            HStack {
                Button("Save") {
                    onSave()
                }
                .padding()

                Button("Cancel") {
                    onCancel()
                }
                .padding()
            }
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

