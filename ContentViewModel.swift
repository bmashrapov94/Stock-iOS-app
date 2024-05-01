//
//  ContentViewViewModel.swift
//  StocksApp
//
//  Created by Bek Mashrapov on 2024-04-22.
//
import Foundation
import Combine
import CoreData

final class ContentViewViewModel: ObservableObject {
    private var context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    @Published var symbolValid = false
    @Published var stockData: [StockData] = []
    @Published var symbol: String = ""
    @Published var stockEntities: [StockEntity] = []

    init() {
        self.context = PersistenceController.shared.container.viewContext
        loadFromCoreData()
        loadAllStockData()
    }

    func validateSymbolField() {
        $symbol
            .dropFirst()
            .sink { [unowned self] newValue in
                self.symbolValid = !newValue.isEmpty
            }
            .store(in: &cancellables)
    }

    func loadFromCoreData() {
        let request: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        do {
            stockEntities = try context.fetch(request)
        } catch {
            print("Failed to fetch stock entities: \(error)")
        }
    }

    func addStock() {
        let newStock = StockEntity(context: context)
        newStock.symbol = symbol
        do {
            try context.save()
            stockEntities.append(newStock)
            fetchStockData(for: symbol)
            symbol = ""
        } catch {
            print("Failed to save new stock: \(error)")
        }
    }

    func deleteStock(at offsets: IndexSet) {
        offsets.forEach { index in
            let entity = stockEntities[index]
            context.delete(entity)
        }
        stockEntities.remove(atOffsets: offsets)
    }

    func loadAllStockData() {
        stockData.removeAll()
        stockEntities.forEach { stockEntity in
            fetchStockData(for: stockEntity.symbol ?? "")
        }
    }

    func fetchStockData(for symbol: String) {
        let apiKey = APIKEY.alphavantage
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=5min&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL for symbol: \(symbol)")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: StockData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching data for \(symbol): \(error)")
                }
            }, receiveValue: { [weak self] newStockData in
                self?.stockData.append(newStockData)
            })
            .store(in: &cancellables)
    }
    
    func updateNoteForStock(stockEntity: StockEntity, newNote: String) {
        // Update the note for the provided stockEntity
        stockEntity.note = newNote
        
        // Save the changes to Core Data context
        do {
            try context.save()
        } catch {
            print("Failed to update note for stock: \(error)")
        }
    }
}
