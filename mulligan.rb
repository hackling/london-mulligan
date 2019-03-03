require 'thread/pool'
require 'irb'
def new_deck
  (['Bazaar'] * 4) + (['Powder'] * 4) + (['Card'] * 52)
end

MAX_GAMES = 500_000
# MAX_GAMES = 10

games_run = 0
success = 0
threads = []
pool = Thread.pool(10)

begin
  # puts "--- NEW GAME ---"
  pool.process do
    exile = []
    mulligans = 6
    deck = new_deck

    begin
      # puts "Cards in Deck: #{deck.count}"
      # puts "Drawing #{mulligans+1} Cards"
      hand = deck.shuffle!.slice!(0..mulligans)

      case
      when hand.include?('Bazaar')
        # puts "Found Bazaar"
        success += 1
        break
      when hand.include?('Powder')
        # puts "Found Powder"
        exile << hand
      else
        # puts "Found Nothing"
        deck = deck + hand
        mulligans -= 1
      end
    end while mulligans > 0
    # puts "These cards were exiled:"
    # puts exile
    # puts "Final hand was:"
    # puts hand

  end
games_run += 1
end while games_run < MAX_GAMES
pool.shutdown
puts "Games Run: #{games_run}"
puts "Found Bazaar: #{(1.0 * success)/games_run * 100.0}"
