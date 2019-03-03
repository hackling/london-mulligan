require 'thread/pool'
require 'irb'
require 'colorize'
# srand 123456
def new_deck
  (['Bazaar'] * 4) + (['Powder'] * 4) + (['ZCard'] * 52)
end

MAX_GAMES = 100_000
# MAX_GAMES = 10

games_run = 0
success = 0
threads = []
double_powder = 0
pool = Thread.pool(10)

begin
  # puts "--- NEW GAME ---"
  pool.process do
    exile = []
    mulligans = 0
    deck = new_deck

    begin
      # puts "Cards in Deck: #{deck.count}"
      hand = deck.shuffle!.slice!(0..6)
      # puts "Drawing #{hand.count} Cards"
      mulligan_number = mulligans
      # puts "Mulligan Number: #{mulligan_number}"

      case
      when hand.include?('Bazaar')
        # puts "Found Bazaar Mulligan: #{mulligan_number}".green
        success += 1
        break
      when hand.include?('Powder')
        # puts "Found Powder Mulligan: #{mulligan_number}".yellow
        put_back = (mulligans)
        hand.sort! # Fix this later to put back one powder
        counts = hand.group_by(&:itself).transform_values(&:count)
        if counts["Powder"] > 1
          # puts "Double Powder".red
          double_powder +=1
        end

        #put back cards
        cards_to_put_back = put_back.times.map {hand.pop}
        deck = deck + cards_to_put_back
        # exile smaller hand
        exile << hand

        index = 1
        found_it = begin
        # puts "Cards in Deck: #{deck.count}".yellow
        hand = deck.shuffle!.slice!(0..(7-put_back-1))
        # puts "Resolving Powder: #{index}, Drawing: #{hand.count}".yellow
        case
        when hand.include?('Bazaar')
          # puts "Found Bazaar in Powder: #{index}, Mulligan: #{mulligan_number}".green
          found_it = true
          break
        when hand.include?('Powder')
          counts = hand.group_by(&:itself).transform_values(&:count)
          if counts["Powder"] > 1
            # puts "Double Powder".red
          double_powder +=1
          end
          # puts "Found Powder in Powder: #{index}, Mulligan: #{mulligan_number}".yellow
          exile << hand
        else
          # puts "Found Nothing in Powder: #{index}, Mulligan: #{mulligan_number}".red
          deck = deck + hand
          found_it = false
          break
        end
        index += 1
        end until 0 == 1
        if found_it
          success += 1
          break
        else
          mulligans += 1
        end
      else
        # puts "Found Nothing Mulligan: #{mulligan_number}".red
        deck = deck + hand
        mulligans += 1
      end
    end while mulligans < 7
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
puts "Double powder came up: #{double_powder}"
