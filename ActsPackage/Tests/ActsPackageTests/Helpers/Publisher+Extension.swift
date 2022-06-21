import AsyncAlgorithms
import Combine

var cancellables: [AnyCancellable] = []

extension Publisher where Failure == Never {
    func iterator() -> AsyncChannel<Output>.Iterator {
        let channel: AsyncChannel<Output> = .init()

        dropFirst().sink { value in
            let _ = Task {
                await channel.send(value)
            }
        }
        .store(in: &cancellables)

        return channel.makeAsyncIterator()
    }
}
