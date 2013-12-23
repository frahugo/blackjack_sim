require File.dirname(__FILE__) + "/" + 'deck.rb'

class Shoe

  attr_accessor :shoe, :dealt_cards, :used_cards


  #initialize pass in number of decks defaults to 1
  def initialize num_decks = 1
    @shoe = []
    @used_cards = []
    @dealt_cards = []
    num_decks.times do
      @shoe.concat(Deck.new.deck)
    end
    shuffle!
  end

  def at_end?
    @shoe.size < @marker
  end

  def deal_card
    next_card = @shoe.pop
    @dealt_cards << next_card

    return next_card
  end

  def burn_cards
    @used_cards << @dealt_cards
    @used_cards.flatten!
    @dealt_cards = []
    shuffle! if at_end?
  end

  def shuffle!
    @shoe = @used_cards + @shoe
    @used_cards = []
    @shoe.shuffle!
    @marker = @shoe.size / 5
  end

end
