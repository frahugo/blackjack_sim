require File.dirname(__FILE__) + "/" + 'card.rb'


class BlackjackHand

  attr_accessor :cards

  def initialize initCard1, initCard2
    @cards = Array.new
    @cards << initCard1 << initCard2
  end

  def << card
    @cards << card
    @aces = @non_aces = nil
  end

  def is_pair?
    if @cards.count == 2 && @cards[0].value == @cards[1].value
      return true
    else
      return false
    end
  end

  def blackjack?
    @cards.count == 2 && hand_value == 21
  end

  def is_soft_17?
    soft? && hand_value == 17
  end

  def soft?
    aces && aces.any?
  end

  def hard?
    !soft?
  end

  def hand_value
    sum = @cards.inject(0) { |sum, card| sum + card.face_value }
    sum += 10 if soft? && sum <= 11
    sum
  end

	def get_strategy_key
		non_ace_sum = get_non_ace_sum

    if soft?
      value = hand_value - 11
      key = "A#{value}"
    else
		  if is_pair?
        key = @cards.map(&:face_value).join
  	  else
        key = hand_value.to_s
      end
		end

    key.to_sym
	end

  def get_strategy dealer_show_card, strategy_table
    strat_key = get_strategy_key

    strat_set = strategy_table[strat_key]
    if (strat_set.nil?)
      return :hit
    end

    dealer_key = nil
    if (dealer_show_card.is_ace?)
      dealer_key = :ace
    else
      dealer_key = dealer_show_card.face_value.to_s.to_sym
    end
    suggested_play = strat_set[dealer_key]
    if @cards.count > 2 && (suggested_play == :double || suggested_play == :surrender)
      suggested_play = :hit
    end
    return suggested_play
  end

  def to_s
    rtrn = ""
    @cards.each do |currCard|
      rtrn = rtrn + currCard.to_s + ","
    end
    return rtrn.chomp(",")
  end

  private

	def get_non_ace_sum
		non_aces = @cards.reject { |card| card.value == :ace }
    non_aces.inject(0) { |sum, card|
      if (card.value.kind_of? Fixnum)
		    sum+card.value
		  else
		    sum + 10
		  end
		}
  end

	def aces
    @aces ||= @cards.reject { |card| card.value != :ace }
	end

	def non_aces
	  @non_aces ||= @cards.reject { |card| card.value == :ace }
	end

end

